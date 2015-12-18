defmodule GroupManager.Chatter.MulticastHandler do

  use ExActor.GenServer
  
  defstart start_link([ my_addr: my_addr,
                        my_port: my_port,
                        multicast_addr: multicast_addr,
                        multicast_port: multicast_port,
                        multicast_ttl: ttl ],
                      opts),
    gen_server_opts: opts
  do
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

  defcast stop, do: stop_server(:normal)
  
  #defcall foo, do: set_and_reply(new_state, response)
  
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
