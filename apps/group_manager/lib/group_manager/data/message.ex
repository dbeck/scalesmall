defmodule GroupManager.Data.Message do
  @moduledoc """
  Message is what we pass between members in order to reach an agreement about the state of the world.
  Message keeps track of added and removed items in two corresponding `TimedSet` items.
  
  `Message` itself is a Record type that we manipulate and access with the methods provided in the module.
  """
  
  require Record
  require GroupManager.Data.WorldClock
  require GroupManager.Data.TimedSet
  require GroupManager.Data.TimedItem
  require GroupManager.Data.Item
  require GroupManager.Data.LocalClock
  alias GroupManager.Data.WorldClock
  alias GroupManager.Data.TimedSet
  alias GroupManager.Data.TimedItem
  
  Record.defrecord :message, time: nil, added: nil, removed: nil
  @type t :: record( :message, time: WorldClock.t, added: TimedSet.t, removed: TimedSet.t )
  
  @spec new() :: t
  def new()
  do
    message(time: WorldClock.new()) |> message(added: TimedSet.new()) |> message(removed: TimedSet.new())
  end
      
  @doc """
  Validate as much we can about the `data` parameter which should be an Message record.
   
  Validation rules are:
  
  - 1st is an `:message` atom
  - 2nd `time`: is non-nil
  - 3rd `added`: is non-nil
  - 4th `removed`: is non-nil
  
  The purpose of this macro is to help checking input parameters in function guards.
  """
  defmacro is_valid(data) do
    case Macro.Env.in_guard?(__CALLER__) do
      true ->
        quote do
          is_tuple(unquote(data)) and tuple_size(unquote(data)) == 4 and
          :erlang.element(1, unquote(data)) == :message and
          # time
          is_nil(:erlang.element(2, unquote(data))) == false and
          WorldClock.is_valid(:erlang.element(2, unquote(data))) and
          # added
          is_nil(:erlang.element(3, unquote(data))) == false and
          TimedSet.is_valid(:erlang.element(3, unquote(data))) and
          # removed
          is_nil(:erlang.element(4, unquote(data))) == false and
          TimedSet.is_valid(:erlang.element(4, unquote(data)))
        end
      false ->
        quote do
          result = unquote(data)
          is_tuple(result) and tuple_size(result) == 4 and
          :erlang.element(1, result) == :message
          # time
          is_nil(:erlang.element(2, result)) == false and
          WorldClock.is_valid(:erlang.element(2, result)) and
          # added
          is_nil(:erlang.element(3, result)) == false and
          TimedSet.is_valid(:erlang.element(3, result)) and
          # removed
          is_nil(:erlang.element(4, result)) == false and
          TimedSet.is_valid(:erlang.element(4, result))
        end
    end
  end
  
  defmacro is_empty(data) do
    case Macro.Env.in_guard?(__CALLER__) do
      true ->
        quote do
          # time
          WorldClock.is_empty(:erlang.element(2, unquote(data))) and
          # added
          TimedSet.is_empty(:erlang.element(3, unquote(data))) and
          # removed
          TimedSet.is_empty(:erlang.element(4, unquote(data)))
        end
      false ->
        quote do
          result = unquote(data)
          # time
          WorldClock.is_empty(:erlang.element(2, result)) and
          # added
          TimedSet.is_empty(:erlang.element(3, result)) and
          # removed
          TimedSet.is_empty(:erlang.element(4, result))
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
  when is_valid(data) and is_empty(data)
  do
    true
  end
  
  def empty?(data)
  when is_valid(data)
  do
    false
  end
  
  @spec add(t, TimedItem.t) :: t
  def add(msg, timed_item)
  when is_valid(msg) and TimedItem.is_valid(timed_item)
  do
    {:message, time, added, removed} = msg
    {:message, WorldClock.add(time, TimedItem.updated_at(timed_item)), TimedItem.add(added, timed_item), removed}
  end
  
  @spec remove(t, TimedItem.t) :: t
  def remove(msg, timed_item)
  when is_valid(msg) and TimedItem.is_valid(timed_item)
  do
    {:message, time, added, removed} = msg
    {:message, WorldClock.add(time, TimedItem.updated_at(timed_item)), added, TimedItem.add(removed, timed_item) }
  end
end