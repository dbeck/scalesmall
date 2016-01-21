defmodule GroupManagerTest do

  use ExUnit.Case
  alias GroupManager.Chatter.NetID

  defp dummy_peer do
    NetID.new({2,3,4,5},2)
  end

  test "check if we can join and leave a new group" do
    :ok
  end

  test "ensure we can't leave a nonexistent group" do
    :ok
  end

  test "ensure we can't leave a group twice" do
    :ok
  end

  test "ensure we can't join a group twice" do
    :ok
  end
end
