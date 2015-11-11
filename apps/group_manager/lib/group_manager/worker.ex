defmodule GroupManager.Worker do
  @moduledoc """
  """
  
  use Supervisor
  
  def start_link(args, opts) do
    case args do
      [group_name: _, prefix: _] ->
        Supervisor.start_link(__MODULE__, args, opts)
      [group_name: _] ->
        prefixed_args = args ++ [prefix: nil]
        Supervisor.start_link(__MODULE__, prefixed_args, opts)
      end
  end

  def init([group_name: group_name, prefix: prefix]) do
    
    # IO.inspect ["worker opts", opts, group_name]
    chatter_name   = GroupManager.Chatter.id_atom(group_name, prefix)
    log_name       = GroupManager.Log.id_atom(group_name, prefix)
    monitor_name   = GroupManager.Monitor.id_atom(group_name, prefix)
    
    children = [
      worker(GroupManager.Chatter, [[group_name: group_name], [name: chatter_name]]),
      worker(GroupManager.Log,     [[group_name: group_name], [name: log_name]]),
      worker(GroupManager.Monitor, [[group_name: group_name], [name: monitor_name]])
    ]
    {:ok, pid} = supervise(children, strategy: :one_for_all)
  end
  
  # helpers without state
  def locate(group_name, prefix \\ nil) do
    Process.whereis(id_atom(group_name, prefix))
  end
  
  def id_atom(group_name, prefix \\ nil) do
    case prefix do
      nil -> String.to_atom("GroupManager.Worker." <> group_name)
      _ -> String.to_atom(prefix <> ".GroupManager.Worker." <> group_name)
    end
  end
end