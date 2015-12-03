defmodule GroupManager.Worker do
  
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
    
    chatter_name   = GroupManager.Chatter.id_atom(group_name, prefix)
    log_name       = GroupManager.Log.id_atom(group_name, prefix)
    monitor_name   = GroupManager.Monitor.id_atom(group_name, prefix)
    engine_name    = GroupManager.Engine.id_atom(group_name, prefix)
    
    component_names = [
      group_name:    group_name,
      chatter_name:  chatter_name,
      log_name:      log_name,
      monitor_name:  monitor_name,
      engine_name:   engine_name
    ]
    
    children = [
      worker(GroupManager.Chatter, [component_names, [name: chatter_name]]),
      worker(GroupManager.Log,     [component_names, [name: log_name]]),
      worker(GroupManager.Monitor, [component_names, [name: monitor_name]]),
      worker(GroupManager.Engine,  [component_names, [name: engine_name]])
    ]
    {:ok, pid} = supervise(children, strategy: :one_for_all)
  end
  
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