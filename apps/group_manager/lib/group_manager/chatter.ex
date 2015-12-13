defmodule GroupManager.Chatter do
  
  use Supervisor
  alias GroupManager.Chatter.OutgoingSupervisor
  alias GroupManager.Chatter.IncomingHandler
  alias GroupManager.Chatter.MulticastHandler
  alias GroupManager.Chatter.PeerDB
  
  def start_link(opts \\ []) do
    IO.inspect ["opts", opts]
    case opts do
      [name: name] ->
        Supervisor.start_link(__MODULE__, :no_args, opts)
      _ ->
        Supervisor.start_link(__MODULE__, :no_args, [name: id_atom()] ++ opts)
    end
  end
  
  def init(:no_args) do
    # TODO collect config parameters here ...
    opts = [port: 8001]
    listener_spec = :ranch.child_spec(
      :"GroupManager.Chatter.IncomingHandler",
      100,
      :ranch_tcp,
      opts,
      GroupManager.Chatter.IncomingHandler,
      []
    )
    multicast_args = [my_addr: {0,0,0,0}, port: 29999, multicast_addr: {224,0,1,1}, ttl: 4]
    children = [
      worker(PeerDB, [[], [name: PeerDB.id_atom()]]),
      listener_spec,
      supervisor(OutgoingSupervisor, [[], [name: OutgoingSupervisor.id_atom()]]),
      worker(MulticastHandler, [multicast_args, [name: MulticastHandler.id_atom()]])
    ]
    {:ok, pid} = supervise(children, strategy: :one_for_one)
  end
  
  def locate do
    case Process.whereis(id_atom()) do
      pid when is_pid(pid) ->
        pid
    end
  end
  
  def id_atom, do: __MODULE__
end
