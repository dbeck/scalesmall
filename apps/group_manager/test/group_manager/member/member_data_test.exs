defmodule GroupManager.Member.MemberDataTest do

  use ExUnit.Case
  alias GroupManager.Member.MemberData
  alias GroupManager.Chatter.NetID

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
  # remove
  # members
end
