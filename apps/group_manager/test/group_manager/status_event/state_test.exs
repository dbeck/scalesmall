defmodule GroupManager.StatusEvent.StateTest do
  use ExUnit.Case

  test "can merge the same values into one" do
    a = %GroupManager.StatusEvent.State{}
    b = a
    assert [a] == GroupManager.StatusEvent.State.merge([a],[b])
  end
  
  test "can merge distinct event types for the same host" do
    a = %GroupManager.StatusEvent.State{type: :join,  node: "test"}
    b = %GroupManager.StatusEvent.State{type: :leave, node: "test"}
    c = [a, b]
    assert c == GroupManager.StatusEvent.State.merge([a],[b])
    assert c == GroupManager.StatusEvent.State.merge([b],[a])
  end
end
