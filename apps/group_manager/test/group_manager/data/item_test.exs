defmodule GroupManager.Data.ItemTest do

  use ExUnit.Case
  alias GroupManager.Data.Item
  alias Chatter.NetID

  defp dummy_netid do
    NetID.new({1,2,3,4},1)
  end

  test "basic test for new" do
    assert Item.valid?(Item.new(dummy_netid))
  end

  test "basic test for invalid input" do
    assert Item.valid?(nil) == false
    assert Item.valid?([]) == false
    assert Item.valid?({}) == false
    assert Item.valid?(:ok) == false
    assert Item.valid?({:ok}) == false
    assert Item.valid?({:item}) == false
    assert Item.valid?({:item, nil}) == false
    assert Item.valid?({:item, nil, nil}) == false
    assert Item.valid?({:item, nil, nil, nil}) == false
    assert Item.valid?({:item, nil, nil, nil, nil}) == false
    assert Item.valid?({:item, nil, nil, nil, nil, nil}) == false
    assert Item.valid?({:item, nil, nil, nil, nil, nil, nil}) == false
  end

  test "member property can be retrieved" do
    assert dummy_netid == Item.new(dummy_netid) |> Item.member
  end

  test "cannot get member from an invalid Item" do
    assert_raise FunctionClauseError, fn -> Item.member(:ok) end
    assert_raise FunctionClauseError, fn -> Item.member([]) end
    assert_raise FunctionClauseError, fn -> Item.member({}) end
    assert_raise FunctionClauseError, fn -> Item.member({:ok}) end
    assert_raise FunctionClauseError, fn -> Item.member({:item}) end
    assert_raise FunctionClauseError, fn -> Item.member({:item, nil}) end
    assert_raise FunctionClauseError, fn -> Item.member({:item, nil, nil}) end
    assert_raise FunctionClauseError, fn -> Item.member({:item, nil, nil, nil}) end
    assert_raise FunctionClauseError, fn -> Item.member({:item, nil, nil, nil, nil}) end
    assert_raise FunctionClauseError, fn -> Item.member({:item, nil, nil, nil, nil, nil}) end
  end

  test "op property can be set and retrieved" do
    assert :rmv == Item.new(dummy_netid) |> Item.op(:rmv) |> Item.op
    assert :add == Item.new(dummy_netid) |> Item.op(:add) |> Item.op
  end

  test "cannot get op() from an invalid Item" do
    assert_raise FunctionClauseError, fn -> Item.op(:ok) end
    assert_raise FunctionClauseError, fn -> Item.op([]) end
    assert_raise FunctionClauseError, fn -> Item.op({}) end
    assert_raise FunctionClauseError, fn -> Item.op({:ok}) end
    assert_raise FunctionClauseError, fn -> Item.op({:item}) end
    assert_raise FunctionClauseError, fn -> Item.op({:item, nil}) end
    assert_raise FunctionClauseError, fn -> Item.op({:item, nil, nil}) end
    assert_raise FunctionClauseError, fn -> Item.op({:item, nil, nil, nil}) end
    assert_raise FunctionClauseError, fn -> Item.op({:item, nil, nil, nil, nil}) end
    assert_raise FunctionClauseError, fn -> Item.op({:item, nil, nil, nil, nil, nil}) end
  end

  test "cannot set invalid atom to op" do
    assert_raise FunctionClauseError, fn -> Item.new(dummy_netid) |> Item.op(:invalid) end
  end

  test "cannot set op on invalid Item" do
    assert_raise FunctionClauseError, fn -> Item.op(nil, :add) end
  end

  test "cannot get start_range() from an invalid Item" do
    assert_raise FunctionClauseError, fn -> Item.start_range(:ok) end
    assert_raise FunctionClauseError, fn -> Item.start_range([]) end
    assert_raise FunctionClauseError, fn -> Item.start_range({}) end
    assert_raise FunctionClauseError, fn -> Item.start_range({:ok}) end
    assert_raise FunctionClauseError, fn -> Item.start_range({:item}) end
    assert_raise FunctionClauseError, fn -> Item.start_range({:item, nil}) end
    assert_raise FunctionClauseError, fn -> Item.start_range({:item, nil, nil}) end
    assert_raise FunctionClauseError, fn -> Item.start_range({:item, nil, nil, nil}) end
    assert_raise FunctionClauseError, fn -> Item.start_range({:item, nil, nil, nil, nil}) end
    assert_raise FunctionClauseError, fn -> Item.start_range({:item, nil, nil, nil, nil, nil}) end
  end

  test "start_range property can be set and retrieved" do
    assert 11 == Item.new(dummy_netid) |> Item.start_range(11) |> Item.start_range
  end

  test "cannot set invalid start_range" do
    assert_raise FunctionClauseError, fn -> Item.new(dummy_netid) |> Item.start_range(-1) end
  end

  test "cannot set start_range on invalid Item" do
    assert_raise FunctionClauseError, fn -> Item.start_range(nil, 1) end
  end

  test "end_range property can be set and retrieved" do
    assert 99 == Item.new(dummy_netid) |> Item.end_range(99) |> Item.end_range
  end

  test "cannot get end_range() from an invalid Item" do
    assert_raise FunctionClauseError, fn -> Item.end_range(:ok) end
    assert_raise FunctionClauseError, fn -> Item.end_range([]) end
    assert_raise FunctionClauseError, fn -> Item.end_range({}) end
    assert_raise FunctionClauseError, fn -> Item.end_range({:ok}) end
    assert_raise FunctionClauseError, fn -> Item.end_range({:item}) end
    assert_raise FunctionClauseError, fn -> Item.end_range({:item, nil}) end
    assert_raise FunctionClauseError, fn -> Item.end_range({:item, nil, nil}) end
    assert_raise FunctionClauseError, fn -> Item.end_range({:item, nil, nil, nil}) end
    assert_raise FunctionClauseError, fn -> Item.end_range({:item, nil, nil, nil, nil}) end
    assert_raise FunctionClauseError, fn -> Item.end_range({:item, nil, nil, nil, nil, nil}) end
  end

  test "cannot set invalid end_range" do
    assert_raise FunctionClauseError, fn -> Item.new(dummy_netid) |> Item.end_range(-1) end
  end

  test "cannot set end_range on invalid Item" do
    assert_raise FunctionClauseError, fn -> Item.end_range(nil, 1) end
  end

  test "cannot get port() from an invalid Item" do
    assert_raise FunctionClauseError, fn -> Item.port(:ok) end
    assert_raise FunctionClauseError, fn -> Item.port([]) end
    assert_raise FunctionClauseError, fn -> Item.port({}) end
    assert_raise FunctionClauseError, fn -> Item.port({:ok}) end
    assert_raise FunctionClauseError, fn -> Item.port({:item}) end
    assert_raise FunctionClauseError, fn -> Item.port({:item, nil}) end
    assert_raise FunctionClauseError, fn -> Item.port({:item, nil, nil}) end
    assert_raise FunctionClauseError, fn -> Item.port({:item, nil, nil, nil}) end
    assert_raise FunctionClauseError, fn -> Item.port({:item, nil, nil, nil, nil}) end
    assert_raise FunctionClauseError, fn -> Item.port({:item, nil, nil, nil, nil, nil}) end
  end

  test "port property can be set and retrieved" do
    assert 1199 == Item.new(dummy_netid) |> Item.port(1199) |> Item.port
  end

  test "cannot set invalid port" do
    assert_raise FunctionClauseError, fn -> Item.new(dummy_netid) |> Item.port(-1) end
  end

  test "cannot set port on invalid Item" do
    assert_raise FunctionClauseError, fn -> Item.port(nil, 1) end
  end

  test "cannot set() values on an invalid Item" do
    assert_raise FunctionClauseError, fn -> Item.set(:ok, :add, 0, 0, 0) end
    assert_raise FunctionClauseError, fn -> Item.set([], :add, 0, 0, 0) end
    assert_raise FunctionClauseError, fn -> Item.set({}, :add, 0, 0, 0) end
    assert_raise FunctionClauseError, fn -> Item.set({:ok}, :add, 0, 0, 0) end
  end

  test "cannot set() invalid atom" do
    it = Item.new(dummy_netid)
    assert_raise FunctionClauseError, fn -> Item.set(it, :addx, 0, 0, 0) end
    assert_raise FunctionClauseError, fn -> Item.set(it, nil, 0, 0, 0) end
    assert_raise FunctionClauseError, fn -> Item.set(it, [], 0, 0, 0) end
    assert_raise FunctionClauseError, fn -> Item.set(it, {}, 0, 0, 0) end
  end

  test "cannot set() invalid start_range" do
    it = Item.new(dummy_netid)
    assert_raise FunctionClauseError, fn -> Item.set(it, :add, nil, 0, 0) end
    assert_raise FunctionClauseError, fn -> Item.set(it, :add, -1, 0, 0) end
    assert_raise FunctionClauseError, fn -> Item.set(it, :add, 0xffffffffffff, 0, 0) end
    assert_raise FunctionClauseError, fn -> Item.set(it, :add, [], 0, 0) end
  end

  test "cannot set() invalid end_range" do
    it = Item.new(dummy_netid)
    assert_raise FunctionClauseError, fn -> Item.set(it, :add, 0, nil, 0) end
    assert_raise FunctionClauseError, fn -> Item.set(it, :add, 0, -1, 0) end
    assert_raise FunctionClauseError, fn -> Item.set(it, :add, 0, 0xffffffffffff, 0) end
    assert_raise FunctionClauseError, fn -> Item.set(it, :add, 0, [], 0) end
  end

  test "cannot set() invalid port" do
    it = Item.new(dummy_netid)
    assert_raise FunctionClauseError, fn -> Item.set(it, :add, 0, 0, nil) end
    assert_raise FunctionClauseError, fn -> Item.set(it, :add, 0, 0, -1) end
    assert_raise FunctionClauseError, fn -> Item.set(it, :add, 0, 0, 0xffffffffffff) end
    assert_raise FunctionClauseError, fn -> Item.set(it, :add, 0, 0, []) end
  end

  test "encode_with() failes with invalid input" do
    assert_raise FunctionClauseError, fn -> Item.encode_with(:ok, %{}) end
    assert_raise FunctionClauseError, fn -> Item.encode_with([], %{}) end
    assert_raise FunctionClauseError, fn -> Item.encode_with({:item, 0}, %{}) end

    it = Item.new(dummy_netid)
    assert_raise KeyError, fn -> Item.encode_with(it, %{}) end
    assert_raise KeyError, fn -> Item.encode_with(it, %{0 => 0}) end
  end

  test "encode_with() works with decode_with()" do
    it = Item.new(dummy_netid)
    encoded = Item.encode_with(it, %{dummy_netid => 1231})
    {decoded, <<>>} = Item.decode_with(encoded, %{1231 => dummy_netid})
    assert decoded == it

    # decode_with fails on bad input
    assert_raise KeyError, fn -> Item.decode_with(encoded, %{}) end
    assert_raise KeyError, fn -> Item.decode_with(encoded, %{0 => 0}) end
    assert_raise FunctionClauseError, fn -> Item.decode_with(encoded, %{1231 => 0}) end
  end
end
