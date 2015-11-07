defmodule GroupManager.Log do
  @moduledoc """
  """
  
  use ExActor.GenServer

  # boilerplate only ...
  defstart start_link, do: initial_state(0)
  defcall get, state: state, do: reply(state)
  defcast stop, do: stop_server(:normal)
  
end