defmodule GroupManager.Chatter.Gossip do

  require Record
  require GroupManager.Chatter.BroadcastID
  require GroupManager.Chatter.NetID
  alias GroupManager.Chatter.BroadcastID
  alias GroupManager.Chatter.NetID
  alias GroupManager.Chatter.Serializer

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

  @spec new(NetID.t, integer, term) :: t
  def new(my_id, seqno, data)
  when NetID.is_valid(my_id) and
       is_integer(seqno) and
       seqno >= 0
  do
    gossip(current_id: BroadcastID.new(my_id) |> BroadcastID.seqno(seqno))
    |> gossip(payload: data)
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
        quote bind_quoted: binding() do
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

  @spec current_id(t) :: BroadcastID.t
  def current_id(g)
  when is_valid(g)
  do
    gossip(g, :current_id)
  end

  @spec seen_ids(t, list(BroadcastID.t)) :: t
  def seen_ids(g, ids)
  when is_valid(g) and
       is_list(ids)
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

  @spec seen_ids(t) :: list(BroadcastID.t)
  def seen_ids(g)
  when is_valid(g)
  do
    gossip(g, :seen_ids)
  end

  @spec payload(t) :: term
  def payload(g)
  when is_valid(g)
  do
    gossip(g, :payload)
  end

  @spec payload(t, term) :: t
  def payload(g, pl)
  when is_valid(g)
  do
    gossip(g, payload: pl)
  end

  @spec seen_netids(t) :: list(NetID.t)
  def seen_netids(g)
  when is_valid(g)
  do
    Enum.reduce(gossip(g, :seen_ids), [], fn(x, acc) ->
      [GroupManager.Chatter.BroadcastID.origin(x)|acc]
    end)
  end

  @spec distribution_list(t, list(NetID.t)) :: t
  def distribution_list(g, ids)
  when is_valid(g) and
       is_list(ids)
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

  @spec remove_from_distribution_list(t, list(NetID.t)) :: t
  def remove_from_distribution_list(g, [])
  when is_valid(g)
  do
    g
  end

  def remove_from_distribution_list(g, to_remove)
  when is_valid(g)
  do
    :ok = NetID.validate_list!(to_remove)
    old_list = gossip(g, :distribution_list)
    old_set = Enum.into(old_list, HashSet.new)
    remove_set = Enum.into(to_remove, HashSet.new)
    new_set = HashSet.difference(old_set, remove_set)
    gossip(g, distribution_list: HashSet.to_list(new_set))
  end

  @spec add_to_distribution_list(t, list(NetID.t)) :: t
  def add_to_distribution_list(g, [])
  when is_valid(g)
  do
    g
  end

  def add_to_distribution_list(g, to_add)
  when is_valid(g)
  do
    :ok = NetID.validate_list!(to_add)
    old_list = gossip(g, :distribution_list)
    old_set = Enum.into(old_list, HashSet.new)
    add_set = Enum.into(to_add, HashSet.new)
    new_set = HashSet.union(old_set, add_set)
    gossip(g, distribution_list: HashSet.to_list(new_set))
  end

  @spec extract_netids(t) :: list(NetID.t)
  def extract_netids(g)
  when is_valid(g)
  do
    [gossip(g, :current_id) |> BroadcastID.origin | gossip(g, :distribution_list)] ++
    Enum.map(gossip(g, :seen_ids), fn(x) -> BroadcastID.origin(x) end)
    |> Enum.uniq
  end

  @spec encode_with(t, map) :: binary
  def encode_with(g, id_map)
  when is_valid(g) and
       is_map(id_map) # TODO: check map too ...
  do
    #current_id: BroadcastID.t,
    bin_current_id    = gossip(g, :current_id) |> BroadcastID.encode_with(id_map)

    #seen_ids: list(BroadcastID.t),
    bin_seen_ids_size = gossip(g, :seen_ids) |> length |> Serializer.encode_uint
    bin_seen_ids      = gossip(g, :seen_ids) |> Enum.reduce(<<>>, fn(x,acc) ->
      acc <> BroadcastID.encode_with(x, id_map)
    end)

    #distribution_list: list(NetID.t),
    bin_distrib_size  = gossip(g, :distribution_list) |> length |> Serializer.encode_uint
    bin_distrib       = gossip(g, :distribution_list) |> Enum.reduce(<<>>, fn(x,acc) ->
      id = Map.fetch!(id_map, x)
      acc <> Serializer.encode_uint(id)
    end)

    << bin_current_id     :: binary,
       bin_seen_ids_size  :: binary,
       bin_seen_ids       :: binary,
       bin_distrib_size   :: binary,
       bin_distrib        :: binary >>
  end

  @spec decode_with(binary, map) :: t
  def decode_with(bin, id_map)
  when is_binary(bin) and
       byte_size(bin) > 0 and
       is_map(id_map)
  do
    {current_id, remaining} = BroadcastID.decode_with(bin, id_map)
  end

end
