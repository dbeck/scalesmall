defmodule GroupManagerTest do

  use ExUnit.Case
  alias Common.NetID

  test "check if we can join and leave a new group" do
    my_id = GroupManager.my_id
    assert [] == GroupManager.members("test-me-group")
    assert :ok == GroupManager.join("test-me-group")
    assert [my_id] == GroupManager.members("test-me-group")
    assert ["test-me-group"] == Enum.filter(GroupManager.my_groups(), fn(x) ->
      x == "test-me-group"
    end)
    assert :ok == GroupManager.leave("test-me-group")
    assert [] == GroupManager.members("test-me-group")
    assert [] == Enum.filter(GroupManager.my_groups(), fn(x) ->
      x == "test-me-group"
    end)
  end

  test "my_groups() returns my groups" do
    assert [] == Enum.filter(GroupManager.my_groups(), fn(x) ->
      x == "test-my-group-1"
    end)
    assert [] == GroupManager.members("test-my-group-1")
    assert :ok == GroupManager.join("test-my-group-1")
    assert ["test-my-group-1"] == Enum.filter(GroupManager.my_groups(), fn(x) ->
      x == "test-my-group-1"
    end)
    assert ["test-my-group-1"] == Enum.filter(GroupManager.groups(), fn(x) ->
      x == "test-my-group-1"
    end)
    assert :ok == GroupManager.leave("test-my-group-1")
    assert [] == Enum.filter(GroupManager.my_groups(), fn(x) ->
      x == "test-my-group-1"
    end)
  end
end
