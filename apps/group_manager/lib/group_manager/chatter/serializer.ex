defmodule GroupManager.Chatter.Serializer do

  require GroupManager.Chatter.Gossip
  require GroupManager.Chatter.BroadcastID
  require GroupManager.Chatter.NetID
  alias GroupManager.Chatter.Gossip

  @spec encode(Gossip.t) :: binary
  def encode(gossip)
  when Gossip.is_valid(gossip)
  do
    :erlang.term_to_binary(gossip)
  end

  @spec decode(binary) :: {:ok, Gossip.t} | {:error, :invalid_data, integer}
  def decode(msg)
  do
    gossip = :erlang.binary_to_term(msg)
    if Gossip.valid?(gossip)
    do
      {:ok, gossip}
    else
      {:error, :invalid_data, byte_size(gossip)}
    end
  end
end
