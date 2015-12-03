defmodule GroupManager.Data.TimedSet do
  @moduledoc """
  TimedSet is a collection of TimedItems that represent the state of a collection as
  seen by the members of the group at their LocalClock time.
  """
  
  alias GroupManager.Data.TimedItem
  
  require Record
  Record.defrecord :timed_set, items: []
  @type t :: record( :timed_set, items: list(TimedItem.t) )
  
  @spec new() :: t
  def new()
  do
    timed_set()
  end
  
  @doc """
  Validate as much we can about the `data` parameter which should be an TimedSet record.
   
  Validation rules are:
  
  - 1st is an `:world_clock` atom
  - 2nd `items`: is a list
  
  The purpose of this macro is to help checking input parameters in function guards.
  """
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
        quote do
          result = unquote(data)
          is_tuple(result) and tuple_size(result) == 2 and
          :erlang.element(1, result) == :timed_set and
          # items
          is_list(:erlang.element(2, result))
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
          result = unquote(data)
          # items
          :erlang.element(2, result) == []
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
    
  # manipulators:
  # accessors:
end
