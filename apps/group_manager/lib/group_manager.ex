defmodule GroupManager do
  @moduledoc """
  TODO
  """
  use Application

  @doc """
  Starts GroupManager.Master supervisor
  """
  def start(_type, _args) do
    GroupManager.Master.start_link([])
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
  def join(_remote_name, group_name) do
    master_pid = GroupManager.Master.locate()
    GroupManager.Master.start_group(master_pid, _remote_name, group_name) 
  end
  
  @doc """
  The `leave/1` function allows the node to politely leave `group_name`, rather than just disapearing. 
  
  It returns:
  
  - `{:error, :no_such_grop}` if the group has not started yet
  - otherwise what GroupManager.Chatter.stop() returns
  
  """
  def leave(group_name) do
    GroupManager.Master.leave_group(group_name)
  end
end