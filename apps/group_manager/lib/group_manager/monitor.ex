defmodule GroupManager.Monitor do
  
  use ExActor.GenServer

  defstart start_link(args, opts),
    gen_server_opts: opts
  do
    initial_state(0)
  end
    
  defcall get, state: state, do: reply(state)
  defcast stop, do: stop_server(:normal)

  def locate(group_name, prefix \\ nil) do
    Process.whereis(id_atom(group_name, prefix))
  end
  
  def id_atom(group_name, prefix \\ nil) do
    case prefix do
      nil -> String.to_atom("GroupManager.Monitor." <> group_name)
      _ -> String.to_atom(prefix <> ".GroupManager.Monitor." <> group_name)
    end
  end
end