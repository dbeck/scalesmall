defmodule GroupManager.Chatter.Serializer do

  require GroupManager
  require GroupManager.Chatter.Gossip
  require GroupManager.Chatter.BroadcastID
  require GroupManager.Chatter.NetID
  require GroupManager.Data.WorldClock
  require GroupManager.Data.TimedSet
  require GroupManager.Data.TimedItem
  require GroupManager.Data.Item
  require GroupManager.Data.LocalClock
  require GroupManager.Data.Message
  alias GroupManager.Chatter.Gossip
  alias GroupManager.Chatter.NetID
  alias GroupManager.Data.Message

  @spec encode(Gossip.t) :: binary
  def encode(gossip)
  when Gossip.is_valid(gossip)
  do
    {:ok, result} = :erlang.term_to_binary(gossip) |> :snappy.compress
    result
  end

  @spec decode(binary) :: {:ok, Gossip.t} | {:error, :invalid_data, integer}
  def decode(msg)
  when is_binary(msg) and
       byte_size(msg) > 0
  do
    case :snappy.decompress(msg)
    do
      {:ok, decomp} ->
        gossip = :erlang.binary_to_term(decomp)
        if Gossip.valid?(gossip)
        do
          {:ok, gossip}
        else
          {:error, :invalid_data, byte_size(msg)}
        end
      {:error, :corrupted_data} ->
        {:error, :invalid_data, byte_size(msg)}
    end
  end

  def encode_gossip(gossip)
  when Gossip.is_valid(gossip)
  do
    ids = (extract_netids(gossip) ++ extract_netids(Gossip.payload(gossip)))
    |> Enum.uniq
    id_table = List.foldl(ids, encode_uint(length(ids)), fn(id, acc) ->
      acc <> NetID.encode(id)
    end)
    {id_count, id_map} = ids |> Enum.reduce({0, %{}}, fn(x,acc) ->
      {count, m} = acc
      {count+1, Map.put(m, x, count)}
    end)

    encoded_gossip  = Gossip.encode_with(gossip, id_map)
    encoded_message = Message.encode_with(Gossip.payload(gossip), id_map)

    << id_table :: binary,
       encoded_gossip :: binary,
       encoded_message :: binary >>
  end

  # format:
  # 0xff - magic
  # \- encrypted :
  #    11 bytes random padding
  #    \- compressed content:
  #       1 byte version
  #       \- data
  #          id table
  #          payload
  #    4 byte checksum

  # alias GroupManager.Chatter.Serializer
  # g = {:gossip, {:broadcast_id, {:net_id, {192, 168, 1, 97}, 29999}, 4}, [{:broadcast_id, {:net_id, {192, 168, 1, 100}, 29999}, 3}, {:broadcast_id, {:net_id, {192, 168, 1, 134}, 29999}, 1}], [{:net_id, {192, 168, 1, 97}, 29999}, {:net_id, {192, 168, 1, 100}, 29999}, {:net_id, {192, 168, 1, 134}, 29999}], {:message, {:world_clock, [{:local_clock, {:net_id, {192, 168, 1, 97}, 29999}, 2}, {:local_clock, {:net_id, {192, 168, 1, 100}, 29999}, 0}, {:local_clock, {:net_id, {192, 168, 1, 134}, 29999}, 0}]}, {:timed_set, [{:timed_item, {:item, {:net_id, {192, 168, 1, 97}, 29999}, :get, 0, 4294967295, 0}, {:local_clock, {:net_id, {192, 168, 1, 97}, 29999}, 2}}, {:timed_item, {:item, {:net_id, {192, 168, 1, 100}, 29999}, :get, 0, 4294967295, 0}, {:local_clock, {:net_id, {192, 168, 1, 100}, 29999}, 0}}, {:timed_item, {:item, {:net_id, {192, 168, 1, 134}, 29999}, :get, 0, 4294967295, 0}, {:local_clock, {:net_id, {192, 168, 1, 134}, 29999}, 0}}]}, "G"}}

  def decode_gossip(msg)
  do
    {id_list, remaining} = NetID.decode_list(msg)
    Enum.map(id_list, fn(x) ->
      IO.inspect ["p:", x]
      x
    end)

    #id_map = decode_netids(remaining, count, []) |> Enum.reduce({0, %{}}, fn(x, acc) ->
    #  {count, m} = acc
    #  {count+1, Map.put(m, x, count)}
    #end)

    #{decoded_gossip, remaining} = Gossip.decode_with(remaining, id_map)
    #{decoded_message, remaining} = Message.decode_with(remaining, id_map)
    #{Gossip.payload(decoded_gossip, decoded_message), remaining}
  end

