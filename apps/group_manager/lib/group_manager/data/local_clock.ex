defmodule GroupManager.Data.LocalClock do
  @moduledoc """
  TODO
  """
  
  alias GroupManager.Data.Item
  
  # helper types
  @type member :: Item.member
  @type time_val :: pos_integer
  
  # The LocalClock.t type
  @type t :: { :local_clock, member, time_val }  

  @spec new(term) :: t
  def new(id), do: { :local_clock, id, 0 }
  
  # setters:
  # - member
  # - time_val
  
  # getters:
  # manipulators:  
  # accessors:  
end