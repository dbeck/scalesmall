defmodule GroupManager.Data.LocalClockTest do
  use ExUnit.Case
  alias GroupManager.Data.LocalClock
  alias GroupManager.Chatter.NetID

  defp dummy_me do
    NetID.new({1,2,3,4},1)
  end

  defp dummy_other do
    NetID.new({2,3,4,5},2)
  end

  # TODO
  # doctest GroupManager.Data.LocalClock

  test "basic test for new" do
    assert LocalClock.valid?(LocalClock.new(dummy_me))
  end

  test "basic test for invalid input" do
    assert LocalClock.valid?(nil) == false
    assert LocalClock.valid?([]) == false
    assert LocalClock.valid?({}) == false
    assert LocalClock.valid?(:ok) == false
    assert LocalClock.valid?({:ok}) == false
    assert LocalClock.valid?({:local_clock}) == false
    assert LocalClock.valid?({:local_clock, nil}) == false
    assert LocalClock.valid?({:local_clock, nil, nil}) == false
    assert LocalClock.valid?({:local_clock, nil, nil, nil}) == false
  end

  test "next() raises on invalid clock" do
    assert_raise FunctionClauseError, fn -> LocalClock.next(:ok) end
    assert_raise FunctionClauseError, fn -> LocalClock.next(nil) end
    assert_raise FunctionClauseError, fn -> LocalClock.next([]) end
    assert_raise FunctionClauseError, fn -> LocalClock.next({}) end
  end

  test "time_val() returns the local clock time" do
    clock = LocalClock.new(dummy_me)
    clock2 = LocalClock.next(clock)
    assert LocalClock.time_val(clock) + 1 == LocalClock.time_val(clock2)
  end

  test "time_val() raises on bad parameter" do
    assert_raise FunctionClauseError, fn -> LocalClock.time_val(:ok) end
    assert_raise FunctionClauseError, fn -> LocalClock.time_val([]) end
    assert_raise FunctionClauseError, fn -> LocalClock.time_val({}) end
    assert_raise FunctionClauseError, fn -> LocalClock.time_val({:ok}) end
  end

  test "member() returns the local clock's member" do
    clock = LocalClock.new(dummy_me)
    assert LocalClock.member(clock) == dummy_me
  end

  test "member() raises on bad parameter" do
    assert_raise FunctionClauseError, fn -> LocalClock.member(:ok) end
    assert_raise FunctionClauseError, fn -> LocalClock.member([]) end
    assert_raise FunctionClauseError, fn -> LocalClock.member({}) end
    assert_raise FunctionClauseError, fn -> LocalClock.member({:ok}) end
  end

  test "merge_into() is idempotent" do
    lst = []
    clock = LocalClock.new(dummy_me)
    merged = LocalClock.merge_into(lst, clock)
    assert length(merged) == 1
    assert merged == LocalClock.merge_into(merged, clock)
    # merge in another one
    clock2 = LocalClock.new(dummy_other)
    merged = LocalClock.merge_into(merged, clock2)
    assert length(merged) == 2
    assert merged == LocalClock.merge_into(merged, clock)
  end

  test "merge_into() keeps the latest clock for a member" do
    clock = LocalClock.new(dummy_me)
    clock2 = LocalClock.next(clock)
    assert clock != clock2
    assert [clock2] == LocalClock.merge_into([clock], clock2)
    assert [clock2] == LocalClock.merge_into([clock2], clock)
    assert [clock2] == LocalClock.merge_into([clock, clock], clock2)
    assert [clock2] == LocalClock.merge_into([clock2, clock], clock)
  end

  test "merge_into() raises on bad elements" do
    assert_raise FunctionClauseError, fn ->
      LocalClock.merge_into([], :ok)
    end
    assert_raise FunctionClauseError, fn ->
      LocalClock.merge_into([:ok], LocalClock.new(dummy_me))
    end
    assert_raise FunctionClauseError, fn ->
      LocalClock.merge_into([LocalClock.new(dummy_me), :ok], LocalClock.new(dummy_me))
    end
  end

  test "max_clock() returns identity for the same values" do
    clock = LocalClock.new(dummy_me)
    assert clock == LocalClock.max_clock(clock, clock)
  end

  test "max_clock() raises error for incompatible clocks" do
    clock1 = LocalClock.new(dummy_me)
    clock2 = LocalClock.new(dummy_other)
    assert_raise FunctionClauseError, fn -> LocalClock.max_clock(clock1, clock2) end
  end

  test "max_clock() picks up the maximum of two clocks" do
    clock1 = LocalClock.new(dummy_me)
    clock2 = LocalClock.next(clock1)
    assert clock2 == LocalClock.max_clock(clock1, clock2)
    assert clock2 == LocalClock.max_clock(clock2, clock1)
  end

  test "max_clock() raises on invalid parameters" do
    clock = LocalClock.new(dummy_me)
    assert_raise FunctionClauseError, fn ->  LocalClock.max_clock(clock, nil) end
    assert_raise FunctionClauseError, fn ->  LocalClock.max_clock(nil, clock) end
    assert_raise FunctionClauseError, fn ->  LocalClock.max_clock(nil, nil) end
    assert_raise FunctionClauseError, fn ->  LocalClock.max_clock([], []) end
    assert_raise FunctionClauseError, fn ->  LocalClock.max_clock(clock, []) end
    assert_raise FunctionClauseError, fn ->  LocalClock.max_clock([], clock) end
  end
end
