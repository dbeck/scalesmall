defmodule GroupManager.Data.LocalClock do

  require Record
  require GroupManager.Chatter.NetID
  alias GroupManager.Chatter.NetID
  alias GroupManager.Chatter.Serializer

  Record.defrecord :local_clock,
                   member: nil,
                   time_val: 0

  @type t :: record( :local_clock,
                     member: NetID.t,
                     time_val: integer )

  @type local_clock_list :: list(t)

  @spec new(NetID.t) :: t
  def new(id)
  when NetID.is_valid(id)
  do
    local_clock(member: id)
  end

  @spec new(NetID.t, integer) :: t
  def new(id, time)
  when NetID.is_valid(id) and
       is_integer(time) and
       time >= 0 and
       time <= 0xffffffff
  do
    local_clock(member: id) |> local_clock(time_val: time)
  end

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
    local_clock(clock, time_val: local_clock(clock, :time_val)+1)
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

  @spec merge(local_clock_list, t) :: local_clock_list
  def merge(lhs, rhs)
  when is_list(lhs) and
       is_valid(rhs)
  do
    # optimize this ???
    dict = Enum.map([rhs|lhs], fn(x) -> {member(x), time_val(x)} end)
    |> Enum.reduce(%{}, fn({m, t} ,acc) ->
      Map.update(acc, m, t, fn(prev_time) ->
        max(t, prev_time)
      end)
    end)
    keys = Map.keys(dict) |> Enum.sort
    Enum.map(keys, fn(k) ->
      local_clock(member: k)
      |> local_clock(time_val: Map.get(dict, k))
    end)
  end

  @spec merge(local_clock_list, local_clock_list) :: local_clock_list
  def merge(lhs, rhs)
  when is_list(lhs) and
       is_list(rhs)
  do
    # optimize this ???
    dict = Enum.map(lhs ++ rhs, fn(x) -> {member(x), time_val(x)} end)
    |> Enum.reduce(%{}, fn({m, t} ,acc) ->
      Map.update(acc, m, t, fn(prev_time) ->
        max(t, prev_time)
      end)
    end)
    keys = Map.keys(dict) |> Enum.sort
    Enum.map(keys, fn(k) ->
      local_clock(member: k)
      |> local_clock(time_val: Map.get(dict, k))
    end)
  end

  @spec max_clock(t, t) :: t
  def max_clock(lhs, rhs)
  when is_valid(lhs) and
       is_valid(rhs) and
       local_clock(lhs, :member) == local_clock(rhs, :member)
  do
    if( local_clock(lhs, :time_val) > local_clock(rhs, :time_val) )
    do
      lhs
    else
      rhs
    end
  end

  @spec encode_with(t, map) :: binary
  def encode_with(clock, id_map)
  when is_valid(clock) and
       is_map(id_map)
  do
    id = Map.fetch!(id_map, local_clock(clock, :member))
    << Serializer.encode_uint(id) :: binary,
       Serializer.encode_uint(local_clock(clock, :time_val)) :: binary >>
  end

  @spec decode_with(binary, map) :: {t, binary}
  def decode_with(bin, id_map)
  when is_binary(bin) and
       byte_size(bin) > 0 and
       is_map(id_map)
  do
    {id, rest}    = Serializer.decode_uint(bin)
    {time, rest}  = Serializer.decode_uint(rest)
    net_id        = Map.fetch!(id_map, id)
    {new(net_id,time) , rest}
  end
end
