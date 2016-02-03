defmodule GroupManager.Data.MessageTest do

  use ExUnit.Case
  require GroupManager.Data.Message
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

  defp dummy_other do
    NetID.new({2,3,4,5},2)
  end

  defp dummy_third do
    NetID.new({3,4,5,6},3)
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

  test "add() updates both the world clock and the timed set" do
    timed_item1 = Item.new(dummy_me)    |> TimedItem.construct(LocalClock.new(dummy_me))
    timed_item2 = Item.new(dummy_other) |> TimedItem.construct(LocalClock.new(dummy_other))
    timed_item3 = Item.new(dummy_third) |> TimedItem.construct(LocalClock.new(dummy_third))

    m = Message.new("hello") |> Message.add(timed_item1)

    assert 1 == Message.time(m)  |> WorldClock.count(dummy_me)
    assert 1 == Message.items(m) |> TimedSet.count(dummy_me)
    assert 0 == Message.time(m)  |> WorldClock.count(dummy_other)
    assert 0 == Message.items(m) |> TimedSet.count(dummy_other)

    m = m |> Message.add(timed_item2)

    assert 1 == Message.time(m)  |> WorldClock.count(dummy_me)
    assert 1 == Message.items(m) |> TimedSet.count(dummy_me)
    assert 1 == Message.time(m)  |> WorldClock.count(dummy_other)
    assert 1 == Message.items(m) |> TimedSet.count(dummy_other)

    m = m |> Message.add(timed_item3)

    assert 1 == Message.time(m)  |> WorldClock.count(dummy_me)
    assert 1 == Message.items(m) |> TimedSet.count(dummy_me)
    assert 1 == Message.time(m)  |> WorldClock.count(dummy_other)
    assert 1 == Message.items(m) |> TimedSet.count(dummy_other)
    assert 1 == Message.time(m)  |> WorldClock.count(dummy_third)
    assert 1 == Message.items(m) |> TimedSet.count(dummy_third)
  end

  test "merge() updates both the world clock and the timed set" do
    timed_item1 = Item.new(dummy_me)    |> TimedItem.construct(LocalClock.new(dummy_me))
    timed_item2 = Item.new(dummy_other) |> TimedItem.construct(LocalClock.new(dummy_other))
    timed_item3 = Item.new(dummy_third) |> TimedItem.construct(LocalClock.new(dummy_third))

    m1 = Message.new("hello") |> Message.add(timed_item1)
    m2 = Message.new("hello") |> Message.add(timed_item2)
    m3 = Message.new("hello") |> Message.add(timed_item3)

    # merge is idempotent w/ respect to world clock and items
    assert 1 == Message.merge(m1,m1) |> Message.time  |> WorldClock.count(dummy_me)
    assert 1 == Message.merge(m1,m1) |> Message.items |> TimedSet.count(dummy_me)

    # merge keeps both elements
    m12 = Message.merge(m1,m2)
    assert 1 == m12 |> Message.time  |> WorldClock.count(dummy_me)
    assert 1 == m12 |> Message.items |> TimedSet.count(dummy_me)
    assert 1 == m12 |> Message.time  |> WorldClock.count(dummy_other)
    assert 1 == m12 |> Message.items |> TimedSet.count(dummy_other)

    # merge keeps all 3 elements
    m123 = Message.merge(m12, m3)
    assert 1 == m123 |> Message.time  |> WorldClock.count(dummy_me)
    assert 1 == m123 |> Message.items |> TimedSet.count(dummy_me)
    assert 1 == m123 |> Message.time  |> WorldClock.count(dummy_other)
    assert 1 == m123 |> Message.items |> TimedSet.count(dummy_other)
    assert 1 == m123 |> Message.time  |> WorldClock.count(dummy_third)
    assert 1 == m123 |> Message.items |> TimedSet.count(dummy_third)

    # merge keeps overlapping elemnts too
    m23 = Message.merge(m2,m3)
    m1223 = Message.merge(m12, m23)
    assert 1 == m1223 |> Message.time  |> WorldClock.count(dummy_me)
    assert 1 == m1223 |> Message.items |> TimedSet.count(dummy_me)
    assert 1 == m1223 |> Message.time  |> WorldClock.count(dummy_other)
    assert 1 == m1223 |> Message.items |> TimedSet.count(dummy_other)
    assert 1 == m1223 |> Message.time  |> WorldClock.count(dummy_third)
    assert 1 == m1223 |> Message.items |> TimedSet.count(dummy_third)
  end

  # group_name
  test "group_name() raises on invalid input" do
    assert_raise FunctionClauseError, fn -> Message.group_name(:ok) end
    assert_raise FunctionClauseError, fn -> Message.group_name([]) end
    assert_raise FunctionClauseError, fn -> Message.group_name({}) end
    assert_raise FunctionClauseError, fn -> Message.group_name(nil) end
  end

  test "group_name() returns the name it was set to" do
    m1 = Message.new("hello")
    assert "hello" == Message.group_name(m1)
  end

  test "merge() is idempotent" do
    timed_item1 = Item.new(dummy_me)    |> TimedItem.construct(LocalClock.new(dummy_me))
    timed_item2 = Item.new(dummy_other) |> TimedItem.construct(LocalClock.new(dummy_other))

    m1 = Message.new("hello") |> Message.add(timed_item1)
    m2 = Message.new("hello") |> Message.add(timed_item2)

    assert m2 == Message.merge(m2,m2)
    assert m2 == Message.merge(m2,m2) |> Message.merge(m2)

    m12 = Message.merge(m1,m2)
    assert m12 == Message.merge(m12,m1)
    assert m12 == Message.merge(m12,m2)
    assert m12 == Message.merge(m12,m1) |> Message.merge(m1)
    assert m12 == Message.merge(m12,m2) |> Message.merge(m2)
  end

  test "merge() raises for invalid input" do
    m = Message.new("hello")
    assert_raise FunctionClauseError, fn -> Message.merge(m, :ok) end
    assert_raise FunctionClauseError, fn -> Message.merge(m, []) end
    assert_raise FunctionClauseError, fn -> Message.merge(m, {}) end
    assert_raise FunctionClauseError, fn -> Message.merge(m, nil) end

    assert_raise FunctionClauseError, fn -> Message.merge(:ok, m) end
    assert_raise FunctionClauseError, fn -> Message.merge([], m) end
    assert_raise FunctionClauseError, fn -> Message.merge({}, m) end
    assert_raise FunctionClauseError, fn -> Message.merge(nil, m) end
  end

  # merge keeps the latest elements
  # merge 4 elements
  # members
  # topology
end
