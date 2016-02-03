defmodule GroupManager.Chatter.IncomingHandler do

  require Logger
  require GroupManager.Chatter.Gossip
  require GroupManager.Chatter.BroadcastID
  require GroupManager.Chatter.NetID
  alias GroupManager.Chatter.NetID
  alias GroupManager.Chatter.Gossip
  alias GroupManager.Chatter.Serializer
  alias GroupManager.Chatter.PeerDB
  alias GroupManager.Chatter
  alias GroupManager.Receiver
  alias GroupManager.TopologyDB

  def start_link(ref, socket, transport, opts) do
    pid = spawn_link(__MODULE__, :init, [ref, socket, transport, opts])
    {:ok, pid}
  end

  def init(ref, socket, transport, opts) do
    :ok = :ranch.accept_ack(ref)
    own_id = Keyword.get(opts, :own_id)
    timeout_seconds = Keyword.get(opts, :timeout_seconds, 60)
    loop(socket, transport, own_id, timeout_seconds, 0)
  end

  def loop(socket, transport, own_id, timeout_seconds, act_wait)
  when act_wait >= timeout_seconds
  do
    :ok = transport.close(socket)
  end

  def loop(socket, transport, own_id, timeout_seconds, act_wait)
  when NetID.is_valid(own_id) and
       is_integer(timeout_seconds) and
       is_integer(act_wait) and
       act_wait < timeout_seconds
  do
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

            Logger.info "received on TCP [#{inspect gossip}] size=[#{byte_size data}]"
            {:ok, new_message} = Receiver.handle(Receiver.locate!, Gossip.payload(gossip))

            # make sure we pass the message forward with the modified payload
            :ok = Chatter.broadcast(gossip |> Gossip.payload(new_message))

            loop(socket, transport, own_id, timeout_seconds, 0)

          {:error, :invalid_data, _} ->
            :ok = transport.close(socket)
        end

      {:error, :timeout} ->
        loop(socket, transport, own_id, timeout_seconds, act_wait+5)

      _ ->
        :ok = transport.close(socket)
    end
  end
end
