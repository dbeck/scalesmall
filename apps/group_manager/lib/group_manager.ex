defmodule GroupManager do

  @moduledoc """
  `GroupManager` is the top level wrapper over the group management
  services provided by other modules:

  - `Chatter` is responsible for network communication
  - `Chatter.PeerDB` is a wrapper over the Chatter's knowledge about peers, stored in ETS
  - `GroupManager.TopologyDB` stores information about groups and their topology (ETS)
  """

  use Application
  require Logger
  require Chatter.NetID
  require GroupManager.Data.Item
  alias Chatter.NetID
  alias Chatter.EncoderDecoder
  alias Chatter.SerializerDB
  alias Chatter
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
    :random.seed(:os.timestamp)

    # register encoder and decoder for the Message type
    msg = Message.new("dummy")
    extract_fn  = fn(id)       -> Message.extract_netids(id) end
    encode_fn   = fn(id, ids)  -> Message.encode_with(id, ids) end
    decode_fn   = fn(bin, ids) -> Message.decode_with(bin, ids) end
    encdec = EncoderDecoder.new(msg, extract_fn, encode_fn, decode_fn)
    ser_db = SerializerDB.locate!
    SerializerDB.add(ser_db, encdec)
    {:ok, _encded} = SerializerDB.get(ser_db, msg)

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

  Example usage:
  ```
  iex(2)> GroupManager.join("G")
  :ok
  ```
  """
  @spec join(binary) :: :ok
  def join(group_name)
  when is_valid_group_name(group_name)
  do
    others = members(group_name)
    join(group_name, others)
  end

  @doc """
  Calling this function tells others that we leave the group. It first checks what
  we already know about the `group_name` and for each non-removal `Item` it generates
  a remove item and merges this into the topology. This effectively replaces all
  `:get` and `:add` items in the `TopologyDB` for our `NetID`.

  When the local `TopologyDB` is updated with our request, we send
  the new topology over to others. `Chatter` makes sure we both multicast the
  new topology and also broadcast to the `peers` (parameter, a list of `NetID`s).

  Parameters:

  - `group_name` a non-empty string

  Returns: :ok or an exception is raised

  Example usage:
  ```
  iex(2)> GroupManager.leave("G")
  :ok
  ```
  """
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
        Message.add(acc, TimedItem.construct_next(del_item, local_clock))
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

  @doc """
  returns the list of nodes participating in a group in the form
  of a list of `NetID`s.

  Example usage:

  ```
  iex(1)> GroupManager.my_id
  {:net_id, {192, 168, 1, 100}, 29999}
  iex(2)> GroupManager.join("G")
  :ok
  iex(3)> GroupManager.members("G")
  [{:net_id, {192, 168, 1, 100}, 29999}]
  ```
  """
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

  @doc """
  returns the list of groups this node has ever seen. Note that this
  checks the `TopologyDB` for the list of groups. `TopologyDB` may receive
  uopdates from other nodes through UDP multicast so the list of
  groups may contain group names without ever participating in any of them.

  Example usage:
  ```
  iex(1)> GroupManager.groups
  []
  iex(2)> GroupManager.join("G")
  :ok
  iex(3)> GroupManager.leave("G")
  :ok
  iex(4)> GroupManager.my_groups
  []
  iex(5)> GroupManager.groups
  ["G"]
  ```
  """
  @spec groups() :: {:ok, list(binary)}
  def groups()
  do
    TopologyDB.groups_
  end

  @doc """
  returns the list of groups we either want to receive messages from (:get `Item`) or
  we are actively participating in (:add `Item`)

  Example usage:

  ```
  iex(1)> GroupManager.join("G")
  :ok
  iex(2)> GroupManager.my_groups
  ["G"]
  ```
  """
  @spec my_groups() :: {:ok, list(binary)}
  def my_groups()
  do
    get_lst = TopologyDB.groups_(:get, my_id)
    add_lst = TopologyDB.groups_(:add, my_id)
    (get_lst ++ add_lst) |> Enum.uniq
  end

  @doc """
  returns the topology of the given group in the form of `list(TimedItem.t)`.

  The `TimedItem` element has an `Item` member that is the topology information
  together with a `LocalClock` which tells when the change has happened.

  Example usage:

  ```
  iex(1)> GroupManager.topology("G")
  []
  iex(2)> GroupManager.join("G")
  :ok
  iex(3)> GroupManager.topology("G")
  [{:timed_item,
    {:item, {:net_id, {192, 168, 1, 100}, 29999}, :get, 0, 4294967295, 0},
    {:local_clock, {:net_id, {192, 168, 1, 100}, 29999}, 0}}]
  iex(4)> GroupManager.add_item("G",0,255,11000)
  {:ok,
   {:timed_item, {:item, {:net_id, {192, 168, 1, 100}, 29999}, :add, 0, 255, 11000},
    {:local_clock, {:net_id, {192, 168, 1, 100}, 29999}, 1}}}
  iex(5)> GroupManager.topology("G")
  [{:timed_item, {:item, {:net_id, {192, 168, 1, 100}, 29999}, :add, 0, 255, 11000},
    {:local_clock, {:net_id, {192, 168, 1, 100}, 29999}, 1}},
   {:timed_item, {:item, {:net_id, {192, 168, 1, 100}, 29999}, :get, 0, 4294967295, 0},
    {:local_clock, {:net_id, {192, 168, 1, 100}, 29999}, 0}}]
  ```

  Explanation:

  - `iex(1)`: when topology is empty it returns an empty list
  - `iex(2)`: joining the group, which means we add a :get `Item` to the topology
  - `iex(3)`: the topology has a single :get `Item`
  - `iex(4)`: register that we want to serve the range 0-255 with port=11000
  - `iex(5)`: the topology now has two items, the `:get` and the `:add`
  """
  @spec topology(binary) :: list(TimedItem.t)
  def topology(group_name)
  when is_valid_group_name(group_name)
  do
    case TopologyDB.get_(group_name)
    do
      {:error, :not_found} ->
        []
      {:ok, msg} ->
        Message.items(msg)
        |> TimedSet.items
    end
  end

  @doc """
  see `topology(group_name)` for more information

  This variant of the `topology` function returns the filtered list of
  the topology items. The result set only has the items with the `op` field
  equals to the `filter` parameter.

  The filter parameter can be `:add`, `:rmv` or `:get`.
  """
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

  @doc """
  adds a topology item as an `:add` `Item` which represents a range that the
  given node wants to serve within the group. The responsability of the group is
  represented by a key range 0..0xffffffff. Each node tells what part of the range
  it wants to serve. Further ranges can be added and removed based on the node's
  decision, may be based on its capacity, speed or other factors.

  Parameters:

  - `group_name`
  - `from` and `to` represent the boundaries of the range
  - `port` is a hint to other nodes based on the node's capacities

  Example usage:

  ```
  iex(1)> GroupManager.add_item("G",1,2,3)
  {:ok,
   {:timed_item, {:item, {:net_id, {192, 168, 1, 100}, 29999}, :add, 1, 2, 3},
     {:local_clock, {:net_id, {192, 168, 1, 100}, 29999}, 0}}}
  iex(2)> GroupManager.my_groups
  ["G"]
  iex(3)> GroupManager.topology("G")
  [{:timed_item, {:item, {:net_id, {192, 168, 1, 100}, 29999}, :add, 1, 2, 3},
    {:local_clock, {:net_id, {192, 168, 1, 100}, 29999}, 0}}]
  ```

  Explanation:

  - `iex(1)`: add_item is also an implicit join to the group if it has not joined before
  - `iex(2)`: `my_groups` show that we are now part of the `G` group
  - `iex(3)`: the topology shows our new `:add` item
  """
  @spec add_item(binary, integer, integer, integer) :: {:ok, TimedItem.t}
  def add_item(group_name, from, to, port)
  when is_valid_group_name(group_name)
  do
    # 1: prepare a new message with the help of TopologyDB
    item               = Item.new(my_id) |> Item.set(:add, from, to, port)
    topo_db            = TopologyDB.locate!
    {:ok, timed_item}  = topo_db |> TopologyDB.add_item(group_name, item)
    {:ok, msg}         = topo_db |> TopologyDB.get(group_name)

    # 2: gather peers
    peers = members(group_name)

    # 3: broadcast the new message
    :ok = Chatter.broadcast(peers, msg)

    {:ok, timed_item}
  end

  @doc """
  similar to `add_item` except it adds a :rmv item to signify it no longer serves
  the given range
  """
  @spec remove_item(binary, integer, integer, integer) :: {:ok, TimedItem.t}
  def remove_item(group_name, from, to, port)
  when is_valid_group_name(group_name)
  do
    # 1: prepare a new message with the help of TopologyDB
    item               = Item.new(my_id) |> Item.set(:rmv, from, to, port)
    topo_db            = TopologyDB.locate!
    {:ok, timed_item}  = topo_db |> TopologyDB.add_item(group_name, item)
    {:ok, msg}         = topo_db |> TopologyDB.get(group_name)

    # 2: gather peers
    peers = members(group_name)

    # 3: broadcast the new message
    :ok = Chatter.broadcast(peers, msg)

    {:ok, timed_item}
  end

  @doc """
  return our local identifier as a `NetID`

  Example usage:

  ```
  iex(1)> GroupManager.my_id
  {:net_id, {192, 168, 1, 100}, 29999}
  ```
  """
  @spec my_id() :: NetID.t
  def my_id(), do: Chatter.local_netid
end
