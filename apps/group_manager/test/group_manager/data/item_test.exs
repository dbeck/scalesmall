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

  test "op property can be set and retrieved" do
    assert :rmv == Item.new(:hello) |> Item.set_op(:rmv) |> Item.op
    assert :add == Item.new(:hello) |> Item.set_op(:add) |> Item.op
  end
  
  test "cannot set invalid atom to op" do
    assert_raise FunctionClauseError, fn -> Item.new(:hello) |> Item.set_op(:invalid) end
  end

  test "cannot set op on invalid Item" do
    assert_raise FunctionClauseError, fn -> Item.set_op(nil, :add) end
  end

  test "start_range property can be set and retrieved" do
    assert 11 == Item.new(:hello) |> Item.set_start_range(11) |> Item.start_range
  end
  
  test "cannot set invalid start_range" do
    assert_raise FunctionClauseError, fn -> Item.new(:hello) |> Item.set_start_range(-1) end
  end

  test "cannot set start_range on invalid Item" do
    assert_raise FunctionClauseError, fn -> Item.set_start_range(nil, 1) end
  end
  
  test "end_range property can be set and retrieved" do
    assert 99 == Item.new(:hello) |> Item.set_end_range(99) |> Item.end_range
  end

  test "cannot set invalid end_range" do
    assert_raise FunctionClauseError, fn -> Item.new(:hello) |> Item.set_end_range(-1) end
  end

  test "cannot set end_range on invalid Item" do
    assert_raise FunctionClauseError, fn -> Item.set_end_range(nil, 1) end
  end

  test "priority property can be set and retrieved" do
    assert 1199 == Item.new(:hello) |> Item.set_priority(1199) |> Item.priority
  end
  
  test "cannot set invalid priority" do
    assert_raise FunctionClauseError, fn -> Item.new(:hello) |> Item.set_priority(-1) end
  end

  test "cannot set priority on invalid Item" do
    assert_raise FunctionClauseError, fn -> Item.set_priority(nil, 1) end
  end
end