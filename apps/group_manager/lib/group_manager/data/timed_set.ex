defmodule GroupManager.Data.TimedSet do

  require Record
  require GroupManager.Data.Item
  require GroupManager.Data.LocalClock
  require GroupManager.Data.TimedItem
  require GroupManager.Chatter.NetID
  alias GroupManager.Data.TimedItem
  alias GroupManager.Chatter.NetID
  alias GroupManager.Data.Item
  alias GroupManager.Data.LocalClock
  alias GroupManager.Chatter.Serializer

  Record.defrecord :timed_set,
                   items: []

  @type t :: record( :timed_set,
                     items: list(TimedItem.t) )

  @spec new() :: t
  def new()
  do
    timed_set()
  end

  defmacro is_valid(data) do
    case Macro.Env.in_guard?(__CALLER__) do
      true ->
        quote do
          is_tuple(unquote(data)) and tuple_size(unquote(data)) == 2 and
          :erlang.element(1, unquote(data)) == :timed_set and
          # items
          is_list(:erlang.element(2, unquote(data)))
        end
      false ->
        quote bind_quoted: binding() do
          is_tuple(data) and tuple_size(data) == 2 and
          :erlang.element(1, data) == :timed_set and
          # items
          is_list(:erlang.element(2, data))
        end
    end
  end

  defmacro is_empty(data) do
    case Macro.Env.in_guard?(__CALLER__) do
      true ->
        quote do
          # items
          :erlang.element(2, unquote(data)) == []
        end
      false ->
        quote do
          # items
          :erlang.element(2, unquote(data)) == []
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

  @spec items(t) :: list(TimedItem.t)
  def items(set)
  when is_valid(set)
  do
    timed_set(set, :items)
  end

  @spec add(t, TimedItem.t) :: t
  def add(set, item)
  when is_valid(set) and
       TimedItem.is_valid(item)
  do
    timed_set(items: TimedItem.merge(timed_set(set, :items), item))
  end

  @spec merge(t, t) :: t
  def merge(lhs, rhs)
  when is_valid(lhs) and
      is_valid(rhs)
  do
    timed_set(items: TimedItem.merge(timed_set(lhs, :items),
                                     timed_set(rhs, :items)))
  end

  @spec count(t, NetID.t) :: integer
  def count(set, id)
  when is_valid(set) and
       NetID.is_valid(id)
  do
    List.foldl(timed_set(set, :items), 0, fn(x, acc) ->
      item_id = TimedItem.item(x) |> Item.member
      if( item_id == id )
      do
        acc + 1
      else
        acc
      end
    end)
  end

  @spec count(t, LocalClock.t) :: integer
  def count(set, id)
  when is_valid(set) and
       LocalClock.is_valid(id)
  do
    List.foldl(timed_set(set, :items), 0, fn(x, acc) ->
      if( TimedItem.updated_at(x) == id )
      do
        acc + 1
      else
        acc
      end
    end)
  end

  @spec extract_netids(t) :: list(NetID.t)
  def extract_netids(set)
  when is_valid(set)
  do
    Enum.map(timed_set(set, :items), fn(x) -> TimedItem.updated_at(x) |> LocalClock.member end)
    |> Enum.uniq
  end

  @spec encode_with(t, map) :: binary
  def encode_with(set, id_map)
  when is_valid(set) and
       is_map(id_map)
  do
    bin_set_size = timed_set(set, :items) |> length |> Serializer.encode_uint
    bin_set      = timed_set(set, :items) |> Enum.reduce(<<>>, fn(x,acc) ->
      acc <> TimedItem.encode_with(x, id_map)
    end)
    << bin_set_size :: binary, bin_set :: binary >>
  end
end
