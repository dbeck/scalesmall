defmodule GroupManager.Chatter.BroadcastIDTest do
  use ExUnit.Case
  alias GroupManager.Chatter.NetID
  alias GroupManager.Chatter.BroadcastID
  
  test "basic test for new" do
    assert BroadcastID.valid?(BroadcastID.new(NetID.new({127,0,0,1}, 29999)))
  end
  
  test "basic test for invalid input" do
    assert BroadcastID.valid?(nil) == false
    assert BroadcastID.valid?([]) == false
    assert BroadcastID.valid?({}) == false
    assert BroadcastID.valid?(:ok) == false
    assert BroadcastID.valid?({:ok}) == false
    assert BroadcastID.valid?({:broadcast_id}) == false
    assert BroadcastID.valid?({:broadcast_id, nil}) == false
    assert BroadcastID.valid?({:broadcast_id, nil, nil}) == false
    assert BroadcastID.valid?({:broadcast_id, nil, nil, nil}) == false
  end
end
