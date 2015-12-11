defmodule GroupManager.OutHandler do

  use ExActor.GenServer

  defstart start_link(args, opts),
    gen_server_opts: opts
  do
    initial_state(args)
  end
  
  defcast stop, do: stop_server(:normal)
  
  #def locate(group_name) do
  #  Process.whereis(id_atom(group_name))
  #end
  
  #def id_atom(group_name) do
  #  String.to_atom("GroupManager.Engine." <> group_name)
  #end
end