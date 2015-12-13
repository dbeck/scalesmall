defmodule GroupManager.OutgoingHandler do

  use ExActor.GenServer

  defstart start_link([host: host, port: port, own_host: own_host, own_port: own_port], opts),
    gen_server_opts: opts
  do
    # kept 'active' so we can stop on anything from the other side
    opts = [:binary, active: true]
    {:ok, socket} = :gen_tcp.connect(host, port, opts)
    initial_state([host: host, port: port, own_host: own_host, own_port: own_port, socket: socket])
  end

  defcast stop, do: stop_server(:normal)

  # stop on any message or event from the other side
  def handle_info({:tcp_closed, _port}, state), do: {:stop, "socket closed", state}
  def handle_info({:tcp_error, _port, reason}, state), do: {:stop, reason, state}
  def handle_info(msg, state), do: {:stop, "unknown message received", state}

  def locate([host: host, port: port])
  when is_nil(host) == false and
       is_integer(port) and port > 0 and port < 65536
  do
    Process.whereis(id_atom([host: host, port: port]))
  end

  def id_atom([host: host, port: port])
  when is_nil(host) == false and
       is_integer(port) and port > 0 and port < 65536
  do
    String.to_atom("GroupManager.OutgoingHandler.#{host}:#{port}")
  end
end
