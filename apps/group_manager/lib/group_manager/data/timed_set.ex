defmodule GroupManager.Data.TimedSet do

  require Record
  require GroupManager.Data.Item
  require GroupManager.Data.LocalClock
  require GroupManager.Data.TimedItem
  require GroupManager.Chatter.NetID
  alias GroupManager.Data.TimedItem

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
end
