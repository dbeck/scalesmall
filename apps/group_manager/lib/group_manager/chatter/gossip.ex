defmodule GroupManager.Chatter.Gossip do
  
  require Record
  alias GroupManager.Chatter.BroadcastID
  alias GroupManager.Chatter.NetID
  
  Record.defrecord :gossip, broadcast_id: nil, seen_ids: [], distribution_list: [], payload: nil
  @type t :: record( :gossip, broadcast_id: BroadcastID.t, seen_ids: list(BroadcastID.t), distribution_list: list(NetID.t), payload: term )
  
  #@spec new() :: t
  def new()
  do
    :ok
  end
end
