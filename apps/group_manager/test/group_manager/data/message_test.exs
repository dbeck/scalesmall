defmodule GroupManager.Data.MessageTest do

  use ExUnit.Case
  alias GroupManager.Data.Message
  alias GroupManager.Data.LocalClock
  alias GroupManager.Data.WorldClock
  alias GroupManager.Data.TimedSet
  alias GroupManager.Data.TimedItem
  alias GroupManager.Data.Item
  alias GroupManager.Chatter.NetID

  defp dummy_me do
    NetID.new({1,2,3,4},1)
  end

  # TODO
  # doctest GroupManager.Data.Message

  test "basic test for new" do
    assert Message.valid?(Message.new("hello"))
  end

  test "basic test for invalid input" do
    assert Message.valid?(nil) == false
    assert Message.valid?([]) == false
    assert Message.valid?({}) == false
    assert Message.valid?(:ok) == false
    assert Message.valid?({:ok}) == false
    assert Message.valid?({:message}) == false
    assert Message.valid?({:message, nil}) == false
    assert Message.valid?({:message, nil, nil}) == false
    assert Message.valid?({:message, nil, nil, nil}) == false
  end

  test "check if a newly created object is empty" do
    m = Message.new("hello")
    assert Message.empty?(m)
  end

  test "checking for emptiness on an invalid object leads to exception" do
    assert_raise FunctionClauseError, fn -> Message.empty?(:ok) end
    assert_raise FunctionClauseError, fn -> Message.empty?([]) end
    assert_raise FunctionClauseError, fn -> Message.empty?({}) end
    assert_raise FunctionClauseError, fn -> Message.empty?(nil) end
  end

  test "time() returns an empty and valid WorldClock for new objects" do
    t = Message.new("hello") |> Message.time
    assert WorldClock.valid?(t)
    assert WorldClock.empty?(t)
  end

  test "time() raises on invalid objects" do
    assert_raise FunctionClauseError, fn -> Message.time(:ok) end
    assert_raise FunctionClauseError, fn -> Message.time([]) end
    assert_raise FunctionClauseError, fn -> Message.time({}) end
    assert_raise FunctionClauseError, fn -> Message.time(nil) end
  end

  test "items() returns an empty and valid TimedSet for new objects" do
    t = Message.new("hello") |> Message.items
    assert TimedSet.valid?(t)
    assert TimedSet.empty?(t)
  end

  test "items() raises on invalid objects" do
    assert_raise FunctionClauseError, fn -> Message.items(:ok) end
    assert_raise FunctionClauseError, fn -> Message.items([]) end
    assert_raise FunctionClauseError, fn -> Message.items({}) end
    assert_raise FunctionClauseError, fn -> Message.items(nil) end
  end

  test "can add() a valid TimedItem" do
    local = LocalClock.new(dummy_me) |> LocalClock.next
    timed_item = Item.new(dummy_me) |> TimedItem.construct(local)
    m = Message.new("hello") |> Message.add(timed_item)
    assert "hello" == Message.group_name(m)
    assert Message.valid?(m) == true
    assert Message.empty?(m) == false
    assert [timed_item] == Message.items(m) |> TimedSet.items
    assert [local] == Message.time(m) |> WorldClock.time
  end

  test "add() raises for invalid item or invalid message" do
    m = Message.new("hello")
    assert_raise FunctionClauseError, fn -> Message.add(m, :ok) end
    assert_raise FunctionClauseError, fn -> Message.add(m, []) end
    assert_raise FunctionClauseError, fn -> Message.add(m, {}) end
    assert_raise FunctionClauseError, fn -> Message.add(m, nil) end

    local = LocalClock.new(dummy_me) |> LocalClock.next
    timed_item = Item.new(dummy_me) |> TimedItem.construct(local)

    assert_raise FunctionClauseError, fn -> Message.add(:ok, timed_item) end
    assert_raise FunctionClauseError, fn -> Message.add([], timed_item) end
    assert_raise FunctionClauseError, fn -> Message.add({}, timed_item) end
    assert_raise FunctionClauseError, fn -> Message.add(nil, timed_item) end
  end

  # group_name
end
