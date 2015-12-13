defmodule GroupManager.Supervisor do
  
  use Supervisor
  alias GroupManager.OutgoingSupervisor
  alias GroupManager.IncomingHandler
  
  def start_link(opts \\ []) do
    IO.inspect ["opts", opts]
    case opts do
      [name: name] ->
        Supervisor.start_link(__MODULE__, :no_args, opts)
      _ ->
        Supervisor.start_link(__MODULE__, :no_args, [name: __MODULE__] ++ opts)
    end
  end
  
  def init(:no_args) do
    # TODO collect config parameters here ...
    opts = [port: 8001]
    listener_spec = :ranch.child_spec(
      :"GroupManager.IncomingHandler",
      100,
      :ranch_tcp,
      opts,
      GroupManager.IncomingHandler,
      []
    )
    children = [
      listener_spec,
      supervisor(OutgoingSupervisor, [[], []]),
      supervisor(GroupManager.Master, [])
    ]
    {:ok, pid} = supervise(children, strategy: :one_for_one)
  end
  
  def locate do
    case Process.whereis(__MODULE__) do
      pid when is_pid(pid) ->
        pid
    end
  end
end
