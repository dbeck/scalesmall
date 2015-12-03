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
end