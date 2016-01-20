defmodule GroupManager.MemberDBTest do

  use ExUnit.Case
  alias GroupManager.MemberDB
  alias GroupManager.Chatter.NetID
  alias GroupManager.Member.MemberData

  test "locate MemberDB" do
    pid = MemberDB.locate
    assert is_pid(pid)
  end

  test "cannot add() invalid" do
    pid = MemberDB.locate
    assert_raise FunctionClauseError, fn -> MemberDB.add(pid, nil, nil) end
    assert_raise FunctionClauseError, fn -> MemberDB.add(pid, <<>>, nil) end
  end

  test "can add() and members()/members_() valid NetID" do
    pid = MemberDB.locate
    id = NetID.new({127,0,0,1}, 29919)
    group = "test-only"
    assert :ok == MemberDB.add(pid, group, id)
    # {:ok, [{:net_id, {127, 0, 0, 1}, 29919}]}
    assert {:ok, [id]} == MemberDB.members(pid, group)
    assert {:ok, [id]} == MemberDB.members_(group)
  end

  test "can add(), remove() and query members()/members_() w/ valid NetID" do
    pid = MemberDB.locate
    id = NetID.new({127,0,0,1}, 29929)
    group = "test-only2"
    assert :ok == MemberDB.add(pid, group, id)
    assert {:ok, [id]} == MemberDB.members(pid, group)
    assert :ok == MemberDB.remove(pid, group, id)
    assert {:ok, []} == MemberDB.members(pid, group)
  end

  # add
  test "add() throws on invalid input" do
    pid = MemberDB.locate
    id = NetID.new({127,0,0,1}, 29951)

    assert_raise FunctionClauseError, fn -> MemberDB.add(pid, nil, id) end
    assert_raise FunctionClauseError, fn -> MemberDB.add(pid, [], id) end
    assert_raise FunctionClauseError, fn -> MemberDB.add(pid, {}, id) end
    assert_raise FunctionClauseError, fn -> MemberDB.add(pid, "test-only4", nil) end
    assert_raise FunctionClauseError, fn -> MemberDB.add(pid, "test-only4", []) end
    assert_raise FunctionClauseError, fn -> MemberDB.add(pid, "test-only4", {}) end

    assert_raise FunctionClauseError, fn -> MemberDB.add(nil, "test-only4", id) end
    assert_raise FunctionClauseError, fn -> MemberDB.add([], "test-only4", id) end
    assert_raise FunctionClauseError, fn -> MemberDB.add({}, "test-only4", id) end
  end

  # remove
  test "remove() throws on invalid input" do
    pid = MemberDB.locate
    id = NetID.new({127,0,0,1}, 29951)

    assert_raise FunctionClauseError, fn -> MemberDB.remove(pid, nil, id) end
    assert_raise FunctionClauseError, fn -> MemberDB.remove(pid, [], id) end
    assert_raise FunctionClauseError, fn -> MemberDB.remove(pid, {}, id) end
    assert_raise FunctionClauseError, fn -> MemberDB.remove(pid, "test-only3", nil) end
    assert_raise FunctionClauseError, fn -> MemberDB.remove(pid, "test-only3", []) end
    assert_raise FunctionClauseError, fn -> MemberDB.remove(pid, "test-only3", {}) end

    assert_raise FunctionClauseError, fn -> MemberDB.remove(nil, "test-only3", id) end
    assert_raise FunctionClauseError, fn -> MemberDB.remove([], "test-only3", id) end
    assert_raise FunctionClauseError, fn -> MemberDB.remove({}, "test-only3", id) end
  end

  # members
  test "members() throws on invalid input" do
    pid = MemberDB.locate
    assert_raise FunctionClauseError, fn -> MemberDB.members(pid, nil) end
    assert_raise FunctionClauseError, fn -> MemberDB.members(pid, []) end
    assert_raise FunctionClauseError, fn -> MemberDB.members(pid, {}) end
    id = NetID.new({127,0,0,1}, 29951)

    assert_raise FunctionClauseError, fn -> MemberDB.members(nil, id) end
    assert_raise FunctionClauseError, fn -> MemberDB.members([], id) end
    assert_raise FunctionClauseError, fn -> MemberDB.members({}, id) end
  end

  # members_
  test "members_() throws on invalid input" do
    assert_raise FunctionClauseError, fn -> MemberDB.members_(nil) end
    assert_raise FunctionClauseError, fn -> MemberDB.members_([]) end
    assert_raise FunctionClauseError, fn -> MemberDB.members_({}) end
  end

  # start w/ different name
end
