defmodule GroupManager.Data.LocalClockTest do
  use ExUnit.Case
  alias GroupManager.Data.LocalClock

  # TODO
  # doctest GroupManager.Data.LocalClock 
    
  test "basic test for new" do
    assert LocalClock.valid?(LocalClock.new(:hello))
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
  
  test "compare the same clock" do
    c1 = LocalClock.new(:hello)
    c2 = LocalClock.new(:hello)
    assert LocalClock.compare(c1, c2) == :same    
  end
  
  test "compare different clocks" do
    c1 = LocalClock.new(:hello1)
    c2 = LocalClock.new(:hello2)
    assert LocalClock.compare(c1, c2) == :different
  end

  test "compare same member different values" do
    c1 = LocalClock.new(:hello)
    c2 = LocalClock.next(c1)
    assert LocalClock.compare(c1, c2) == :before
    assert LocalClock.compare(c2, c1) == :after
  end
  
  test "compare invalid clock to valid one" do
    c = LocalClock.new(:hello)
    assert_raise FunctionClauseError, fn ->
      LocalClock.compare(c, :ok)
    end
  end

  test "next() raises on invalid clock" do
    assert_raise FunctionClauseError, fn -> LocalClock.next(:ok) end
    assert_raise FunctionClauseError, fn -> LocalClock.next(nil) end
    assert_raise FunctionClauseError, fn -> LocalClock.next([]) end
    assert_raise FunctionClauseError, fn -> LocalClock.next({}) end
  end
end
