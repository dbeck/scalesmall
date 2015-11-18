defmodule GroupManager.StatusEvent.Event do

  @moduledoc """
  TODO
  """
  
  @doc """
  valid types are:
  - :join
  - :leave
  """
  defstruct events: []
  
  alias GroupManager.StatusEvent.Event, as: Event
  
  def merge(events) when is_list(events) do
    List.foldl(events, %Event{}, fn(x, acc) -> merge_two(x, acc) end)
  end

  def merge_two(%Event{events: l_events}, %Event{events: r_events})
  when is_list(l_events) and is_list(r_events)
  do
    %Event{events: GroupManager.StatusEvent.Status.merge(l_events, r_events)}
  end  
end
