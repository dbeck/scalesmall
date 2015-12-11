defmodule GroupManager.ClientSup do

  use Supervisor
  alias GroupManager.OutHandler
  
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

end