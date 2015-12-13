defmodule GroupManager.Engine do

  use ExActor.GenServer
  alias GroupManager.Data.LocalClock
  alias GroupManager.Data.Message
  alias GroupManager.Data.TimedItem

  defstart start_link(args, opts),
    gen_server_opts: opts
  do
    initial_state({LocalClock.new(node()), Message.new()})
  end
  
  defcall get, state: state, do: reply(state)
    
  defcast add_item(item), state: state
  do
    {old_clock, msg} = state
    next_clock = LocalClock.next(old_clock)
    new_state( {next_clock, Message.add(msg, TimedItem.construct(item, next_clock))} )
  end
  
  defcast stop, do: stop_server(:normal)
  
  def locate(group_name) do
    Process.whereis(id_atom(group_name))
  end
  
  def id_atom(group_name) do
    String.to_atom("GroupManager.Engine." <> group_name)
  end
end