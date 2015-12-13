defmodule GroupManager.Chatter.MulticastHandler do

  use ExActor.GenServer

  defstart start_link([host: _host, port: _port, multicast_host: _multicast_host], opts),
    gen_server_opts: opts
  do
    initial_state([])
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
