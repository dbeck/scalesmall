defmodule GroupManager.Chatter.NetIDTest do
  use ExUnit.Case
  alias GroupManager.Chatter.NetID

  test "basic test for new" do
    assert NetID.valid?(NetID.new({127,0,0,1}, 29999))
  end

  test "basic test for invalid input" do
    assert NetID.valid?(nil) == false
    assert NetID.valid?([]) == false
    assert NetID.valid?({}) == false
    assert NetID.valid?(:ok) == false
    assert NetID.valid?({:ok}) == false
    assert NetID.valid?({:net_id}) == false
    assert NetID.valid?({:net_id, nil}) == false
    assert NetID.valid?({:net_id, nil, nil}) == false
    assert NetID.valid?({:net_id, nil, nil, nil}) == false
  end

  test "validate valid list" do
    id1 = NetID.new({127,0,0,1}, 29999)
    id2 = NetID.new({127,0,0,1}, 29998)
    id3 = NetID.new({127,0,0,1}, 29997)

    assert NetID.validate_list([]) == :ok
    assert NetID.validate_list([id1]) == :ok
    assert NetID.validate_list([id1, id2, id3]) == :ok
  end

  test "validate bad net_id list" do
    id1 = NetID.new({127,0,0,1}, 29999)
    id2 = NetID.new({127,0,0,1}, 29998)
    id3 = NetID.new({127,0,0,1}, 29997)

    assert NetID.validate_list([:ok]) == :error
    assert NetID.validate_list([{:net_id}]) == :error
    assert NetID.validate_list([id1, :ok]) == :error
    assert NetID.validate_list([:ok, id1]) == :error
    assert NetID.validate_list([id1, :error, id2, id3]) == :error
    assert NetID.validate_list([id1, id2, {:net_id}, id3]) == :error
    assert NetID.validate_list([id1, id2, id3, :ok]) == :error
    assert NetID.validate_list([id1, id2, id3, {:net_id}]) == :error
  end

  # ip
  # port
  # validate_list!

end
