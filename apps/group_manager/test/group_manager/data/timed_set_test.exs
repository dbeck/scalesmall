defmodule GroupManager.Data.TimedSetTest do
  use ExUnit.Case
  alias GroupManager.Data.TimedSet
  alias GroupManager.Data.TimedItem

  # TODO
  # doctest GroupManager.Data.TimedSet
  
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
  
  test "items() returns what had been added" do
    ti = TimedItem.new(:me)
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
    ts = TimedSet.new() |> TimedSet.add(TimedItem.new(:a1)) |> TimedSet.add(TimedItem.new(:a2))
    assert length(TimedSet.items(ts)) == 2
  end
  
  test "add() raises on invalid items" do
    ts = TimedSet.new()
    assert_raise FunctionClauseError, fn -> TimedSet.add(ts, :ok) end
    assert_raise FunctionClauseError, fn -> TimedSet.add(ts, []) end
    assert_raise FunctionClauseError, fn -> TimedSet.add(ts, {}) end
    assert_raise FunctionClauseError, fn -> TimedSet.add(ts, nil) end
  end
end
