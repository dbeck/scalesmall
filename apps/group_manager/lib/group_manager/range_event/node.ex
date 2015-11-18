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
  defstruct type: :register, node: nil, point: 1.0
  
  alias GroupManager.RangeEvent.Node, as: Node
  alias GroupManager.RangeEvent.Split, as: Split
  
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
  when is_number(split_at) and is_atom(node_type) and is_number(event_loc) and is_list(acc)
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
  when is_number(l_loc) and is_number(r_loc) and is_atom(l_type) and l_type == r_type
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