defmodule GroupManager.Data.WorldClockTest do
  use ExUnit.Case
  alias GroupManager.Data.WorldClock
  alias GroupManager.Data.LocalClock
  alias GroupManager.Chatter.NetID

  # TODO
  # doctest GroupManager.Data.WorldClock

  defp dummy_me do
    NetID.new({1,2,3,4},1)
  end

  defp dummy_other do
    NetID.new({2,3,4,5},2)
  end

  defp dummy_third do
    NetID.new({3,4,5,6},3)
  end

  test "basic test for new" do
    assert WorldClock.valid?(WorldClock.new())
  end

  test "basic test for invalid input" do
    assert WorldClock.valid?(nil) == false
    assert WorldClock.valid?([]) == false
    assert WorldClock.valid?({}) == false
    assert WorldClock.valid?(:ok) == false
    assert WorldClock.valid?({:ok}) == false
    assert WorldClock.valid?({:world_clock}) == false
    assert WorldClock.valid?({:world_clock, nil}) == false
    assert WorldClock.valid?({:world_clock, nil, nil}) == false
  end

  test "check if a newly created world clock is empty" do
    cl = WorldClock.new()
    assert WorldClock.empty?(cl)
  end

  test "checking for emptiness on an invalid object leads to exception" do
    assert_raise FunctionClauseError, fn -> WorldClock.empty?(:ok) end
    assert_raise FunctionClauseError, fn -> WorldClock.empty?([]) end
    assert_raise FunctionClauseError, fn -> WorldClock.empty?({}) end
    assert_raise FunctionClauseError, fn -> WorldClock.empty?(nil) end
  end

  test "add() a local clock to the world clock" do
    w = WorldClock.new()
    l = LocalClock.new(dummy_me)
    new_clock = WorldClock.add(w, l)
    assert 1 == WorldClock.size(new_clock)
    assert l == WorldClock.get(new_clock, dummy_me)
  end

  test "add() raises on invalid inputs" do
    w = WorldClock.new()
    l = LocalClock.new(dummy_me)

    assert_raise FunctionClauseError, fn -> WorldClock.add(w, :ok) end
    assert_raise FunctionClauseError, fn -> WorldClock.add(w, []) end
    assert_raise FunctionClauseError, fn -> WorldClock.add(w, {}) end
    assert_raise FunctionClauseError, fn -> WorldClock.add(w, nil) end

    assert_raise FunctionClauseError, fn -> WorldClock.add(:ok, l) end
    assert_raise FunctionClauseError, fn -> WorldClock.add([], l) end
    assert_raise FunctionClauseError, fn -> WorldClock.add({}, l) end
    assert_raise FunctionClauseError, fn -> WorldClock.add(nil, l) end
  end

  test "add() the same clock twice doesn't change the world clock" do
    w = WorldClock.new()
    l = LocalClock.new(dummy_me)
    new_clock = WorldClock.add(w, l)
    assert 1 == WorldClock.size(new_clock)
    assert l == WorldClock.get(new_clock, dummy_me)
    # second time
    clock2 = WorldClock.add(new_clock, l)
    assert 1 == WorldClock.size(clock2)
    assert l == WorldClock.get(clock2, dummy_me)
    assert clock2 == new_clock
  end

  test "add() updates the clock if newer one arrives, but doesn't change if older arrives" do
    w = WorldClock.new()
    l = LocalClock.new(dummy_me)
    new_clock = WorldClock.add(w, l)
    assert 1 == WorldClock.size(new_clock)
    assert l == WorldClock.get(new_clock, dummy_me)

    # second time
    l2 = LocalClock.next(l)
    clock2 = WorldClock.add(new_clock, l2)
    assert 1 == WorldClock.size(clock2)
    assert l2 == WorldClock.get(clock2, dummy_me)
    assert clock2 != new_clock

    # trying the old one again
    clock3 = WorldClock.add(clock2, l)
    assert 1 == WorldClock.size(clock3)
    assert l2 == WorldClock.get(clock3, dummy_me)
    assert clock2 == clock3
  end

  test "time() raises on invalid input" do
    assert_raise FunctionClauseError, fn -> WorldClock.time(:ok) end
    assert_raise FunctionClauseError, fn -> WorldClock.time([]) end
    assert_raise FunctionClauseError, fn -> WorldClock.time({}) end
    assert_raise FunctionClauseError, fn -> WorldClock.time(nil) end
  end

  test "size() raises on invalid input" do
    assert_raise FunctionClauseError, fn -> WorldClock.size(:ok) end
    assert_raise FunctionClauseError, fn -> WorldClock.size([]) end
    assert_raise FunctionClauseError, fn -> WorldClock.size({}) end
    assert_raise FunctionClauseError, fn -> WorldClock.size(nil) end
  end

  test "get() raises on invalid input" do
    assert_raise FunctionClauseError, fn -> WorldClock.get(:ok, :ok) end
    assert_raise FunctionClauseError, fn -> WorldClock.get([], :ok) end
    assert_raise FunctionClauseError, fn -> WorldClock.get({}, :ok) end
    assert_raise FunctionClauseError, fn -> WorldClock.get(nil, :ok) end
  end

  test "get() returns FunctionClauseError on missing clock" do
    w = WorldClock.new()
    l = LocalClock.new(dummy_me)
    new_clock = WorldClock.add(w, l)
    assert_raise FunctionClauseError, fn -> WorldClock.get(new_clock, :missing) end
    assert nil == WorldClock.get(new_clock, dummy_other)
  end

  # count
  test "count() returns zero on empty world clock" do
    w = WorldClock.new()
    assert 0 == WorldClock.count(w, dummy_me)
  end

  test "count() raises on invalid parameters" do
    assert_raise FunctionClauseError, fn -> WorldClock.count(:ok, :ok) end
    assert_raise FunctionClauseError, fn -> WorldClock.count([], :ok) end
    assert_raise FunctionClauseError, fn -> WorldClock.count({}, :ok) end
    assert_raise FunctionClauseError, fn -> WorldClock.count(nil, :ok) end

    w = WorldClock.new()
    assert_raise FunctionClauseError, fn -> WorldClock.count(w, :ok) end
    assert_raise FunctionClauseError, fn -> WorldClock.count(w, []) end
    assert_raise FunctionClauseError, fn -> WorldClock.count(w, {}) end
    assert_raise FunctionClauseError, fn -> WorldClock.count(w, nil) end

    id = dummy_me
    assert_raise FunctionClauseError, fn -> WorldClock.count(:ok, id) end
    assert_raise FunctionClauseError, fn -> WorldClock.count([], id) end
    assert_raise FunctionClauseError, fn -> WorldClock.count({}, id) end
    assert_raise FunctionClauseError, fn -> WorldClock.count(nil, id) end
  end

  test "count() retuns 1 for a single existing elem w/ respect to add()" do
    w = WorldClock.new() |> WorldClock.add(LocalClock.new(dummy_me))
    assert 1 == WorldClock.count(w, dummy_me)
    assert 0 == WorldClock.count(w, dummy_other)
    w2 = WorldClock.add(w, LocalClock.new(dummy_other))
    assert 1 == WorldClock.count(w2, dummy_me)
    assert 1 == WorldClock.count(w2, dummy_other)
    assert 0 == WorldClock.count(w2, dummy_third)
    w3 = WorldClock.add(w2, LocalClock.new(dummy_third))
    assert 1 == WorldClock.count(w3, dummy_me)
    assert 1 == WorldClock.count(w3, dummy_other)
    assert 1 == WorldClock.count(w3, dummy_third)
  end

  test "count() retuns 1 for a single existing elem w/ respect to merge()" do
    w1 = WorldClock.new() |> WorldClock.add(LocalClock.new(dummy_me))
    w2 = WorldClock.new() |> WorldClock.add(LocalClock.new(dummy_other))
    w3 = WorldClock.new() |> WorldClock.add(LocalClock.new(dummy_third))

    # merge is idempotent
    assert 1 == WorldClock.merge(w1, w1) |> WorldClock.count(dummy_me)

    # merge keeps both elements
    w12 = WorldClock.merge(w1, w2)
    assert 1 == WorldClock.count(w12, dummy_me)
    assert 1 == WorldClock.count(w12, dummy_other)

    # merge keeps all 3 elements
    w123 = WorldClock.merge(w12, w3)
    assert 1 == WorldClock.count(w123, dummy_me)
    assert 1 == WorldClock.count(w123, dummy_other)
    assert 1 == WorldClock.count(w123, dummy_third)

    # merge keeps overlapping elemnts too
    w23 = WorldClock.merge(w2, w3)
    w1223 = WorldClock.merge(w12, w23)
    assert 1 == WorldClock.count(w1223, dummy_me)
    assert 1 == WorldClock.count(w1223, dummy_other)
    assert 1 == WorldClock.count(w1223, dummy_third)
  end

  test "count(local_clock) retuns 1 for a single existing elem w/ respect to merge()" do
    lc1 = LocalClock.new(dummy_me)
    lc2 = LocalClock.new(dummy_other)
    lc3 = LocalClock.new(dummy_third)

    w1 = WorldClock.new() |> WorldClock.add(lc1)
    w2 = WorldClock.new() |> WorldClock.add(lc2)
    w3 = WorldClock.new() |> WorldClock.add(lc3)

    # merge is idempotent
    assert 1 == WorldClock.merge(w1, w1) |> WorldClock.count(lc1)

    # merge keeps both elements
    w12 = WorldClock.merge(w1, w2)
    assert 1 == WorldClock.count(w12, lc1)
    assert 1 == WorldClock.count(w12, lc2)

    # merge keeps all 3 elements
    w123 = WorldClock.merge(w12, w3)
    assert 1 == WorldClock.count(w123, lc1)
    assert 1 == WorldClock.count(w123, lc2)
    assert 1 == WorldClock.count(w123, lc3)

    # merge keeps overlapping elemnts too
    w23 = WorldClock.merge(w2, w3)
    w1223 = WorldClock.merge(w12, w23)
    assert 1 == WorldClock.count(w1223, lc1)
    assert 1 == WorldClock.count(w1223, lc2)
    assert 1 == WorldClock.count(w1223, lc3)
  end

  test "merge() raises on invalid parameters" do
    assert_raise FunctionClauseError, fn -> WorldClock.merge(:ok, :ok) end
    assert_raise FunctionClauseError, fn -> WorldClock.merge([], :ok) end
    assert_raise FunctionClauseError, fn -> WorldClock.merge({}, :ok) end
    assert_raise FunctionClauseError, fn -> WorldClock.merge(nil, :ok) end

    w = WorldClock.new()
    assert_raise FunctionClauseError, fn -> WorldClock.merge(w, :ok) end
    assert_raise FunctionClauseError, fn -> WorldClock.merge(w, []) end
    assert_raise FunctionClauseError, fn -> WorldClock.merge(w, {}) end
    assert_raise FunctionClauseError, fn -> WorldClock.merge(w, nil) end

    assert_raise FunctionClauseError, fn -> WorldClock.merge(:ok, w) end
    assert_raise FunctionClauseError, fn -> WorldClock.merge([], w) end
    assert_raise FunctionClauseError, fn -> WorldClock.merge({}, w) end
    assert_raise FunctionClauseError, fn -> WorldClock.merge(nil, w) end
  end

  test "merge() keeps the latest element" do
    lc1 = LocalClock.new(dummy_me)
    lc2 = LocalClock.new(dummy_other)
    lc3 = LocalClock.new(dummy_third)

    lc1p = LocalClock.next(lc1)
    lc2p = LocalClock.next(lc2)
    lc3p = LocalClock.next(lc3)

    w1 = WorldClock.new() |> WorldClock.add(lc1)
    w2 = WorldClock.new() |> WorldClock.add(lc2)
    w3 = WorldClock.new() |> WorldClock.add(lc3)

    # merge keeps both elements
    w12 = WorldClock.merge(w1, w2)
    assert 1 == WorldClock.count(w12, lc1)
    assert 1 == WorldClock.count(w12, lc2)

    w12 = WorldClock.add(w12, lc1p)
    assert 0 == WorldClock.count(w12, lc1)
    assert 1 == WorldClock.count(w12, lc1p)

    w12 = WorldClock.add(w12, lc2p)
    assert 0 == WorldClock.count(w12, lc2)
    assert 1 == WorldClock.count(w12, lc1p)
    assert 1 == WorldClock.count(w12, lc2p)

    # merge keeps all 3 elements
    w123 = WorldClock.merge(w12, w3)
    assert 1 == WorldClock.count(w123, lc1p)
    assert 1 == WorldClock.count(w123, lc2p)
    assert 1 == WorldClock.count(w123, lc3)

    w123 = WorldClock.add(w123, lc3p)
    assert 0 == WorldClock.count(w123, lc3)
    assert 1 == WorldClock.count(w123, lc3p)

    # merge keeps the latest of the clocks
    w23 = WorldClock.merge(w2, w3)
    w1223 = WorldClock.merge(w12, w23)

    assert 0 == WorldClock.count(w1223, lc1)
    assert 0 == WorldClock.count(w1223, lc2)
    assert 1 == WorldClock.count(w1223, lc3)
    assert 1 == WorldClock.count(w1223, lc1p)
    assert 1 == WorldClock.count(w1223, lc2p)
    assert 0 == WorldClock.count(w1223, lc3p)
  end

  test "next(clock, netid) raises on invalid parameters" do
    assert_raise FunctionClauseError, fn -> WorldClock.next(:ok, :ok) end
    assert_raise FunctionClauseError, fn -> WorldClock.next([], :ok) end
    assert_raise FunctionClauseError, fn -> WorldClock.next({}, :ok) end
    assert_raise FunctionClauseError, fn -> WorldClock.next(nil, :ok) end

    w = WorldClock.new()
    assert_raise FunctionClauseError, fn -> WorldClock.next(w, :ok) end
    assert_raise FunctionClauseError, fn -> WorldClock.next(w, []) end
    assert_raise FunctionClauseError, fn -> WorldClock.next(w, {}) end
    assert_raise FunctionClauseError, fn -> WorldClock.next(w, nil) end

    id = dummy_me
    assert_raise FunctionClauseError, fn -> WorldClock.next(:ok, id) end
    assert_raise FunctionClauseError, fn -> WorldClock.next([], id) end
    assert_raise FunctionClauseError, fn -> WorldClock.next({}, id) end
    assert_raise FunctionClauseError, fn -> WorldClock.next(nil, id) end
  end

  test "next(clock, netid) adds a new local_clock if netid is not yet in the world clock" do
    lc1 = LocalClock.new(dummy_me)
    w = WorldClock.new() |> WorldClock.next(dummy_me)
    assert 1 == WorldClock.count(w,lc1)
  end

  test "next(clock, netid) increases the existing local_clock withing the world clock" do
    lc1 = LocalClock.new(dummy_me)
    w = WorldClock.new() |> WorldClock.next(dummy_me)
    assert 1 == WorldClock.count(w,lc1)
    lc1p = LocalClock.next(lc1)
    assert 0 == WorldClock.count(w,lc1p)
    w = WorldClock.next(w,dummy_me)
    assert 0 == WorldClock.count(w,lc1)
    assert 1 == WorldClock.count(w,lc1p)
  end
end
