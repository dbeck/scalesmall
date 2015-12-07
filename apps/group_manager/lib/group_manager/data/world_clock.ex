defmodule GroupManager.Data.WorldClock do
  @moduledoc """
  WorldClock is a collection of LocalClocks gathered from members. WorldClocks can be merged by
  selecting the latest clock from members.
  """
  
  require Record
  require GroupManager.Data.LocalClock
  alias GroupManager.Data.LocalClock
  
  Record.defrecord :world_clock, time: []
  @type t :: record( :world_clock, time: list(LocalClock.t) )
  
  @spec new() :: t
  def new()
  do
    world_clock(time: [])
  end

  @doc """
  Validate as much as we can about the `data` parameter which should be a WorldClock record.
   
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
        quote bind_quoted: [result: data] do
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
  
  @spec time(t) :: list(LocalClock.t)
  def time(clock)
  when is_valid(clock)
  do
    world_clock(clock, :time)
  end
  
  @spec add(t, LocalClock.t) :: t
  def add(clock, local_clock)
  when is_valid(clock) and LocalClock.is_valid(local_clock)
  do
    world_clock(time: LocalClock.merge_into(time(clock), local_clock))
  end
  
  @spec size(t) :: integer
  def size(clock)
  when is_valid(clock)
  do
    length(world_clock(clock, :time))
  end
  
  @spec get(t, term) :: LocalClock.t
  def get(clock, id)
  when is_valid(clock)
  do
    [result] = Enum.reduce(world_clock(clock, :time), [], fn(local, acc) ->
      case LocalClock.member(local) do
        ^id -> [local|acc]
        _ -> acc
      end
    end) |> Enum.take(1)
    result
  end
  
  # accessors:
  # - delta_clock(WorldClock, WorldClock) ???
end