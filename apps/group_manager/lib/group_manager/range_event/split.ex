defmodule GroupManager.RangeEvent.Split do
  @moduledoc """
  TODO
  """

  alias GroupManager.RangeEvent.Split
  
  defstruct point: 1.0
  @type t :: %Split{point: float}
  
  def merge(events)
  when is_list(events)
  do
    Enum.sort(events, &(is_greater(&2, &1)))
    |> Enum.uniq
  end
  
  def is_greater(%Split{point: lhs}, %Split{point: rhs})
  when is_float(lhs) and is_float(rhs) and rhs >= 0.0 and rhs <= 1.0 and lhs >= 0.0 and lhs <= 1.0
  do
    lhs > rhs
  end
end
