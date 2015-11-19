defmodule GroupManager.MasterTest do
  use ExUnit.Case
  
  alias GroupManager.Master

  test "only one master can be started with a name" do
    assert {:ok, pid} = Master.start_link([name: :test_group_master])
    assert {:error, {:already_started, ^pid}} = Master.start_link([name: :test_group_master])
  end
  
  test "group can be started and stopped with a non-default master" do
    assert {:ok, master_pid} = Master.start_link([name: :test_group_master])
    assert {:ok, worker_pid} = Master.start_group(master_pid, "peer", "MasterTest1")
    assert is_pid(worker_pid) == true
    assert :ok = Master.leave_group(master_pid, "MasterTest1")
  end

  test "two group instances can be started and stopped with a non-default master with different prefix" do
    assert {:ok, master_pid} = Master.start_link([name: :test_group_master])
    assert {:ok, worker_pid1} = Master.start_group(master_pid, "peer", "MasterTest1", "1")
    assert {:ok, worker_pid2} = Master.start_group(master_pid, "peer", "MasterTest1", "2")
    assert worker_pid1 != worker_pid2
    assert :ok = Master.leave_group(master_pid, "MasterTest1", "1")
    assert :ok = Master.leave_group(master_pid, "MasterTest1", "2")
  end
end