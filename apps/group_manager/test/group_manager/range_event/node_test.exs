defmodule GroupManager.RangeEvent.NodeTest do
  use ExUnit.Case
  
  alias GroupManager.RangeEvent.Node, as: Node
  alias GroupManager.RangeEvent.Split, as: Split

  test "order between Nodes favor larger point" do
    smaller = %Node{type: :register, node: "", point: 0.5}
    greater  = %Node{type: :register, node: "", point: 0.6}
    assert Node.is_greater(smaller, greater) == false
    assert Node.is_greater(greater, smaller) == true
    # equal Nodes are not greater
    assert Node.is_greater(greater, greater) == false
    assert Node.is_greater(smaller, smaller) == false
  end
  
  test "equal Nodes are not greater" do
    n = %Node{type: :register, node: "", point: 0.5}
    assert Node.is_greater(n, n) == false
  end
  
  test "if split happens after the Node's point that doesn't impact the Node list" do
    node  = %Node{type: :register, node: "", point: 0.5}
    split = %Split{point: 0.6}
    assert [node] == Node.split_node(split, node, [])
  end
  
  test "if split happens before the Node's point that generates a new node" do
    node   = %Node{type: :register, node: "", point: 0.5}
    node2  = %Node{type: :register, node: "", point: 0.3}
    split = %Split{point: 0.3}
    assert [node2, node] == Node.split_node(split, node, [])
  end
  
  test "empty split list doesn't impact the Node list" do
    node  = %Node{type: :register, node: "", point: 0.5}
    assert [node] == Node.split_node([], node, [])
  end
  
  test "split nodes twice doesn't change the list" do
    node   = %Node{type: :register, node: "", point: 0.5}
    node2  = %Node{type: :register, node: "", point: 0.3}
    split  = %Split{point: 0.3}
    [n1, n2] = Node.split([split], [node, node2])
    assert [n1, n2] == Node.split([split, split, split], [n1, n2])
  end
end