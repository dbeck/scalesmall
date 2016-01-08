defmodule GroupManager.Chatter.MulticastHandler do

  use ExActor.GenServer
  require GroupManager.Chatter.Gossip
  require GroupManager.Chatter.BroadcastID
  require GroupManager.Chatter.NetID
  alias GroupManager.Chatter.NetID
  alias GroupManager.Chatter.Gossip
  alias GroupManager.Chatter.Serializer

  defstart start_link([my_id: my_id,
                       multicast_id: multi_id,
                       multicast_ttl: ttl],
                      opts),
    gen_server_opts: opts
  do
    my_addr         = NetID.ip(my_id)
    multicast_addr  = NetID.ip(multi_id)
    multicast_port  = NetID.port(multi_id)

    udp_options = [
      :binary,
      active:          10,
      add_membership:  { multicast_addr, my_addr },
      multicast_if:    my_addr,
      multicast_loop:  false,
      multicast_ttl:   ttl,
      reuseaddr:       true
    ]

    {:ok, socket} = :gen_udp.open( multicast_port, udp_options )
    initial_state([socket: socket, my_id: my_id, multicast_id: multi_id])
  end

  @spec send(pid, Gossip.t) :: Gossip.t
  def send(pid, gossip)
  when is_pid(pid) and Gossip.is_valid(gossip)
  do
    GenServer.call(pid, {:send, gossip})
  end

  # GenServer

  defcast stop, do: stop_server(:normal)

  def handle_call({:send, gossip}, _from, state)
  when Gossip.is_valid(gossip)
  do
    [socket: socket, my_id: _, multicast_id: multi_id] = state
    packet = Serializer.encode(gossip)
    case :gen_udp.send(socket, NetID.ip(multi_id), NetID.port(multi_id), packet)
    do
      :ok ->
        {:reply, {:ok, gossip}, state}

      {:error, reason} ->
        :gen_udp.close(socket)
        {:stop, reason, :error, state}
    end
  end

  # incoming handler
  def handle_info({:udp, socket, ip, port, data}, state)
  do
    # when we popped one message we allow one more to be buffered
    :inet.setopts(socket, [active: 1])
    IO.inspect data
    {:noreply, state}
  end

  def handle_info(msg, state)
  do
    {:noreply, state}
  end

  def locate, do: Process.whereis(id_atom())

  def locate! do
    case Process.whereis(id_atom()) do
      pid when is_pid(pid) ->
        pid
    end
  end

  def id_atom, do: __MODULE__
end
