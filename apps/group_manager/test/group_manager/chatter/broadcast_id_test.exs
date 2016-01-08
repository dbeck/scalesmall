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

  # origin
  test "origin() throws on invalid input" do
    assert_raise FunctionClauseError, fn -> BroadcastID.origin(nil) end
    assert_raise FunctionClauseError, fn -> BroadcastID.origin([]) end
    assert_raise FunctionClauseError, fn -> BroadcastID.origin({}) end
    assert_raise FunctionClauseError, fn -> BroadcastID.origin({:ok}) end
    assert_raise FunctionClauseError, fn -> BroadcastID.origin({:ok, nil}) end
    assert_raise FunctionClauseError, fn -> BroadcastID.origin({:ok, nil, nil}) end
    assert_raise FunctionClauseError, fn -> BroadcastID.origin({:broadcast_id, nil}) end
    assert_raise FunctionClauseError, fn -> BroadcastID.origin({:broadcast_id, nil, nil}) end
    assert_raise FunctionClauseError, fn -> BroadcastID.origin({:broadcast_id, nil, nil, nil}) end

    id = BroadcastID.new(NetID.new({127,0,0,1}, 29999))
    assert_raise FunctionClauseError, fn -> BroadcastID.origin(nil, nil) end
    assert_raise FunctionClauseError, fn -> BroadcastID.origin(id, nil) end
    assert_raise FunctionClauseError, fn -> BroadcastID.origin(id, []) end
    assert_raise FunctionClauseError, fn -> BroadcastID.origin(id, {}) end
    assert_raise FunctionClauseError, fn -> BroadcastID.origin(id, {:ok}) end
    assert_raise FunctionClauseError, fn -> BroadcastID.origin(id, {:ok, nil}) end
    assert_raise FunctionClauseError, fn -> BroadcastID.origin(id, {:ok, nil, nil}) end
    assert_raise FunctionClauseError, fn -> BroadcastID.origin(id, {:net_id, nil}) end
    assert_raise FunctionClauseError, fn -> BroadcastID.origin(id, {:net_id, nil, nil}) end
    assert_raise FunctionClauseError, fn -> BroadcastID.origin(id, {:net_id, nil, nil, nil}) end
  end

  test "origin() get and set" do
    id = BroadcastID.new(NetID.new({127,0,0,1}, 29999))
    nid = NetID.new({127,0,0,1}, 29998)
    v = id |> BroadcastID.origin(nid)
    assert id != v
    assert nid == BroadcastID.origin(v)
  end

  # seqno
  test "seqno() throws on invalid input" do
    assert_raise FunctionClauseError, fn -> BroadcastID.seqno(nil) end
    assert_raise FunctionClauseError, fn -> BroadcastID.seqno([]) end
    assert_raise FunctionClauseError, fn -> BroadcastID.seqno({}) end
    assert_raise FunctionClauseError, fn -> BroadcastID.seqno({:ok}) end
    assert_raise FunctionClauseError, fn -> BroadcastID.seqno({:ok, nil}) end
    assert_raise FunctionClauseError, fn -> BroadcastID.seqno({:ok, nil, nil}) end
    assert_raise FunctionClauseError, fn -> BroadcastID.seqno({:broadcast_id, nil}) end
    assert_raise FunctionClauseError, fn -> BroadcastID.seqno({:broadcast_id, nil, nil}) end
    assert_raise FunctionClauseError, fn -> BroadcastID.seqno({:broadcast_id, nil, nil, nil}) end

    id = BroadcastID.new(NetID.new({127,0,0,1}, 29999))
    assert_raise FunctionClauseError, fn -> BroadcastID.seqno(nil, nil) end
    assert_raise FunctionClauseError, fn -> BroadcastID.seqno(id, nil) end
    assert_raise FunctionClauseError, fn -> BroadcastID.seqno(id, []) end
    assert_raise FunctionClauseError, fn -> BroadcastID.seqno(id, {}) end
    assert_raise FunctionClauseError, fn -> BroadcastID.seqno(id, {:ok}) end
    assert_raise FunctionClauseError, fn -> BroadcastID.seqno(id, {:ok, nil}) end
    assert_raise FunctionClauseError, fn -> BroadcastID.seqno(id, {:ok, nil, nil}) end
    assert_raise FunctionClauseError, fn -> BroadcastID.seqno(id, {:net_id, nil}) end
    assert_raise FunctionClauseError, fn -> BroadcastID.seqno(id, {:net_id, nil, nil}) end
    assert_raise FunctionClauseError, fn -> BroadcastID.seqno(id, {:net_id, nil, nil, nil}) end
  end

  test "seqno() get and set" do
    id = BroadcastID.new(NetID.new({127,0,0,1}, 29999))
    v = id |> BroadcastID.seqno(111)
    assert id != v
    assert 111 == BroadcastID.seqno(v)
  end

  # validate_list!
  test "validate_list!() throws on invalid input" do
    assert_raise FunctionClauseError, fn -> BroadcastID.validate_list!(nil) end
    assert_raise FunctionClauseError, fn -> BroadcastID.validate_list!({}) end
    assert_raise FunctionClauseError, fn -> BroadcastID.validate_list!({:ok}) end
    assert_raise FunctionClauseError, fn -> BroadcastID.validate_list!({:ok, nil}) end
    assert_raise FunctionClauseError, fn -> BroadcastID.validate_list!({:ok, nil, nil}) end
    assert_raise FunctionClauseError, fn -> BroadcastID.validate_list!({:broadcast_id, nil}) end
    assert_raise FunctionClauseError, fn -> BroadcastID.validate_list!({:broadcast_id, nil, nil}) end
    assert_raise FunctionClauseError, fn -> BroadcastID.validate_list!({:broadcast_id, nil, nil, nil}) end

    assert_raise FunctionClauseError, fn -> BroadcastID.validate_list!([{}]) end
    assert_raise FunctionClauseError, fn -> BroadcastID.validate_list!([{:ok}]) end
    assert_raise FunctionClauseError, fn -> BroadcastID.validate_list!([{:ok, nil}]) end
    assert_raise FunctionClauseError, fn -> BroadcastID.validate_list!([{:ok, nil, nil}]) end
    assert_raise FunctionClauseError, fn -> BroadcastID.validate_list!([{:broadcast_id, nil}]) end
    assert_raise FunctionClauseError, fn -> BroadcastID.validate_list!([{:broadcast_id, nil, nil}]) end
    assert_raise FunctionClauseError, fn -> BroadcastID.validate_list!([{:broadcast_id, nil, nil, nil}]) end
  end

  test "validate_list!([]) is :ok" do
    assert :ok == BroadcastID.validate_list!([])
  end

  # merge_lists
  test "merge_lists() throws on invalid input" do
    id = BroadcastID.new(NetID.new({127,0,0,1}, 29999))

    assert_raise FunctionClauseError, fn -> BroadcastID.merge_lists([{}], [id]) end
    assert_raise FunctionClauseError, fn -> BroadcastID.merge_lists([{:ok}], [id]) end
    assert_raise FunctionClauseError, fn -> BroadcastID.merge_lists([{:ok, nil}], [id]) end
    assert_raise FunctionClauseError, fn -> BroadcastID.merge_lists([{:ok, nil, nil}], [id]) end
    assert_raise FunctionClauseError, fn -> BroadcastID.merge_lists([{:broadcast_id, nil}], [id]) end
    assert_raise FunctionClauseError, fn -> BroadcastID.merge_lists([{:broadcast_id, nil, nil}], [id]) end
    assert_raise FunctionClauseError, fn -> BroadcastID.merge_lists([{:broadcast_id, nil, nil, nil}], [id]) end

    assert_raise FunctionClauseError, fn -> BroadcastID.merge_lists([id], [{}]) end
    assert_raise FunctionClauseError, fn -> BroadcastID.merge_lists([id], [{:ok}]) end
    assert_raise FunctionClauseError, fn -> BroadcastID.merge_lists([id], [{:ok, nil}]) end
    assert_raise FunctionClauseError, fn -> BroadcastID.merge_lists([id], [{:ok, nil, nil}]) end
    assert_raise FunctionClauseError, fn -> BroadcastID.merge_lists([id], [{:broadcast_id, nil}]) end
    assert_raise FunctionClauseError, fn -> BroadcastID.merge_lists([id], [{:broadcast_id, nil, nil}]) end
    assert_raise FunctionClauseError, fn -> BroadcastID.merge_lists([id], [{:broadcast_id, nil, nil, nil}]) end
  end

  test "merge_list([], []) is []" do
    assert [] == BroadcastID.merge_lists([], [])
  end

  test "merge_list([x], []) is [x]" do
    id = BroadcastID.new(NetID.new({127,0,0,1}, 29999))
    assert [id] == BroadcastID.merge_lists([id], [])
  end

  test "merge_list([], [x]) is [x]" do
    id = BroadcastID.new(NetID.new({127,0,0,1}, 29999))
    assert [id] == BroadcastID.merge_lists([], [id])
  end

  test "merge_list([x], [x]) is [x]" do
    id = BroadcastID.new(NetID.new({127,0,0,1}, 29999))
    assert [id] == BroadcastID.merge_lists([id], [id])
  end

  test "merge_list([x, x], [x, x]) is [x]" do
    id = BroadcastID.new(NetID.new({127,0,0,1}, 29999))
    assert [id] == BroadcastID.merge_lists([id, id], [id, id])
  end

  test "merge_list([x, x+1], [x, x]) is [x+1]" do
    id = BroadcastID.new(NetID.new({127,0,0,1}, 29999))
    id2 = id |> BroadcastID.seqno( BroadcastID.seqno(id) + 1)
    assert id != id2
    assert [^id2] = BroadcastID.merge_lists([id, id2], [id, id])
    assert (BroadcastID.seqno(id) + 1) == BroadcastID.seqno(id2)
  end

  # inc_seqno
  test "inc_seqno() throws on invalid input" do
    assert_raise FunctionClauseError, fn -> BroadcastID.seqno(nil) end
    assert_raise FunctionClauseError, fn -> BroadcastID.seqno([]) end
    assert_raise FunctionClauseError, fn -> BroadcastID.seqno({}) end
    assert_raise FunctionClauseError, fn -> BroadcastID.seqno({:ok}) end
    assert_raise FunctionClauseError, fn -> BroadcastID.seqno({:ok, nil}) end
    assert_raise FunctionClauseError, fn -> BroadcastID.seqno({:ok, nil, nil}) end
    assert_raise FunctionClauseError, fn -> BroadcastID.seqno({:broadcast_id, nil}) end
    assert_raise FunctionClauseError, fn -> BroadcastID.seqno({:broadcast_id, nil, nil}) end
    assert_raise FunctionClauseError, fn -> BroadcastID.seqno({:broadcast_id, nil, nil, nil}) end
  end

  test "inc_seqno() bumps the sequence number" do
    id = BroadcastID.new(NetID.new({127,0,0,1}, 29999))
    id2 = BroadcastID.inc_seqno(id)
    assert (BroadcastID.seqno(id)+1) == BroadcastID.seqno(id2)
  end

  # validate_list
  test "validate_list() returns :error on invalid input" do
    assert :error = BroadcastID.validate_list({})
    assert :error = BroadcastID.validate_list({:ok})
    assert :error = BroadcastID.validate_list({:ok, nil})
    assert :error = BroadcastID.validate_list({:ok, nil, nil})
    assert :error = BroadcastID.validate_list({:broadcast_id, nil})
    assert :error = BroadcastID.validate_list({:broadcast_id, nil, nil})
    assert :error = BroadcastID.validate_list({:broadcast_id, nil, nil, nil})

    assert :error = BroadcastID.validate_list([{}])
    assert :error = BroadcastID.validate_list([{:ok}])
    assert :error = BroadcastID.validate_list([{:ok, nil}])
    assert :error = BroadcastID.validate_list([{:ok, nil, nil}])
    assert :error = BroadcastID.validate_list([{:broadcast_id, nil}])
    assert :error = BroadcastID.validate_list([{:broadcast_id, nil, nil}])
    assert :error = BroadcastID.validate_list([{:broadcast_id, nil, nil, nil}])
  end

  test "validate_list([]) is :ok" do
    assert :ok == BroadcastID.validate_list([])
  end

  # current_id
  # new(netid, seqno)
end
