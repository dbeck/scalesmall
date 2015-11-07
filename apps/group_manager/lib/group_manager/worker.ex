defmodule GroupManager.Worker do
  @moduledoc """
  """
  
  use Supervisor
  
  def start_link(opts \\ []) do
    Supervisor.start_link(__MODULE__, [])
  end

  def init([]) do
    children = [
      worker(GroupManager.Chatter, []),
      worker(GroupManager.Log, []),
      worker(GroupManager.Monitor, [])
    ]
    {:ok, pid} = supervise(children, strategy: :one_for_all)
  end
end