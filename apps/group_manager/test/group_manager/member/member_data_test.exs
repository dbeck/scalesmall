defmodule GroupManager.Member.MemberDataTest do

  use ExUnit.Case
  alias GroupManager.Member.MemberData
  alias GroupManager.Chatter.NetID

  defp dummy_netid do
    NetID.new({1,2,3,4},1)
  end

  defp dummy_other do
    NetID.new({2,3,4,5},6)
  end

  # new
  test "basic test for new" do
    assert MemberData.valid?(MemberData.new("mygroup"))
  end

  test "new() doesn't accept invalid groupnames" do
  	assert_raise FunctionClauseError, fn -> MemberData.new(nil) end
  	assert_raise FunctionClauseError, fn -> MemberData.new(:ok) end
  	assert_raise FunctionClauseError, fn -> MemberData.new([]) end
 	assert_raise FunctionClauseError, fn -> MemberData.new({}) end
 	assert_raise FunctionClauseError, fn -> MemberData.new(<<>>) end
  end

  # valid?
  test "valid?() returns false for invalid MemberData objects" do
  	assert false == MemberData.valid?(nil)
  	assert false == MemberData.valid?(:ok)
  	assert false == MemberData.valid?(true)
  	assert false == MemberData.valid?({:member_data})
  	assert false == MemberData.valid?({:member_data, nil})
  	assert false == MemberData.valid?({:member_data, nil, nil})
  	assert false == MemberData.valid?({:member_data, nil, nil, nil})
  end

  # add
  test "can add() new elements" do
    assert [] == MemberData.new("test") |>
                 MemberData.members
    dta = MemberData.new("test") |>
          MemberData.add(dummy_netid)
    assert [dummy_netid] == MemberData.members(dta)
  end

  test "add() returns valid member data" do
    assert MemberData.new("test") |>
           MemberData.add(dummy_netid) |>
           MemberData.valid?
  end

  # remove
  test "remove() returns valid member data" do
    assert MemberData.new("test") |>
           MemberData.remove(dummy_netid) |>
           MemberData.valid?
  end

  test "remove() from an empty MemberData results an empty list" do
    assert [] == MemberData.new("test") |>
                 MemberData.remove(dummy_netid) |>
                 MemberData.members

  end

  test "remove() one element" do
    assert [] == MemberData.new("test") |>
                 MemberData.add(dummy_netid) |>
                 MemberData.remove(dummy_netid) |>
                 MemberData.members
  end

  test "add() one and remove a nonexitant element" do
    assert [dummy_netid] == MemberData.new("test") |>
                            MemberData.add(dummy_netid) |>
                            MemberData.remove(dummy_other) |>
                            MemberData.members
  end

  test "add() two members and remove them" do
    dta = MemberData.new("test") |>
          MemberData.add(dummy_other) |>
          MemberData.add(dummy_netid)
    assert [dummy_netid] == dta |>
                            MemberData.remove(dummy_other) |>
                            MemberData.members
    assert [dummy_other] == dta |>
                            MemberData.remove(dummy_netid) |>
                            MemberData.members
  end

  # add to invalid obj
  # remove from invalid obj
  # members of an invalid obj
end
