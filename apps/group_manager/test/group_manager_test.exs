defmodule GroupManagerTest do
  use ExUnit.Case

  test "check if we can join and leave a new group" do
    assert {:ok, _} = GroupManager.join("", "hello1")
    assert :ok = GroupManager.leave("hello1")
  end
  
  test "ensure we can't leave a nonexistent group" do
    assert {:error, _} = GroupManager.leave("nonexistent")
  end
  
  test "ensure we can't leave a group twice" do
    assert {:ok, _} = GroupManager.join("", "twice")
    assert :ok = GroupManager.leave("twice")
    assert {:error, _} = GroupManager.leave("twice")
  end
  
  test "ensure we can't join a group twice" do
    assert {:ok, _} = GroupManager.join("", "join_twice")
    assert {:error, _} = GroupManager.join("", "join_twice")
    assert :ok = GroupManager.leave("join_twice")
  end
end