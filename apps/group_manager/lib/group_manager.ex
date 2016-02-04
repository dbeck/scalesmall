defmodule GroupManager do

  use Application
  require GroupManager.Chatter.NetID
  alias GroupManager.Chatter.NetID
  alias GroupManager.Chatter
  alias GroupManager.TopologyDB
  alias GroupManager.Data.Item
  alias GroupManager.Data.TimedItem
  alias GroupManager.Data.Message

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

  def start(_type, args)
  do
    GroupManager.Supervisor.start_link(args)
  end

  def join(group_name, peers)
  when is_valid_group_name(group_name) and
       is_list(peers)
  do
    :ok = NetID.validate_list!(peers)

    # 1: prepare a new message with the help of TopologyDB
    topo_db    = TopologyDB.locate!
    item       = Item.new(my_id) |> Item.op(:get)
    :ok        = topo_db |> TopologyDB.add_item(group_name, item)
    {:ok, msg} = topo_db |> TopologyDB.get(group_name)

    # 2: broadcast the new message
    :ok = Chatter.broadcast(peers, msg)
  end

  def join(group_name)
  when is_valid_group_name(group_name)
  do
    others = members(group_name)
    join(group_name, others)
  end

  def leave(group_name)
  when is_valid_group_name(group_name)
  do
    # 1: prepare a leave message with the help of TopologyDB
    topo_db    = TopologyDB.locate!
    item       = Item.new(my_id) |> Item.op(:rmv)
    :ok        = topo_db |> TopologyDB.add_item(group_name, item)
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

  @spec my_id() :: NetID.t
  def my_id(), do: Chatter.local_netid

  # get topology
  # my entries -> Message / filter
  # add item
  # remove item

end
