defmodule GroupManager.Data.WorldClockTest do
  use ExUnit.Case
  alias GroupManager.Data.WorldClock

  # TODO
  # doctest GroupManager.Data.WorldClock 
    
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
end