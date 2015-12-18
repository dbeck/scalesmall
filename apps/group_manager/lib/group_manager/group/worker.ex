defmodule GroupManager.Group.Worker do
  
  use Supervisor
  alias GroupManager.Group.Engine
  
  def start_link(args, opts) do
    Supervisor.start_link(__MODULE__, args, opts)
  end

  def init([group_name: group_name]) do
    
    engine_name = Engine.id_atom(group_name)
    
    component_names = [
      group_name:    group_name,
      engine_name:   engine_name
    ]
    
    children = [
      worker(Engine, [component_names, [name: engine_name]])
    ]
    
    {:ok, pid} = supervise(children, strategy: :one_for_all)
  end
  
  def locate(group_name), do: Process.whereis(id_atom(group_name))
  
  def locate!(group_name) do
    case Process.whereis(id_atom(group_name)) do
      pid when is_pid(pid) ->
        pid
    end
  end
  
  def id_atom(group_name) do
    String.to_atom("GroupManager.Group.Worker." <> group_name)
  end
end