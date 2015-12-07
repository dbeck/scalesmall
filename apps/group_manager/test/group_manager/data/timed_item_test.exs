defmodule GroupManager.Data.TimedItemTest do
  use ExUnit.Case
  alias GroupManager.Data.TimedItem
  alias GroupManager.Data.Item
  alias GroupManager.Data.LocalClock

  # TODO
  # doctest GroupManager.Data.TimedItem
  
  test "basic test for new" do
    assert TimedItem.valid?(TimedItem.new(:hello))
  end
  
  test "basic test for invalid input" do
    assert TimedItem.valid?(nil) == false
    assert TimedItem.valid?([]) == false
    assert TimedItem.valid?({}) == false
    assert TimedItem.valid?(:ok) == false
    assert TimedItem.valid?({:ok}) == false
    assert TimedItem.valid?({:timed_item}) == false
    assert TimedItem.valid?({:timed_item, nil}) == false
    assert TimedItem.valid?({:timed_item, nil, nil}) == false
  end
  
  test "item() returns the Item member" do
    it = TimedItem.new(:hello) |> TimedItem.item
    assert Item.valid?(it)
  end
  
  test "item() raises on invalid parameter" do
    assert_raise FunctionClauseError, fn -> TimedItem.item(nil) end
    assert_raise FunctionClauseError, fn -> TimedItem.item([]) end
    assert_raise FunctionClauseError, fn -> TimedItem.item({}) end
    assert_raise FunctionClauseError, fn -> TimedItem.item(:ok) end
    assert_raise FunctionClauseError, fn -> TimedItem.item({:timed_item}) end
  end

  test "updated_at() returns the LocalClock member" do
    cl = TimedItem.new(:hello) |> TimedItem.updated_at
    assert LocalClock.valid?(cl)
  end
  
  test "updated_at() raises on invalid parameter" do
    assert_raise FunctionClauseError, fn -> TimedItem.updated_at(nil) end
    assert_raise FunctionClauseError, fn -> TimedItem.updated_at([]) end
    assert_raise FunctionClauseError, fn -> TimedItem.updated_at({}) end
    assert_raise FunctionClauseError, fn -> TimedItem.updated_at(:ok) end
    assert_raise FunctionClauseError, fn -> TimedItem.updated_at({:timed_item}) end
  end

  test "construct() creates a valid TimedItem object with valid members" do
    it = Item.new(:me)
    cl = LocalClock.new(:me)
    ti = TimedItem.construct(it, cl)
    assert TimedItem.valid?(ti)
    assert it == TimedItem.item(ti)
    assert cl == TimedItem.updated_at(ti)
  end
  
  test "construct() raises on different member variables" do
    it = Item.new(:me)
    cl = LocalClock.new(:other)
    assert_raise FunctionClauseError, fn -> TimedItem.construct(it, cl) end
  end
  
  test "construct() raises on invalid Item" do
    cl = LocalClock.new(:other)
    assert_raise FunctionClauseError, fn -> TimedItem.construct(nil, cl) end
    assert_raise FunctionClauseError, fn -> TimedItem.construct(:ok, cl) end
    assert_raise FunctionClauseError, fn -> TimedItem.construct({:item}, cl) end
    assert_raise FunctionClauseError, fn -> TimedItem.construct([], cl) end
    assert_raise FunctionClauseError, fn -> TimedItem.construct({}, cl) end
  end
  
  test "construct() raises on invalid LocalClock" do
    it = Item.new(:me)
    assert_raise FunctionClauseError, fn -> TimedItem.construct(it, nil) end
    assert_raise FunctionClauseError, fn -> TimedItem.construct(it, :ok) end
    assert_raise FunctionClauseError, fn -> TimedItem.construct(it, {:item}) end
    assert_raise FunctionClauseError, fn -> TimedItem.construct(it, []) end
    assert_raise FunctionClauseError, fn -> TimedItem.construct(it, {}) end
  end
  
  test "construct_next() creates a valid TimedItem object with valid members" do
    it = Item.new(:me)
    cl = LocalClock.new(:me)
    ti = TimedItem.construct_next(it, cl)
    assert TimedItem.valid?(ti)
    assert it == TimedItem.item(ti)
    assert LocalClock.next(cl) == TimedItem.updated_at(ti)
  end
  
  test "construct_next() raises on different member variables" do
    it = Item.new(:me)
    cl = LocalClock.new(:other)
    assert_raise FunctionClauseError, fn -> TimedItem.construct_next(it, cl) end
  end
  
  test "construct_next() raises on invalid Item" do
    cl = LocalClock.new(:other)
    assert_raise FunctionClauseError, fn -> TimedItem.construct_next(nil, cl) end
    assert_raise FunctionClauseError, fn -> TimedItem.construct_next(:ok, cl) end
    assert_raise FunctionClauseError, fn -> TimedItem.construct_next({:item}, cl) end
    assert_raise FunctionClauseError, fn -> TimedItem.construct_next([], cl) end
    assert_raise FunctionClauseError, fn -> TimedItem.construct_next({}, cl) end
  end
  
  test "construct_next() raises on invalid LocalClock" do
    it = Item.new(:me)
    assert_raise FunctionClauseError, fn -> TimedItem.construct_next(it, nil) end
    assert_raise FunctionClauseError, fn -> TimedItem.construct_next(it, :ok) end
    assert_raise FunctionClauseError, fn -> TimedItem.construct_next(it, {:item}) end
    assert_raise FunctionClauseError, fn -> TimedItem.construct_next(it, []) end
    assert_raise FunctionClauseError, fn -> TimedItem.construct_next(it, {}) end
  end
  
  # max_item
  
  # merge_into
  test "merge_into() updates the same item to the latest clock" do
    true
  end
  
end