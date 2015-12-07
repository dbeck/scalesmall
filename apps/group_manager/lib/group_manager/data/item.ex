defmodule GroupManager.Data.Item do
  @moduledoc """
  TODO check doc here
  
  Item represents a range associated to a member. Each member has a priority for each range. If multiple ranges exist for
  a give point in the range, their resulting priority is the maximum of all priority values. The Item inside is represented by
  a record (tuple with these members): 
  
  - :item atom
  - member term
  - op atom
  - start_range integer
  - end_range integer
  - priority integer
  
  `Item` itself is a Record type that we manipulate and access with the methods provided in the module.  
  TODO check doc here
  """

  require Record  
  
  Record.defrecord :item, member: nil, op: :add, start_range: 0, end_range: 0xffffffff, priority: 0
  @type t :: record( :item, member: term, op: atom, start_range: integer, end_range: integer, priority: integer )
  
  @spec new(term) :: t
  def new(id)
  do
    item(member: id)
  end
  
  @doc """
  Validate as much as we can about the `data` parameter which should be an Item record.
   
  Validation rules are:
  
  - 1st is an `:item` atom
  - 2nd `member`: is a non nil term
  - 3rd `op`: is :add or :rmv
  - 4th `start_range`: is non-negative integer [0x0..0xffffffff]
  - 5th `end_range`: is non-negative integer [0x0..0xffffffff]
  - 6th `priority`: is non-negative integer [0x0..0xffffffff]
  - start_range <= end_range
  
  The purpose of this macro is to help checking input parameters in function guards.
  """
  defmacro is_valid(data) do
    case Macro.Env.in_guard?(__CALLER__) do
      true ->
        quote do
          is_tuple(unquote(data)) and tuple_size(unquote(data)) == 6 and
          :erlang.element(1, unquote(data)) == :item and
          # member
          is_nil(:erlang.element(2, unquote(data))) == false and
          # op
          (:erlang.element(3, unquote(data)) == :add or :erlang.element(3, unquote(data)) == :rmv) and
          # start_range
          is_integer(:erlang.element(4, unquote(data))) and
          :erlang.element(4, unquote(data)) >= 0 and
          :erlang.element(4, unquote(data)) <= 0xffffffff and
          # end_range
          is_integer(:erlang.element(5, unquote(data))) and
          :erlang.element(5, unquote(data)) >= 0 and
          :erlang.element(5, unquote(data)) <= 0xffffffff and
          # priority
          is_integer(:erlang.element(6, unquote(data))) and
          :erlang.element(6, unquote(data)) >= 0 and
          :erlang.element(6, unquote(data)) <= 0xffffffff and
          # start_range <= end_range
          :erlang.element(4, unquote(data)) <= :erlang.element(5, unquote(data))
        end
      false ->
        quote bind_quoted: [result: data] do
          is_tuple(result) and tuple_size(result) == 6 and
          :erlang.element(1, result) == :item and
          # member
          is_nil(:erlang.element(2, result)) == false and
          # op
          (:erlang.element(3, result) == :add or :erlang.element(3, result) == :rmv) and
           # start_range
          is_integer(:erlang.element(4, result)) and
          :erlang.element(4,result) >= 0 and
          :erlang.element(4, result) <= 0xffffffff and
          # end_range
          is_integer(:erlang.element(5, result)) and
          :erlang.element(5, result) >= 0 and
          :erlang.element(5, result) <= 0xffffffff and
          # priority
          is_integer(:erlang.element(6, result)) and
          :erlang.element(6, result) >= 0 and
          :erlang.element(6, result) <= 0xffffffff and
          # start_range <= end_range
          :erlang.element(4, result) <= :erlang.element(5,result)
        end
    end
  end
    
  @spec valid?(t) :: boolean
  def valid?(data)
  when is_valid(data)
  do
    true
  end
  
  def valid?(_), do: false
  
  @spec set_op(t, atom) :: t
  def set_op(itm, v)
  when is_valid(itm) and (v == :add or v == :rmv)
  do
    item(itm, op: v)
  end
  
  @spec set_start_range(t, integer) :: t
  def set_start_range(itm, v)
  when is_valid(itm) and is_integer(v) and v >= 0 and v <= 0xffffffff
  do
    item(itm, start_range: v)
  end
  
  @spec set_end_range(t, integer) :: t
  def set_end_range(itm, v)
  when is_valid(itm) and is_integer(v) and v >= 0 and v <= 0xffffffff
  do
    item(itm, end_range: v)
  end

  @spec set_priority(t, integer) :: t
  def set_priority(itm, v)
  when is_valid(itm) and is_integer(v) and v >= 0 and v <= 0xffffffff
  do
    item(itm, priority: v)
  end

end
