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

    %Event{split: l_split, release: l_rel, register: l_reg, promote: l_prom, demote: l_dem} = lhs
    %Event{split: r_split, release: r_rel, register: r_reg, promote: r_prom, demote: r_dem} = rhs
    
    # TODO
    %Event{ split:    l_split ++ r_split,
            release:  l_rel ++ r_rel,
            register: l_reg ++ r_reg,
            promote:  l_prom ++ r_prom,
            demote:   l_dem ++ r_dem }
  end
end