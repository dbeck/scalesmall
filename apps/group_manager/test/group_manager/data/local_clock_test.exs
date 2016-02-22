defmodule GroupManager.Data.LocalClockTest do
  use ExUnit.Case
  alias GroupManager.Data.LocalClock
  alias GroupManager.Chatter.NetID

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

  defp dummy_clock_list do
    dummy_list |> Enum.reduce([], fn(x,acc) ->
      [LocalClock.new(x) | acc]
    end)
  end

  test "basic test for new" do
    assert LocalClock.valid?(LocalClock.new(dummy_me))
  end

  test "basic test for invalid input" do
    assert LocalClock.valid?(nil) == false
    assert LocalClock.valid?([]) == false
    assert LocalClock.valid?({}) == false
    assert LocalClock.valid?(:ok) == false
    assert LocalClock.valid?({:ok}) == false
    assert LocalClock.valid?({:local_clock}) == false
    assert LocalClock.valid?({:local_clock, nil}) == false
    assert LocalClock.valid?({:local_clock, nil, nil}) == false
    assert LocalClock.valid?({:local_clock, nil, nil, nil}) == false
  end

  test "next() raises on invalid clock" do
    assert_raise FunctionClauseError, fn -> LocalClock.next(:ok) end
    assert_raise FunctionClauseError, fn -> LocalClock.next(nil) end
    assert_raise FunctionClauseError, fn -> LocalClock.next([]) end
    assert_raise FunctionClauseError, fn -> LocalClock.next({}) end
  end

  test "time_val() returns the local clock time" do
    clock = LocalClock.new(dummy_me)
    clock2 = LocalClock.next(clock)
    assert LocalClock.time_val(clock) + 1 == LocalClock.time_val(clock2)
  end

  test "time_val() raises on bad parameter" do
    assert_raise FunctionClauseError, fn -> LocalClock.time_val(:ok) end
    assert_raise FunctionClauseError, fn -> LocalClock.time_val([]) end
    assert_raise FunctionClauseError, fn -> LocalClock.time_val({}) end
    assert_raise FunctionClauseError, fn -> LocalClock.time_val({:ok}) end
  end

  test "member() returns the local clock's member" do
    clock = LocalClock.new(dummy_me)
    assert LocalClock.member(clock) == dummy_me
  end

  test "member() raises on bad parameter" do
    assert_raise FunctionClauseError, fn -> LocalClock.member(:ok) end
    assert_raise FunctionClauseError, fn -> LocalClock.member([]) end
    assert_raise FunctionClauseError, fn -> LocalClock.member({}) end
    assert_raise FunctionClauseError, fn -> LocalClock.member({:ok}) end
  end

  test "merge([], item) is idempotent" do
    lst = []
    clock = LocalClock.new(dummy_me)
    merged = LocalClock.merge(lst, clock)
    assert length(merged) == 1
    assert merged == LocalClock.merge(merged, clock)
    # merge in another one
    clock2 = LocalClock.new(dummy_other)
    merged = LocalClock.merge(merged, clock2)
    assert length(merged) == 2
    assert merged == LocalClock.merge(merged, clock)
  end

  test "merge([], item) keeps the latest clock for a member" do
    clock = LocalClock.new(dummy_me)
    clock2 = LocalClock.next(clock)
    assert clock != clock2
    assert [clock2] == LocalClock.merge([clock], clock2)
    assert [clock2] == LocalClock.merge([clock2], clock)
    assert [clock2] == LocalClock.merge([clock, clock], clock2)
    assert [clock2] == LocalClock.merge([clock2, clock], clock)
  end

  test "merge([],*) raises on bad elements" do
    assert_raise FunctionClauseError, fn -> LocalClock.merge([], :ok) end
    assert_raise FunctionClauseError, fn -> LocalClock.merge([:ok], LocalClock.new(dummy_me)) end
    assert_raise FunctionClauseError, fn ->
      LocalClock.merge([LocalClock.new(dummy_me), :ok],
                       LocalClock.new(dummy_me))
    end
  end

  test "max_clock() returns identity for the same values" do
    clock = LocalClock.new(dummy_me)
    assert clock == LocalClock.max_clock(clock, clock)
  end

  test "max_clock() raises error for incompatible clocks" do
    clock1 = LocalClock.new(dummy_me)
    clock2 = LocalClock.new(dummy_other)
    assert_raise FunctionClauseError, fn -> LocalClock.max_clock(clock1, clock2) end
  end

  test "max_clock() picks up the maximum of two clocks" do
    clock1 = LocalClock.new(dummy_me)
    clock2 = LocalClock.next(clock1)
    assert clock2 == LocalClock.max_clock(clock1, clock2)
    assert clock2 == LocalClock.max_clock(clock2, clock1)
  end

  test "max_clock() raises on invalid parameters" do
    clock = LocalClock.new(dummy_me)
    assert_raise FunctionClauseError, fn ->  LocalClock.max_clock(clock, nil) end
    assert_raise FunctionClauseError, fn ->  LocalClock.max_clock(nil, clock) end
    assert_raise FunctionClauseError, fn ->  LocalClock.max_clock(nil, nil) end
    assert_raise FunctionClauseError, fn ->  LocalClock.max_clock([], []) end
    assert_raise FunctionClauseError, fn ->  LocalClock.max_clock(clock, []) end
    assert_raise FunctionClauseError, fn ->  LocalClock.max_clock([], clock) end
  end

  # merge([],[])
  test "merge([],[]) raises on bad elements" do
    assert_raise FunctionClauseError, fn -> LocalClock.merge(:ok, :ok) end
    assert_raise FunctionClauseError, fn -> LocalClock.merge({}, {}) end
  end

  test "merge([], []) is idempotent" do
    assert [] == LocalClock.merge([], [])
    clock = LocalClock.new(dummy_me)
    assert [clock] == LocalClock.merge([clock], [clock])
    other = LocalClock.new(dummy_other)
    assert [clock, other] |> Enum.sort == LocalClock.merge([clock, other], [clock]) |> Enum.sort
    assert [clock, other] |> Enum.sort == LocalClock.merge([clock], [clock, other]) |> Enum.sort
  end

  test "new(id,time) raises on invalid input" do
    assert_raise FunctionClauseError, fn -> LocalClock.new(dummy_me, :ok) end
    assert_raise FunctionClauseError, fn -> LocalClock.new(dummy_me, []) end
    assert_raise FunctionClauseError, fn -> LocalClock.new(dummy_me, {}) end
    assert_raise FunctionClauseError, fn -> LocalClock.new(dummy_me, -1) end

    assert_raise FunctionClauseError, fn -> LocalClock.new(:ok, 12) end
    assert_raise FunctionClauseError, fn -> LocalClock.new({}, 12) end
    assert_raise FunctionClauseError, fn -> LocalClock.new([], 12) end
    assert_raise FunctionClauseError, fn -> LocalClock.new({:net_id, 1}, 12) end
  end

  test "new(id,time) generates valid value" do
    assert LocalClock.valid?(LocalClock.new(dummy_me, 11))
  end

  # validate_list
  test "validate_list() returns :error on invalid input" do
    assert :error = LocalClock.validate_list({})
    assert :error = LocalClock.validate_list({:ok})
    assert :error = LocalClock.validate_list({:ok, nil})
    assert :error = LocalClock.validate_list({:ok, nil, nil})
    assert :error = LocalClock.validate_list({:local_clock, nil})
    assert :error = LocalClock.validate_list({:local_clock, nil, nil})
    assert :error = LocalClock.validate_list({:local_clock, nil, nil, nil})

    assert :error = LocalClock.validate_list([{}])
    assert :error = LocalClock.validate_list([{:ok}])
    assert :error = LocalClock.validate_list([{:ok, nil}])
    assert :error = LocalClock.validate_list([{:ok, nil, nil}])
    assert :error = LocalClock.validate_list([{:local_clock, nil}])
    assert :error = LocalClock.validate_list([{:local_clock, nil, nil}])
    assert :error = LocalClock.validate_list([{:local_clock, nil, nil, nil}])
  end

  test "validate_list([]) is :ok" do
    assert :ok == LocalClock.validate_list([])
  end

  test "validate_list([valid_item]) is :ok" do
    assert :ok == LocalClock.validate_list([LocalClock.new(dummy_me)])
  end

  # validate_list!
  test "validate_list!() throws on invalid input" do
    assert_raise FunctionClauseError, fn -> LocalClock.validate_list!(nil) end
    assert_raise FunctionClauseError, fn -> LocalClock.validate_list!({}) end
    assert_raise FunctionClauseError, fn -> LocalClock.validate_list!({:ok}) end
    assert_raise FunctionClauseError, fn -> LocalClock.validate_list!({:ok, nil}) end
    assert_raise FunctionClauseError, fn -> LocalClock.validate_list!({:ok, nil, nil}) end
    assert_raise FunctionClauseError, fn -> LocalClock.validate_list!({:local_clock, nil}) end
    assert_raise FunctionClauseError, fn -> LocalClock.validate_list!({:local_clock, nil, nil}) end
    assert_raise FunctionClauseError, fn -> LocalClock.validate_list!({:local_clock, nil, nil, nil}) end

    assert_raise FunctionClauseError, fn -> LocalClock.validate_list!([{}]) end
    assert_raise FunctionClauseError, fn -> LocalClock.validate_list!([{:ok}]) end
    assert_raise FunctionClauseError, fn -> LocalClock.validate_list!([{:ok, nil}]) end
    assert_raise FunctionClauseError, fn -> LocalClock.validate_list!([{:ok, nil, nil}]) end
    assert_raise FunctionClauseError, fn -> LocalClock.validate_list!([{:local_clock, nil}]) end
    assert_raise FunctionClauseError, fn -> LocalClock.validate_list!([{:local_clock, nil, nil}]) end
    assert_raise FunctionClauseError, fn -> LocalClock.validate_list!([{:local_clock, nil, nil, nil}]) end
  end

  test "validate_list!([]) is :ok" do
    assert :ok == LocalClock.validate_list!([])
  end

  test "validate_list!([valid_item]) is :ok" do
    assert :ok == LocalClock.validate_list!([LocalClock.new(dummy_me)])
  end

  test "encode_with() failes with invalid input" do
    assert_raise FunctionClauseError, fn -> LocalClock.encode_with(:ok, %{}) end
    assert_raise FunctionClauseError, fn -> LocalClock.encode_with([], %{}) end
    assert_raise FunctionClauseError, fn -> LocalClock.encode_with({:item, 0}, %{}) end

    clock = LocalClock.new(dummy_me)
    assert_raise KeyError, fn -> LocalClock.encode_with(clock, %{}) end
    assert_raise KeyError, fn -> LocalClock.encode_with(clock, %{0 => 0}) end
  end

  test "encode_with() works with decode_with()" do
    clock = LocalClock.new(dummy_me)
    encoded = LocalClock.encode_with(clock, %{dummy_me => 3121231})
    {decoded, <<>>} = LocalClock.decode_with(encoded, %{3121231 => dummy_me})
    assert decoded == clock

    # decode_with fails on bad input
    assert_raise KeyError, fn -> LocalClock.decode_with(encoded, %{}) end
    assert_raise KeyError, fn -> LocalClock.decode_with(encoded, %{0 => 0}) end
    assert_raise FunctionClauseError, fn -> LocalClock.decode_with(encoded, %{3121231 => 0}) end
  end

  # encode_list_with
  test "encode_list_with() throws on invalid input" do
    assert_raise FunctionClauseError, fn -> LocalClock.encode_list_with(<<>>, %{dummy_me => 0}) end
    assert_raise FunctionClauseError, fn -> LocalClock.encode_list_with({}, %{dummy_me => 0}) end
    assert_raise FunctionClauseError, fn -> LocalClock.encode_list_with([{:ok}], %{dummy_me => 0}) end
    assert_raise FunctionClauseError, fn -> LocalClock.encode_list_with([:ok], %{dummy_me => 0}) end
  end

  # decode_list_with
  test "decode_list_with() throws on invalid input" do
    assert_raise FunctionClauseError, fn -> LocalClock.decode_list_with(<<>>, %{}) end
    assert_raise FunctionClauseError, fn -> LocalClock.decode_list_with({}, %{}) end
    assert_raise FunctionClauseError, fn -> LocalClock.decode_list_with(:ok, %{}) end
  end

  test "encode_list_with() works with decode_list_with()" do
    {_count, fwd, rev} = dummy_list |> Enum.reduce({0, %{}, %{}}, fn(x,acc) ->
      {count, fw, re} = acc
      {count+1, Map.put(fw, x, count), Map.put(re, count, x)}
    end)
    encoded = LocalClock.encode_list_with(dummy_clock_list, fwd)
    {decoded, <<>>} = LocalClock.decode_list_with(encoded, rev)

    assert decoded == dummy_clock_list

    # decode_list_with fails with bad input
    assert_raise KeyError, fn -> LocalClock.decode_list_with(encoded, %{}) end
    assert_raise KeyError, fn -> LocalClock.decode_list_with(encoded, %{0 => 0}) end
  end
end
