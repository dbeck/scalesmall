defmodule GroupManager.StatusEvent.EventTest do
  use ExUnit.Case
  
  alias GroupManager.StatusEvent.Event, as: Event
  alias GroupManager.StatusEvent.State, as: State

  test "merging empty events" do
    a = %Event{}
    b = %Event{}
    assert a == Event.merge([a, b])
  end

  test "merging empty and non empty events" do
    s1 = %State{type: :join,  node: "test"}
    a = %Event{}
    b = %Event{events: [s1]}
    assert b == Event.merge([a, b])
  end

  test "merging non-empty events" do
    s1 = %State{type: :join,  node: "test"}
    s2 = %State{type: :leave,  node: "test"}
    a = %Event{events: [s1]}
    b = %Event{events: [s2]}
    c = %Event{events: [s1, s2]}
    assert c == Event.merge([a, b])
  end
end
