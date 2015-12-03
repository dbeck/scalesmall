defmodule GroupManager.Data.TimedItemTest do
  use ExUnit.Case
  alias GroupManager.Data.TimedItem

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
  
  # construct
  # construct next
end