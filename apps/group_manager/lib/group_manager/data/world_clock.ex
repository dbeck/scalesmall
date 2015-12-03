defmodule GroupManager.Data.WorldClock do
  @moduledoc """
  WorldClock is a collection of LocalClocks gathered from members. WorldClocks can be merged by
  selecting the latest clock from members.
  """
  
  alias GroupManager.Data.LocalClock
  
  require Record
  Record.defrecord :world_clock, time: []
  @type t :: record( :world_clock, time: list(LocalClock.t) )
  
  @spec new() :: t
  def new()
  do
    world_clock(time: [])
  end

  @doc """
  Validate as much we can about the `data` parameter which should be an WorldClock record.
   
  Validation rules are:
  
  - 1st is an `:world_clock` atom
  - 2nd `time`: is a list
  
  The purpose of this macro is to help checking input parameters in function guards.
  """
  defmacro is_valid(data) do
    case Macro.Env.in_guard?(__CALLER__) do
      true ->
        quote do
          is_tuple(unquote(data)) and tuple_size(unquote(data)) == 2 and
          :erlang.element(1, unquote(data)) == :world_clock and   
          # time
          is_list(:erlang.element(2, unquote(data))) == true
        end
      false ->
        quote do
          result = unquote(data)
          is_tuple(result) and tuple_size(result) == 2 and
          :erlang.element(1, result) == :world_clock and
          # time
          is_list(:erlang.element(2, result)) == true
        end
    end
  end
  
  defmacro is_empty(data) do
    case Macro.Env.in_guard?(__CALLER__) do
      true ->
        quote do
          # time
          :erlang.element(2, unquote(data)) == []
        end
      false ->
        quote do
          result = unquote(data)
          # time
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
  # - add_local_clock(WorldClock, LocalClock)
  #     overwrites previous local clock
  #     keeps world clock sorted, and unique entries
  
  # accessors:
  # - delta_clock(WorldClock, WorldClock) ???
end