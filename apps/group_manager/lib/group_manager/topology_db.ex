defmodule GroupManager.TopologyDB do

  use ExActor.GenServer
  require GroupManager
  require GroupManager.Chatter.NetID
  require GroupManager.Data.Message
  require GroupManager.Data.WorldClock
  require GroupManager.Data.TimedSet
  require GroupManager.Data.Item
  alias GroupManager.Data.Message
  alias GroupManager.Data.Item
  alias GroupManager.Chatter

  defstart start_link(opts \\ []),
    gen_server_opts: opts
  do
    name    = Keyword.get(opts, :name, id_atom())
    own_id  = Keyword.get(opts, :own_id, Chatter.local_netid)
    table   = :ets.new(name, [:named_table, :set, :protected, {:keypos, 4}])
    initial_state({own_id, table})
  end

  # Convenience API

  def add(pid, message)
  when is_pid(pid) and
       Message.is_valid(message)
  do
    GenServer.cast(pid, {:add, message})
  end

  def add_item(pid, group_name, item)
  when is_pid(pid) and
       GroupManager.is_valid_group_name(group_name) and
       Item.is_valid(item)
  do
    GenServer.call(pid, {:add_item, group_name, item})
  end

  def get(pid, group_name)
  when is_pid(pid) and
       GroupManager.is_valid_group_name(group_name)
  do
    GenServer.call(pid, {:get, group_name})
  end

  # Direct, read-only ETS access
  # note: since the writer process may be slower than the readers
  #       the direct readers may not see the immediate result of the
  #       writes

  def get_(group_name)
  when GroupManager.is_valid_group_name(group_name)
  do
    case :ets.lookup(id_atom(), group_name)
    do
      []      -> {:error, :not_found}
      [value] -> {:ok, value}
    end
  end

  # GenServer

  defcast stop, do: stop_server(:normal)

  def handle_cast({:add, message}, {own_id, table})
  when Message.is_valid(message)
  do
  	case :ets.lookup(table, Message.group_name(message))
    do
      [] ->
        :ets.insert_new(table, message)
      [old_message] ->
        new_message = Message.merge(old_message, message)
      	:ets.insert(table, new_message)
    end
    {:noreply, table}
  end

  def handle_cast({:add_item, group_name, item}, {own_id, table})
  when GroupManager.is_valid_group_name(group_name) and
       Item.is_valid(item)
  do
    case :ets.lookup(table, group_name)
    do
      [] ->
        clock = LocalClock.new(own_id)
        timed_item = TimedItem.construct(item, clock)
        new_message = Message.new(group_name) |> Message.add(timed_item)
        :ets.insert(table, new_message)
      [old_message] ->
        old_clock = old_message
        |> Message.time
        |> WorldClock.get(own_id)
        if( old_clock == nil )
        do
          new_clock = LocalClock.new(own_id)
        else
          new_clock = old_clock |> LocalClock.next
        end
        timed_item = TimedItem.construct(item, new_clock)
        new_message = Message.add(old_message, timed_item)
        :ets.insert(table, new_message)
    end
    {:noreply, table}
  end

  def handle_call({:get, group_name}, _from, {own_id, table})
  when GroupManager.is_valid_group_name(group_name)
  do
    case :ets.lookup(table, group_name)
    do
      []      -> {:reply, {:error, []}, table}
      [value] -> {:reply, {:ok, value}, table}
    end
  end

  def locate, do: Process.whereis(id_atom())

  def locate! do
    case Process.whereis(id_atom()) do
      pid when is_pid(pid) ->
        pid
    end
  end

  def id_atom, do: __MODULE__
end
