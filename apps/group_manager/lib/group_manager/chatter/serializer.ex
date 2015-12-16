defmodule GroupManager.Chatter.Serializer do

  alias GroupManager.Chatter.Gossip
  
  def encode(gossip) do
    :msg
  end
  
  def decode(msg) do
    :gossip
  end
end
