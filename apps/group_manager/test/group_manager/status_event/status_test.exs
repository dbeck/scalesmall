defmodule GroupManager.StatusEvent.StatusTest do
  use ExUnit.Case

  test "can merge the same values into one" do
    a = %GroupManager.StatusEvent.Status{}
    b = a
    assert [a] == GroupManager.StatusEvent.Status.merge([a],[b])
  end
  
  test "can merge distinct event types for the same host" do
    a = %GroupManager.StatusEvent.Status{type: :join,  node: "test"}
    b = %GroupManager.StatusEvent.Status{type: :leave, node: "test"}
    c = [a, b]
    assert c == GroupManager.StatusEvent.Status.merge([a],[b])
    assert c == GroupManager.StatusEvent.Status.merge([b],[a])
  end
end
