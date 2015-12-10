defmodule GroupManager.ClientSup do

  use ExActor.GenServer

  defstart start_link(args, opts),
    gen_server_opts: opts
  do
    initial_state(0)
  end
  
  defcall get, state: state, do: reply(state)
    
  defcast stop, do: stop_server(:normal)
end
