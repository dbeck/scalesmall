defmodule GroupManager.Chatter.PeerDataTest do
  use ExUnit.Case
  alias GroupManager.Chatter.PeerData
  alias GroupManager.Chatter.NetID
  
  test "basic test for new" do
    assert PeerData.valid?(PeerData.new(NetID.new({127,0,0,1}, 29999)))
  end
  
  test "basic test for invalid input" do
    assert PeerData.valid?(nil) == false
    assert PeerData.valid?([]) == false
    assert PeerData.valid?({}) == false
    assert PeerData.valid?(:ok) == false
    assert PeerData.valid?({:ok}) == false
    assert PeerData.valid?({:peer_data}) == false
    assert PeerData.valid?({:peer_data, nil}) == false
    assert PeerData.valid?({:peer_data, nil, nil}) == false
    assert PeerData.valid?({:peer_data, nil, nil, nil}) == false
  end
  
  # validate
end