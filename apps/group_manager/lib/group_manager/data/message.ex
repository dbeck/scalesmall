defmodule GroupManager.Data.Message do

  require Record
  require GroupManager.Data.WorldClock
  require GroupManager.Data.TimedSet
  require GroupManager.Data.TimedItem
  require GroupManager.Data.Item
  require GroupManager.Data.LocalClock
  require GroupManager.Chatter.NetID
  require GroupManager
  alias GroupManager.Data.WorldClock
  alias GroupManager.Data.TimedSet
  alias GroupManager.Data.TimedItem
  alias GroupManager.Data.Item
  alias GroupManager.Chatter.NetID
  alias GroupManager.Chatter.Serializer

  Record.defrecord :message,
                   time: nil,
                   items: nil,
                   group_name: nil

  @type t :: record( :message,
                     time: WorldClock.t,
                     items: TimedSet.t,
                     group_name: binary )

  @spec new(binary) :: t
  def new(group_name)
  when GroupManager.is_valid_group_name(group_name)
  do
    message([time: WorldClock.new(), items: TimedSet.new(), group_name: group_name])
  end

  defmacro is_valid(data) do
    case Macro.Env.in_guard?(__CALLER__) do
      true ->
        quote do
          is_tuple(unquote(data)) and tuple_size(unquote(data)) == 4 and
          :erlang.element(1, unquote(data)) == :message and
          # time
          is_nil(:erlang.element(2, unquote(data))) == false and
          WorldClock.is_valid(:erlang.element(2, unquote(data))) and
          # items
          is_nil(:erlang.element(3, unquote(data))) == false and
          TimedSet.is_valid(:erlang.element(3, unquote(data))) and
          # group_name
          GroupManager.is_valid_group_name(:erlang.element(4, unquote(data)))
        end
      false ->
        quote bind_quoted: binding() do
          is_tuple(data) and tuple_size(data) == 4 and
          :erlang.element(1, data) == :message and
          # time
          is_nil(:erlang.element(2, data)) == false and
          WorldClock.is_valid(:erlang.element(2, data)) and
          # items
          is_nil(:erlang.element(3, data)) == false and
          TimedSet.is_valid(:erlang.element(3, data)) and
          # group_name
          GroupManager.is_valid_group_name(:erlang.element(4, data))
        end
    end
  end

  defmacro is_empty(data) do
    case Macro.Env.in_guard?(__CALLER__) do
      true ->
        quote do
          # time
          WorldClock.is_empty(:erlang.element(2, unquote(data))) and
          # items
          TimedSet.is_empty(:erlang.element(3, unquote(data)))
        end
      false ->
        quote bind_quoted: binding() do
          # time
          WorldClock.is_empty(:erlang.element(2, data)) and
          # items
          TimedSet.is_empty(:erlang.element(3, data))
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

  @spec empty?(t) :: boolean
  def empty?(data)
  when is_valid(data) and
       is_empty(data)
  do
    true
  end

  def empty?(data)
  when is_valid(data)
  do
    false
  end

  @spec time(t) :: WorldClock.t
  def time(msg)
  when is_valid(msg)
  do
    message(msg, :time)
  end

  @spec items(t) :: TimedSet.t
  def items(msg)
  when is_valid(msg)
  do
    message(msg, :items)
  end

  @spec group_name(t) :: binary
  def group_name(msg)
  when is_valid(msg)
  do
    message(msg, :group_name)
  end

  @spec add(t, TimedItem.t) :: t
  def add(msg, timed_item)
  when is_valid(msg) and
       TimedItem.is_valid(timed_item)
  do
    msg
    |> message(time: WorldClock.add(message(msg, :time), TimedItem.updated_at(timed_item)))
    |> message(items: TimedSet.add(message(msg, :items), timed_item))
  end

  @spec merge(t,t) :: t
  def merge(lhs, rhs)
  when is_valid(lhs) and
       is_valid(rhs) and
       message(lhs, :group_name) == message(rhs, :group_name)
  do
    message(time: WorldClock.merge(message(lhs, :time),
                                   message(rhs, :time)))
    |> message(items: TimedSet.merge(message(lhs, :items),
                                     message(rhs, :items)))
    |> message(group_name: message(lhs, :group_name))
  end

  @spec members(t) :: list(NetID.t)
  def members(m)
  when is_valid(m)
  do
    List.foldl(message(m, :items) |> TimedSet.items, [], fn(x,acc) ->
      op = TimedItem.item(x) |> Item.op
      if( op == :rmv )
      do
        acc
      else
        member = TimedItem.item(x) |> Item.member
        [member|acc]
      end
    end) |> Enum.uniq
  end

  @spec topology(t) :: list(TimedItem.t)
  def topology(m)
  when is_valid(m)
  do
    List.foldl(message(m, :items) |> TimedSet.items, [], fn(x,acc) ->
      op = TimedItem.item(x) |> Item.op
      if( op == :rmv)
      do
        acc
      else
        [x|acc]
      end
    end)
  end

  @spec count(t, NetID.t, :add|:rmv|:get) :: integer
  def count(m, id, filter)
  when is_valid(m) and
       NetID.is_valid(id) and
       filter in [:add, :rmv, :get]
  do
    List.foldl(message(m, :items) |> TimedSet.items, 0, fn(x,acc) ->
      op     = TimedItem.item(x) |> Item.op
      member = TimedItem.item(x) |> Item.member
      if( op == filter and id == member )
      do
        acc+1
      else
        acc
      end
    end)
  end

  @spec extract_netids(t) :: list(NetID.t)
  def extract_netids(msg)
  when is_valid(msg)
  do
    ((message(msg, :time) |> WorldClock.extract_netids) ++
      (message(msg, :items) |> TimedSet.extract_netids))
    |> Enum.uniq
  end

  @spec encode_with(t, map) :: binary
  def encode_with(msg, id_map)
  when is_valid(msg) and
       is_map(id_map)
  do
    bin_time       = message(msg, :time)       |> WorldClock.encode_with(id_map)
    bin_items      = message(msg, :items)      |> TimedSet.encode_with(id_map)
    bin_name_size  = message(msg, :group_name) |> byte_size |> Serializer.encode_uint

    << bin_time                   :: binary,
       bin_items                  :: binary,
       bin_name_size              :: binary,
       message(msg, :group_name)  :: binary >>
  end

  @spec decode_with(binary, map) :: {t, binary}
  def decode_with(bin, id_map)
  when is_binary(bin) and
       byte_size(bin) > 0 and
       is_map(id_map)
  do
    {decoded_time, remaining}    = WorldClock.decode_with(bin, id_map)
    {decoded_items, remaining}   = TimedSet.decode_with(remaining, id_map)
    {name_size, remaining}       = Serializer.decode_uint(remaining)

    << name :: binary-size(name_size), remaining :: binary >> = remaining

    { message([time: decoded_time, items: decoded_items, group_name: name]), remaining }
  end
end
