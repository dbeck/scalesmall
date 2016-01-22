defmodule GroupManager.Member.MemberData do

  require Record
  require GroupManager
  require GroupManager.Chatter.NetID
  alias GroupManager.Chatter.NetID

  Record.defrecord :member_data,
                   group_name: nil,
                   members: []

  @type t :: record( :member_data,
                     group_name: binary,
                     members: list(NetID.t) )

  @spec new(binary) :: t
  def new(group_name)
  when GroupManager.is_valid_group_name(group_name)
  do
    member_data(group_name: group_name)
  end

  defmacro is_valid(data) do
    case Macro.Env.in_guard?(__CALLER__) do
      true ->
        quote do
          is_tuple(unquote(data)) and tuple_size(unquote(data)) == 3 and
          :erlang.element(1, unquote(data)) == :member_data and
          # group_name
          GroupManager.is_valid_group_name(:erlang.element(2, unquote(data))) and
          # members
          is_list(:erlang.element(3, unquote(data)))
      	end
      false ->
        quote bind_quoted: binding() do
          is_tuple(data) and tuple_size(data) == 3 and
          :erlang.element(1, data) == :member_data and
          # group_name
          GroupManager.is_valid_group_name(:erlang.element(2, data)) and
          # members
          is_list(:erlang.element(3, data))
        end
    end
  end

  @spec valid?(t) :: boolean
  def valid?(data)
  when is_valid(data)
  do
    true
  end

  def valid?(_), do: false

  @spec members(t) :: list(NetID.t)
  def members(data)
  when is_valid(data)
  do
  	member_data(data, :members)
  end

  @spec add(t, NetID.t) :: t
  def add(data, member)
  when is_valid(data) and
       NetID.is_valid(member)
  do
  	newlist = [member| member_data(data, :members)]
  	|> Enum.into(HashSet.new)
  	|> HashSet.to_list
  	member_data(group_name: member_data(data, :group_name), members: newlist)
  end

  @spec remove(t, NetID.t) :: t
  def remove(data, member)
  when is_valid(data) and
       NetID.is_valid(member)
  do
  	newlist = member_data(data, :members)
  	|> Enum.filter( fn(x) -> x != member end)
  	member_data(group_name: member_data(data, :group_name), members: newlist)
  end
end
