defmodule GroupManager.RangeEvent.Split do
  @moduledoc """
  TODO
  """
  
  defstruct point: 1.0

  alias GroupManager.RangeEvent.Split
  
  def merge(events)
  when is_list(events)
  do
    Enum.sort(events, &(is_greater(&2, &1)))
    |> Enum.uniq
  end
  
  def is_greater(%Split{point: lhs}, %Split{point: rhs})
  when is_number(lhs) and is_number(rhs) and rhs >= 0.0 and rhs <= 1.0
  do
    lhs > rhs
  end
end
