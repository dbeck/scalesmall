defmodule GroupManager.Master do
  @moduledoc """
  """
  
  use Supervisor
  
  def start_link(opts \\ []) do
    Supervisor.start_link(__MODULE__, :ok, [name: __MODULE__] ++ opts)
  end

  def init(:ok) do
    children = [
       supervisor(GroupManager.Worker, [], restart: :temporary)
    ]
    supervise(children, strategy: :simple_one_for_one)
  end
  
  def join(peer_name, group_name) do
  end
end
