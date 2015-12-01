defmodule GroupManager.Data.Message do
  @moduledoc """
  TODO
  """
  
  alias GroupManager.Data.WorldClock
  alias GroupManager.Data.TimedSet
  
  # The Message.t type
  @type t :: { :message, WorldClock.t, TimedSet.t, TimedSet.t }
  
  @spec new(term) :: t
  def new(id), do: { :message, WorldClock.new(), TimedSet.new(), TimedSet.new() }
  
  # setters:
  # getters:
  # manipulators:  
  # accessors:
end
