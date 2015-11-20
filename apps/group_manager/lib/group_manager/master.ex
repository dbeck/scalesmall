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
    children = [ supervisor(GroupManager.Worker, [], restart: :temporary) ]
    supervise(children, strategy: :simple_one_for_one)
  end

  @doc """
  TODO
  """
  def start_group(master_pid, _peer, group_name, prefix \\ nil)
  when is_pid(master_pid)
  do
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
  def leave_group(master_pid, group_name, prefix \\ nil)
  when is_pid(master_pid)
  do
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
  def register_node_at(master_pid, group_name, point, prefix \\ nil)
  when is_pid(master_pid) and is_number(point) and point >= 0.0 and point <= 1.0
  do
    raise "implement me"
  end
  
  @doc """
  TODO
  """
  def release_node_from(master_pid, group_name, point, prefix \\ nil)
  when is_pid(master_pid) and is_number(point) and point >= 0.0 and point <= 1.0
  do
    raise "implement me"
  end
  
  @doc """
  TODO
  """
  def promote_node_at(master_pid, group_name, point, prefix \\ nil)
  when is_pid(master_pid) and is_number(point) and point >= 0.0 and point <= 1.0
  do
    raise "implement me"
  end
  
  @doc """
  TODO
  """
  def demote_node_at(master_pid, group_name, point, prefix \\ nil)
  when is_pid(master_pid) and is_number(point) and point >= 0.0 and point <= 1.0
  do
    raise "implement me"
  end
  
  @doc """
  TODO
  """
  def get_peers_at(master_pid, group_name, point, prefix \\ nil)
  when is_pid(master_pid) and is_number(point) and point >= 0.0 and point <= 1.0
  do
    raise "implement me"
  end
  
  @doc """
  TODO
  """
  def get_all_peers(master_pid, group_name, options, prefix \\ nil)
  when is_pid(master_pid) and is_tuple(options)
  do
    raise "implement me"
  end
  
  @doc """
  TODO
  """
  def get_topology(master_pid, group_name, options, prefix \\ nil)
  when is_pid(master_pid) and is_tuple(options)
  do
    raise "implement me"
  end

  @doc """
  TODO
  """
  def locate do
    case Process.whereis(__MODULE__) do
      master_pid when is_pid(master_pid) ->
        master_pid
    end
  end
end