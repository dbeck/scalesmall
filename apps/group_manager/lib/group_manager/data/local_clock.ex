defmodule GroupManager.Data.LocalClock do
  @moduledoc """
  LocalClock tells what is/was the clock at a given member, this it has two elements:

  - `member` : term
  - `time_val` : non negative integer

  `LocalClock` itself is a Record type that we manipulate and access with the methods provided in the module.
  """

  require Record
  require GroupManager.Chatter.NetID
  alias GroupManager.Chatter.NetID

  Record.defrecord :local_clock, member: nil, time_val: 0
  @type t :: record( :local_clock, member: NetID.t, time_val: integer )
  @type local_clock_list :: list(t)

  @spec new(NetID.t) :: t
  def new(id)
  when NetID.is_valid(id)
  do
    local_clock(member: id)
  end

  @doc """
  Validate as much as we can about the `data` parameter which should be a LocalClock record.

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
          NetID.is_valid(:erlang.element(2, unquote(data))) and
          # time_val
          is_integer(:erlang.element(3, unquote(data))) and
          :erlang.element(3, unquote(data)) >= 0 and
          :erlang.element(3, unquote(data)) <= 0xffffffff
        end
      false ->
        quote bind_quoted: binding() do
          is_tuple(data) and tuple_size(data) == 3 and
          :erlang.element(1, data) == :local_clock and
          # member
          NetID.is_valid(:erlang.element(2, data)) and
          # time_val
          is_integer(:erlang.element(3, data)) and
          :erlang.element(3, data) >= 0 and
          :erlang.element(3, data) <= 0xffffffff
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

  @spec next(t) :: t
  def next(clock)
  when is_valid(clock)
  do
    {:local_clock, member, time} = clock
    {:local_clock, member, time+1}
  end

  @spec time_val(t) :: integer
  def time_val(clock)
  when is_valid(clock)
  do
    local_clock(clock, :time_val)
  end

  @spec member(t) :: NetID.t
  def member(clock)
  when is_valid(clock)
  do
    local_clock(clock, :member)
  end

  @spec merge_into(local_clock_list, t) :: local_clock_list
  def merge_into(lst, clock)
  when is_list(lst) and is_valid(clock)
  do
    # optimize this ???
    dict = Enum.map([clock|lst], fn(x) -> {member(x), time_val(x)} end)
    |> Enum.reduce(%{}, fn({m, t} ,acc) ->
      Map.update(acc, m, t, fn(prev_time) ->
        max(t, prev_time)
      end)
    end)
    keys = Map.keys(dict) |> Enum.sort
    Enum.map(keys, fn(k) -> local_clock(member: k) |> local_clock(time_val: Map.get(dict, k)) end)
  end

  @spec max_clock(t, t) :: t
  def max_clock(lhs, rhs)
  when is_valid(lhs) and is_valid(rhs) and local_clock(lhs, :member) == local_clock(rhs, :member)
  do
    new(member(lhs)) |> local_clock(time_val: max(time_val(lhs), time_val(rhs)))
  end
end
