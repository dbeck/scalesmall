defmodule GroupManager.Chatter.MulticastHandler do

  use ExActor.GenServer
  
  #  res = :gen_udp.open(9982, [:binary, active: :false, add_membership: {{224,0,0,1}, {0,0,0,0}}, multicast_if: {224,0,0,1}, multicast_loop: false, multicast_ttl: 4, reuseaddr: true])

  defstart start_link([my_addr: my_addr, port: port, multicast_addr: multicast_addr, ttl: ttl], opts),
    gen_server_opts: opts
  do
    {:ok, socket} = :gen_udp.open(
      port,
      [
        :binary, 
        active:          :false,
        add_membership:  { multicast_addr, my_addr},
        multicast_if:    multicast_addr,
        multicast_loop:  false,
        multicast_ttl:   ttl,
        reuseaddr:       true
      ]
    )
    initial_state(socket)
  end

  defcast stop, do: stop_server(:normal)

  def locate do
    case Process.whereis(id_atom()) do
      pid when is_pid(pid) ->
        pid
    end
  end
  
  def id_atom, do: __MODULE__
end
