defmodule GroupManager.TopologyDB do

  use ExActor.GenServer
  require GroupManager
  require GroupManager.Chatter.NetID
  require GroupManager.Data.Message
  require GroupManager.Data.WorldClock
  require GroupManager.Data.TimedSet
  require GroupManager.Data.Item
  alias GroupManager.Data.Message
  alias GroupManager.Data.WorldClock
  alias GroupManager.Data.LocalClock
  alias GroupManager.Data.Item
  alias GroupManager.Data.TimedItem
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

  # note: we can merge in foreign data through adding a full message
  #       via add() but! we cannot merge in naked data for otehr nodes
  #       through add_item()
  def add_item(pid, group_name, item)
  when is_pid(pid) and
       GroupManager.is_valid_group_name(group_name) and
       Item.is_valid(item)
  do
    id = Item.member(item)
    {{:ok, ^id}, :lookup_own_id} = {GenServer.call(pid, {:get_id}), :lookup_own_id}
    GenServer.cast(pid, {:add_item, group_name, item})
  end

  def get(pid, group_name)
  when is_pid(pid) and
       GroupManager.is_valid_group_name(group_name)
  do
    GenServer.call(pid, {:get, group_name})
  end

  def get_id(pid)
  when is_pid(pid)
  do
    GenServer.call(pid, {:get_id})
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
    {:noreply, {own_id, table}}
  end

  def handle_cast({:add_item, group_name, item}, {own_id, table})
  when GroupManager.is_valid_group_name(group_name) and
       Item.is_valid(item) and
       Item.item(item, :member) == own_id
  do
    retval =
    case :ets.lookup(table, group_name)
    do
      [] ->
        clock = LocalClock.new(own_id)
        timed_item = TimedItem.construct(item, clock)
        new_message = Message.new(group_name) |> Message.add(timed_item)
        :ets.insert(table, new_message)
        {:noreply, {own_id, table}}

      [old_message] ->
        old_clock = old_message
        |> Message.time
        |> WorldClock.get(Item.member(item))

        if( old_clock == nil )
        do
          new_clock = LocalClock.new(Item.member(item))
        else
          new_clock = old_clock |> LocalClock.next
        end

        if( LocalClock.member(new_clock) == Item.member(item) )
        do
          timed_item = TimedItem.construct(item, new_clock)
          new_message = Message.add(old_message, timed_item)
          :ets.insert(table, new_message)
          {:noreply, {own_id, table}}
        else
          # TODO: warning
          {:noreply, {own_id, table}}
        end
    end
  end

  def handle_call({:get, group_name}, _from, {own_id, table})
  when GroupManager.is_valid_group_name(group_name)
  do
    case :ets.lookup(table, group_name)
    do
      []      -> {:reply, {:error, :not_found}, {own_id, table}}
      [value] -> {:reply, {:ok, value}, {own_id, table}}
    end
  end

  def handle_call({:get_id}, _from, {own_id, table})
  do
    {:reply, {:ok, own_id}, {own_id, table}}
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
