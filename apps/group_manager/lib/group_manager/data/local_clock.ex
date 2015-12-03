defmodule GroupManager.Data.LocalClock do
  @moduledoc """
  LocalClock tells what is/was the clock at a given member, this it has two elements:
  
  - `member` : term
  - `time_val` : non negative integer
  
  `LocalClock` itself is a Record type that we manipulate and access with the methods provided in the module.
  """
  
  require Record
  Record.defrecord :local_clock, member: nil, time_val: 0
  @type t :: record( :local_clock, member: term, time_val: integer )
  
  @spec new(term) :: t
  def new(id)
  do
    local_clock(member: id)
  end
  
  @doc """
  Validate as much we can about the `data` parameter which should be an LocalClock record.
   
  Validation rules are:
  
  - 1st is an `:local_clock` atom
  - 2nd `member`: is a non nil term
  - 3rd `time_val:`: is non-negative integer [0x0..0xffffffff]
  
  The purpose of this macro is to help checking input parameters in function guards.
  """
  defmacro is_valid(data) do
    case Macro.Env.in_guard?(__CALLER__) do
      true ->
        quote do
          is_tuple(unquote(data)) and tuple_size(unquote(data)) == 3 and
          :erlang.element(1, unquote(data)) == :local_clock and
          # member
          is_nil(:erlang.element(2, unquote(data))) == false and
          # time_val
          is_integer(:erlang.element(3, unquote(data))) and
          :erlang.element(3, unquote(data)) >= 0 and
          :erlang.element(3, unquote(data)) <= 0xffffffff
        end
      false ->
        quote do
          result = unquote(data)
          is_tuple(result) and tuple_size(result) == 3 and
          :erlang.element(1, result) == :local_clock and
          # member
          is_nil(:erlang.element(2, result)) == false and
          # time_val
          is_integer(:erlang.element(3, result)) and
          :erlang.element(3, result) >= 0 and
          :erlang.element(3, result) <= 0xffffffff          
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
  
  @spec compare(t, t) :: :before | :after | :same | :different
  def compare(lhs, rhs)
  when is_valid(lhs) and is_valid(rhs)
  do
    {:local_clock, l_member, l_time} = lhs
    {:local_clock, r_member, r_time} = rhs
    cond do
      l_member != r_member -> :different
      l_time == r_time -> :same
      l_time < r_time -> :before
      l_time > r_time -> :after
    end
  end
  
  @spec next(t) :: t
  def next(clock)
  when is_valid(clock)
  do
    {:local_clock, member, time} = clock
    {:local_clock, member, time+1}
  end
end