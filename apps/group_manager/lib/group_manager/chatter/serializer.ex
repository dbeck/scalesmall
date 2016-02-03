defmodule GroupManager.Chatter.Serializer do

  require GroupManager.Chatter.Gossip
  require GroupManager.Chatter.BroadcastID
  require GroupManager.Chatter.NetID
  alias GroupManager.Chatter.Gossip

  @spec encode(Gossip.t) :: binary
  def encode(gossip)
  when Gossip.is_valid(gossip)
  do
    {:ok, result} = :erlang.term_to_binary(gossip) |> :snappy.compress
  end

  @spec decode(binary) :: {:ok, Gossip.t} | {:error, :invalid_data, integer}
  def decode(msg)
  do
    {:ok, decomp} = :snappy.decompress(msg)
    gossip = :erlang.binary_to_term(decomp)
    if Gossip.valid?(gossip)
    do
      {:ok, gossip}
    else
      {:error, :invalid_data, byte_size(gossip)}
    end
  end
end
