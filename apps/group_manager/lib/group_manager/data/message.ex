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
end
