defmodule GroupManager do
  use Application
  require GroupManager.Chatter.NetID
  alias GroupManager.Chatter.NetID

  def start(_type, args)
  do
    GroupManager.Supervisor.start_link(args)
  end

  def join(peer, group_name)
  when NetID.is_valid(peer) and
       is_binary(group_name) and
       byte_size(group_name) > 0
  do
    master_pid = GroupManager.Master.locate!()
    GroupManager.Master.start_group(master_pid, peer, group_name)
  end

  def leave(group_name)
  when is_binary(group_name) and
       byte_size(group_name) > 0
  do
    master_pid = GroupManager.Master.locate!()
    GroupManager.Master.leave_group(master_pid, group_name)
  end



  # get topology
  # my entries -> Message / filter
  # add item
  # remove item

end
