defmodule GroupManager.Data.WorldClock do

  require Record
  require GroupManager.Data.LocalClock
  require Chatter.NetID
  alias GroupManager.Data.LocalClock
  alias Chatter.NetID

  Record.defrecord :world_clock,
                   time: []

  @type t :: record( :world_clock,
                     time: list(LocalClock.t) )

  @spec new() :: t
  def new()
  do
    world_clock(time: [])
  end

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

  @spec time(t) :: list(LocalClock.t)
  def time(clock)
  when is_valid(clock)
  do
    world_clock(clock, :time)
  end

  @spec add(t, LocalClock.t) :: t
  def add(clock, local_clock)
  when is_valid(clock) and
       LocalClock.is_valid(local_clock)
  do
    world_clock(time: LocalClock.merge(world_clock(clock, :time), local_clock))
  end

  @spec size(t) :: integer
  def size(clock)
  when is_valid(clock)
  do
    length(world_clock(clock, :time))
  end

  @spec get(t, NetID.t) :: LocalClock.t | nil
  def get(clock, id)
  when is_valid(clock) and
       NetID.is_valid(id)
  do
    world_clock(clock, :time) |> Enum.find(fn(x) -> LocalClock.member(x) == id end)
  end

  @spec next(t, NetID.t) :: t
  def next(clock, id)
  when is_valid(clock) and
       NetID.is_valid(id)
  do
    case get(clock, id) do
      nil         -> add(clock, LocalClock.new(id))
      local_clock -> add(clock, LocalClock.next(local_clock))
    end
  end

  @spec merge(t, t) :: t
  def merge(lhs, rhs)
  when is_valid(lhs) and
       is_valid(rhs)
  do
    world_clock(time: LocalClock.merge(world_clock(lhs, :time),
                                       world_clock(rhs, :time)))
  end

  @spec count(t, NetID.t) :: integer
  def count(clock, id)
  when is_valid(clock) and
       NetID.is_valid(id)
  do
    List.foldl(world_clock(clock, :time), 0, fn(x, acc) ->
      clock_id = LocalClock.member(x)
      if( clock_id == id )
      do
        acc + 1
      else
        acc
      end
    end)
  end

  @spec count(t, LocalClock.t) :: integer
  def count(clock, id)
  when is_valid(clock) and
       LocalClock.is_valid(id)
  do
    List.foldl(world_clock(clock, :time), 0, fn(x, acc) ->
      if( x == id )
      do
        acc + 1
      else
        acc
      end
    end)
  end

  @spec extract_netids(t) :: list(NetID.t)
  def extract_netids(clock)
  when is_valid(clock)
  do
    Enum.map(world_clock(clock, :time), fn(x) -> LocalClock.member(x) end)
    |> Enum.uniq
  end

  @spec encode_with(t, map) :: binary
  def encode_with(clock, id_map)
  when is_valid(clock) and
       is_map(id_map)
  do
    world_clock(clock, :time) |> LocalClock.encode_list_with(id_map)
  end

  @spec decode_with(binary, map) :: {t, binary}
  def decode_with(bin, id_map)
  when is_binary(bin) and
       byte_size(bin) > 0 and
       is_map(id_map)
  do
    {elems, remaining} = LocalClock.decode_list_with(bin, id_map)
    {world_clock(time: elems), remaining}
  end
end
