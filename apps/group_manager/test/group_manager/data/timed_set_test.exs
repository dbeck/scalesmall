defmodule GroupManager.Data.TimedSetTest do
  use ExUnit.Case
  alias GroupManager.Data.TimedSet

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
  
  # items
  # add
end