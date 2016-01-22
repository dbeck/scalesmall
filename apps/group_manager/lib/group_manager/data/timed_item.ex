defmodule GroupManager.Data.TimedItem do

  require Record
  require GroupManager.Data.Item
  require GroupManager.Data.LocalClock
  require GroupManager.Chatter.NetID
  alias GroupManager.Data.Item
  alias GroupManager.Data.LocalClock
  alias GroupManager.Chatter.NetID

  Record.defrecord :timed_item, item: nil, updated_at: nil
  @type t :: record( :timed_item, item: Item.t, updated_at: LocalClock.t)
  @type timed_item_list :: list(t)

  @spec new(NetID.t) :: t
  def new(id)
  when NetID.is_valid(id)
  do
    timed_item(item: Item.new(id))
    |> timed_item(updated_at: LocalClock.new(id))
  end

  defmacro is_valid(data) do
    case Macro.Env.in_guard?(__CALLER__) do
      true ->
        quote do
          is_tuple(unquote(data)) and tuple_size(unquote(data)) == 3 and
          :erlang.element(1, unquote(data)) == :timed_item and
          # item
          is_nil(:erlang.element(2, unquote(data))) == false and
          Item.is_valid(:erlang.element(2, unquote(data))) and
          # updated_at
          is_nil(:erlang.element(3, unquote(data))) == false and
          LocalClock.is_valid(:erlang.element(3, unquote(data)))
        end
      false ->
        quote bind_quoted: binding() do
          is_tuple(data) and tuple_size(data) == 3 and
          :erlang.element(1, data) == :timed_item and
          # item
          is_nil(:erlang.element(2, data)) == false and
          Item.is_valid(:erlang.element(2, data)) and
          # updated_at
          is_nil(:erlang.element(3, data)) == false and
          LocalClock.is_valid(:erlang.element(3, data))
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

  @spec item(TimedItem.t) :: Item.t
  def item(itm)
  when is_valid(itm)
  do
    timed_item(itm, :item)
  end

  @spec updated_at(TimedItem.t) :: LocalClock.t
  def updated_at(itm)
  when is_valid(itm)
  do
    timed_item(itm, :updated_at)
  end

  @spec construct(Item.t, LocalClock.t) :: t
  def construct(item, updated_at)
  when Item.is_valid(item) and
       LocalClock.is_valid(updated_at) and
       Item.item(item, :member) == LocalClock.local_clock(updated_at, :member)
  do
    timed_item(item: item) |> timed_item(updated_at: updated_at)
  end

  @spec construct_next(Item.t, LocalClock.t) :: t
  def construct_next(item, updated_at)
  when Item.is_valid(item) and
       LocalClock.is_valid(updated_at) and
       Item.item(item, :member) == LocalClock.local_clock(updated_at, :member)
  do
    timed_item(item: item) |> timed_item(updated_at: LocalClock.next(updated_at))
  end

  @spec max_item(t, t) :: t
  def max_item(lhs, rhs)
  when is_valid(lhs) and is_valid(rhs)
  do
    if LocalClock.max_clock(updated_at(lhs), updated_at(rhs)) == updated_at(lhs)
    do
      lhs
    else
      rhs
    end
  end

  @spec merge(timed_item_list, t) :: timed_item_list
  def merge(lhs, rhs)
  when is_list(lhs) and
       is_valid(rhs)
  do
    # optimize this ???
    dict = Enum.map([rhs|lhs], fn(x) -> {
      # keep items based on the {member, start_range, end_range} triple
      { timed_item(x, :item) |> Item.member,
        timed_item(x, :item) |> Item.start_range,
        timed_item(x, :item) |> Item.end_range },
      x } end)
    |> Enum.reduce(%{}, fn({key, value} ,acc) ->
      Map.update(acc, key, value, fn(other_value) ->
        max_item(value, other_value)
      end)
    end)
    keys = Map.keys(dict) |> Enum.sort
    Enum.map(keys, fn(key) -> Map.get(dict, key) end)
  end

  @spec merge(timed_item_list, timed_item_list) :: timed_item_list
  def merge(lhs, rhs)
  when is_list(lhs) and
       is_list(rhs)
  do
    # TODO : optimize this ???
    dict = Enum.map(lhs ++ rhs, fn(x) -> {
      # keep items based on the {member, start_range, end_range} triple
      { item(x) |> Item.member,
        item(x) |> Item.start_range,
        item(x) |> Item.end_range },
      x } end)
    |> Enum.reduce(%{}, fn({key, value} ,acc) ->
      Map.update(acc, key, value, fn(other_value) ->
        max_item(value, other_value)
      end)
    end)
    keys = Map.keys(dict) |> Enum.sort
    Enum.map(keys, fn(key) -> Map.get(dict, key) end)
  end
end
