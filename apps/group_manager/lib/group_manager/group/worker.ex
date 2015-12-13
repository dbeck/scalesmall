defmodule GroupManager.Worker do
  
  use Supervisor
  
  def start_link(args, opts) do
    Supervisor.start_link(__MODULE__, args, opts)
  end

  def init([group_name: group_name]) do
    
    engine_name = GroupManager.Engine.id_atom(group_name)
    
    component_names = [
      group_name:    group_name,
      engine_name:   engine_name
    ]
    
    children = [
      worker(GroupManager.Engine,  [component_names, [name: engine_name]])
    ]
    
    {:ok, pid} = supervise(children, strategy: :one_for_all)
  end
  
  def locate(group_name) do
    Process.whereis(id_atom(group_name))
  end
  
  def id_atom(group_name) do
    String.to_atom("GroupManager.Worker." <> group_name)
  end
end