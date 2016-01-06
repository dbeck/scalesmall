defmodule GroupManager.Chatter.OutgoingHandler do

  use ExActor.GenServer
  require GroupManager.Chatter.NetID
  alias GroupManager.Chatter.NetID

  defstart start_link([peer_id: peer, own_id: me], opts),
    gen_server_opts: opts
  do
    # kept 'active' so we can stop on anything from the other side
    opts = [:binary, active: true]
    true = NetID.valid?(peer)
    true = NetID.valid?(me)
    {:ok, socket} = :gen_tcp.connect(NetID.ip(peer), NetID.port(peer), opts)
    initial_state([peer_id: peer, own_id: me, socket: socket])
  end

  defcast stop, do: stop_server(:normal)

  # stop on any message or event from the other side
  def handle_info({:tcp_closed, _port}, state), do: {:stop, "socket closed", state}
  def handle_info({:tcp_error, _port, reason}, state), do: {:stop, reason, state}
  def handle_info(msg, state), do: {:stop, "unknown message received", state}

  def locate(id)
  when NetID.is_valid(id)
  do
    Process.whereis(id_atom(id))
  end

  def locate!(id)
  when NetID.is_valid(id)
  do
    case Process.whereis(id_atom(id)) do
      pid when is_pid(pid) ->
        pid
    end
  end

  def id_atom(id)
  when NetID.is_valid(id)
  do
    host = NetID.ip(id) |> :inet_parse.ntoa |> String.Chars.to_string
    String.to_atom("GroupManager.Chatter.OutgoingHandler.#{host}:#{NetID.port(id)}")
  end
end
