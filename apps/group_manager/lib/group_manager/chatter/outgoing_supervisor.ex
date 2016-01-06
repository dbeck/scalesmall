defmodule GroupManager.Chatter.OutgoingSupervisor do

  use Supervisor
  require GroupManager.Chatter.NetID
  alias GroupManager.Chatter.NetID
  alias GroupManager.Chatter.OutgoingHandler

  def start_link(args, opts \\ []) do
    case opts do
      [name: name] ->
        Supervisor.start_link(__MODULE__, args, opts)
      _ ->
        Supervisor.start_link(__MODULE__, args, [name: __MODULE__] ++ opts)
    end
  end

  def init(_args) do
    children = [ supervisor(OutgoingHandler, [], restart: :temporary) ]
    supervise(children, strategy: :simple_one_for_one)
  end

  def start_handler(sup_pid, [peer_id: peer, own_id: me])
  when is_pid(sup_pid) and
       NetID.is_valid(peer) and
       NetID.is_valid(me)
  do
    case OutgoingHandler.locate(peer) do
      handler_pid when is_pid(handler_pid) ->
        {:ok, handler_pid}
      _ ->
        id = OutgoingHandler.id_atom(peer)
        Supervisor.start_child(sup_pid, [[peer_id: peer, own_id: me], [name: id]])
    end
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
