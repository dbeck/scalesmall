defmodule GroupManagerTest do

  use ExUnit.Case
  alias GroupManager.Chatter.NetID

  defp dummy_peer do
    NetID.new({2,3,4,5},2)
  end

  test "check if we can join and leave a new group" do
    result = GroupManager.join([dummy_peer], "hello1")
    assert {:ok, _} = result
    assert :ok = GroupManager.leave("hello1")
  end

  test "ensure we can't leave a nonexistent group" do
    result = GroupManager.leave("nonexistent")
    expected = {:error, {:no_engine, "nonexistent"}}
    #Logger.warn "result=#{result |> inspect} expected=#{expected |> inspect}"
    assert result == expected
  end

  test "ensure we can't leave a group twice" do
    assert {:ok, _} = GroupManager.join([dummy_peer], "twice")
    assert :ok = GroupManager.leave("twice")
    assert {:error, {:no_engine, "twice"}} == GroupManager.leave("twice")
  end

  test "ensure we can't join a group twice" do
    assert {:ok, _} = GroupManager.join([dummy_peer], "join_twice")
    result = GroupManager.join([dummy_peer], "join_twice")
    assert {:error, {:already_started, pid}} = result
    assert is_pid(pid)
    assert :ok == GroupManager.leave("join_twice")
  end
end
