defmodule GroupManager.Data.Item do
  @moduledoc """
  TODO
  """
    
  # helper types
  @type member :: term
  @type start_range :: non_neg_integer
  @type end_range :: pos_integer
  @type priority :: non_neg_integer
  
  # The Item.t type
  @type t :: { :item, member, start_range, end_range, priority }
  
  @spec new(term) :: t
  def new(id), do: { :item, id, 0, 1, 0 }
  
  # setters:
  # - member
  # - start_range
  # - end_range
  # - priority
  
  # getters:
  # - member
  # - start_range
  # - end_range
  # - priority
  
  # manipulators:
  # accessors:
end
