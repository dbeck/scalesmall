defmodule GroupManager do

  use Application
  require GroupManager.Chatter.NetID
  alias GroupManager.Chatter.NetID
  alias GroupManager.Chatter
  alias GroupManager.MemberDB
  alias GroupManager.TopologyDB
  alias GroupManager.Data.Item

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

  def join(peers, group_name)
  when is_list(peers) and
       is_valid_group_name(group_name)
  do
    :ok = NetID.validate_list!(peers)

    # 1: register in the member database
    :ok = MemberDB.add(MemberDB.locate!, group_name, my_id)

    # 2: prepare a new message with the help of TopologyDB
    topo_db    = TopologyDB.locate!
    item       = Item.new(my_id) |> Item.op(:get)
    :ok        = topo_db |> TopologyDB.add_item(group_name, item)
    {:ok, msg} = topo_db |> TopologyDB.get(group_name)

    # 3: broadcast the new message
    :ok = Chatter.broadcast(peers, msg)
  end

  def leave(group_name)
  when is_valid_group_name(group_name)
  do
    :error
    #master_pid = GroupManager.Master.locate!()
    #GroupManager.Master.leave(master_pid, my_id(), group_name)

    # deregister local membership information
  end

  # TODO :
  @spec members(binary) :: list(NetID.t)
  def members(group_name)
  when is_valid_group_name(group_name)
  do
    #master_pid = GroupManager.Master.locate!()
    #GroupManager.Master.get_members(master_pid, group_name)
    :error
  end

  @spec joined_groups() :: {:ok, list(binary)}
  def joined_groups()
  do
    #master_pid = GroupManager.Master.locate!()
    #GroupManager.Master.joined_groups(master_pid)
    :error
  end

  @spec my_id() :: NetID.t
  def my_id(), do: Chatter.local_netid

  # get topology
  # my entries -> Message / filter
  # add item
  # remove item

end