# {:gossip,
#  {:broadcast_id,
#   {:net_id, {192, 168, 1, 97}, 29999}, 5},
#  [{:broadcast_id, {:net_id, {192, 168, 1, 100}, 29999}, 3},
#   {:broadcast_id, {:net_id, {192, 168, 1, 134}, 29999}, 1}],
#  [{:net_id, {192, 168, 1, 97}, 29999},
#   {:net_id, {192, 168, 1, 100}, 29999},
#   {:net_id, {192, 168, 1, 134}, 29999}],
#  {:message,
#     {:world_clock,
#      [{:local_clock, {:net_id, {192, 168, 1, 97}, 29999}, 2},
#       {:local_clock, {:net_id, {192, 168, 1, 100}, 29999}, 0},
#       {:local_clock, {:net_id, {192, 168, 1, 134}, 29999}, 0}]},
#     {:timed_set,
#       [{:timed_item,
#          {:item, {:net_id, {192, 168, 1, 97}, 29999}, :get, 0, 4294967295, 0},
#          {:local_clock, {:net_id, {192, 168, 1, 97}, 29999}, 2}},
#        {:timed_item,
#          {:item, {:net_id, {192, 168, 1, 100}, 29999}, :get, 0, 4294967295, 0},
#          {:local_clock, {:net_id, {192, 168, 1, 100}, 29999}, 0}},
#        {:timed_item,
#          {:item, {:net_id, {192, 168, 1, 134}, 29999}, :get, 0, 4294967295, 0},
#          {:local_clock, {:net_id, {192, 168, 1, 134}, 29999}, 0}}]},
#     "G"}}

  @spec encode_uint(integer) :: binary
  def encode_uint(i)
  when is_integer(i) and i >= 0
  do
    encode_uint_(<<>>, i)
  end

  @spec decode_uint(binary) :: {integer, binary}
  def decode_uint(b)
  when is_binary(b) and
       byte_size(b) > 0
  do
    decode_uint_(b, 0, 1)
  end

  defp encode_uint_(binstr, val)
  when val >= 128
  do
    encode_uint_(<< binstr :: binary, 1 :: size(1), rem(val, 128) :: size(7) >>, div(val, 128))
  end

  defp encode_uint_(binstr, val)
  when val < 128
  do
    << binstr :: binary, 0 :: size(1), val :: size(7) >>
  end

  defp decode_uint_(<< 1 :: size(1), act :: size(7), remaining :: binary>>, val, scale)
  do
    decode_uint_(remaining, val + (act*scale), scale*128)
  end

  defp decode_uint_(<< 0 :: size(1), act :: size(7)>>, val, scale)
  do
    {val + (act*scale), <<>>}
  end

  defp decode_uint_(<< 0 :: size(1), act :: size(7), remaining :: binary>>, val, scale)
  do
    {val + (act*scale), remaining}
  end

  defp decode_uint_(<<>>, val, _scale), do: val

  defp extract_netids(message)
  when Message.is_valid(message)
  do
    Message.extract_netids(message)
  end

  defp extract_netids(gossip)
  when Gossip.is_valid(gossip)
  do
    Gossip.extract_netids(gossip)
  end
end
