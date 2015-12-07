defmodule GroupManager.Data.MessageLog do
  @moduledoc """
  MessageLog is a collection of `Message` entries.
  
  `MessageLog` itself is a Record type that we manipulate and access with the methods provided in the module.
  """
  
  require Record
  require GroupManager.Data.Message
  require GroupManager.Data.WorldClock
  require GroupManager.Data.TimedSet
  alias GroupManager.Data.Message
    
  Record.defrecord :message_log, entries: []
  @type t :: record( :message_log, entries: list(Message.t) )
  
  @spec new() :: t
  def new()
  do
    message_log()
  end
  
  @doc """
  Validate as much as we can about the `data` parameter which should be a MessageLog record.
   
  Validation rules are:
  
  - 1st is an `:message_log` atom
  - 2nd `entries`: is a list
  
  The purpose of this macro is to help checking input parameters in function guards.
  """
  defmacro is_valid(data) do
    case Macro.Env.in_guard?(__CALLER__) do
      true ->
        quote do
          is_tuple(unquote(data)) and tuple_size(unquote(data)) == 2 and
          :erlang.element(1, unquote(data)) == :message_log and
          # entries
          is_list(:erlang.element(2, unquote(data)))
        end
      false ->
        quote bind_quoted: [result: data] do
          is_tuple(result) and tuple_size(result) == 2 and
          :erlang.element(1, result) == :message_log and
          # entries
          is_list(:erlang.element(2, result))
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
  
  @spec entries(t) :: list(Message.t)
  def entries(log)
  when is_valid(log)
  do
    message_log(log, :entries)
  end
  
  @spec size(t) :: integer
  def size(log)
  when is_valid(log)
  do
    length(message_log(log, :entries))
  end

  @spec add(t, Message.t) :: t
  def add(log, msg)
  when is_valid(log) and Message.is_valid(msg) and Message.is_empty(msg) == false
  do
    message_log(log, entries: [msg | entries(log)])
  end
end