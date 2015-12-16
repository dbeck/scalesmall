defmodule GroupManager.Chatter.BroadcastID do
  
  require Record
  alias GroupManager.Chatter.NetID
  
  Record.defrecord :broadcast_id, origin: nil, seqno: nil
  @type t :: record( :broadcast_id, origin: NetID.t, seqno: integer )
  
  #@spec new() :: t
  def new()
  do
    :ok
  end
end
