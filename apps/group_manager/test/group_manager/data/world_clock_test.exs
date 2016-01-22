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

  # next(clock, netid) adds a new local_clock if netid is not yet in the world clock
  # next(clock, netid) increases the existing local_clock withing the world clock
  # merge is idempotent
  # merge raises on invalid input
  # merge keeps the latest elements
end
