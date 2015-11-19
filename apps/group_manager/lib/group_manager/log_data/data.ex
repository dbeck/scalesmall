defmodule GroupManager.LogData.Data do
  @moduledoc """
  TODO
  """
  
  alias GroupManager.StatusEvent.Event, as: StatusEvent
  alias GroupManager.RangeEvent.Event,  as: RangeEvent
  
  defstruct prev_hash: 0, status_event: %StatusEvent{}, range_event: %RangeEvent{}

  alias GroupManager.LogData.Data, as: Data
  
  def hash(data)
  when is_map(data)
  do
    :xxhash.hash64(:erlang.term_to_binary(data), 1)
  end
  
  def prev_hash(data)
  when is_map(data)
  do
    %Data{prev_hash: retval} = data
    retval
  end  

end
