defmodule GroupManager.Sup do
  
  use Supervisor
  
  def start_link(opts \\ []) do
    case opts do
      [name: name] ->
        Supervisor.start_link(__MODULE__, :no_args, opts)
      _ ->
        Supervisor.start_link(__MODULE__, :no_args, [name: __MODULE__] ++ opts)
    end
  end
  
  def init(:no_args) do
    opts = [port: 8001]
    listener_spec = :ranch.child_spec(:"GroupManager.InHandler", 100, :ranch_tcp, opts, GroupManager.InHandler, [])
    children = [
      listener_spec,
      worker(GroupManager.ClientSup, [[], [name: :"GroupManager.ClientSup"]]),
      supervisor(GroupManager.Master, [])
    ]
    {:ok, pid} = supervise(children, strategy: :one_for_one)
  end
  
end
