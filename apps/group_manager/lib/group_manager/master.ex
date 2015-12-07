require Logger

defmodule GroupManager.Master do
  @moduledoc """
  Starts, stops and manages GroupManager.Worker instances. Each Worker represents a group.
  
  The master by default is registered locally under the `GroupManager.Master` id.
  If the user decides to give a different name than it needs to be passed to the `start_link/1` function.
  
  Note that the `:group_manager` application starts a default Master on start which is the Supervisor of the
  application too.
  
  The Master process is a container of `GroupManager.Worker` instances. Each Worker represents a group and the
  Master process supervises these groups.
  """
  
  use Supervisor
  alias GroupManager.Engine
  alias GroupManager.Worker

  @doc """
  Starts the Master process:
  
      GroupManager.Master.start_link([])
      
  The caller can start other masters with a name like this:
  
      GroupManager.Master.start_link([name: :master_name])
  """
  def start_link(opts \\ []) do
    case opts do
      [name: name] ->
        Supervisor.start_link(__MODULE__, :no_args, opts)
      _ ->
        Supervisor.start_link(__MODULE__, :no_args, [name: __MODULE__] ++ opts)
    end
  end
  
  @doc false
  def init(:no_args) do
    children = [ supervisor(Worker, [], restart: :temporary) ]
    supervise(children, strategy: :simple_one_for_one)
  end

  def start_group(master_pid, _peer, group_name, prefix \\ nil)
  when is_pid(master_pid)
  do
    # create the atom to register the
    case Worker.locate(group_name, prefix) do
      worker_pid when is_pid(worker_pid) ->
        Logger.warn "group: '#{group_name}' already started"
        {:error, {:already_started, worker_pid}}
      nil ->
        worker_id = Worker.id_atom(group_name, prefix)
        Supervisor.start_child(master_pid,
                              [
                                [group_name: group_name, prefix: prefix],
                                [name: worker_id]
                              ])
    end
  end
  
  def leave_group(master_pid, group_name, prefix \\ nil)
  when is_pid(master_pid)
  do
    case Engine.locate(group_name, prefix) do      
      engine_pid when is_pid(engine_pid) ->
        Engine.stop(engine_pid)
        case Worker.locate(group_name, prefix) do
          worker_pid when is_pid(worker_pid) ->
            Supervisor.terminate_child(master_pid, worker_pid)
          nil ->
            {:error, :no_worker}
        end
      nil ->
        Logger.warn "Not found Chatter for local group: #{group_name}"
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