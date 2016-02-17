defmodule GroupManager.Chatter.SerializerTest do
  use ExUnit.Case

  alias GroupManager.Chatter.Gossip
  alias GroupManager.Chatter.Serializer
  alias GroupManager.Chatter.NetID

  test "encode and decode works together" do
    g = Gossip.new(NetID.new({127,0,0,1}, 29999), 9999, [])
    assert Gossip.valid?(g)
    encoded = Serializer.encode(g)
    assert {:ok, decoded} = Serializer.decode(encoded)
    assert Gossip.valid?(decoded)
    assert g == decoded
  end

  test "encode only works with valid Gossip" do
  	assert_raise FunctionClauseError, fn -> Serializer.encode(nil) end
    assert_raise FunctionClauseError, fn -> Serializer.encode([]) end
    assert_raise FunctionClauseError, fn -> Serializer.encode({}) end
    assert_raise FunctionClauseError, fn -> Serializer.encode({:ok}) end
    assert_raise FunctionClauseError, fn -> Serializer.encode({:ok, nil}) end
    assert_raise FunctionClauseError, fn -> Serializer.encode({:ok, nil, nil}) end
    assert_raise FunctionClauseError, fn -> Serializer.encode({:gossip, nil}) end
    assert_raise FunctionClauseError, fn -> Serializer.encode({:gossip, nil, nil}) end
    assert_raise FunctionClauseError, fn -> Serializer.encode({:gossip, nil, nil, nil}) end
  end

  test "decode returns error on invalid input" do
  	assert {:error, :invalid_data, size} = Serializer.decode("hello")
  	assert is_integer(size)
  	assert size > 0
  end

  # encode/decode uint
  # encode/decode gossip
end
