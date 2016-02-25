defmodule GroupManager.TopologyDBTest do

  use ExUnit.Case
  require GroupManager
  require GroupManager.Data.Item
  require GroupManager.Data.Message
  require GroupManager.Data.WorldClock
  require GroupManager.Data.LocalClock
  require GroupManager.Data.TimedSet
  require GroupManager.Data.TimedItem
  require Common.NetID
  alias GroupManager.TopologyDB
  alias GroupManager.Data.Message
  alias GroupManager.Data.Item
  alias GroupManager.Data.TimedItem
  alias Common.NetID

  defp dummy_netid do
    NetID.new({1,2,3,4},1)
  end

  test "locate TopologyDB" do
    pid = TopologyDB.locate
    assert is_pid(pid)
  end

  # add
  test "cannot add() invalid" do
    pid = TopologyDB.locate
    assert_raise FunctionClauseError, fn -> TopologyDB.add(pid, nil) end
    assert_raise FunctionClauseError, fn -> TopologyDB.add(pid, <<>>) end
    assert_raise FunctionClauseError, fn -> TopologyDB.add(pid, []) end
    assert_raise FunctionClauseError, fn -> TopologyDB.add(pid, {:message}) end
  end

  test "can add() and get()/get_() valid Messages" do
    pid = TopologyDB.locate
    group = "topo-db-test-group"
    msg = Message.new(group)
    assert :ok == TopologyDB.add(pid, msg)
    # {:message, {:world_clock, []}, {:timed_set, []}, "topo-db-test-group"}
    assert {:ok, msg} == TopologyDB.get(pid, group)
    assert {:ok, msg} == TopologyDB.get_(group)
  end

  # add_item
  test "cannot add_item() invalid" do
    pid = TopologyDB.locate
    itm = Item.new(dummy_netid)
    assert_raise FunctionClauseError, fn -> TopologyDB.add_item(pid, nil, itm) end
    assert_raise FunctionClauseError, fn -> TopologyDB.add_item(pid, <<>>, itm) end
    assert_raise FunctionClauseError, fn -> TopologyDB.add_item(pid, [], itm) end
    assert_raise FunctionClauseError, fn -> TopologyDB.add_item(pid, {:message}, itm) end
  end

  test "can add() and add_item() and get()/get_() valid Messages" do
    pid = TopologyDB.locate
    group = "topo-db-test-group-item"
    itm1 = Item.new(dummy_netid)
    assert Item.is_valid(itm1)
    msg = Message.new(group)
    assert :ok == TopologyDB.add(pid, msg)
    assert_raise MatchError, fn-> TopologyDB.add_item(pid, group, itm1) end
    # {:message, {:world_clock, []}, {:timed_set, []}, "topo-db-test-group"}
    assert {:ok, msg} == TopologyDB.get(pid, group)
    assert {:ok, id} = TopologyDB.get_id(pid)
    itm2 = Item.new(id)
    assert {:ok, timed_item} = TopologyDB.add_item(pid, group, itm2)
    assert TimedItem.is_valid(timed_item)
    {:ok, msg2} = TopologyDB.get(pid, group)
    assert Message.is_valid(msg2)
  end

  test "get() raises on invalid parameters" do
    pid = TopologyDB.locate
    assert_raise FunctionClauseError, fn -> TopologyDB.get(pid, nil) end
    assert_raise FunctionClauseError, fn -> TopologyDB.get(pid, <<>>) end
    assert_raise FunctionClauseError, fn -> TopologyDB.get(pid, []) end
    assert_raise FunctionClauseError, fn -> TopologyDB.get(pid, {:message}) end
  end

  # get
  # get_
  # groups_
  # groups_(id,type)
end
