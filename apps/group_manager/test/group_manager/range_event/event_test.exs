defmodule GroupManager.RangeEvent.EventTest do
  use ExUnit.Case

  test "one node registers, other node splits before" do
    register_event = %GroupManager.RangeEvent.Node{type: :register, node: "", point: 0.5}    
    split_event = %GroupManager.RangeEvent.Split{point: 0.3}
    ev1 = %GroupManager.RangeEvent.Event{split: [split_event]}
    ev2 = %GroupManager.RangeEvent.Event{register: [register_event]}
    
    # merging the two events should split the register event into two parts
    split_register_event = %GroupManager.RangeEvent.Node{type: :register, node: "", point: 0.3}
    expected = %GroupManager.RangeEvent.Event{split: [split_event], register: [split_register_event, register_event]}
    assert expected == GroupManager.RangeEvent.Event.merge([ev1, ev2])
    # changing order should not impact the result
    assert expected == GroupManager.RangeEvent.Event.merge([ev2, ev1])
    # neither duplicate events
    assert expected == GroupManager.RangeEvent.Event.merge([ev2, ev2, ev1, ev1])
  end
  
  test "multiple splits should split node events if they happen before the node event location" do
    register_event = %GroupManager.RangeEvent.Node{type: :register, node: "", point: 0.5}    
    not_impacted_register_event = %GroupManager.RangeEvent.Node{type: :register, node: "", point: 0.1}    
    split_event = %GroupManager.RangeEvent.Split{point: 0.3}
    non_splitting_event = %GroupManager.RangeEvent.Split{point: 0.9}
        
    ev1 = %GroupManager.RangeEvent.Event{split: [split_event]}
    ev2 = %GroupManager.RangeEvent.Event{register: [register_event]}
    ev3 = %GroupManager.RangeEvent.Event{split: [non_splitting_event]}
    ev4 = %GroupManager.RangeEvent.Event{register: [not_impacted_register_event]}
    
    # merging the tevents should split the register event into two parts
    split_register_event = %GroupManager.RangeEvent.Node{type: :register, node: "", point: 0.3}
    expected = %GroupManager.RangeEvent.Event{
      split: [split_event, non_splitting_event],
      register: [not_impacted_register_event, split_register_event, register_event]
    }
    
    # all permutations should result the same expected result
    assert expected == GroupManager.RangeEvent.Event.merge([ev1, ev2, ev3, ev4])
    assert expected == GroupManager.RangeEvent.Event.merge([ev1, ev2, ev4, ev3])
    assert expected == GroupManager.RangeEvent.Event.merge([ev1, ev3, ev2, ev4])
    assert expected == GroupManager.RangeEvent.Event.merge([ev1, ev3, ev4, ev2])
    assert expected == GroupManager.RangeEvent.Event.merge([ev1, ev4, ev2, ev3])
    assert expected == GroupManager.RangeEvent.Event.merge([ev1, ev4, ev3, ev2])

    assert expected == GroupManager.RangeEvent.Event.merge([ev2, ev1, ev3, ev4]) 
    assert expected == GroupManager.RangeEvent.Event.merge([ev2, ev1, ev4, ev3])
    assert expected == GroupManager.RangeEvent.Event.merge([ev2, ev3, ev1, ev4])
    assert expected == GroupManager.RangeEvent.Event.merge([ev2, ev3, ev4, ev1])
    assert expected == GroupManager.RangeEvent.Event.merge([ev2, ev4, ev1, ev3])
    assert expected == GroupManager.RangeEvent.Event.merge([ev2, ev4, ev3, ev1])
    
    assert expected == GroupManager.RangeEvent.Event.merge([ev3, ev1, ev2, ev4])
    assert expected == GroupManager.RangeEvent.Event.merge([ev3, ev1, ev4, ev2])
    assert expected == GroupManager.RangeEvent.Event.merge([ev3, ev2, ev1, ev4])
    assert expected == GroupManager.RangeEvent.Event.merge([ev3, ev2, ev4, ev1])
    assert expected == GroupManager.RangeEvent.Event.merge([ev3, ev4, ev1, ev2])
    assert expected == GroupManager.RangeEvent.Event.merge([ev3, ev4, ev2, ev1])
    
    assert expected == GroupManager.RangeEvent.Event.merge([ev4, ev1, ev2, ev3])
    assert expected == GroupManager.RangeEvent.Event.merge([ev4, ev1, ev3, ev2])
    assert expected == GroupManager.RangeEvent.Event.merge([ev4, ev2, ev1, ev3])
    assert expected == GroupManager.RangeEvent.Event.merge([ev4, ev2, ev3, ev1])    
    assert expected == GroupManager.RangeEvent.Event.merge([ev4, ev3, ev2, ev1])
    assert expected == GroupManager.RangeEvent.Event.merge([ev4, ev3, ev1, ev2])
  end
end