defmodule GroupManager.RangeEvent.Node do
  @moduledoc """
  TODO
  """
  
  @doc """
  valid types are:
  - :register
  - :release
  - :promote
  - :demote
  """
  defstruct type: nil, node: nil, point: 1.0
  
  def split(foreign_splits, own_events) when is_list(foreign_splits) and is_list(own_events) do
    # TODO
    own_events
  end
  
end