defmodule GroupManager.Data.MessageLogTest do
  use ExUnit.Case
  alias GroupManager.Data.MessageLog

  # TODO
  # doctest GroupManager.Data.MessageLog
  
  test "basic test for new" do
    assert MessageLog.valid?(MessageLog.new())
  end
  
  test "basic test for invalid input" do
    assert MessageLog.valid?(nil) == false
    assert MessageLog.valid?([]) == false
    assert MessageLog.valid?({}) == false
    assert MessageLog.valid?(:ok) == false
    assert MessageLog.valid?({:ok}) == false
    assert MessageLog.valid?({:message_log}) == false
    assert MessageLog.valid?({:message_log, nil}) == false
    assert MessageLog.valid?({:message_log, nil, nil}) == false
    assert MessageLog.valid?({:message_log, nil, nil, nil}) == false
  end
  
  # add
end