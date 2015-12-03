defmodule GroupManager.Data.Item do
  @moduledoc """
  Item represents a range associated to a member. Each member has a priority for each range. If multiple ranges exist for
  a give point in the range, their resulting priority is the maximum of all priority values. The Item inside is represented by
  a record (tuple with these members):
  
  - :item atom
  - member term
  - start_range integer
  - end_range integer
  - priority integer
  
  `Item` itself is a Record type that we manipulate and access with the methods provided in the module.  
  """
  
  alias GroupManager.Data.Item
  
  require Record
  Record.defrecord :item, member: nil, start_range: 0, end_range: 0xffffffff, priority: 0  
  @type t :: record( :item, member: term, start_range: integer, end_range: integer, priority: integer )
  
  @spec new(term) :: t
  def new(id)
  do
    item(member: id)
  end
  
  @doc """
  Validate as much we can about the `data` parameter which should be an Item record.
   
  Validation rules are:
  
  - 1st is an `:item` atom
  - 2nd `member`: is a non nil term
  - 3rd `start_range`: is non-negative integer [0x0..0xffffffff]
  - 4th `end_range`: is non-negative integer [0x0..0xffffffff]
  - 5th `priority`: is non-negative integer [0x0..0xffffffff]
  - start_range <= end_range
  
  The purpose of this macro is to help checking input parameters in function guards.
  """
  defmacro is_valid(data) do
    case Macro.Env.in_guard?(__CALLER__) do
      true ->
        quote do
          is_tuple(unquote(data)) and tuple_size(unquote(data)) == 5 and
          :erlang.element(1, unquote(data)) == :item and
          # member
          is_nil(:erlang.element(2, unquote(data))) == false and
          # start_range
          is_integer(:erlang.element(3, unquote(data))) and
          :erlang.element(3, unquote(data)) >= 0 and
          :erlang.element(3, unquote(data)) <= 0xffffffff and
          # end_range
          is_integer(:erlang.element(4, unquote(data))) and
          :erlang.element(4, unquote(data)) >= 0 and
          :erlang.element(4, unquote(data)) <= 0xffffffff and
          # priority
          is_integer(:erlang.element(5, unquote(data))) and
          :erlang.element(5, unquote(data)) >= 0 and
          :erlang.element(5, unquote(data)) <= 0xffffffff and
          # start_range <= end_range
          :erlang.element(3, unquote(data)) <= :erlang.element(4, unquote(data))          
        end
      false ->
        quote do
          result = unquote(data)
          is_tuple(result) and tuple_size(result) == 5 and
          :erlang.element(1, result) == :item and
          # member
          is_nil(:erlang.element(2, result)) == false and
          # start_range
          is_integer(:erlang.element(3, result)) and
          :erlang.element(3,result) >= 0 and
          :erlang.element(3, result) <= 0xffffffff and
          # end_range
          is_integer(:erlang.element(4, result)) and
          :erlang.element(4, result) >= 0 and
          :erlang.element(4, result) <= 0xffffffff and
          # priority
          is_integer(:erlang.element(5, result)) and
          :erlang.element(5, result) >= 0 and
          :erlang.element(5, result) <= 0xffffffff and
          # start_range <= end_range
          :erlang.element(3, result) <= :erlang.element(4,result)
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
  
  # manipulators:
  # accessors:
end
