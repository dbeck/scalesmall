defmodule GroupManager.Chatter.PeerDBTest do
  use ExUnit.Case
  alias GroupManager.Chatter.PeerDB
  alias GroupManager.Chatter.NetID
  alias GroupManager.Chatter.BroadcastID
  alias GroupManager.Chatter.PeerData

  test "locate PeerDB" do
    pid = PeerDB.locate
    assert is_pid(pid)
  end

  test "cannot add() invalid " do
    pid = PeerDB.locate
    assert_raise FunctionClauseError, fn -> PeerDB.add(pid, nil) end
  end

  test "can add() valid NetID" do
    pid = PeerDB.locate
    id = NetID.new({127,0,0,1}, 29999)
    assert :ok == PeerDB.add(pid, id)
  end

  test "can add() and get() valid NetID" do
    pid = PeerDB.locate
    id = NetID.new({127,0,0,1}, 29999)
    assert :ok == PeerDB.add(pid, id)
    # {:ok, {:peer_data, {:net_id, {127, 0, 0, 1}, 29999}, 0, [], nil, nil}}
    assert {:ok, _} = PeerDB.get(pid, id)
  end

  test "get() raises on invalid id" do
    pid = PeerDB.locate
    assert_raise FunctionClauseError, fn -> PeerDB.get(pid, nil) end
    assert_raise FunctionClauseError, fn -> PeerDB.get(pid, []) end
    assert_raise FunctionClauseError, fn -> PeerDB.get(pid, {}) end
  end

  # add_seen_id
  test "add_seen_id() raises on invalid id" do
    pid = PeerDB.locate
    assert_raise FunctionClauseError, fn -> PeerDB.add_seen_id(pid, nil, nil) end
    assert_raise FunctionClauseError, fn -> PeerDB.add_seen_id(pid, :ok, {}) end
  end

  # add_seen_id_list
  test "add_seen_id_list() raises on invalid id" do
    pid = PeerDB.locate
    assert_raise FunctionClauseError, fn -> PeerDB.add_seen_id_list(pid, nil, nil) end
    assert_raise FunctionClauseError, fn -> PeerDB.add_seen_id_list(pid, :ok, []) end
  end

  test "add_seen_id_list() adds ids" do
    pid  = PeerDB.locate
    id1  = BroadcastID.new(NetID.new({127,0,0,1}, 29991))
    id2  = BroadcastID.new(NetID.new({127,0,0,1}, 29992))
    id3  = BroadcastID.new(NetID.new({127,0,0,1}, 29993))
    id4  = BroadcastID.new(NetID.new({127,0,0,1}, 29994))
    PeerDB.add_seen_id_list(pid, id1, [id2, id3, id4])
    assert {:ok, _} = PeerDB.get(pid, BroadcastID.origin(id1))
    id1  = BroadcastID.inc_seqno(id1)
    id2  = BroadcastID.inc_seqno(id2)
    id3  = BroadcastID.inc_seqno(id3)
    id4  = BroadcastID.inc_seqno(id4)
    PeerDB.add_seen_id_list(pid, id1, [id2, id3, id4])
    assert {:ok, new_peer_data} = PeerDB.get(pid, BroadcastID.origin(id1))
    check_id = fn(list, id) ->
      List.foldl(list, nil, fn(x, acc) ->
        case x do
          ^id -> id
          _ -> acc
        end
      end)
    end

    assert id2 == check_id.(PeerData.seen_ids(new_peer_data), id2)
    assert id3 == check_id.(PeerData.seen_ids(new_peer_data), id3)
    assert id4 == check_id.(PeerData.seen_ids(new_peer_data), id4)
    assert PeerData.id(new_peer_data) == BroadcastID.origin(id1)
    assert PeerData.broadcast_seqno(new_peer_data) == BroadcastID.seqno(id1)
  end

  # get_
  # get_seen_id_list_
end
