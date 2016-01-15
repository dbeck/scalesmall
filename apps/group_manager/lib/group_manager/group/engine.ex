defmodule GroupManager.Group.Engine do

  use ExActor.GenServer
  alias GroupManager.Data.LocalClock
  alias GroupManager.Data.Message
  alias GroupManager.Data.TimedItem
  alias GroupManager.Chatter

  defstart start_link(args, opts),
    gen_server_opts: opts
  do
    own_id     = Keyword.get(args, :own_id, Chatter.local_netid)
    group_name = Keyword.get(args, :group_name)
    initial_state({LocalClock.new(own_id), Message.new(group_name)})
  end

  defcall get, state: state, do: reply(state)

  defcast add_item(item), state: state
  do
    {old_clock, msg} = state
    next_clock = LocalClock.next(old_clock)
    new_state( {next_clock, Message.add(msg, TimedItem.construct(item, next_clock))} )
  end

  defcast stop, do: stop_server(:normal)

  def locate(group_name), do: Process.whereis(id_atom(group_name))

  def locate!(group_name) do
    case Process.whereis(id_atom(group_name)) do
      pid when is_pid(pid) ->
        pid
    end
  end

  def id_atom(group_name) do
    String.to_atom("GroupManager.Group.Engine." <> group_name)
  end
end
