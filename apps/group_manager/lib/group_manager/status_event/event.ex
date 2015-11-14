defmodule GroupManager.StatusEvent.Event do
  
  @moduledoc """
  TODO
  """
  
  @doc """
  valid types are:
  - :join
  - :leave
  """
  defstruct type: :register, node: nil
  
  alias GroupManager.StatusEvent.Event, as: Event
  
  def merge(lhs, rhs) when is_list(lhs) and is_list(rhs) do
    # TODO
    lhs ++ rhs
    |> List.flatten
    |> Enum.sort(&(is_greater(&2, &1)))
    |> Enum.uniq
  end
  
  def is_greater(%Event{type: l_type, node: l_name},
                 %Event{type: r_type, node: r_name})
  when is_atom(l_type) and l_type == r_type
  do
    # TODO
    l_name > r_name
  end
end