defmodule GroupManager.Data.WorldClockTest do
  use ExUnit.Case
  alias GroupManager.Data.WorldClock
  alias GroupManager.Data.LocalClock

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
  
  test "adding a local clock to the world clock" do
    w = WorldClock.new()
    l = LocalClock.new(:a)
    new_clock = WorldClock.add(w, l)
    assert 1 == WorldClock.size(new_clock)
    assert l == WorldClock.get(new_clock, :a)
  end

  # time
  # add
  # size
  # get
end