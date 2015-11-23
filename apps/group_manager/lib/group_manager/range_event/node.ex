defmodule GroupManager.RangeEvent.Node do
  @moduledoc """
  TODO
  """
  
  @doc """
  valid types are:
  - :register
  - :release
  - :promote
  - :demote
  """
  alias GroupManager.RangeEvent.Node
  alias GroupManager.RangeEvent.Split
  
  @type node_event_type :: :register | :release | :promote | :demote
  defstruct type: :register, node: nil, point: 1.0
  @type t :: %Node{type: node_event_type, node: String.t, point: float}
  
  def merge(lhs, rhs)
  when is_list(lhs) and is_list(rhs)
  do
    lhs ++ rhs
    |> List.flatten
    |> Enum.sort(&(is_greater(&2, &1)))
    |> Enum.uniq
  end
  
  def split(foreign_splits, own_events)
  when is_list(foreign_splits) and is_list(own_events)
  do
    List.foldl(own_events, [], fn(x, acc) -> split_node(foreign_splits, x, acc) end)
    |> List.flatten
    |> Enum.sort(&(is_greater(&2, &1)))
    |> Enum.uniq
  end
  
  def split_node([], node, acc)
  when is_map(node) and is_list(acc)
  do
    #
    [node | acc]
  end
  
  def split_node([head|tail], node, acc)
  when is_map(head) and is_map(node) and is_list(acc)
  do
    #
    [split_node(head, node, acc) | split_node(tail, node, acc)]
  end
  
  def split_node(%Split{point: split_at}, %Node{type: node_type, node: name, point: event_loc}, acc)
  when is_float(split_at) and is_atom(node_type) and is_float(event_loc) and is_list(acc) and
       event_loc >= 0.0 and event_loc <= 1.0 and split_at >= 0.0 and split_at <= 1.0
  do
    #
    orig = %Node{type: node_type, node: name, point: event_loc}
    cond do
      split_at < event_loc ->
        new_event  = %Node{type: node_type, node: name, point: split_at}
        [new_event, orig | acc]
      true ->
        [orig | acc]
    end
  end
  
  def is_greater(%Node{type: l_type, node: l_name, point: l_loc},
                 %Node{type: r_type, node: r_name, point: r_loc})
  when is_float(l_loc) and is_float(r_loc) and is_atom(l_type) and l_type == r_type and
       l_loc >= 0.0 and l_loc <= 1.0 and r_loc >= 0.0 and r_loc <= 1.0
  do
    #
    cond do
      l_loc > r_loc -> true
      l_loc < r_loc -> false
      l_name > r_name -> true
      true -> false
    end  
  end
end