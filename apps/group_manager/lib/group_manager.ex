defmodule GroupManager do
  use Application
  
  alias GroupManager.Sup
  alias GroupManager.Master

  def start(_type, _args) do
    Sup.start_link([])
  end
  
  def join(remote_name, group_name) do
    master_pid = Master.locate()
    Master.start_group(master_pid, remote_name, group_name) 
  end
  
  def leave(group_name) do
    master_pid = Master.locate()
    Master.leave_group(master_pid, group_name)
  end
  
  # get topology
  
  # my entries -> Message / filter
  # add item
  # remove item

end
