defmodule GroupManager.Data.TimedItem do
  @moduledoc """
  TODO
  """
  
  alias GroupManager.Data.Item
  alias GroupManager.Data.LocalClock
  
  # The TimedItem.t type
  @type t :: { :timed_item, Item.t, LocalClock.t }
  
  @spec new(term) :: t
  def new(id), do: { :timed_item, Item.new(id), LocalClock.new(id) }
  
  # setters:
  # getters:
  # manipulators:  
  # accessors:
end