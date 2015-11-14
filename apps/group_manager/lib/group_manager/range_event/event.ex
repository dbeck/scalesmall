defmodule GroupManager.RangeEvent.Event do
  @moduledoc """
  TODO
  """
  
  defstruct split: [], release: [], register: [], promote: [], demote: []

  alias GroupManager.RangeEvent.Event, as: Event

  def merge(events) when is_list(events) do
    List.foldl(events, %Event{}, fn(x, acc) -> merge_two(x, acc) end)
  end

  def merge_two(lhs, rhs) when is_map(lhs) and is_map(rhs) do

    %Event{split: l_split, release: l_release, register: l_register, promote: l_promote, demote: l_demote} = lhs
    %Event{split: r_split, release: r_release, register: r_register, promote: r_promote, demote: r_demote} = rhs
    
    # release events
    merged_release = GroupManager.RangeEvent.Node.split(l_split, r_release)
    |> GroupManager.RangeEvent.Node.merge(GroupManager.RangeEvent.Node.split(r_split, l_release))

    # register events
    merged_register = GroupManager.RangeEvent.Node.split(l_split, r_register)
    |> GroupManager.RangeEvent.Node.merge(GroupManager.RangeEvent.Node.split(r_split, l_register))
    
    # promote events
    merged_promote = GroupManager.RangeEvent.Node.split(l_split, r_promote)
    |> GroupManager.RangeEvent.Node.merge(GroupManager.RangeEvent.Node.split(r_split, l_promote))

    # demote events
    merged_demote = GroupManager.RangeEvent.Node.split(l_split, r_demote)
    |> GroupManager.RangeEvent.Node.merge(GroupManager.RangeEvent.Node.split(r_split, l_demote))

    %Event{split:    GroupManager.RangeEvent.Split.merge(l_split ++ r_split),
           release:  merged_release,
           register: merged_register,
           promote:  merged_promote,
           demote:   merged_demote }
  end
end