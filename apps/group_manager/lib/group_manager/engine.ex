defmodule GroupManager.Engine do
  @moduledoc """
  TODO
  """
  
  # TODO : state machine
  
  use ExActor.GenServer

  @doc """
  TODO
  """
  defstart start_link(args, opts),
    gen_server_opts: opts
  do
    initial_state(0)
  end
  
  @doc """
  TODO
  """  
  defcall get, state: state, do: reply(state)
  
  @doc """
  TODO
  """
  defcast stop, do: stop_server(:normal)
  
  @doc """
  TODO
  """
  def locate(group_name, prefix \\ nil) do
    Process.whereis(id_atom(group_name, prefix))
  end
  
  @doc """
  TODO
  """
  def id_atom(group_name, prefix \\ nil) do
    case prefix do
      nil -> String.to_atom("GroupManager.Engine." <> group_name)
      _ -> String.to_atom(prefix <> ".GroupManager.Engine." <> group_name)
    end
  end
end