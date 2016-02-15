defmodule GroupManager.Chatter.Serializer do

  require GroupManager.Chatter.Gossip
  require GroupManager.Chatter.BroadcastID
  require GroupManager.Chatter.NetID
  alias GroupManager.Chatter.Gossip

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

# {:gossip,
#   {:broadcast_id,
#     {:net_id, {192, 168, 1, 100}, 11225}, 1},
#     [], ?
#     [],
#     {:message,
#       {:world_clock, [{:local_clock, {:net_id, {192, 168, 1, 100}, 11225}, 0}]},
#       {:timed_set, [
#            {:timed_item, {:item, {:net_id, {192, 168, 1, 100}, 11225}, :get, 0, 4294967295, 0},
#            {:local_clock, {:net_id, {192, 168, 1, 100}, 11225}, 0}}]}, "G2"}}
end
