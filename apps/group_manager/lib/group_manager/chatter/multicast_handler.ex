defmodule GroupManager.Chatter.MulticastHandler do

  use ExActor.GenServer
  require GroupManager.Chatter.Gossip
  require GroupManager.Chatter.BroadcastID
  require GroupManager.Chatter.NetID
  alias GroupManager.Chatter.NetID
  alias GroupManager.Chatter.Gossip

  defstart start_link([ my_id: my_id,
                        multicast_addr: multicast_addr,
                        multicast_port: multicast_port,
                        multicast_ttl: ttl ],
                      opts),
    gen_server_opts: opts
  do
    my_addr = NetID.ip(my_id)

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
    initial_state(socket)
  end

  def send(pid, gossip)
  when Gossip.is_valid(gossip)
  do

  end

  # GenServer

  defcast stop, do: stop_server(:normal)

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
