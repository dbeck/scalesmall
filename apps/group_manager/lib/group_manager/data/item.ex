defmodule GroupManager.Data.Item do

  require Record
  require GroupManager.Chatter.NetID
  alias GroupManager.Chatter.NetID

  Record.defrecord :item,
                   member:       nil,
                   op:           :get,
                   start_range:  0,
                   end_range:    0xffffffff,
                   priority:     0

  @type t :: record( :item,
                     member:       NetID.t,
                     op:           atom,
                     start_range:  integer,
                     end_range:    integer,
                     priority:     integer )

  @spec new(NetID.t) :: t
  def new(id)
  when NetID.is_valid(id)
  do
    item(member: id)
  end

  defmacro is_valid_uint32(data) do
    case Macro.Env.in_guard?(__CALLER__) do
      true ->
        quote do
          is_integer(unquote(data)) and
          unquote(data) >= 0 and
          unquote(data) <= 0xffffffff
        end
      false ->
        quote bind_quoted: binding() do
          is_integer(data) and
          data >= 0 and
          data <= 0xffffffff
        end
    end
  end

  defmacro is_valid(data) do
    case Macro.Env.in_guard?(__CALLER__) do
      true ->
        quote do
          is_tuple(unquote(data)) and tuple_size(unquote(data)) == 6 and
          :erlang.element(1, unquote(data)) == :item and
          # member
          NetID.is_valid(:erlang.element(2, unquote(data))) and
          # op
          :erlang.element(3, unquote(data)) in [:add, :rmv, :get] and
          # start_range
          is_integer(:erlang.element(4, unquote(data))) and
          :erlang.element(4, unquote(data)) >= 0 and
          :erlang.element(4, unquote(data)) <= 0xffffffff and
          # end_range
          is_integer(:erlang.element(5, unquote(data))) and
          :erlang.element(5, unquote(data)) >= 0 and
          :erlang.element(5, unquote(data)) <= 0xffffffff and
          # priority
          is_integer(:erlang.element(6, unquote(data))) and
          :erlang.element(6, unquote(data)) >= 0 and
          :erlang.element(6, unquote(data)) <= 0xffffffff and
          # start_range <= end_range
          :erlang.element(4, unquote(data)) <= :erlang.element(5, unquote(data))
        end
      false ->
        quote bind_quoted: binding() do
          is_tuple(data) and tuple_size(data) == 6 and
          :erlang.element(1, data) == :item and
          # member
          NetID.is_valid(:erlang.element(2, data)) and
          # op
          :erlang.element(3, data) in [:add, :rmv, :get] and
           # start_range
          is_integer(:erlang.element(4, data)) and
          :erlang.element(4,data) >= 0 and
          :erlang.element(4, data) <= 0xffffffff and
          # end_range
          is_integer(:erlang.element(5, data)) and
          :erlang.element(5, data) >= 0 and
          :erlang.element(5, data) <= 0xffffffff and
          # priority
          is_integer(:erlang.element(6, data)) and
          :erlang.element(6, data) >= 0 and
          :erlang.element(6, data) <= 0xffffffff and
          # start_range <= end_range
          :erlang.element(4, data) <= :erlang.element(5, data)
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

  @spec set(t, :add|:rmv|:get, integer, integer, integer) :: t
  def set(itm, opv, from, to, priority)
  when opv in [:add, :rmv, :get] and
       is_valid_uint32(from) and
       is_valid_uint32(to) and
       from <= to and
       is_valid_uint32(priority)
  do
    item(itm, op: opv)
    |> item(start_range: from)
    |> item(end_range: to)
    |> item(priority: priority)
  end

  @spec member(t) :: NetID
  def member(itm)
  when is_valid(itm)
  do
    item(itm, :member)
  end

  @spec op(t) :: :add | :rmv | :get
  def op(itm)
  when is_valid(itm)
  do
    item(itm, :op)
  end

  @spec op(t, :add|:rmv|:get) :: t
  def op(itm, v)
  when is_valid(itm) and
       v in [:add, :rmv, :get]
  do
    item(itm, op: v)
  end

  @spec start_range(t) :: integer
  def start_range(itm)
  when is_valid(itm)
  do
    item(itm, :start_range)
  end

  @spec start_range(t, integer) :: t
  def start_range(itm, v)
  when is_valid(itm) and
       is_valid_uint32(v)
  do
    item(itm, start_range: v)
  end

  @spec end_range(t) :: integer
  def end_range(itm)
  when is_valid(itm)
  do
    item(itm, :end_range)
  end

  @spec end_range(t, integer) :: t
  def end_range(itm, v)
  when is_valid(itm) and
       is_valid_uint32(v)
  do
    item(itm, end_range: v)
  end

  @spec priority(t) :: integer
  def priority(itm)
  when is_valid(itm)
  do
    item(itm, :priority)
  end

  @spec priority(t, integer) :: t
  def priority(itm, v)
  when is_valid(itm) and
       is_valid_uint32(v)
  do
    item(itm, priority: v)
  end
end
