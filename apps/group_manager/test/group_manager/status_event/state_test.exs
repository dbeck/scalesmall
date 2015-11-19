defmodule GroupManager.StatusEvent.StateTest do
  use ExUnit.Case

  alias GroupManager.StatusEvent.State

  test "can merge the same values into one" do
    a = %State{}
    b = a
    assert [a] == State.merge([a],[b])
  end
  
  test "can merge distinct event types for the same host" do
    a = %State{type: :gone,  node: "test"}
    b = %State{type: :ready, node: "test"}
    c = [a, b]
    assert c == State.merge([a],[b])
    assert c == State.merge([b],[a])
  end
end
