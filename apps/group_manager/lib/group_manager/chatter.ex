defmodule GroupManager.Chatter do
  
  use Supervisor
  alias GroupManager.Chatter.OutgoingSupervisor
  alias GroupManager.Chatter.IncomingHandler
  alias GroupManager.Chatter.MulticastHandler
  alias GroupManager.Chatter.PeerDB
  
  def start_link(opts \\ []) do
    case opts do
      [name: name] ->
        Supervisor.start_link(__MODULE__, :no_args, opts)
      _ ->
        Supervisor.start_link(__MODULE__, :no_args, [name: id_atom()] ++ opts)
    end
  end
  
  def init(:no_args) do
    
    # TODO : make this config stuff nicer ...
    
    # try to figure our local IP if not given
    case Application.fetch_env(:group_manager, :my_addr) do
      {:ok, nil} ->
        my_addr = get_local_ip()      
      {:ok, my_addr_str} ->
        {:ok, my_addr} = my_addr_str |> String.to_char_list |> :inet_parse.address
      _ ->
        my_addr = get_local_ip()
    end         
    
    {:ok, my_port_str}     = Application.fetch_env(:group_manager, :my_port)
    {:ok, mcast_addr_str}  = Application.fetch_env(:group_manager, :multicast_addr)
    {:ok, mcast_port_str}  = Application.fetch_env(:group_manager, :multicast_port)
    {:ok, mcast_ttl_str}   = Application.fetch_env(:group_manager, :multicast_ttl)
    
    {my_port, ""}         = my_port_str    |> Integer.parse
    {:ok, multicast_addr} = mcast_addr_str |> String.to_char_list |> :inet_parse.address
    {multicast_port, ""}  = mcast_port_str |> Integer.parse
    {multicast_ttl, ""}   = mcast_ttl_str  |> Integer.parse
    
    opts = [port: my_port]
    listener_spec = :ranch.child_spec(
      :"GroupManager.Chatter.IncomingHandler",
      100,
      :ranch_tcp,
      opts,
      GroupManager.Chatter.IncomingHandler,
      []
    )
    
    multicast_args = [
      my_addr:         my_addr,
      my_port:         my_port,
      multicast_addr:  multicast_addr,
      multicast_port:  multicast_port,
      multicast_ttl:   multicast_ttl
    ]
    
    children = [
      worker(PeerDB, [[], [name: PeerDB.id_atom()]]),
      listener_spec,
      supervisor(OutgoingSupervisor, [[], [name: OutgoingSupervisor.id_atom()]]),
      worker(MulticastHandler, [multicast_args, [name: MulticastHandler.id_atom()]])
    ]
    
    {:ok, pid} = supervise(children, strategy: :one_for_one)
  end
  
  def broadcast(destination_list, payload) do
    :ok
  end
  
  def locate do
    case Process.whereis(id_atom()) do
      pid when is_pid(pid) ->
        pid
    end
  end
  
  def id_atom, do: __MODULE__
  
  def get_local_ip
  do
    {:ok, list} = :inet.getif
    [{ip, broadcast, netmask}] = list |> Enum.filter( fn({ip, bcast, nm}) -> bcast != :undefined end) |> Enum.take(1)
    ip
  end    
end
