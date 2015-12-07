defmodule GroupManager.Log do
    
  use ExActor.GenServer
  alias GroupManager.Data.MessageLog

  defstart start_link(args, opts),
    gen_server_opts: opts
  do
    initial_state(MessageLog.new())
  end
  
  defcall get, state: state, do: reply(state)
  defcast stop, do: stop_server(:normal)
  
  def locate(group_name, prefix \\ nil) do
    Process.whereis(id_atom(group_name, prefix))
  end
  
  def id_atom(group_name, prefix \\ nil) do
    case prefix do
      nil -> String.to_atom("GroupManager.Log." <> group_name)
      _ -> String.to_atom(prefix <> ".GroupManager.Log." <> group_name)
    end
  end
end