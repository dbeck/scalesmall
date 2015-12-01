defmodule GroupManager.Data.MessageLog do
  @moduledoc """
  TODO
  """
  
  alias GroupManager.Data.Message
  
  # The MessageLog.t type
  @type t :: { :message_log, list(Message.t) }
    
  @spec new() :: t
  def new(), do: { :message_log, [] }
  
  # setters:
  # none
  
  # getters:
  
  # manipulators:
  # - add message
  # - compact
  
  # accessors:
  # - calc state
end