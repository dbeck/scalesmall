defmodule GroupManager.Data.WorldClock do
  @moduledoc """
  TODO
  """
  
  alias GroupManager.Data.LocalClock
  
  # The WorldClock.t type
  @type t :: { :world_clock, list(LocalClock.t) }
  
  @spec new() :: t
  def new(), do: { :world_clock, [] }
  
  # setters:
  # getters:
  # manipulators:  
  # accessors:
end