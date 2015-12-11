defmodule GroupManager.ClientSup do

  use Supervisor
  alias GroupManager.OutHandler
  alias GroupManager.ClientSup
  
  def start_link(opts \\ []) do
    case opts do
      [name: name] ->
        Supervisor.start_link(__MODULE__, :no_arg, opts)
      _ ->
        Supervisor.start_link(__MODULE__, :no_arg, [name: __MODULE__] ++ opts)
    end
  end
  
  def init(:no_args) do
    children = [ supervisor(OutHandler, [], restart: :temporary) ]
    supervise(children, strategy: :simple_one_for_one)
  end
  
  def start_handler(sup_pid, [host: host, port: port, own_host: own_host, own_port: own_port])
  when is_pid(sup_pid)
  do
    Supervisor.start_child(sup_pid,
                          [
                            [host: group_name],
                            [port: worker_id],
                            [own_host: own_host],
                            [own_port: own_port]
                          ])
  end

  def locate do
    case Process.whereis(__MODULE__) do
      pid when is_pid(pid) ->
        pid
    end
  end
end