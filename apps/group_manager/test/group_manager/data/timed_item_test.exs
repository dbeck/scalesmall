defmodule GroupManager.Data.TimedItemTest do
  use ExUnit.Case
  alias GroupManager.Data.TimedItem
  alias GroupManager.Data.Item
  alias GroupManager.Data.LocalClock
  alias Chatter.NetID

  defp dummy_me do
    NetID.new({1,2,3,4},1)
  end

  defp dummy_other do
    NetID.new({2,3,4,5},2)
  end

  defp dummy_third do
    NetID.new({3,4,5,6},3)
  end

  defp dummy_list do
    [dummy_me, dummy_other, dummy_third]
  end

  defp dummy_item_list do
    dummy_list |> Enum.reduce([], fn(x,acc) ->
      [TimedItem.new(x) | acc]
    end)
  end

  test "basic test for new" do
    assert TimedItem.valid?(TimedItem.new(dummy_me))
  end

  test "basic test for invalid input" do
    assert TimedItem.valid?(nil) == false
    assert TimedItem.valid?([]) == false
    assert TimedItem.valid?({}) == false
    assert TimedItem.valid?(:ok) == false
    assert TimedItem.valid?({:ok}) == false
    assert TimedItem.valid?({:timed_item}) == false
    assert TimedItem.valid?({:timed_item, nil}) == false
    assert TimedItem.valid?({:timed_item, nil, nil}) == false
  end

  test "item() returns the Item member" do
    it = TimedItem.new(dummy_me) |> TimedItem.item
    assert Item.valid?(it)
  end

  test "item() raises on invalid parameter" do
    assert_raise FunctionClauseError, fn -> TimedItem.item(nil) end
    assert_raise FunctionClauseError, fn -> TimedItem.item([]) end
    assert_raise FunctionClauseError, fn -> TimedItem.item({}) end
    assert_raise FunctionClauseError, fn -> TimedItem.item(:ok) end
    assert_raise FunctionClauseError, fn -> TimedItem.item({:timed_item}) end
  end

  test "updated_at() returns the LocalClock member" do
    cl = TimedItem.new(dummy_me) |> TimedItem.updated_at
    assert LocalClock.valid?(cl)
  end

  test "updated_at() raises on invalid parameter" do
    assert_raise FunctionClauseError, fn -> TimedItem.updated_at(nil) end
    assert_raise FunctionClauseError, fn -> TimedItem.updated_at([]) end
    assert_raise FunctionClauseError, fn -> TimedItem.updated_at({}) end
    assert_raise FunctionClauseError, fn -> TimedItem.updated_at(:ok) end
    assert_raise FunctionClauseError, fn -> TimedItem.updated_at({:timed_item}) end
  end

  test "construct() creates a valid TimedItem object with valid members" do
    it = Item.new(dummy_me)
    cl = LocalClock.new(dummy_me)
    ti = TimedItem.construct(it, cl)
    assert TimedItem.valid?(ti)
    assert it == TimedItem.item(ti)
    assert cl == TimedItem.updated_at(ti)
  end

  test "construct() raises on different member variables" do
    it = Item.new(dummy_me)
    cl = LocalClock.new(dummy_other)
    assert_raise FunctionClauseError, fn -> TimedItem.construct(it, cl) end
  end

  test "construct() raises on invalid Item" do
    cl = LocalClock.new(dummy_other)
    assert_raise FunctionClauseError, fn -> TimedItem.construct(nil, cl) end
    assert_raise FunctionClauseError, fn -> TimedItem.construct(:ok, cl) end
    assert_raise FunctionClauseError, fn -> TimedItem.construct({:item}, cl) end
    assert_raise FunctionClauseError, fn -> TimedItem.construct([], cl) end
    assert_raise FunctionClauseError, fn -> TimedItem.construct({}, cl) end
  end

  test "construct() raises on invalid LocalClock" do
    it = Item.new(dummy_me)
    assert_raise FunctionClauseError, fn -> TimedItem.construct(it, nil) end
    assert_raise FunctionClauseError, fn -> TimedItem.construct(it, :ok) end
    assert_raise FunctionClauseError, fn -> TimedItem.construct(it, {:item}) end
    assert_raise FunctionClauseError, fn -> TimedItem.construct(it, []) end
    assert_raise FunctionClauseError, fn -> TimedItem.construct(it, {}) end
  end

  test "construct_next() creates a valid TimedItem object with valid members" do
    it = Item.new(dummy_me)
    cl = LocalClock.new(dummy_me)
    ti = TimedItem.construct_next(it, cl)
    assert TimedItem.valid?(ti)
    assert it == TimedItem.item(ti)
    assert LocalClock.next(cl) == TimedItem.updated_at(ti)
  end

  test "construct_next() raises on different member variables" do
    it = Item.new(dummy_me)
    cl = LocalClock.new(dummy_other)
    assert_raise FunctionClauseError, fn -> TimedItem.construct_next(it, cl) end
  end

  test "construct_next() raises on invalid Item" do
    cl = LocalClock.new(dummy_other)
    assert_raise FunctionClauseError, fn -> TimedItem.construct_next(nil, cl) end
    assert_raise FunctionClauseError, fn -> TimedItem.construct_next(:ok, cl) end
    assert_raise FunctionClauseError, fn -> TimedItem.construct_next({:item}, cl) end
    assert_raise FunctionClauseError, fn -> TimedItem.construct_next([], cl) end
    assert_raise FunctionClauseError, fn -> TimedItem.construct_next({}, cl) end
  end

  test "construct_next() raises on invalid LocalClock" do
    it = Item.new(dummy_me)
    assert_raise FunctionClauseError, fn -> TimedItem.construct_next(it, nil) end
    assert_raise FunctionClauseError, fn -> TimedItem.construct_next(it, :ok) end
    assert_raise FunctionClauseError, fn -> TimedItem.construct_next(it, {:item}) end
    assert_raise FunctionClauseError, fn -> TimedItem.construct_next(it, []) end
    assert_raise FunctionClauseError, fn -> TimedItem.construct_next(it, {}) end
  end

  test "max_item() returns what has the max() of LocalClock" do
    it = Item.new(dummy_me) |> Item.port(1)
    cl = LocalClock.new(dummy_me)
    ti = TimedItem.construct(it, cl)
    it = Item.new(dummy_me) |> Item.port(2) |> Item.op(:rmv)
    ti2 = TimedItem.construct_next(it, cl)
    assert ti2 == TimedItem.max_item(ti, ti2)
  end

  test "max_item() returns identity for the same params" do
    id = TimedItem.new(dummy_me)
    assert id == TimedItem.max_item(id, id)
  end

  test "max_item() raises on invalid params" do
    assert_raise FunctionClauseError, fn -> TimedItem.max_item(nil, nil) end
    assert_raise FunctionClauseError, fn -> TimedItem.max_item(TimedItem.new(dummy_me), nil) end
    assert_raise FunctionClauseError, fn -> TimedItem.max_item(TimedItem.new(dummy_me), []) end
    assert_raise FunctionClauseError, fn -> TimedItem.max_item(TimedItem.new(dummy_me), {}) end
    assert_raise FunctionClauseError, fn -> TimedItem.max_item(TimedItem.new(dummy_me), {:timed_item}) end

    assert_raise FunctionClauseError, fn -> TimedItem.max_item(nil, TimedItem.new(dummy_me)) end
    assert_raise FunctionClauseError, fn -> TimedItem.max_item([], TimedItem.new(dummy_me)) end
    assert_raise FunctionClauseError, fn -> TimedItem.max_item({}, TimedItem.new(dummy_me)) end
    assert_raise FunctionClauseError, fn -> TimedItem.max_item({:timed_item}, TimedItem.new(dummy_me)) end
  end

  test "merge() updates the same item to the latest clock" do
    it1 = Item.new(dummy_me)    |> Item.port(1)        |> TimedItem.construct(LocalClock.new(dummy_me))
    it2 = Item.new(dummy_other) |> Item.start_range(2) |> TimedItem.construct_next(LocalClock.new(dummy_other))

    assert [it1, it2] == TimedItem.merge([], it1) |> TimedItem.merge(it2)

    it3 = TimedItem.construct_next(TimedItem.item(it1), TimedItem.updated_at(it1))
    it4 = TimedItem.construct_next(TimedItem.item(it2) |> Item.port(20), TimedItem.updated_at(it2))

    # all permutations
    assert [it3, it4] == TimedItem.merge([], it1) |> TimedItem.merge(it2) |> TimedItem.merge(it3) |> TimedItem.merge(it4)
    assert [it3, it4] == TimedItem.merge([], it1) |> TimedItem.merge(it2) |> TimedItem.merge(it4) |> TimedItem.merge(it3)
    assert [it3, it4] == TimedItem.merge([], it1) |> TimedItem.merge(it3) |> TimedItem.merge(it2) |> TimedItem.merge(it4)
    assert [it3, it4] == TimedItem.merge([], it1) |> TimedItem.merge(it3) |> TimedItem.merge(it4) |> TimedItem.merge(it2)
    assert [it3, it4] == TimedItem.merge([], it1) |> TimedItem.merge(it4) |> TimedItem.merge(it2) |> TimedItem.merge(it3)
    assert [it3, it4] == TimedItem.merge([], it1) |> TimedItem.merge(it4) |> TimedItem.merge(it3) |> TimedItem.merge(it2)

    assert [it3, it4] == TimedItem.merge([], it2) |> TimedItem.merge(it1) |> TimedItem.merge(it3) |> TimedItem.merge(it4)
    assert [it3, it4] == TimedItem.merge([], it2) |> TimedItem.merge(it1) |> TimedItem.merge(it4) |> TimedItem.merge(it3)
    assert [it3, it4] == TimedItem.merge([], it2) |> TimedItem.merge(it3) |> TimedItem.merge(it1) |> TimedItem.merge(it4)
    assert [it3, it4] == TimedItem.merge([], it2) |> TimedItem.merge(it3) |> TimedItem.merge(it4) |> TimedItem.merge(it1)
    assert [it3, it4] == TimedItem.merge([], it2) |> TimedItem.merge(it4) |> TimedItem.merge(it1) |> TimedItem.merge(it3)
    assert [it3, it4] == TimedItem.merge([], it2) |> TimedItem.merge(it4) |> TimedItem.merge(it3) |> TimedItem.merge(it1)

    assert [it3, it4] == TimedItem.merge([], it3) |> TimedItem.merge(it2) |> TimedItem.merge(it1) |> TimedItem.merge(it4)
    assert [it3, it4] == TimedItem.merge([], it3) |> TimedItem.merge(it2) |> TimedItem.merge(it4) |> TimedItem.merge(it1)
    assert [it3, it4] == TimedItem.merge([], it3) |> TimedItem.merge(it1) |> TimedItem.merge(it2) |> TimedItem.merge(it4)
    assert [it3, it4] == TimedItem.merge([], it3) |> TimedItem.merge(it1) |> TimedItem.merge(it4) |> TimedItem.merge(it2)
    assert [it3, it4] == TimedItem.merge([], it3) |> TimedItem.merge(it4) |> TimedItem.merge(it2) |> TimedItem.merge(it1)
    assert [it3, it4] == TimedItem.merge([], it3) |> TimedItem.merge(it4) |> TimedItem.merge(it1) |> TimedItem.merge(it2)

    assert [it3, it4] == TimedItem.merge([], it4) |> TimedItem.merge(it2) |> TimedItem.merge(it3) |> TimedItem.merge(it1)
    assert [it3, it4] == TimedItem.merge([], it4) |> TimedItem.merge(it2) |> TimedItem.merge(it1) |> TimedItem.merge(it3)
    assert [it3, it4] == TimedItem.merge([], it4) |> TimedItem.merge(it3) |> TimedItem.merge(it2) |> TimedItem.merge(it1)
    assert [it3, it4] == TimedItem.merge([], it4) |> TimedItem.merge(it3) |> TimedItem.merge(it1) |> TimedItem.merge(it2)
    assert [it3, it4] == TimedItem.merge([], it4) |> TimedItem.merge(it1) |> TimedItem.merge(it2) |> TimedItem.merge(it3)
    assert [it3, it4] == TimedItem.merge([], it4) |> TimedItem.merge(it1) |> TimedItem.merge(it3) |> TimedItem.merge(it2)
  end

  test "merge() raises on invalid item" do
    assert_raise FunctionClauseError, fn -> TimedItem.merge([], nil) end
    assert_raise FunctionClauseError, fn -> TimedItem.merge([], {}) end
    assert_raise FunctionClauseError, fn -> TimedItem.merge([], :ok) end
    assert_raise FunctionClauseError, fn -> TimedItem.merge([], :timed_item) end
    assert_raise FunctionClauseError, fn -> TimedItem.merge([], {:timed_item}) end
  end

  test "merge([],item) is idempotent" do
    it1 = Item.new(dummy_me)    |> Item.port(1)    |> TimedItem.construct(LocalClock.new(dummy_me))
    it2 = Item.new(dummy_other) |> Item.start_range(2) |> TimedItem.construct_next(LocalClock.new(dummy_other))

    assert [it1, it2] == TimedItem.merge([],         it1) |> TimedItem.merge(it2)
    assert [it1, it2] == TimedItem.merge([it1],      it1) |> TimedItem.merge(it2)
    assert [it1, it2] == TimedItem.merge([it2],      it1) |> TimedItem.merge(it2)
    assert [it1, it2] == TimedItem.merge([it1, it2], it1) |> TimedItem.merge(it2)
  end

  test "merge([],[]) is idempotent" do
    it1 = Item.new(dummy_me)    |> Item.port(1)        |> TimedItem.construct(LocalClock.new(dummy_me))
    it2 = Item.new(dummy_other) |> Item.start_range(2) |> TimedItem.construct_next(LocalClock.new(dummy_other))

    assert [it1, it2] == TimedItem.merge([],         [it1]) |> TimedItem.merge([it2])
    assert [it1, it2] == TimedItem.merge([it1],      [it1]) |> TimedItem.merge([it2])
    assert [it1, it2] == TimedItem.merge([it2],      [it1]) |> TimedItem.merge([it2])
    assert [it1, it2] == TimedItem.merge([it1, it2], [it1]) |> TimedItem.merge([it2])
    assert [it1, it2] == TimedItem.merge([it1, it2], [it1, it2])
  end

  test "merge([],[]) basic functionality" do
    it1 = Item.new(dummy_me)    |> Item.port(1)    |> TimedItem.construct(LocalClock.new(dummy_me))
    it2 = Item.new(dummy_other) |> Item.start_range(2) |> TimedItem.construct_next(LocalClock.new(dummy_other))

    assert [it1, it2] == TimedItem.merge([], [it1]) |> TimedItem.merge([it2])

    it3 = TimedItem.construct_next(TimedItem.item(it1), TimedItem.updated_at(it1))
    it4 = TimedItem.construct_next(TimedItem.item(it2) |> Item.port(20), TimedItem.updated_at(it2))

    # all permutations
    assert [it3, it4] == TimedItem.merge([], [it1]) |> TimedItem.merge([it2]) |> TimedItem.merge([it3]) |> TimedItem.merge([it4])
    assert [it3, it4] == TimedItem.merge([], [it1]) |> TimedItem.merge([it2]) |> TimedItem.merge([it4]) |> TimedItem.merge([it3])
    assert [it3, it4] == TimedItem.merge([], [it1]) |> TimedItem.merge([it3]) |> TimedItem.merge([it2]) |> TimedItem.merge([it4])
    assert [it3, it4] == TimedItem.merge([], [it1]) |> TimedItem.merge([it3]) |> TimedItem.merge([it4]) |> TimedItem.merge([it2])
    assert [it3, it4] == TimedItem.merge([], [it1]) |> TimedItem.merge([it4]) |> TimedItem.merge([it2]) |> TimedItem.merge([it3])
    assert [it3, it4] == TimedItem.merge([], [it1]) |> TimedItem.merge([it4]) |> TimedItem.merge([it3]) |> TimedItem.merge([it2])

    assert [it3, it4] == TimedItem.merge([], [it2]) |> TimedItem.merge([it1]) |> TimedItem.merge([it3]) |> TimedItem.merge([it4])
    assert [it3, it4] == TimedItem.merge([], [it2]) |> TimedItem.merge([it1]) |> TimedItem.merge([it4]) |> TimedItem.merge([it3])
    assert [it3, it4] == TimedItem.merge([], [it2]) |> TimedItem.merge([it3]) |> TimedItem.merge([it1]) |> TimedItem.merge([it4])
    assert [it3, it4] == TimedItem.merge([], [it2]) |> TimedItem.merge([it3]) |> TimedItem.merge([it4]) |> TimedItem.merge([it1])
    assert [it3, it4] == TimedItem.merge([], [it2]) |> TimedItem.merge([it4]) |> TimedItem.merge([it1]) |> TimedItem.merge([it3])
    assert [it3, it4] == TimedItem.merge([], [it2]) |> TimedItem.merge([it4]) |> TimedItem.merge([it3]) |> TimedItem.merge([it1])

    assert [it3, it4] == TimedItem.merge([], [it3]) |> TimedItem.merge([it2]) |> TimedItem.merge([it1]) |> TimedItem.merge([it4])
    assert [it3, it4] == TimedItem.merge([], [it3]) |> TimedItem.merge([it2]) |> TimedItem.merge([it4]) |> TimedItem.merge([it1])
    assert [it3, it4] == TimedItem.merge([], [it3]) |> TimedItem.merge([it1]) |> TimedItem.merge([it2]) |> TimedItem.merge([it4])
    assert [it3, it4] == TimedItem.merge([], [it3]) |> TimedItem.merge([it1]) |> TimedItem.merge([it4]) |> TimedItem.merge([it2])
    assert [it3, it4] == TimedItem.merge([], [it3]) |> TimedItem.merge([it4]) |> TimedItem.merge([it2]) |> TimedItem.merge([it1])
    assert [it3, it4] == TimedItem.merge([], [it3]) |> TimedItem.merge([it4]) |> TimedItem.merge([it1]) |> TimedItem.merge([it2])

    assert [it3, it4] == TimedItem.merge([], [it4]) |> TimedItem.merge([it2]) |> TimedItem.merge([it3]) |> TimedItem.merge([it1])
    assert [it3, it4] == TimedItem.merge([], [it4]) |> TimedItem.merge([it2]) |> TimedItem.merge([it1]) |> TimedItem.merge([it3])
    assert [it3, it4] == TimedItem.merge([], [it4]) |> TimedItem.merge([it3]) |> TimedItem.merge([it2]) |> TimedItem.merge([it1])
    assert [it3, it4] == TimedItem.merge([], [it4]) |> TimedItem.merge([it3]) |> TimedItem.merge([it1]) |> TimedItem.merge([it2])
    assert [it3, it4] == TimedItem.merge([], [it4]) |> TimedItem.merge([it1]) |> TimedItem.merge([it2]) |> TimedItem.merge([it3])
    assert [it3, it4] == TimedItem.merge([], [it4]) |> TimedItem.merge([it1]) |> TimedItem.merge([it3]) |> TimedItem.merge([it2])
  end

  # validate_list
  test "validate_list() returns :error on invalid input" do
    assert :error = TimedItem.validate_list({})
    assert :error = TimedItem.validate_list({:ok})
    assert :error = TimedItem.validate_list({:ok, nil})
    assert :error = TimedItem.validate_list({:ok, nil, nil})
    assert :error = TimedItem.validate_list({:local_clock, nil})
    assert :error = TimedItem.validate_list({:local_clock, nil, nil})
    assert :error = TimedItem.validate_list({:local_clock, nil, nil, nil})

    assert :error = TimedItem.validate_list([{}])
    assert :error = TimedItem.validate_list([{:ok}])
    assert :error = TimedItem.validate_list([{:ok, nil}])
    assert :error = TimedItem.validate_list([{:ok, nil, nil}])
    assert :error = TimedItem.validate_list([{:local_clock, nil}])
    assert :error = TimedItem.validate_list([{:local_clock, nil, nil}])
    assert :error = TimedItem.validate_list([{:local_clock, nil, nil, nil}])
  end

  test "validate_list([]) is :ok" do
    assert :ok == TimedItem.validate_list([])
  end

  test "validate_list([valid_item]) is :ok" do
    assert :ok == TimedItem.validate_list([TimedItem.new(dummy_me)])
  end

  # validate_list!
  test "validate_list!() throws on invalid input" do
    assert_raise FunctionClauseError, fn -> TimedItem.validate_list!(nil) end
    assert_raise FunctionClauseError, fn -> TimedItem.validate_list!({}) end
    assert_raise FunctionClauseError, fn -> TimedItem.validate_list!({:ok}) end
    assert_raise FunctionClauseError, fn -> TimedItem.validate_list!({:ok, nil}) end
    assert_raise FunctionClauseError, fn -> TimedItem.validate_list!({:ok, nil, nil}) end
    assert_raise FunctionClauseError, fn -> TimedItem.validate_list!({:local_clock, nil}) end
    assert_raise FunctionClauseError, fn -> TimedItem.validate_list!({:local_clock, nil, nil}) end
    assert_raise FunctionClauseError, fn -> TimedItem.validate_list!({:local_clock, nil, nil, nil}) end

    assert_raise FunctionClauseError, fn -> TimedItem.validate_list!([{}]) end
    assert_raise FunctionClauseError, fn -> TimedItem.validate_list!([{:ok}]) end
    assert_raise FunctionClauseError, fn -> TimedItem.validate_list!([{:ok, nil}]) end
    assert_raise FunctionClauseError, fn -> TimedItem.validate_list!([{:ok, nil, nil}]) end
    assert_raise FunctionClauseError, fn -> TimedItem.validate_list!([{:local_clock, nil}]) end
    assert_raise FunctionClauseError, fn -> TimedItem.validate_list!([{:local_clock, nil, nil}]) end
    assert_raise FunctionClauseError, fn -> TimedItem.validate_list!([{:local_clock, nil, nil, nil}]) end
  end

  test "validate_list!([]) is :ok" do
    assert :ok == TimedItem.validate_list!([])
  end

  test "validate_list!([valid_item]) is :ok" do
    assert :ok == TimedItem.validate_list!([TimedItem.new(dummy_me)])
  end

  test "encode_with() failes with invalid input" do
    assert_raise FunctionClauseError, fn -> TimedItem.encode_with(:ok, %{}) end
    assert_raise FunctionClauseError, fn -> TimedItem.encode_with([], %{}) end
    assert_raise FunctionClauseError, fn -> TimedItem.encode_with({:item, 0}, %{}) end

    itm = TimedItem.new(dummy_me)
    assert_raise KeyError, fn -> TimedItem.encode_with(itm, %{}) end
    assert_raise KeyError, fn -> TimedItem.encode_with(itm, %{0 => 0}) end
  end

  test "encode_with() works with decode_with()" do
    itm = TimedItem.new(dummy_me)
    encoded = TimedItem.encode_with(itm, %{dummy_me => 9911231})
    {decoded, <<>>} = TimedItem.decode_with(encoded, %{9911231 => dummy_me})
    assert decoded == itm

    # decode_with fails on bad input
    assert_raise KeyError, fn -> TimedItem.decode_with(encoded, %{}) end
    assert_raise KeyError, fn -> TimedItem.decode_with(encoded, %{0 => 0}) end
    assert_raise FunctionClauseError, fn -> TimedItem.decode_with(encoded, %{9911231 => 0}) end
  end

  # encode_list_with
  test "encode_list_with() throws on invalid input" do
    assert_raise FunctionClauseError, fn -> TimedItem.encode_list_with(<<>>, %{dummy_me => 0}) end
    assert_raise FunctionClauseError, fn -> TimedItem.encode_list_with({}, %{dummy_me => 0}) end
    assert_raise FunctionClauseError, fn -> TimedItem.encode_list_with([{:ok}], %{dummy_me => 0}) end
    assert_raise FunctionClauseError, fn -> TimedItem.encode_list_with([:ok], %{dummy_me => 0}) end
  end

  # decode_list_with
  test "decode_list_with() throws on invalid input" do
    assert_raise FunctionClauseError, fn -> TimedItem.decode_list_with(<<>>, %{}) end
    assert_raise FunctionClauseError, fn -> TimedItem.decode_list_with({}, %{}) end
    assert_raise FunctionClauseError, fn -> TimedItem.decode_list_with(:ok, %{}) end
  end

  test "encode_list_with() works with decode_list_with()" do
    {_count, fwd, rev} = dummy_list |> Enum.reduce({0, %{}, %{}}, fn(x,acc) ->
      {count, fw, re} = acc
      {count+1, Map.put(fw, x, count), Map.put(re, count, x)}
    end)
    encoded = TimedItem.encode_list_with(dummy_item_list, fwd)
    {decoded, <<>>} = TimedItem.decode_list_with(encoded, rev)

    assert decoded == dummy_item_list

    # decode_list_with fails with bad input
    assert_raise KeyError, fn -> TimedItem.decode_list_with(encoded, %{}) end
    assert_raise KeyError, fn -> TimedItem.decode_list_with(encoded, %{0 => 0}) end
  end
end
