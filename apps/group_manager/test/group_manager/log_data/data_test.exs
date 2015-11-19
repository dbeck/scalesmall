defmodule GroupManager.LogData.DataTest do
  use ExUnit.Case
  
  alias GroupManager.LogData.Data, as: Data

  test "can generate a deterministic hash" do
    data = %Data{prev_hash: 123}
    hash1 = Data.hash(data)
    hash2 = Data.hash(data) 
    assert hash1 == hash2
  end
end