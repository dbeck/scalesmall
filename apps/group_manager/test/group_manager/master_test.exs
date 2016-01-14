defmodule GroupManager.MasterTest do
  use ExUnit.Case

  alias GroupManager.Master
  alias GroupManager.Chatter.NetID

  test "only one master can be started with a name" do
    assert {:ok, pid} = Master.start_link([name: :test_group_master])
    assert {:error, {:already_started, ^pid}} = Master.start_link([name: :test_group_master])
  end

  test "group can be started and stopped with a non-default master" do
    assert {:ok, master_pid} = Master.start_link([name: :test_group_master])
    assert {:ok, worker_pid} = Master.start_group(master_pid, NetID.new({1,2,3,4},5), "MasterTest1")
    assert is_pid(worker_pid) == true
    assert :ok = Master.leave_group(master_pid, "MasterTest1")
  end
end
