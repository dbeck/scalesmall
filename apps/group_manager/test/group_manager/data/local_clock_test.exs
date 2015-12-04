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
  
  test "merge_into() is idempotent" do
    lst = []
    clock = LocalClock.new(:hello)
    merged = LocalClock.merge_into(lst, clock)
    assert length(merged) == 1
    assert merged == LocalClock.merge_into(merged, clock)
    # merge in another one
    clock2 = LocalClock.new(:world)
    merged = LocalClock.merge_into(merged, clock2)
    assert length(merged) == 2
    assert merged == LocalClock.merge_into(merged, clock)
  end
  
  test "merge_into() keeps the latest clock for a member" do
    clock = LocalClock.new(:hello)
    clock2 = LocalClock.next(clock)
    assert clock != clock2
    assert [clock2] == LocalClock.merge_into([clock], clock2)
    assert [clock2] == LocalClock.merge_into([clock2], clock)
    assert [clock2] == LocalClock.merge_into([clock, clock], clock2)
    assert [clock2] == LocalClock.merge_into([clock2, clock], clock)
  end
  
  test "merge_into() raises on bad elements" do
    assert_raise FunctionClauseError, fn -> LocalClock.merge_into([], :ok) end
    assert_raise FunctionClauseError, fn -> LocalClock.merge_into([:ok], LocalClock.new(:ok)) end
    assert_raise FunctionClauseError, fn -> LocalClock.merge_into([LocalClock.new(:ok), :ok], LocalClock.new(:ok)) end
  end    
  
  test "time_val() returns the local clock time" do
    clock = LocalClock.new(:hello)
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
    clock = LocalClock.new(:hello)
    assert LocalClock.member(clock) == :hello
  end
  
  test "member() raises on bad parameter" do
    assert_raise FunctionClauseError, fn -> LocalClock.member(:ok) end
    assert_raise FunctionClauseError, fn -> LocalClock.member([]) end
    assert_raise FunctionClauseError, fn -> LocalClock.member({}) end
    assert_raise FunctionClauseError, fn -> LocalClock.member({:ok}) end
  end 
end
