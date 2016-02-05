defmodule GroupManager do

  @moduledoc """
  `GroupManager` is the top level wrapper over the group management
  services provided by other modules:

  - `GroupManager.Chatter` is responsible for network communication
  - `GroupManager.Chatter.PeerDB` is a wrapper over the Chatter's knowledge about peers, stored in ETS
  - `GroupManager.TopologyDB` stores information about groups and their topology (ETS)
  """

  use Application
  require GroupManager.Chatter.NetID
  require GroupManager.Data.Item
  alias GroupManager.Chatter.NetID
  alias GroupManager.Chatter
  alias GroupManager.TopologyDB
  alias GroupManager.Data.Item
  alias GroupManager.Data.TimedItem
  alias GroupManager.Data.TimedSet
  alias GroupManager.Data.Message

  @doc """
  Helper macro used in function guards to validate group names.
  """
  defmacro is_valid_group_name(name) do
    case Macro.Env.in_guard?(__CALLER__) do
      true ->
        quote do
          is_binary(unquote(name)) and byte_size(unquote(name)) > 0
        end
      false ->
        quote bind_quoted: binding() do
          is_binary(name) and byte_size(name) > 0
        end
    end
  end

  @doc false
  def start(_type, args)
  do
    GroupManager.Supervisor.start_link(args)
  end

  @doc """
  Calling this function registers our interest in a group. It first checks what
  we already know about the `group_name` and combines the information with our
  intent to participate in the group. This combined information is the group
  topology stored in the `TopologyDB`.

  When the local `TopologyDB` is updated with our request to participate, we send
  the new topology over to others. `Chatter` makes sure we both multicast the
  new topology and also broadcast to the `peers` (parameter, a list of `NetID`s).

  Parameters:

  - `group_name` a non-empty string
  - `peers` a list of `NetID`s

  Returns: :ok or an exception is raised

  Example `NetID`:

  ```
  iex(1)> GroupManager.my_id
  {:net_id, {192, 168, 1, 100}, 29999}
  ```

  Example usage:
  ```
  iex(2)> GroupManager.join("G", [])
  :ok
  ```
  """
  @spec join(binary, list(NetID.t)) :: :ok
  def join(group_name, peers)
  when is_valid_group_name(group_name) and
       is_list(peers)
  do
    :ok = NetID.validate_list!(peers)

    # 1: prepare a new message with the help of TopologyDB
    topo_db    = TopologyDB.locate!
    item       = Item.new(my_id) |> Item.op(:get)
    {:ok, _}   = topo_db |> TopologyDB.add_item(group_name, item)
    {:ok, msg} = topo_db |> TopologyDB.get(group_name)

    # 2: broadcast the new message
    :ok = Chatter.broadcast(peers, msg)
  end

  @doc """
  see `join(group_name, peers)`

  The only difference is that this function checks the members of the group with
  the help of the `GroupManager.member(group_name)` function. The group
  membership information comes from the `TopologyDB`.

  When it gathered the group members it calls `join(group_name, peers)` with that
  member list.
  """
  @spec join(binary) :: :ok
  def join(group_name)
  when is_valid_group_name(group_name)
  do
    others = members(group_name)
    join(group_name, others)
  end

  @spec leave(binary) :: :ok
  def leave(group_name)
  when is_valid_group_name(group_name)
  do
    # 1: prepare a leave message with the help of TopologyDB
    topo_db    = TopologyDB.locate!
    item       = Item.new(my_id) |> Item.op(:rmv)
    {:ok, _}   = topo_db |> TopologyDB.add_item(group_name, item)
    {:ok, msg} = topo_db |> TopologyDB.get(group_name)

    # 2: remove all other group participation from the message
    topology = Message.topology(msg)
    msg = List.foldl(topology, msg, fn(x,acc) ->
      del_item = TimedItem.item(x) |> Item.op(:rmv)
      if( Item.member(del_item) == my_id )
      do
        local_clock = TimedItem.updated_at(x)
        Message.add_item(acc, TimedItem.construct_next(del_item, local_clock))
      else
        acc
      end
    end)

    # 3: update topo DB and get a new msg to be distributed
    :ok = topo_db |> TopologyDB.add(msg)
    {:ok, msg} = topo_db |> TopologyDB.get(group_name)

    # 4: broadcast the new message
    others = members(group_name)
    :ok = Chatter.broadcast(others, msg)
  end

  @spec members(binary) :: list(NetID.t)
  def members(group_name)
  when is_valid_group_name(group_name)
  do
    case TopologyDB.get(TopologyDB.locate!, group_name)
    do
      {:error, :not_found} -> []
      {:ok, msg}           -> Message.members(msg)
    end
  end

  @spec groups() :: {:ok, list(binary)}
  def groups()
  do
    TopologyDB.groups_
  end

  @spec my_groups() :: {:ok, list(binary)}
  def my_groups()
  do
    TopologyDB.groups_(:get, my_id) ++ TopologyDB.groups_(:add, my_id)
    |> Enum.uniq
  end

  @spec topology(binary) :: list(TimedItem.t)
  def topology(group_name)
  when is_valid_group_name(group_name)
  do
    case TopologyDB.get_(group_name)
    do
      {:error, :not_found} ->
        []
      {:ok, msg} ->
        Message.items(msg) |> TimedSet.items
    end
  end

  @spec topology(binary, :add|:rmv|:get) :: list(TimedItem.t)
  def topology(group_name, filter)
  when is_valid_group_name(group_name) and
       filter in [:add, :rmv, :get]
  do
    case TopologyDB.get_(group_name)
    do
      {:error, :not_found} ->
        []
      {:ok, msg} ->
        Message.items(msg)
        |> TimedSet.items
        |> Enum.filter(fn(x) -> (filter == TimedItem.item(x) |> Item.op) end)
    end
  end

  @spec add_item(binary, integer, integer, integer) :: {:ok, TimedItem.t}
  def add_item(group_name, from, to, priority)
  when is_valid_group_name(group_name)
  do
    # 1: prepare a new message with the help of TopologyDB
    item               = Item.new(my_id) |> Item.set(:add, from, to, priority)
    topo_db            = TopologyDB.locate!
    {:ok, timed_item}  = topo_db |> TopologyDB.add_item(group_name, item)
    {:ok, msg}         = topo_db |> TopologyDB.get(group_name)

    # 2: gather peers
    peers = members(group_name)

    # 3: broadcast the new message
    :ok = Chatter.broadcast(peers, msg)

    {:ok, timed_item}
  end

  @spec remove_item(binary, integer, integer, integer) :: {:ok, TimedItem.t}
  def remove_item(group_name, from, to, priority)
  when is_valid_group_name(group_name)
  do
    # 1: prepare a new message with the help of TopologyDB
    item               = Item.new(my_id) |> Item.set(:rmv, from, to, priority)
    topo_db            = TopologyDB.locate!
    {:ok, timed_item}  = topo_db |> TopologyDB.add_item(group_name, item)
    {:ok, msg}         = topo_db |> TopologyDB.get(group_name)

    # 2: gather peers
    peers = members(group_name)

    # 3: broadcast the new message
    :ok = Chatter.broadcast(peers, msg)

    {:ok, timed_item}
  end

  @spec my_id() :: NetID.t
  def my_id(), do: Chatter.local_netid

end
