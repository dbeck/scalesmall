defmodule GroupManager.Data.TimedSet do
  @moduledoc """
  TODO
  """
  
  alias GroupManager.Data.TimedItem
  
  # The TimedSet.t type
  @type t :: { :timed_set, list(TimedItem.t) }
  
  @spec new() :: t
  def new(), do: { :timed_set, [] }
  
  # setters:
  # getters:
  # manipulators:  
  # accessors:
end
