defmodule GroupManager.Data.TimedItem do

  require Record
  require GroupManager.Data.Item
  require GroupManager.Data.LocalClock
  require GroupManager.Chatter.NetID
  alias GroupManager.Data.Item
  alias GroupManager.Data.LocalClock
  alias GroupManager.Chatter.NetID
  alias GroupManager.Chatter.Serializer

  Record.defrecord :timed_item,
                   item: nil,
                   updated_at: nil

  @type t :: record( :timed_item,
                     item: Item.t,
                     updated_at: LocalClock.t )

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

  @spec validate_list(list(t)) :: :ok | :error
  def validate_list([]), do: :ok

  def validate_list([head|rest])
  do
    case valid?(head) do
      true -> validate_list(rest)
      false -> :error
    end
  end

  def validate_list(_), do: :error

  @spec validate_list!(list(t)) :: :ok
  def validate_list!([]), do: :ok

  def validate_list!([head|rest])
  when is_valid(head)
  do
    validate_list!(rest)
  end

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

  @spec encode_with(t, map) :: binary
  def encode_with(itm, id_map)
  when is_valid(itm) and
       is_map(id_map)
  do
    bin_item     = timed_item(itm, :item)       |> Item.encode_with(id_map)
    bin_updated  = timed_item(itm, :updated_at) |> LocalClock.encode_with(id_map)
    << bin_item :: binary,
       bin_updated :: binary >>
  end

  @spec decode_with(binary, map) :: {t, binary}
  def decode_with(bin, id_map)
  when is_binary(bin) and
       byte_size(bin) > 0 and
       is_map(id_map)
  do
    { decoded_item, remaining } = Item.decode_with(bin, id_map)
    { decoded_time, remaining } = LocalClock.decode_with(remaining, id_map)
    { timed_item([item: decoded_item, updated_at: decoded_time]), remaining }
  end

  @spec encode_list_with(list(t), map) :: binary
  def encode_list_with(elems, id_map)
  when is_list(elems) and
       is_map(id_map)
  do
    :ok = validate_list!(elems)
    bin_size  = elems |> length |> Serializer.encode_uint
    bin_list  = elems |> Enum.reduce(<<>>, fn(x,acc) ->
      acc <> encode_with(x, id_map)
    end)
    << bin_size :: binary,
       bin_list :: binary >>
  end

  @spec decode_list_with(binary, map) :: {list(t), binary}
  def decode_list_with(bin, id_map)
  do
    {count, remaining} = Serializer.decode_uint(bin)
    {list, remaining}  = decode_list_with_(remaining, count, [], id_map)
    {Enum.reverse(list), remaining}
  end

  defp decode_list_with_(<<>>, _count, acc, _map), do: {acc, <<>>}
  defp decode_list_with_(binary, 0, acc, _map), do: {acc, binary}

  defp decode_list_with_(msg, count, acc, map)
  when is_binary(msg) and
       is_integer(count) and
       count > 0 and
       is_list(acc) and
       is_map(map)
  do
    {id, remaining} = decode_with(msg, map)
    decode_list_with_(remaining, count-1, [id | acc], map)
  end
end
