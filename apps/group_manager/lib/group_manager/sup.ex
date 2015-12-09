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
    children = [
      worker(GroupManager.Chatter, [[], [name: :"GroupManager.Chatter"]]),
      supervisor(GroupManager.Master, [])
    ]
    {:ok, pid} = supervise(children, strategy: :one_for_one)
  end
  
end