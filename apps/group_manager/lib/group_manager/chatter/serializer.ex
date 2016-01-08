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

  @spec decode(binary) :: Gossip.t
  def decode(msg)
  do
    gossip = :erlang.binary_to_term(msg)
    true = Gossip.valid?(gossip)
    gossip
  end
end
