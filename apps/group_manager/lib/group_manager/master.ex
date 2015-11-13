require Logger

defmodule GroupManager.Master do
  @moduledoc """
  Starts, stops and manages GroupManager.Worker instances. Each Worker represents a group.
  TODO
  """
  
  use Supervisor

  @doc """
  TODO
  """
  def start_link(opts \\ []) do
    case opts do
      [name: name] ->
        Supervisor.start_link(__MODULE__, [], opts)
      _ ->
        Supervisor.start_link(__MODULE__, [], [name: __MODULE__] ++ opts)
    end
  end
  
  @doc """
  TODO
  """
  def init([]) do
    children = [ supervisor(GroupManager.Worker, [], restart: :temporary) ]
    supervise(children, strategy: :simple_one_for_one)
  end

  @doc """
  TODO
  """
  def start_group(master_pid, _peer, group_name, prefix \\ nil) when is_pid(master_pid) do
    # create the atom to register the
    case GroupManager.Worker.locate(group_name, prefix) do
      worker_pid when is_pid(worker_pid) ->
        Logger.warn "group: '#{group_name}' already started"
        {:error, {:already_started, worker_pid}}
      nil ->
        worker_id = GroupManager.Worker.id_atom(group_name, prefix)
        Supervisor.start_child(master_pid,
                              [
                                [group_name: group_name, prefix: prefix],
                                [name: worker_id]
                              ])
    end
  end
  
  @doc """
  TODO
  """
  def leave_group(master_pid, group_name, prefix \\ nil) when is_pid(master_pid) do
    case GroupManager.Chatter.locate(group_name, prefix) do      
      chatter_pid when is_pid(chatter_pid) ->
        GroupManager.Chatter.stop(chatter_pid)
        case GroupManager.Worker.locate(group_name, prefix) do
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

  @doc """
  TODO
  """
  def locate do
    case Process.whereis(:GroupManager.Master) do
      master_pid when is_pid(master_pid) ->
        master_pid
    end
  end
end