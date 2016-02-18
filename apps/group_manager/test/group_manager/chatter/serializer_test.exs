defmodule GroupManager.Chatter.SerializerTest do
  use ExUnit.Case

  alias GroupManager.Chatter.Gossip
  alias GroupManager.Chatter.Serializer
  alias GroupManager.Chatter.NetID
  alias GroupManager.Data.Message

  @default_key "01234567890123456789012345678901"

  defp dummy_me do
    NetID.new({1,2,3,4},1)
  end

  test "encode and decode works together" do
    g = Gossip.new(dummy_me, 9999, Message.new("hello"))
    assert Gossip.valid?(g)
    encoded = Serializer.encode(g, @default_key)
    assert {:ok, decoded} = Serializer.decode(encoded, @default_key)
    assert Gossip.valid?(decoded)
    assert g == decoded
  end

  test "encode only works with valid Gossip" do
  	assert_raise FunctionClauseError, fn -> Serializer.encode(nil, @default_key) end
    assert_raise FunctionClauseError, fn -> Serializer.encode([], @default_key) end
    assert_raise FunctionClauseError, fn -> Serializer.encode({}, @default_key) end
    assert_raise FunctionClauseError, fn -> Serializer.encode({:ok}, @default_key) end
    assert_raise FunctionClauseError, fn -> Serializer.encode({:ok, nil}, @default_key) end
    assert_raise FunctionClauseError, fn -> Serializer.encode({:ok, nil, nil}, @default_key) end
    assert_raise FunctionClauseError, fn -> Serializer.encode({:gossip, nil}, @default_key) end
    assert_raise FunctionClauseError, fn -> Serializer.encode({:gossip, nil, nil}, @default_key) end
    assert_raise FunctionClauseError, fn -> Serializer.encode({:gossip, nil, nil, nil}, @default_key) end
  end

  test "decode returns error on invalid input" do
    assert_raise FunctionClauseError, fn -> Serializer.decode("hello world" <> @default_key <> @default_key, @default_key) end
  	assert {:error, :invalid_data, code} = Serializer.decode(<< 0xff >> <> "hello world" <> @default_key, @default_key)
  end

  test "encode and decode gossip" do
    g = {:gossip,
          {:broadcast_id, {:net_id, {192, 168, 1, 97}, 29999}, 4},
          [{:broadcast_id, {:net_id, {192, 168, 1, 100}, 29999}, 3},
           {:broadcast_id, {:net_id, {192, 168, 1, 134}, 29999}, 1}],
          [{:net_id, {192, 168, 1, 97}, 29999},
           {:net_id, {192, 168, 1, 100}, 29999},
           {:net_id, {192, 168, 1, 134}, 29999}],
          {:message,
           {:world_clock,
            [{:local_clock, {:net_id, {192, 168, 1, 97}, 29999}, 2},
             {:local_clock, {:net_id, {192, 168, 1, 100}, 29999}, 0},
             {:local_clock, {:net_id, {192, 168, 1, 134}, 29999}, 0}]},
           {:timed_set,
            [{:timed_item, {:item, {:net_id, {192, 168, 1, 97}, 29999}, :get, 0, 4294967295, 0},
                           {:local_clock, {:net_id, {192, 168, 1, 97}, 29999}, 2}},
             {:timed_item, {:item, {:net_id, {192, 168, 1, 100}, 29999}, :get, 0, 4294967295, 0},
                           {:local_clock, {:net_id, {192, 168, 1, 100}, 29999}, 0}},
             {:timed_item, {:item, {:net_id, {192, 168, 1, 134}, 29999}, :get, 0, 4294967295, 0},
                           {:local_clock, {:net_id, {192, 168, 1, 134}, 29999}, 0}}]}, "G"}}
    assert Gossip.valid?(g)
    assert {:ok, g} == Serializer.encode(g, @default_key) |> Serializer.decode(@default_key)
  end

  # encode/decode uint
  # encode/decode gossip
end
