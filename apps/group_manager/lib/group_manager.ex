defmodule GroupManager do
  @moduledoc """
  The GroupManager application allows you to:
  - join or leave a group of nodes
  - register your intent for participating in the group's purpose
    - the purpose is represented by a 32bit integer range and
    - a priority hint supplied by the participant
  - query the group's members

  The group members are identified by GroupManager.Chatter.NetID which is a pair
  of IP address and port.
  """

  use Application
  require GroupManager.Chatter.NetID
  alias GroupManager.Chatter.NetID
  alias GroupManager.Chatter

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

  # TODO : peers, my_id, group_name
  def join(peers, group_name)
  when is_list(peers) and
       is_valid_group_name(group_name)
  do
    :ok = NetID.validate_list!(peers)
    master_pid = GroupManager.Master.locate!()
    GroupManager.Master.join(master_pid, peers, my_id(), group_name)

    # register membership locally
    # send a dummy message to others to get members of the group
  end

  def leave(group_name)
  when is_valid_group_name(group_name)
  do
    master_pid = GroupManager.Master.locate!()
    GroupManager.Master.leave(master_pid, my_id(), group_name)

    # deregister local membership information
  end

  # TODO :
  @spec members(binary) :: list(NetID.t)
  def members(group_name)
  when is_valid_group_name(group_name)
  do
    master_pid = GroupManager.Master.locate!()
    GroupManager.Master.get_members(master_pid, group_name)
  end

  @spec joined_groups() :: {:ok, list(binary)}
  def joined_groups()
  do
    master_pid = GroupManager.Master.locate!()
    GroupManager.Master.joined_groups(master_pid)
  end

  @spec my_id() :: NetID.t
  def my_id(), do: Chatter.local_netid

  # get topology
  # my entries -> Message / filter
  # add item
  # remove item

end
