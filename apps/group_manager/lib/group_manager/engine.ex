defmodule GroupManager.Engine do

  use ExActor.GenServer
  alias GroupManager.Data.LocalClock

  defstart start_link(args, opts),
    gen_server_opts: opts
  do
    initial_state({:engine, LocalClock.new(node())})
  end
  
  defcall get, state: state, do: reply(state)  
  defcast stop, do: stop_server(:normal)
  
  def locate(group_name, prefix \\ nil) do
    Process.whereis(id_atom(group_name, prefix))
  end
  
  def id_atom(group_name, prefix \\ nil) do
    case prefix do
      nil -> String.to_atom("GroupManager.Engine." <> group_name)
      _ -> String.to_atom(prefix <> ".GroupManager.Engine." <> group_name)
    end
  end
end