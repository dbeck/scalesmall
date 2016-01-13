defmodule GroupManager.Chatter.GossipTest do

  use ExUnit.Case
  alias GroupManager.Chatter.NetID
  alias GroupManager.Chatter.BroadcastID
  alias GroupManager.Chatter.Gossip

  test "basic test for new(netid, data)" do
    assert Gossip.valid?(Gossip.new(NetID.new({127,0,0,1}, 29999), []))
  end

  test "basic test for new(netid, seqno, data)" do
    g = Gossip.new(NetID.new({127,0,0,1}, 29999), 9999, [])
    assert Gossip.valid?(g)
    assert 9999 == g |> Gossip.current_id |> BroadcastID.seqno
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

  # current_id
  test "current_id() throws on invalid input" do
    assert_raise FunctionClauseError, fn -> Gossip.current_id(nil) end
    assert_raise FunctionClauseError, fn -> Gossip.current_id([]) end
    assert_raise FunctionClauseError, fn -> Gossip.current_id({}) end
    assert_raise FunctionClauseError, fn -> Gossip.current_id({:ok}) end
    assert_raise FunctionClauseError, fn -> Gossip.current_id({:ok, nil}) end
    assert_raise FunctionClauseError, fn -> Gossip.current_id({:ok, nil, nil}) end
    assert_raise FunctionClauseError, fn -> Gossip.current_id({:gossip, nil}) end
    assert_raise FunctionClauseError, fn -> Gossip.current_id({:gossip, nil, nil}) end
    assert_raise FunctionClauseError, fn -> Gossip.current_id({:gossip, nil, nil, nil}) end
  end

  test "current_id() get" do
    g = Gossip.new(NetID.new({127,0,0,1}, 29999), [])
    id = Gossip.current_id(g)
    assert BroadcastID.valid?(id)
    nid = BroadcastID.origin(id)
    assert nid == NetID.new({127,0,0,1}, 29999)
  end

  # seen_ids
  test "seen_ids() throws on invalid input" do
    assert_raise FunctionClauseError, fn -> Gossip.seen_ids(nil) end
    assert_raise FunctionClauseError, fn -> Gossip.seen_ids([]) end
    assert_raise FunctionClauseError, fn -> Gossip.seen_ids({}) end
    assert_raise FunctionClauseError, fn -> Gossip.seen_ids({:ok}) end
    assert_raise FunctionClauseError, fn -> Gossip.seen_ids({:ok, nil}) end
    assert_raise FunctionClauseError, fn -> Gossip.seen_ids({:ok, nil, nil}) end
    assert_raise FunctionClauseError, fn -> Gossip.seen_ids({:broadcast_id, nil}) end
    assert_raise FunctionClauseError, fn -> Gossip.seen_ids({:broadcast_id, nil, nil}) end
    assert_raise FunctionClauseError, fn -> Gossip.seen_ids({:broadcast_id, nil, nil, nil}) end

    g = Gossip.new(NetID.new({127,0,0,1}, 29999), [])
    assert_raise FunctionClauseError, fn -> Gossip.seen_ids(nil, nil) end
    assert_raise FunctionClauseError, fn -> Gossip.seen_ids(g, nil) end
    assert_raise FunctionClauseError, fn -> Gossip.seen_ids(g, {}) end
    assert_raise FunctionClauseError, fn -> Gossip.seen_ids(g, {:ok}) end
    assert_raise FunctionClauseError, fn -> Gossip.seen_ids(g, [{:ok}]) end
  end

  test "seen_ids() get and set" do
    g = Gossip.new(NetID.new({127,0,0,1}, 29999), [])
    id1 = BroadcastID.new(NetID.new({127,0,0,1}, 29998))
    id2 = BroadcastID.new(NetID.new({127,0,0,1}, 29997))
    g2 = g |> Gossip.seen_ids([id1, id2])
    assert [] == g |> Gossip.seen_ids
    assert [id1, id2] == g2 |> Gossip.seen_ids
  end

  # distribution_list
  test "distribution_list() throws on invalid input" do
    assert_raise FunctionClauseError, fn -> Gossip.distribution_list(nil) end
    assert_raise FunctionClauseError, fn -> Gossip.distribution_list([]) end
    assert_raise FunctionClauseError, fn -> Gossip.distribution_list({}) end
    assert_raise FunctionClauseError, fn -> Gossip.distribution_list({:ok}) end
    assert_raise FunctionClauseError, fn -> Gossip.distribution_list({:ok, nil}) end
    assert_raise FunctionClauseError, fn -> Gossip.distribution_list({:ok, nil, nil}) end
    assert_raise FunctionClauseError, fn -> Gossip.distribution_list({:broadcast_id, nil}) end
    assert_raise FunctionClauseError, fn -> Gossip.distribution_list({:broadcast_id, nil, nil}) end
    assert_raise FunctionClauseError, fn -> Gossip.distribution_list({:broadcast_id, nil, nil, nil}) end

    g = Gossip.new(NetID.new({127,0,0,1}, 29999), [])
    assert_raise FunctionClauseError, fn -> Gossip.distribution_list(nil, nil) end
    assert_raise FunctionClauseError, fn -> Gossip.distribution_list(g, nil) end
    assert_raise FunctionClauseError, fn -> Gossip.distribution_list(g, {}) end
    assert_raise FunctionClauseError, fn -> Gossip.distribution_list(g, {:ok}) end
    assert_raise FunctionClauseError, fn -> Gossip.distribution_list(g, [{:ok}]) end
  end

  test "distribution_list() get and set" do
    g = Gossip.new(NetID.new({127,0,0,1}, 29999), [])
    id1 = NetID.new({127,0,0,1}, 29998)
    id2 = NetID.new({127,0,0,1}, 29997)
    g2 = g |> Gossip.distribution_list([id1, id2])
    assert [] == g |> Gossip.distribution_list
    assert [id1, id2] == g2 |> Gossip.distribution_list
  end

  # remove_from_distribution_list
  # seen_netids
  # add_to_distribution_list
end
