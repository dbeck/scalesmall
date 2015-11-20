defmodule GroupManager do
  @moduledoc """
  TODO
  """
  use Application
  
  alias GroupManager.Master

  @doc """
  Starts GroupManager.Master supervisor
  """
  def start(_type, _args) do
    Master.start_link([])
  end
  
  @doc """
  The `join/2` function allows the node to join a group of nodes.
  
  For example:
  
      GroupManager.join(remote_name, "group_name")
  
  This starts all local process responssible for communicating with the group called `group_name`.
  
  Our group entry host is `remote_name` which is the name of the 'gateway' machine which is used to gather
  an initial state so we can participate in the group later.
  
  If returns:  processes it returns:
  
  - `{:error, {:already_started, worker_pid}}` if the current node has already started the `group_name`
  - `{:ok, worker_pid}` if the local group related processes started successfuly
  - for other errors, see `Supervisor.start_child/2` documentation
  
  """
  def join(remote_name, group_name) do
    master_pid = Master.locate()
    Master.start_group(master_pid, remote_name, group_name) 
  end
  
  @doc """
  The `leave/1` function allows the node to politely leave `group_name`, rather than just disapearing. 
  
  It returns:
  
  - `{:error, :no_such_grop}` if the group has not started yet
  - otherwise what GroupManager.Chatter.stop() returns
  
  """
  def leave(group_name) do
    master_pid = Master.locate()
    Master.leave_group(master_pid, group_name)
  end
    
  @doc """
  TODO
  """
  def register(group_name, point)
  when is_number(point) and point >= 0.0 and point <= 1.0
  do
    master_pid = Master.locate()
    Master.register_node_at(master_pid, group_name, point)
  end
  
  @doc """
  TODO
  """
  def release(group_name, point)
  when is_number(point) and point >= 0.0 and point <= 1.0
  do
    master_pid = Master.locate()
    Master.release_node_from(master_pid, group_name, point)
  end
  
  @doc """
  TODO
  """
  def promote(group_name, point)
  when is_number(point) and point >= 0.0 and point <= 1.0
  do
    master_pid = Master.locate()
    Master.promote_node_at(master_pid, group_name, point)
  end

  @doc """
  TODO
  """
  def demote(group_name, point)
  when is_number(point) and point >= 0.0 and point <= 1.0
  do
    master_pid = Master.locate()
    Master.demote_node_at(master_pid, group_name, point)
  end
  
  @doc """
  TODO
  """
  def get_peers(group_name, point)
  when is_number(point) and point >= 0.0 and point <= 1.0
  do
    master_pid = Master.locate()
    Master.get_peers_at(master_pid, group_name, point)
  end
  
  @doc """
  TODO
  """
  def get_all_peers(group_name, options \\ {:all} ) # :all, :ready, :gone, :busy
  when is_tuple(options)
  do
    master_pid = Master.locate()
    Master.get_all_peers(master_pid, group_name, options)
  end
  
  @doc """
  TODO
  """
  def get_topology(group_name, options \\ {:all} ) # {:all}, {:self}, {:nodes, [node1, node2, ...]}
  when is_tuple(options)
  do
    master_pid = Master.locate()
    Master.get_topology(master_pid, group_name, options)
  end
end
