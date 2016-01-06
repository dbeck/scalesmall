defmodule GroupManager.Chatter.PeerDataTest do

  use ExUnit.Case
  alias GroupManager.Chatter.PeerData
  alias GroupManager.Chatter.NetID
  alias GroupManager.Chatter.BroadcastID

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

  # broadcast_seqno
  test "broadcast_seqno() throws on invalid input" do
    assert_raise FunctionClauseError, fn -> PeerData.broadcast_seqno(nil) end
    assert_raise FunctionClauseError, fn -> PeerData.broadcast_seqno([]) end
    assert_raise FunctionClauseError, fn -> PeerData.broadcast_seqno({}) end
    assert_raise FunctionClauseError, fn -> PeerData.broadcast_seqno({:ok}) end
    assert_raise FunctionClauseError, fn -> PeerData.broadcast_seqno({:ok, nil}) end
    assert_raise FunctionClauseError, fn -> PeerData.broadcast_seqno({:ok, nil, nil}) end
    assert_raise FunctionClauseError, fn -> PeerData.broadcast_seqno({:peer_data, nil}) end
    assert_raise FunctionClauseError, fn -> PeerData.broadcast_seqno({:peer_data, nil, nil}) end
    assert_raise FunctionClauseError, fn -> PeerData.broadcast_seqno({:peer_data, nil, nil, nil}) end

    d = PeerData.new(NetID.new({127,0,0,1}, 29999))
    assert_raise FunctionClauseError, fn -> PeerData.broadcast_seqno(nil, nil) end
    assert_raise FunctionClauseError, fn -> PeerData.broadcast_seqno(d, nil) end
    assert_raise FunctionClauseError, fn -> PeerData.broadcast_seqno(d, []) end
    assert_raise FunctionClauseError, fn -> PeerData.broadcast_seqno(d, {}) end
    assert_raise FunctionClauseError, fn -> PeerData.broadcast_seqno(d, {:ok}) end
    assert_raise FunctionClauseError, fn -> PeerData.broadcast_seqno(d, {:ok, nil}) end
    assert_raise FunctionClauseError, fn -> PeerData.broadcast_seqno(d, {:ok, nil, nil}) end
    assert_raise FunctionClauseError, fn -> PeerData.broadcast_seqno(d, {:peer_data, nil}) end
    assert_raise FunctionClauseError, fn -> PeerData.broadcast_seqno(d, {:peer_data, nil, nil}) end
    assert_raise FunctionClauseError, fn -> PeerData.broadcast_seqno(d, {:peer_data, nil, nil, nil}) end
  end

  test "broadcast_seqno() get and set" do
    d = PeerData.new(NetID.new({127,0,0,1}, 29999))
    v = d |> PeerData.broadcast_seqno(111)
    assert d != v
    assert 111 == PeerData.broadcast_seqno(v)
  end

  # max_broadcast_seqno
  test "max_broadcast_seqno() throws on invalid input" do
    assert_raise FunctionClauseError, fn -> PeerData.broadcast_seqno(nil, 1) end
    assert_raise FunctionClauseError, fn -> PeerData.broadcast_seqno([], 1) end
    assert_raise FunctionClauseError, fn -> PeerData.broadcast_seqno({}, 1) end
    assert_raise FunctionClauseError, fn -> PeerData.broadcast_seqno({:ok}, 1) end
    assert_raise FunctionClauseError, fn -> PeerData.broadcast_seqno({:ok, nil}, 1) end
    assert_raise FunctionClauseError, fn -> PeerData.broadcast_seqno({:ok, nil, nil}, 1) end
    assert_raise FunctionClauseError, fn -> PeerData.broadcast_seqno({:peer_data, nil}, 1) end
    assert_raise FunctionClauseError, fn -> PeerData.broadcast_seqno({:peer_data, nil, nil}, 1) end
    assert_raise FunctionClauseError, fn -> PeerData.broadcast_seqno({:peer_data, nil, nil, nil}, 1) end

    d = PeerData.new(NetID.new({127,0,0,1}, 29999))
    assert_raise FunctionClauseError, fn -> PeerData.broadcast_seqno(nil, nil) end
    assert_raise FunctionClauseError, fn -> PeerData.broadcast_seqno(d, nil) end
    assert_raise FunctionClauseError, fn -> PeerData.broadcast_seqno(d, []) end
    assert_raise FunctionClauseError, fn -> PeerData.broadcast_seqno(d, {}) end
    assert_raise FunctionClauseError, fn -> PeerData.broadcast_seqno(d, {:ok}) end
    assert_raise FunctionClauseError, fn -> PeerData.broadcast_seqno(d, {:ok, nil}) end
    assert_raise FunctionClauseError, fn -> PeerData.broadcast_seqno(d, {:ok, nil, nil}) end
    assert_raise FunctionClauseError, fn -> PeerData.broadcast_seqno(d, {:peer_data, nil}) end
    assert_raise FunctionClauseError, fn -> PeerData.broadcast_seqno(d, {:peer_data, nil, nil}) end
    assert_raise FunctionClauseError, fn -> PeerData.broadcast_seqno(d, {:peer_data, nil, nil, nil}) end
  end

  test "max_broadcast_seqno() updates to max" do
    d = PeerData.new(NetID.new({127,0,0,1}, 29999))
    min = d |> PeerData.broadcast_seqno(100)
    max = d |> PeerData.broadcast_seqno(999)
    assert 100 == PeerData.broadcast_seqno(min)
    assert 999 == PeerData.broadcast_seqno(max)

    # min plus min -> min
    assert 100 == min |> PeerData.max_broadcast_seqno(100) |> PeerData.broadcast_seqno

    # max plus min -> max
    assert 999 == max |> PeerData.max_broadcast_seqno(100) |> PeerData.broadcast_seqno

    # min plus max -> max
    assert 999 == min |> PeerData.max_broadcast_seqno(999) |> PeerData.broadcast_seqno
  end

  # seen_ids
  test "seen_ids() throws on invalid input" do
    assert_raise FunctionClauseError, fn -> PeerData.seen_ids(nil) end
    assert_raise FunctionClauseError, fn -> PeerData.seen_ids([]) end
    assert_raise FunctionClauseError, fn -> PeerData.seen_ids({}) end
    assert_raise FunctionClauseError, fn -> PeerData.seen_ids({:ok}) end
    assert_raise FunctionClauseError, fn -> PeerData.seen_ids({:ok, nil}) end
    assert_raise FunctionClauseError, fn -> PeerData.seen_ids({:ok, nil, nil}) end
    assert_raise FunctionClauseError, fn -> PeerData.seen_ids({:peer_data, nil}) end
    assert_raise FunctionClauseError, fn -> PeerData.seen_ids({:peer_data, nil, nil}) end
    assert_raise FunctionClauseError, fn -> PeerData.seen_ids({:peer_data, nil, nil, nil}) end
  end

  # merge_seen_ids
  test "merge_seen_ids() throws on invalid input" do
    assert_raise FunctionClauseError, fn -> PeerData.merge_seen_ids(nil, 1) end
    assert_raise FunctionClauseError, fn -> PeerData.merge_seen_ids([], 1) end
    assert_raise FunctionClauseError, fn -> PeerData.merge_seen_ids({}, 1) end
    assert_raise FunctionClauseError, fn -> PeerData.merge_seen_ids({:ok}, 1) end
    assert_raise FunctionClauseError, fn -> PeerData.merge_seen_ids({:ok, nil}, 1) end
    assert_raise FunctionClauseError, fn -> PeerData.merge_seen_ids({:ok, nil, nil}, 1) end
    assert_raise FunctionClauseError, fn -> PeerData.merge_seen_ids({:peer_data, nil}, 1) end
    assert_raise FunctionClauseError, fn -> PeerData.merge_seen_ids({:peer_data, nil, nil}, 1) end
    assert_raise FunctionClauseError, fn -> PeerData.merge_seen_ids({:peer_data, nil, nil, nil}, 1) end

    d = PeerData.new(NetID.new({127,0,0,1}, 29999))
    assert_raise FunctionClauseError, fn -> PeerData.merge_seen_ids(nil, nil) end
    assert_raise FunctionClauseError, fn -> PeerData.merge_seen_ids(d, nil) end
    assert_raise FunctionClauseError, fn -> PeerData.merge_seen_ids(d, {}) end
    assert_raise FunctionClauseError, fn -> PeerData.merge_seen_ids(d, {:ok}) end
    assert_raise FunctionClauseError, fn -> PeerData.merge_seen_ids(d, {:ok, nil}) end
    assert_raise FunctionClauseError, fn -> PeerData.merge_seen_ids(d, {:ok, nil, nil}) end
    assert_raise FunctionClauseError, fn -> PeerData.merge_seen_ids(d, {:peer_data, nil}) end
    assert_raise FunctionClauseError, fn -> PeerData.merge_seen_ids(d, {:peer_data, nil, nil}) end
    assert_raise FunctionClauseError, fn -> PeerData.merge_seen_ids(d, {:peer_data, nil, nil, nil}) end
  end

  test "merge empty list" do
    d = PeerData.new(NetID.new({127,0,0,1}, 29999))
    assert [] == PeerData.seen_ids(d)
    assert [] == PeerData.merge_seen_ids(d, []) |> PeerData.seen_ids
  end

  test "merge non empty list" do
    d = PeerData.new(NetID.new({127,0,0,1}, 29999))
    id = BroadcastID.new(NetID.new({127,0,0,1}, 29999))
    assert [] == PeerData.seen_ids(d)
    assert [id] == PeerData.merge_seen_ids(d, [id]) |> PeerData.seen_ids
  end

  test "merge picks the larger seqno" do
    d   = PeerData.new(NetID.new({127,0,0,1}, 29999))
    id  = BroadcastID.new(NetID.new({127,0,0,1}, 29999))
    id2 = id |> BroadcastID.seqno(BroadcastID.seqno(id)+1)
    dl  = d |> PeerData.merge_seen_ids([id])
    dl2 = dl |> PeerData.merge_seen_ids([id2])

    assert [] == PeerData.seen_ids(d)
    assert [id] == PeerData.seen_ids(dl)
    assert [id2] == PeerData.seen_ids(dl2)
  end

  # inc_broadcast_seqno
end
