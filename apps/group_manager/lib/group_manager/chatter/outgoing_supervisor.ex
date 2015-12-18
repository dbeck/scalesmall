defmodule GroupManager.Chatter.OutgoingSupervisor do

  use Supervisor
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
  
  def start_handler(sup_pid, [host: host, port: port, own_host: own_host, own_port: own_port])
  when is_pid(sup_pid) and
       is_nil(host) == false and
       is_integer(port) and port > 0 and port < 65536 and
       is_nil(own_host) == false and
       is_integer(own_port) and own_port > 0 and own_port < 65536
  do
    case OutgoingHandler.locate([host: host, port: port]) do
      handler_pid when is_pid(handler_pid) ->
        {:ok, handler_pid}
      _ ->
        id = OutgoingHandler.id_atom([host: host, port: port])
        Supervisor.start_child(sup_pid, [[host: host, port: port, own_host: own_host, own_port: own_port], [name: id]])
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