defmodule GroupManager.Chatter do

  use Supervisor
  require GroupManager.Data.Message
  require GroupManager.Data.WorldClock
  require GroupManager.Data.TimedSet
  alias GroupManager.Chatter.OutgoingSupervisor
  alias GroupManager.Chatter.IncomingHandler
  alias GroupManager.Chatter.MulticastHandler
  alias GroupManager.Chatter.PeerDB
  alias GroupManager.Chatter.NetID
  alias GroupManager.Chatter.Gossip
  alias GroupManager.Data.Message

  def start_link(opts \\ []) do
    case opts do
      [name: name] ->
        Supervisor.start_link(__MODULE__, :no_args, opts)
      _ ->
        Supervisor.start_link(__MODULE__, :no_args, [name: id_atom()] ++ opts)
    end
  end

  def init(:no_args) do

    {:ok, mcast_addr_str}  = Application.fetch_env(:group_manager, :multicast_addr)
    {:ok, mcast_port_str}  = Application.fetch_env(:group_manager, :multicast_port)
    {:ok, mcast_ttl_str}   = Application.fetch_env(:group_manager, :multicast_ttl)

    {:ok, multicast_addr} = mcast_addr_str |> String.to_char_list |> :inet_parse.address
    {multicast_port, ""}  = mcast_port_str |> Integer.parse
    {multicast_ttl, ""}   = mcast_ttl_str  |> Integer.parse

    my_id = local_netid()

    opts = [port: NetID.port(my_id)]

    listener_spec = :ranch.child_spec(
      :"GroupManager.Chatter.IncomingHandler",
      100,
      :ranch_tcp,
      opts,
      GroupManager.Chatter.IncomingHandler,
      []
    )

    multicast_args = [
      my_id:           my_id,
      multicast_addr:  multicast_addr,
      multicast_port:  multicast_port,
      multicast_ttl:   multicast_ttl
    ]

    children = [
      worker(PeerDB, [[], [name: PeerDB.id_atom()]]),
      listener_spec,
      supervisor(OutgoingSupervisor, [[], [name: OutgoingSupervisor.id_atom()]]),
      worker(MulticastHandler, [multicast_args, [name: MulticastHandler.id_atom()]])
    ]

    {:ok, pid} = supervise(children, strategy: :one_for_one)
  end

  @spec broadcast(list(NetID.t), Message.t) :: :ok
  def broadcast(destination_list, msg)
  when is_list(destination_list) and Message.is_valid(msg)
  do
    :ok = NetID.validate_list(destination_list)
    my_id = local_netid()
    seqno = PeerDB.inc_broadcast_seqno(my_id)

    # collect ids seen on multicast and update distribution list too
    gossip = Gossip.new(my_id, seqno, msg)
    |> Gossip.seen_ids(PeerDB.get_seen_ids_(my_id))
    |> Gossip.distribution_list(destination_list)

    # broadcast first and let MulticastHandler decide what to send directly
    direct_gossip = MulticastHandler.send(MulticastHandler.locate!, gossip)

    # outgoing handler uses its alrady open channels and returns the gossip
    # what couldn't be delivered
    # remaining = OutgoingHandler.send(OutgoingHandler.locate!, gossip)

    # TODO: handle what remains

    # TODO: (later) may be send a TCP message too ???
    # use reverse channels ??? : GroupManager.Chatter.IncomingHandler
  end

  def locate, do: Process.whereis(id_atom())

  def locate! do
    case Process.whereis(id_atom()) do
      pid when is_pid(pid) ->
        pid
    end
  end

  def id_atom, do: __MODULE__

  def get_local_ip
  do
    {:ok, list} = :inet.getif
    [{ip, broadcast, netmask}] = list |> Enum.filter( fn({ip, bcast, nm}) -> bcast != :undefined end) |> Enum.take(1)
    ip
  end

  def local_netid
  do
    # try to figure our local IP if not given
    case Application.fetch_env(:group_manager, :my_addr) do
      {:ok, nil} ->
        my_addr = get_local_ip()
      {:ok, my_addr_str} ->
        {:ok, my_addr} = my_addr_str |> String.to_char_list |> :inet_parse.address
      _ ->
        my_addr = get_local_ip()
    end

    {:ok, my_port_str} = Application.fetch_env(:group_manager, :my_port)
    {my_port, ""}      = my_port_str |> Integer.parse

    NetID.new(my_addr, my_port)
  end
end
