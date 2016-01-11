defmodule GroupManager.Chatter.IncomingHandler do

  require GroupManager.Chatter.Gossip
  require GroupManager.Chatter.BroadcastID
  require GroupManager.Chatter.NetID
  alias GroupManager.Chatter.NetID
  alias GroupManager.Chatter.Gossip
  alias GroupManager.Chatter.Serializer
  alias GroupManager.Chatter.PeerDB

  def start_link(ref, socket, transport, opts) do
    pid = spawn_link(__MODULE__, :init, [ref, socket, transport, opts])
    {:ok, pid}
  end

  def init(ref, socket, transport, [own_id: own_id]) do
    :ok = :ranch.accept_ack(ref)
    loop(socket, transport, own_id)
  end

  def loop(socket, transport, own_id) do
    IO.puts "loop"
    case transport.recv(socket, 0, 5000) do
      {:ok, data} ->
        # process data
        case Serializer.decode(data)
        do
          {:ok, gossip} ->
            peer_db = PeerDB.locate!
            my_seqno = case PeerDB.get_broadcast_seqno_(own_id) do
              {:ok, tmp_seqno} -> tmp_seqno
              {:error, _} -> 0
            end

            # register whom the peer have seen
            PeerDB.add_seen_id_list(peer_db,
                                    Gossip.current_id(gossip),
                                    Gossip.seen_ids(gossip))

            IO.inspect ["received TCP", gossip]
            loop(socket, transport, own_id)

          {:error, :invalid_data, _} ->
            IO.puts "invalid data"
            :ok = transport.close(socket)
        end
      _ ->
        :ok = transport.close(socket)
    end
  end
end
