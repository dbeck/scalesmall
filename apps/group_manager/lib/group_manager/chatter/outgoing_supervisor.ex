defmodule GroupManager.Chatter.OutgoingSupervisor do

  use Supervisor
  require GroupManager.Chatter.NetID
  require GroupManager.Chatter.Gossip
  require GroupManager.Chatter.BroadcastID
  alias GroupManager.Chatter.NetID
  alias GroupManager.Chatter.BroadcastID
  alias GroupManager.Chatter.OutgoingHandler
  alias GroupManager.Chatter.Gossip

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

  def broadcast(gossip)
  when Gossip.is_valid(gossip)
  do
    broadcast_to(Gossip.distribution_list(gossip), gossip)
  end

  defp broadcast_to([], gossip), do: :ok

  defp broadcast_to(distribution_list, gossip)
  do
    len = length(distribution_list)
    take_n = div(len, 2)
    {next, [head|rest]} = distribution_list |> Enum.shuffle |> Enum.split(take_n)
    own_id = Gossip.current_id(gossip) |> BroadcastID.origin
    handler_pid = start_handler(locate!, [own_id: own_id, peer_id: head])
    OutgoingHandler.send(handler_pid, gossip |> Gossip.distribution_list(rest))
    broadcast_to(next, Gossip.distribution_list(gossip, next))
  end

  def start_handler(sup_pid, [own_id: own_id, peer_id: peer_id])
  when is_pid(sup_pid) and
       NetID.is_valid(peer_id) and
       NetID.is_valid(own_id)
  do
    case OutgoingHandler.locate(peer_id) do
      handler_pid when is_pid(handler_pid) ->
        {:ok, handler_pid}
      _ ->
        id = OutgoingHandler.id_atom(peer_id)
        Supervisor.start_child(sup_pid, [
          [peer_id: peer_id, own_id: own_id],
          [name: id]])
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
