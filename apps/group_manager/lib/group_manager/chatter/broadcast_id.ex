defmodule GroupManager.Chatter.BroadcastID do

  require Record
  require GroupManager.Chatter.NetID
  alias GroupManager.Chatter.NetID

  Record.defrecord :broadcast_id,
                   origin: nil,
                   seqno: 0

  @type t :: record( :broadcast_id,
                     origin: NetID.t,
                     seqno: integer )

  @spec new(NetID.t) :: t
  def new(id)
  when NetID.is_valid(id)
  do
    broadcast_id(origin: id)
  end

  @spec new(NetID.t, integer) :: t
  def new(id, seqno)
  when NetID.is_valid(id) and
       is_integer(seqno) and
       seqno >= 0
  do
    broadcast_id(origin: id) |> broadcast_id(seqno: seqno)
  end

  defmacro is_valid(data) do
    case Macro.Env.in_guard?(__CALLER__) do
      true ->
        quote do
          is_tuple(unquote(data)) and tuple_size(unquote(data)) == 3 and
          :erlang.element(1, unquote(data)) == :broadcast_id and
          # origin
          NetID.is_valid(:erlang.element(2, unquote(data))) and
          # seqno
          is_integer(:erlang.element(3, unquote(data))) and
          :erlang.element(3, unquote(data)) >= 0
        end
      false ->
        quote bind_quoted: binding() do
          is_tuple(unquote(data)) and tuple_size(data) == 3 and
          :erlang.element(1, data) == :broadcast_id and
          # origin
          NetID.is_valid(:erlang.element(2, data)) and
          # seqno
          is_integer(:erlang.element(3, data)) and
          :erlang.element(3, data) >= 0
        end
    end
  end

  @spec origin(t) :: NetID.t
  def origin(id)
  when is_valid(id)
  do
    broadcast_id(id, :origin)
  end

  @spec origin(t,  NetID.t) :: t
  def origin(id, nid)
  when is_valid(id) and
       NetID.is_valid(nid)
  do
    broadcast_id(id, origin: nid)
  end

  @spec seqno(t) :: NetID.t
  def seqno(id)
  when is_valid(id)
  do
    broadcast_id(id, :seqno)
  end

  @spec seqno(t, integer) :: t
  def seqno(id, v)
  when is_valid(id) and
       is_integer(v) and
       v >= 0
  do
    broadcast_id(id, seqno: v)
  end

  @spec inc_seqno(t) :: t
  def inc_seqno(id)
  when is_valid(id)
  do
    broadcast_id(id, seqno: broadcast_id(id, :seqno)+1)
  end

  @spec valid?(t) :: boolean
  def valid?(data)
  when is_valid(data)
  do
    true
  end

  def valid?(_), do: false

  @spec validate_list(list(t)) :: :ok | :error
  def validate_list([]), do: :ok

  def validate_list([head|rest])
  do
    case valid?(head) do
      true -> validate_list(rest)
      false -> :error
    end
  end

  def validate_list(_), do: :error

  @spec validate_list!(list(t)) :: :ok
  def validate_list!([]), do: :ok

  def validate_list!([head|rest])
  when is_valid(head)
  do
    validate_list!(rest)
  end

  @spec merge_lists(list(BroadcastID.t), list(BroadcastID.t)) :: list(BroadcastID.t)
  def merge_lists([], []), do: []
  def merge_lists(lhs, []) when is_list(lhs), do: lhs
  def merge_lists([], rhs) when is_list(rhs), do: rhs

  def merge_lists(lhs, rhs)
  when is_list(lhs) and
       is_list(rhs)
  do
    # optimize this ???
    dict = Enum.map(lhs ++ rhs, fn(x) -> {origin(x), seqno(x)} end)
    |> Enum.reduce(%{}, fn({m, t} ,acc) ->
      Map.update(acc, m, t, fn(prev_seqno) ->
        max(t, prev_seqno)
      end)
    end)
    Enum.map(Map.keys(dict), fn(k) -> broadcast_id(origin: k) |> broadcast_id(seqno: Map.get(dict, k)) end)
  end
end
