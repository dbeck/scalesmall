require Logger

defmodule GroupManager.Master do
  @moduledoc """
  Starts, stops and manages GroupManager.Worker instances. Each Worker represents a group.
  """
  
  use Supervisor

  def start_link(opts \\ []) do
    case opts do
      [name: name] ->
        Supervisor.start_link(__MODULE__, [], opts)
      _ ->
        Supervisor.start_link(__MODULE__, [], [name: __MODULE__] ++ opts)
    end
  end
  
  def init([]) do
    children = [ supervisor(GroupManager.Worker, [], restart: :temporary) ]
    supervise(children, strategy: :simple_one_for_one)
  end

  def start_group(master_pid, peer, group_name, prefix \\ nil) when is_pid(master_pid) do
    # create the atom to register the
    case GroupManager.Worker.locate(group_name, prefix) do
      worker_pid when is_pid(worker_pid) ->
        Logger.warn "#{group_name} already started"
        {:error, {:already_started, worker_pid}}
      nil ->
        worker_id = GroupManager.Worker.id_atom(group_name, prefix)
        {:ok, child} = Supervisor.start_child(master_pid,
                                              [
                                                [group_name: group_name, prefix: prefix],
                                                [name: worker_id]
                                              ])        
    end
  end

  def locate do
    case Process.whereis(:GroupManager.Master) do
      master_pid when is_pid(master_pid) ->
        master_pid
    end
  end
end