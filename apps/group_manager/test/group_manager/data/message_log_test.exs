defmodule GroupManager.Data.MessageLogTest do
  use ExUnit.Case
  alias GroupManager.Data.MessageLog
  alias GroupManager.Data.Message
  alias GroupManager.Data.TimedItem
  alias GroupManager.Data.LocalClock
  alias GroupManager.Data.Item

  # TODO
  # doctest GroupManager.Data.MessageLog
  
  test "basic test for new" do
    assert MessageLog.valid?(MessageLog.new())
  end
  
  test "basic test for invalid input" do
    assert MessageLog.valid?(nil) == false
    assert MessageLog.valid?([]) == false
    assert MessageLog.valid?({}) == false
    assert MessageLog.valid?(:ok) == false
    assert MessageLog.valid?({:ok}) == false
    assert MessageLog.valid?({:message_log}) == false
    assert MessageLog.valid?({:message_log, nil}) == false
    assert MessageLog.valid?({:message_log, nil, nil}) == false
    assert MessageLog.valid?({:message_log, nil, nil, nil}) == false
  end
  
  test "entries() returns empty list when no entries yet" do
    log = MessageLog.new()
    assert [] == MessageLog.entries(log)
  end
  
  test "entries() raises on invalid parameters" do
    assert_raise FunctionClauseError, fn ->  MessageLog.entries(nil) end
    assert_raise FunctionClauseError, fn ->  MessageLog.entries({}) end
    assert_raise FunctionClauseError, fn ->  MessageLog.entries({:message_log}) end
    assert_raise FunctionClauseError, fn ->  MessageLog.entries({:message_log, nil}) end
  end
  
  test "size() returns zero on a newly created log" do
    log = MessageLog.new()
    assert 0 == MessageLog.size(log)
  end
  
  test "size() raises on invalid input" do
    assert_raise FunctionClauseError, fn ->  MessageLog.size(nil) end
    assert_raise FunctionClauseError, fn ->  MessageLog.size({}) end
    assert_raise FunctionClauseError, fn ->  MessageLog.size({:message_log}) end
    assert_raise FunctionClauseError, fn ->  MessageLog.size({:message_log, nil}) end
  end

  test "cannot add() invalid or empty message" do
    m = Message.new()
    log = MessageLog.new()
    assert_raise FunctionClauseError, fn ->  MessageLog.add(log, m) end
    assert_raise FunctionClauseError, fn ->  MessageLog.add(log, nil) end
    assert_raise FunctionClauseError, fn ->  MessageLog.add(log, {}) end
    assert_raise FunctionClauseError, fn ->  MessageLog.add(log, {:message_log}) end
    assert_raise FunctionClauseError, fn ->  MessageLog.add(log, {:message_log, nil}) end
  end
  
  test "can add non-empty message()" do
    local = LocalClock.new(:me) |> LocalClock.next
    timed_item = Item.new(:me) |> TimedItem.construct(local)
    m = Message.new() |> Message.add(timed_item)
    log = MessageLog.new() |> MessageLog.add(m)
    assert 1 == MessageLog.size(log)
    assert [m] == MessageLog.entries(log)
    timed_item = Item.new(:me) |> TimedItem.construct_next(local)
    m2 = Message.new() |> Message.add(timed_item)
    log = MessageLog.add(log, m2)
    assert 2 == MessageLog.size(log)
    assert [m2, m] == MessageLog.entries(log)
  end
end