defmodule GroupManager.Chatter.Gossip do

  require Record
  require GroupManager.Chatter.BroadcastID
  require GroupManager.Chatter.NetID
  alias GroupManager.Chatter.BroadcastID
  alias GroupManager.Chatter.NetID

  Record.defrecord :gossip,
                   current_id: nil,
                   seen_ids: [],
                   distribution_list: [],
                   payload: nil

  @type t :: record( :gossip,
                     current_id: BroadcastID.t,
                     seen_ids: list(BroadcastID.t),
                     distribution_list: list(NetID.t),
                     payload: term )

  @spec new(NetID.t, term) :: t
  def new(my_id, data)
  when NetID.is_valid(my_id)
  do
    gossip(current_id: BroadcastID.new(my_id)) |> gossip(payload: data)
  end

  defmacro is_valid(data) do
    case Macro.Env.in_guard?(__CALLER__) do
      true ->
        quote do
          is_tuple(unquote(data)) and tuple_size(unquote(data)) == 5 and
          :erlang.element(1, unquote(data)) == :gossip and
          # broadcast id
          BroadcastID.is_valid(:erlang.element(2, unquote(data))) and
          # seen ids
          is_list(:erlang.element(3, unquote(data))) and
          # distribution list
          is_list(:erlang.element(4, unquote(data))) and
          # payload
          is_nil(:erlang.element(5, unquote(data))) == false
        end
      false ->
        quote bind_quoted: [result: data] do
          is_tuple(data) and tuple_size(data) == 5 and
          :erlang.element(1, data) == :gossip and
          # broadcast id
          BroadcastID.is_valid(:erlang.element(2, data)) and
          # seen ids
          is_list(:erlang.element(3, data)) and
          # distribution list
          is_list(:erlang.element(4, data)) and
          # payload
          is_nil(:erlang.element(5, data)) == false
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

  @spec seen_ids(t, list(BroadcastID.t)) :: t
  def seen_ids(g, ids)
  when is_valid(g) and is_list(ids)
  do
    :ok = BroadcastID.validate_list!(ids)
    gossip(g, seen_ids: ids)
  end

  @spec seen_ids(t) :: list(BroadcastID.t)
  def seen_ids(g)
  when is_valid(g)
  do
    gossip(g, :seen_ids)
  end

  @spec distribution_list(t, list(NetID.t)) :: t
  def distribution_list(g, ids)
  when is_valid(g) and is_list(ids)
  do
    :ok = NetID.validate_list!(ids)
    gossip(g, distribution_list: ids)
  end

  @spec distribution_list(t) :: list(NetID.t)
  def distribution_list(g)
  when is_valid(g)
  do
    gossip(g, :distribution_list)
  end
end
