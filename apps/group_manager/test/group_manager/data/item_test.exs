defmodule GroupManager.Data.ItemTest do
  use ExUnit.Case
  alias GroupManager.Data.Item
    
  # TODO
  # doctest GroupManager.Data.Item
  
  test "basic test for new" do
    assert Item.valid?(Item.new(:hello))
  end
  
  test "basic test for invalid input" do
    assert Item.valid?(nil) == false
    assert Item.valid?([]) == false
    assert Item.valid?({}) == false
    assert Item.valid?(:ok) == false
    assert Item.valid?({:ok}) == false
    assert Item.valid?({:item}) == false
    assert Item.valid?({:item, nil}) == false
    assert Item.valid?({:item, nil, nil}) == false
    assert Item.valid?({:item, nil, nil, nil}) == false
    assert Item.valid?({:item, nil, nil, nil, nil}) == false
    assert Item.valid?({:item, nil, nil, nil, nil, nil}) == false
    assert Item.valid?({:item, nil, nil, nil, nil, nil, nil}) == false
  end
  
  test "member property can be retrieved" do
    assert :me == Item.new(:me) |> Item.member
  end
  
  test "cannot get member from an invalid Item" do
    assert_raise FunctionClauseError, fn -> Item.member(:ok) end
    assert_raise FunctionClauseError, fn -> Item.member([]) end
    assert_raise FunctionClauseError, fn -> Item.member({}) end
    assert_raise FunctionClauseError, fn -> Item.member({:ok}) end
    assert_raise FunctionClauseError, fn -> Item.member({:item}) end
    assert_raise FunctionClauseError, fn -> Item.member({:item, nil}) end
    assert_raise FunctionClauseError, fn -> Item.member({:item, nil, nil}) end
    assert_raise FunctionClauseError, fn -> Item.member({:item, nil, nil, nil}) end
    assert_raise FunctionClauseError, fn -> Item.member({:item, nil, nil, nil, nil}) end
    assert_raise FunctionClauseError, fn -> Item.member({:item, nil, nil, nil, nil, nil}) end
  end  

  test "op property can be set and retrieved" do
    assert :rmv == Item.new(:hello) |> Item.op(:rmv) |> Item.op
    assert :add == Item.new(:hello) |> Item.op(:add) |> Item.op
  end
  
  test "cannot set invalid atom to op" do
    assert_raise FunctionClauseError, fn -> Item.new(:hello) |> Item.op(:invalid) end
  end

  test "cannot set op on invalid Item" do
    assert_raise FunctionClauseError, fn -> Item.op(nil, :add) end
  end

  test "start_range property can be set and retrieved" do
    assert 11 == Item.new(:hello) |> Item.start_range(11) |> Item.start_range
  end
  
  test "cannot set invalid start_range" do
    assert_raise FunctionClauseError, fn -> Item.new(:hello) |> Item.start_range(-1) end
  end

  test "cannot set start_range on invalid Item" do
    assert_raise FunctionClauseError, fn -> Item.start_range(nil, 1) end
  end
  
  test "end_range property can be set and retrieved" do
    assert 99 == Item.new(:hello) |> Item.end_range(99) |> Item.end_range
  end

  test "cannot set invalid end_range" do
    assert_raise FunctionClauseError, fn -> Item.new(:hello) |> Item.end_range(-1) end
  end

  test "cannot set end_range on invalid Item" do
    assert_raise FunctionClauseError, fn -> Item.end_range(nil, 1) end
  end

  test "priority property can be set and retrieved" do
    assert 1199 == Item.new(:hello) |> Item.priority(1199) |> Item.priority
  end
  
  test "cannot set invalid priority" do
    assert_raise FunctionClauseError, fn -> Item.new(:hello) |> Item.priority(-1) end
  end

  test "cannot set priority on invalid Item" do
    assert_raise FunctionClauseError, fn -> Item.priority(nil, 1) end
  end
end