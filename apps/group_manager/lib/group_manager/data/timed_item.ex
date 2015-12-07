defmodule GroupManager.Data.TimedItem do
  @moduledoc """
  TimedItem is a state (`Item`) as seen by the various members at a given LocalClock time.
  """
  
  require Record
  require GroupManager.Data.Item
  require GroupManager.Data.LocalClock
  alias GroupManager.Data.Item
  alias GroupManager.Data.LocalClock
  
  Record.defrecord :timed_item, item: nil, updated_at: nil
  @type t :: record( :timed_item, item: Item.t, updated_at: LocalClock.t)
  @type timed_item_list :: list(t)
  
  @spec new(term) :: t
  def new(id)
  do
    timed_item(item: Item.new(id)) |> timed_item(updated_at: LocalClock.new(id))
  end
  
  @doc """
  Validate as much as we can about the `data` parameter which should be a TimedItem record.
   
  Validation rules are:
  
  - 1st is an `:timed_item` atom
  - 2nd `item`: is a valid `Item`
  - 3rd `updated_at`: is a valid `LocalClock`
  
  The purpose of this macro is to help checking input parameters in function guards.
  """
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
        quote bind_quoted: [result: data] do
          is_tuple(result) and tuple_size(result) == 3 and
          :erlang.element(1, result) == :timed_item and
          # item
          is_nil(:erlang.element(2, result)) == false and
          Item.is_valid(:erlang.element(2, result)) and
          # updated_at
          is_nil(:erlang.element(3, result)) == false and
          LocalClock.is_valid(:erlang.element(3, result))
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
  
  @spec construct(Item.t, LocalClock.t) :: t
  def construct(item, updated_at)
  when Item.is_valid(item) and LocalClock.is_valid(updated_at) and
       Item.item(item, :member) == LocalClock.local_clock(updated_at, :member)
  do    
    timed_item(item: item) |> timed_item(updated_at: updated_at)
  end

  @spec construct_next(Item.t, LocalClock.t) :: t
  def construct_next(item, updated_at)
  when Item.is_valid(item) and LocalClock.is_valid(updated_at) and
       Item.item(item, :member) == LocalClock.local_clock(updated_at, :member)
  do    
    timed_item(item: item) |> timed_item(updated_at: LocalClock.next(updated_at))
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
  
  @spec merge_into(timed_item_list, t) :: timed_item_list
  def merge_into(lst, itm)
  when is_list(lst) and is_valid(itm)
  do
    # optimize this ???
    dict = Enum.map([itm|lst], fn(x) -> {item(x), updated_at(x)} end)
    |> Enum.reduce(%{}, fn({i, t} ,acc) ->
      Map.update(acc, i, t, fn(prev_clock) ->
        Map.max_clock(t, prev_clock)
      end)
    end)
    keys = Map.keys(dict) |> Enum.sort
    Enum.map(keys, fn(k) -> timed_item(item: k) |> timed_item(updated_at: Map.get(dict, k)) end)
  end
end