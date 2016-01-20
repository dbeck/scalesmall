defmodule GroupManager.MemberDB do

  use ExActor.GenServer
  require GroupManager
  require GroupManager.Chatter.NetID
  require GroupManager.Member.MemberData
  alias GroupManager.Chatter.NetID
  alias GroupManager.Member.MemberData

  defstart start_link(opts \\ []),
    gen_server_opts: opts
  do
    name = Keyword.get(opts, :name, id_atom())
    table = :ets.new(name, [:named_table, :set, :protected, {:keypos, 2}])
    initial_state(table)
  end

  # Convenience API

  def add(pid, group_name, id)
  when is_pid(pid) and
       GroupManager.is_valid_group_name(group_name) and
       NetID.is_valid(id)
  do
    GenServer.cast(pid, {:add, group_name, id})
  end

  def remove(pid, group_name, id)
  when is_pid(pid) and
       GroupManager.is_valid_group_name(group_name) and
       NetID.is_valid(id)
  do
    GenServer.cast(pid, {:remove, group_name, id})
  end

  def members(pid, group_name)
  when is_pid(pid) and
       GroupManager.is_valid_group_name(group_name)
  do
    GenServer.call(pid, {:members, group_name})
  end

  # Direct, read-only ETS access
  # note: since the writer process may be slower than the readers
  #       the direct readers may not see the immediate result of the
  #       writes

  def members_(group_name)
  when GroupManager.is_valid_group_name(group_name)
  do
    case :ets.lookup(id_atom(), group_name)
    do
      []      -> {:error, :not_found}
      [value] -> {:ok, MemberData.members(value)}
    end
  end

  # GenServer

  defcast stop, do: stop_server(:normal)

  def handle_cast({:add, group_name, id}, table)
  when GroupManager.is_valid_group_name(group_name) and
       NetID.is_valid(id)
  do
  	case :ets.lookup(table, group_name)
    do
      [] ->
      	value = MemberData.new(group_name) |> MemberData.add(id)
      	:ets.insert_new(table, value)
      [value] ->
      	:ets.insert(table, MemberData.add(value,id))
    end
    {:noreply, table}
  end

  def handle_cast({:remove, group_name, id}, table)
  when GroupManager.is_valid_group_name(group_name) and
       NetID.is_valid(id)
  do
  	case :ets.lookup(table, group_name)
    do
      [] ->
      	:ets.insert_new(table, MemberData.new(group_name))
      [value] ->
      	:ets.insert(table, MemberData.remove(value,id))
    end
    {:noreply, table}
  end

  def handle_call({:members, group_name}, _from, table)
  when GroupManager.is_valid_group_name(group_name)
  do
    case :ets.lookup(table, group_name)
    do
      []      -> {:reply, {:error, []}, table}
      [value] -> {:reply, {:ok, MemberData.members(value)}, table}
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
