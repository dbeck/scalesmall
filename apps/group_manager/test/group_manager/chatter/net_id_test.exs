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
end