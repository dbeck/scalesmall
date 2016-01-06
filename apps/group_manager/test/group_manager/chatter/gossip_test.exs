defmodule GroupManager.Chatter.GossipTest do
  use ExUnit.Case
  alias GroupManager.Chatter.NetID
  alias GroupManager.Chatter.Gossip

  test "basic test for new" do
    assert Gossip.valid?(Gossip.new(NetID.new({127,0,0,1}, 29999), []))
  end

  test "basic test for invalid input" do
    assert Gossip.valid?(nil) == false
    assert Gossip.valid?([]) == false
    assert Gossip.valid?({}) == false
    assert Gossip.valid?(:ok) == false
    assert Gossip.valid?({:ok}) == false
    assert Gossip.valid?({:gossip}) == false
    assert Gossip.valid?({:gossip, nil}) == false
    assert Gossip.valid?({:gossip, nil, nil}) == false
    assert Gossip.valid?({:gossip, nil, nil, nil}) == false
  end

  # seen_ids
  # distribution_list
end
