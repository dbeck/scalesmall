defmodule GroupManager.StatusEvent.Status do
  
  @moduledoc """
  TODO
  """
  
  @doc """
  valid types are:
  - :join
  - :leave
  """
  defstruct type: :join, node: nil, hash: 0
  
  alias GroupManager.StatusEvent.Status, as: Status
  
  def merge(lhs, rhs) when is_list(lhs) and is_list(rhs) do
    # TODO
    lhs ++ rhs
    |> List.flatten
    |> Enum.sort(&(is_greater(&2, &1)))
    |> Enum.uniq
  end
  
  def is_greater(%Status{type: l_type, node: l_name, hash: l_hash},
                 %Status{type: r_type, node: r_name, hash: r_hash})
  when is_atom(l_type) and is_atom(r_type) and is_integer(l_hash) and is_integer(r_hash)
  do
    # TODO
    l_name > r_name
    #
    cond do
      l_name > r_name -> true
      l_name < r_name -> false
      l_type > r_type -> true
      l_type < r_type -> false
      l_hash > r_hash -> true
      true -> false
    end 
  end
end