defmodule GroupManager.StatusEvent.EventTest do
  use ExUnit.Case

  test "merging empty events" do
    a = %GroupManager.StatusEvent.Event{}
    b = %GroupManager.StatusEvent.Event{}
    assert a == GroupManager.StatusEvent.Event.merge([a, b])
  end

  test "merging empty and non empty events" do
    s1 = %GroupManager.StatusEvent.Status{type: :join,  node: "test"}
    a = %GroupManager.StatusEvent.Event{}
    b = %GroupManager.StatusEvent.Event{events: [s1]}
    assert b == GroupManager.StatusEvent.Event.merge([a, b])
  end

  test "merging non-empty events" do
    s1 = %GroupManager.StatusEvent.Status{type: :join,  node: "test"}
    s2 = %GroupManager.StatusEvent.Status{type: :leave,  node: "test"}
    a = %GroupManager.StatusEvent.Event{events: [s1]}
    b = %GroupManager.StatusEvent.Event{events: [s2]}
    c = %GroupManager.StatusEvent.Event{events: [s1, s2]}
    assert c == GroupManager.StatusEvent.Event.merge([a, b])
  end
end
