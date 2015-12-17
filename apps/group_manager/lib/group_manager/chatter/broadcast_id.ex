defmodule GroupManager.Chatter.BroadcastID do
  
  require Record
  require GroupManager.Chatter.NetID
  alias GroupManager.Chatter.NetID
  
  Record.defrecord :broadcast_id, origin: nil, seqno: 0
  @type t :: record( :broadcast_id, origin: NetID.t, seqno: integer )
    
  @spec new(NetID.t) :: t
  def new(id)
  when NetID.is_valid(id)
  do
    broadcast_id(origin: id)
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
        quote bind_quoted: [result: data] do
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
  
  @spec valid?(t) :: boolean
  def valid?(data)
  when is_valid(data)
  do
    true
  end
  
  def valid?(_), do: false
end