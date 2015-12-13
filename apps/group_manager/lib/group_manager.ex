defmodule GroupManager do
  use Application
  
  def start(_type, args) do
    GroupManager.Supervisor.start_link(args)
  end
  
  def join(remote_name, group_name) do
    master_pid = Master.locate()
    GroupManager.Master.start_group(master_pid, remote_name, group_name) 
  end
  
  def leave(group_name) do
    master_pid = Master.locate()
    GroupManager.Master.leave_group(master_pid, group_name)
  end
  
  # get topology
  
  # my entries -> Message / filter
  # add item
  # remove item

end
