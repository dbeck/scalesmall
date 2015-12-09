require Logger

defmodule GroupManager.Master do
  use Supervisor
  alias GroupManager.Engine
  alias GroupManager.Worker

  def start_link(opts \\ []) do
    case opts do
      [name: name] ->
        Supervisor.start_link(__MODULE__, :no_args, opts)
      _ ->
        Supervisor.start_link(__MODULE__, :no_args, [name: __MODULE__] ++ opts)
    end
  end
  
  def init(:no_args) do
    children = [ supervisor(Worker, [], restart: :temporary) ]
    supervise(children, strategy: :simple_one_for_one)
  end

  def start_group(master_pid, _peer, group_name)
  when is_pid(master_pid)
  do
    # create the atom to register the
    case Worker.locate(group_name) do
      worker_pid when is_pid(worker_pid) ->
        Logger.warn "group: '#{group_name}' already started"
        {:error, {:already_started, worker_pid}}
      nil ->
        worker_id = Worker.id_atom(group_name)
        Supervisor.start_child(master_pid,
                              [
                                [group_name: group_name],
                                [name: worker_id]
                              ])
    end
  end
  
  def leave_group(master_pid, group_name)
  when is_pid(master_pid)
  do
    case Engine.locate(group_name) do      
      engine_pid when is_pid(engine_pid) ->
        Engine.stop(engine_pid)
        case Worker.locate(group_name) do
          worker_pid when is_pid(worker_pid) ->
            Supervisor.terminate_child(master_pid, worker_pid)
          nil ->
            {:error, :no_worker}
        end
      nil ->
        Logger.warn "Not found Engine for local group: #{group_name}"
        {:error, :no_chatter}
    end
  end
  
  def locate do
    case Process.whereis(__MODULE__) do
      master_pid when is_pid(master_pid) ->
        master_pid
    end
  end
end