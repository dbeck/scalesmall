defmodule GroupManager.Chatter.Serializer do

  require GroupManager.Chatter.Gossip
  require GroupManager.Chatter.BroadcastID
  require GroupManager.Chatter.NetID
  alias GroupManager.Chatter.Gossip

  def encode(gossip)
  when Gossip.is_valid(gossip)
  do
    <<"hello">>
  end

  def decode(msg)
  do
    :gossip
  end
end
