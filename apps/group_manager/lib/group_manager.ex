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

  defmacro group_name_is_valid(name) do
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

  def join(peer, group_name)
  when NetID.is_valid(peer) and
       group_name_is_valid(group_name)
  do
    master_pid = GroupManager.Master.locate!()
    GroupManager.Master.start_group(master_pid, peer, group_name)
  end

  def leave(group_name)
  when group_name_is_valid(group_name)
  do
    master_pid = GroupManager.Master.locate!()
    GroupManager.Master.leave_group(master_pid, group_name)
  end

  @spec members(binary) :: {:ok, list(NetID.t)} | {:error, :not_joined}
  def members(group_name)
  when group_name_is_valid(group_name)
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

  # get topology
  # my entries -> Message / filter
  # add item
  # remove item

end
