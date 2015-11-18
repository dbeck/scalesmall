defmodule GroupManager.LogData.Data do
  @moduledoc """
  TODO
  """
  
  alias GroupManager.StatusEvent.Event, as: StatusEvent
  alias GroupManager.RangeEvent.Event,  as: RangeEvent
  
  defstruct prev_hash: 0, status_event: %StatusEvent{}, range_event: %RangeEvent{}

  alias GroupManager.LogData.Data, as: Data

end
