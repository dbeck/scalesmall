defmodule GroupManager.Data.TimedSetTest do

  use ExUnit.Case
  alias GroupManager.Data.TimedSet
  alias GroupManager.Data.TimedItem
  alias GroupManager.Chatter.NetID
  alias GroupManager.Data.LocalClock

  test "basic test for new" do
    assert TimedSet.valid?(TimedSet.new())
  end

  test "basic test for invalid input" do
    assert TimedSet.valid?(nil) == false
    assert TimedSet.valid?([]) == false
    assert TimedSet.valid?({}) == false
    assert TimedSet.valid?(:ok) == false
    assert TimedSet.valid?({:ok}) == false
    assert TimedSet.valid?({:timed_set}) == false
    assert TimedSet.valid?({:timed_set, nil}) == false
    assert TimedSet.valid?({:timed_set, nil, nil}) == false
  end

  test "check if a newly created object is empty" do
    cl = TimedSet.new()
    assert TimedSet.empty?(cl)
  end

  test "checking for emptiness on an invalid object leads to exception" do
    assert_raise FunctionClauseError, fn -> TimedSet.empty?(:ok) end
    assert_raise FunctionClauseError, fn -> TimedSet.empty?([]) end
    assert_raise FunctionClauseError, fn -> TimedSet.empty?({}) end
    assert_raise FunctionClauseError, fn -> TimedSet.empty?(nil) end
  end

  defp dummy_me do
    NetID.new({1,2,3,4},1)
  end

  defp dummy_other do
    NetID.new({2,3,4,5},2)
  end

  defp dummy_third do
    NetID.new({3,4,5,6},3)
  end

  test "items() returns what had been added" do
    ti = TimedItem.new(dummy_me)
    ts = TimedSet.new() |> TimedSet.add(ti)
    assert [ti] == TimedSet.items(ts)
  end

  test "items() raises on invalid parameter" do
    assert_raise FunctionClauseError, fn -> TimedSet.items(:ok) end
    assert_raise FunctionClauseError, fn -> TimedSet.items([]) end
    assert_raise FunctionClauseError, fn -> TimedSet.items({}) end
    assert_raise FunctionClauseError, fn -> TimedSet.items(nil) end
  end

  test "add() two items" do
    ts = TimedSet.new() |> TimedSet.add(TimedItem.new(dummy_me)) |> TimedSet.add(TimedItem.new(dummy_other))
    assert length(TimedSet.items(ts)) == 2
  end

  test "add() raises on invalid items" do
    ts = TimedSet.new()
    assert_raise FunctionClauseError, fn -> TimedSet.add(ts, :ok) end
    assert_raise FunctionClauseError, fn -> TimedSet.add(ts, []) end
    assert_raise FunctionClauseError, fn -> TimedSet.add(ts, {}) end
    assert_raise FunctionClauseError, fn -> TimedSet.add(ts, nil) end
  end

  # count
  test "count() returns zero on empty world clock" do
    w = TimedSet.new()
    assert 0 == TimedSet.count(w, dummy_me)
  end

  test "count() raises on invalid parameters" do
    assert_raise FunctionClauseError, fn -> TimedSet.count(:ok, :ok) end
    assert_raise FunctionClauseError, fn -> TimedSet.count([], :ok) end
    assert_raise FunctionClauseError, fn -> TimedSet.count({}, :ok) end
    assert_raise FunctionClauseError, fn -> TimedSet.count(nil, :ok) end

    w = TimedSet.new()
    assert_raise FunctionClauseError, fn -> TimedSet.count(w, :ok) end
    assert_raise FunctionClauseError, fn -> TimedSet.count(w, []) end
    assert_raise FunctionClauseError, fn -> TimedSet.count(w, {}) end
    assert_raise FunctionClauseError, fn -> TimedSet.count(w, nil) end

    id = dummy_me
    assert_raise FunctionClauseError, fn -> TimedSet.count(:ok, id) end
    assert_raise FunctionClauseError, fn -> TimedSet.count([], id) end
    assert_raise FunctionClauseError, fn -> TimedSet.count({}, id) end
    assert_raise FunctionClauseError, fn -> TimedSet.count(nil, id) end
  end

  test "count() retuns 1 for a single existing elem" do
    ti = TimedItem.new(dummy_me)
    w = TimedSet.new() |> TimedSet.add(ti)
    assert 1 == TimedSet.count(w, dummy_me)
    assert 0 == TimedSet.count(w, dummy_other)
    w2 = TimedSet.add(w, TimedItem.new(dummy_other))
    assert 1 == TimedSet.count(w2, dummy_me)
    assert 1 == TimedSet.count(w2, dummy_other)
    assert 0 == TimedSet.count(w2, dummy_third)
    w3 = TimedSet.add(w2, TimedItem.new(dummy_third))
    assert 1 == TimedSet.count(w3, dummy_me)
    assert 1 == TimedSet.count(w3, dummy_other)
    assert 1 == TimedSet.count(w3, dummy_third)
  end

  test "count(local_clock) retuns 1 for a single existing elem" do
    ti = TimedItem.new(dummy_me)
    lc = TimedItem.updated_at(ti)
    w = TimedSet.new() |> TimedSet.add(ti)
    assert 1 == TimedSet.count(w, lc)
    assert 0 == TimedSet.count(w, LocalClock.next(lc))
  end

  test "merge() raises on invalid parameters" do
    assert_raise FunctionClauseError, fn -> TimedSet.merge(:ok, :ok) end
    assert_raise FunctionClauseError, fn -> TimedSet.merge([], :ok) end
    assert_raise FunctionClauseError, fn -> TimedSet.merge({}, :ok) end
    assert_raise FunctionClauseError, fn -> TimedSet.merge(nil, :ok) end

    w = TimedSet.new()
    assert_raise FunctionClauseError, fn -> TimedSet.merge(w, :ok) end
    assert_raise FunctionClauseError, fn -> TimedSet.merge(w, []) end
    assert_raise FunctionClauseError, fn -> TimedSet.merge(w, {}) end
    assert_raise FunctionClauseError, fn -> TimedSet.merge(w, nil) end

    assert_raise FunctionClauseError, fn -> TimedSet.merge(:ok, w) end
    assert_raise FunctionClauseError, fn -> TimedSet.merge([], w) end
    assert_raise FunctionClauseError, fn -> TimedSet.merge({}, w) end
    assert_raise FunctionClauseError, fn -> TimedSet.merge(nil, w) end
  end

  test "merge() is idempotent" do
    ti1 = TimedItem.new(dummy_me)
    ti2 = TimedItem.new(dummy_other)

    w1 = TimedSet.new |> TimedSet.add(ti1)
    w2 = TimedSet.new |> TimedSet.add(ti2)
    w12 = TimedSet.new |> TimedSet.add(ti1) |> TimedSet.add(ti2)

    assert w1 == TimedSet.merge(w1, w1)
    assert w1 == TimedSet.merge(w1, w1) |> TimedSet.merge(w1)
    assert w12 == TimedSet.merge(w1, w2)
    assert w12 == TimedSet.merge(w1, w2) |> TimedSet.merge(w1)
    assert w12 == TimedSet.merge(w1, w2) |> TimedSet.merge(w1) |> TimedSet.merge(w2)
  end

  test "merge() keeps the latest elements" do
    ti1 = TimedItem.new(dummy_me)
    ti2 = TimedItem.new(dummy_other)
    ti1x = TimedItem.item(ti1) |> TimedItem.construct_next(TimedItem.updated_at(ti1))
    ti2x = TimedItem.item(ti2) |> TimedItem.construct_next(TimedItem.updated_at(ti2))

    w1    = TimedSet.new |> TimedSet.add(ti1)
    w2    = TimedSet.new |> TimedSet.add(ti2)
    w12   = TimedSet.new |> TimedSet.add(ti1)  |> TimedSet.add(ti2)
    w1x   = TimedSet.new |> TimedSet.add(ti1x)
    w2x   = TimedSet.new |> TimedSet.add(ti2x)
    w1x2  = TimedSet.new |> TimedSet.add(ti1x) |> TimedSet.add(ti2)
    w12x  = TimedSet.new |> TimedSet.add(ti1)  |> TimedSet.add(ti2x)
    w1x2x = TimedSet.new |> TimedSet.add(ti1x) |> TimedSet.add(ti2x)

    assert w1x   == TimedSet.merge(w1, w1x)
    assert w1x2  == TimedSet.merge(w1, w2) |> TimedSet.merge(w1x)
    assert w12x  == TimedSet.merge(w1, w2x) |> TimedSet.merge(w2)
    assert w12x  == TimedSet.merge(w12, w2x)
    assert w1x2x == TimedSet.merge(w1x, w2x)
    assert w1x2x == TimedSet.merge(w1x2, w2x)
    assert w1x2x == TimedSet.merge(w12x, w1x)
    assert w1x2x == TimedSet.merge(w12, w1x) |> TimedSet.merge(w2x)
  end

  # extract_netids
  # encode_with
  # decode_with
end
