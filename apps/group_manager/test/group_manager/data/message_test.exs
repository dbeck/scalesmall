defmodule GroupManager.Data.MessageTest do
  use ExUnit.Case
  alias GroupManager.Data.Message
  
  # TODO
  # doctest GroupManager.Data.Message
  
  test "basic test for new" do
    assert Message.valid?(Message.new())
  end
  
  test "basic test for invalid input" do
    assert Message.valid?(nil) == false
    assert Message.valid?([]) == false
    assert Message.valid?({}) == false
    assert Message.valid?(:ok) == false
    assert Message.valid?({:ok}) == false
    assert Message.valid?({:message}) == false
    assert Message.valid?({:message, nil}) == false
    assert Message.valid?({:message, nil, nil}) == false
    assert Message.valid?({:message, nil, nil, nil}) == false
  end
  
  test "check if a newly created object is empty" do
    cl = Message.new()
    assert Message.empty?(cl)
  end
  
  test "checking for emptiness on an invalid object leads to exception" do
    assert_raise FunctionClauseError, fn -> Message.empty?(:ok) end
    assert_raise FunctionClauseError, fn -> Message.empty?([]) end
    assert_raise FunctionClauseError, fn -> Message.empty?({}) end
    assert_raise FunctionClauseError, fn -> Message.empty?(nil) end
  end
  
  # add
  # remove
end
