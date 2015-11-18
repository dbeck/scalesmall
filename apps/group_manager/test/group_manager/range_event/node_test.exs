defmodule GroupManager.RangeEvent.NodeTest do
  use ExUnit.Case

  test "order between Nodes favor larger point" do
    smaller = %GroupManager.RangeEvent.Node{type: :register, node: "", point: 0.5}
    greater  = %GroupManager.RangeEvent.Node{type: :register, node: "", point: 0.6}
    assert GroupManager.RangeEvent.Node.is_greater(smaller, greater) == false
    assert GroupManager.RangeEvent.Node.is_greater(greater, smaller) == true
    # equal Nodes are not greater
    assert GroupManager.RangeEvent.Node.is_greater(greater, greater) == false
    assert GroupManager.RangeEvent.Node.is_greater(smaller, smaller) == false
  end
  
  test "equal Nodes are not greater" do
    n = %GroupManager.RangeEvent.Node{type: :register, node: "", point: 0.5}
    assert GroupManager.RangeEvent.Node.is_greater(n, n) == false
  end
  
  test "if split happens after the Node's point that doesn't impact the Node list" do
    node  = %GroupManager.RangeEvent.Node{type: :register, node: "", point: 0.5}
    split = %GroupManager.RangeEvent.Split{point: 0.6}
    assert [^node] = GroupManager.RangeEvent.Node.split_node(split, node, [])
  end
  
  test "if split happens before the Node's point that generates a new node" do
    node   = %GroupManager.RangeEvent.Node{type: :register, node: "", point: 0.5}
    node2  = %GroupManager.RangeEvent.Node{type: :register, node: "", point: 0.3}
    split = %GroupManager.RangeEvent.Split{point: 0.3}
    assert [^node2, ^node] = GroupManager.RangeEvent.Node.split_node(split, node, [])
  end
  
  test "empty split list doesn't impact the Node list" do
    node  = %GroupManager.RangeEvent.Node{type: :register, node: "", point: 0.5}
    assert [^node] = GroupManager.RangeEvent.Node.split_node([], node, [])
  end
  
  test "split nodes twice doesn't change the list" do
    node   = %GroupManager.RangeEvent.Node{type: :register, node: "", point: 0.5}
    node2  = %GroupManager.RangeEvent.Node{type: :register, node: "", point: 0.3}
    split  = %GroupManager.RangeEvent.Split{point: 0.3}
    [n1, n2] = GroupManager.RangeEvent.Node.split([split], [node, node2])
    assert [n1, n2] == GroupManager.RangeEvent.Node.split([split, split, split], [n1, n2])
  end
end