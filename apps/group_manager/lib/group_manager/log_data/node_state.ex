defmodule GroupManager.LogData.NodeState do
  @moduledoc """
  TODO
  """
  
  alias GroupManager.StatusEvent.State, as: State
  
  defstruct node_state: %State{}

  alias GroupManager.LogData.NodeState, as: NodeState
  
  # !!! THIS MODULE TO BE GONE SOON !!!
  # redundant StatusEvent.State

end
