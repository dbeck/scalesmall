defmodule GroupManager do
  @moduledoc """
  """
  use Application

  def start(_type, _args) do
    {:ok, master_pid} = GroupManager.Master.start_link([])
  end
  
  def join(peer, group_name) when is_pid(peer) do
    master_pid = GroupManager.Master.locate()
    {:ok, worker_pid} = GroupManager.Master.start_group(master_pid, peer, group_name) 
  end
end