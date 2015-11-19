defmodule GroupManager.LogData.Container do
  @moduledoc """
  TODO
  """
  
  defstruct logs: %HashDict{}

  alias GroupManager.LogData.Container, as: Container
  alias GroupManager.LogData.LogEntry,  as: LogEntry
  alias GroupManager.LogData.Data,      as: Data

  def add(container, log_entry)
  when is_map(container) and is_map(log_entry)
  do
    # unwrap data
    %Container{logs: logs} = container
    %LogEntry{data: %Data{prev_hash: prev_hash}, new_hash: new_hash} = log_entry
    
    if HashDict.has_key?(logs, prev_hash) do
      
      case HashDict.fetch(logs, new_hash) do
        :error ->
          HashDict.put(logs, new_hash, log_entry)
          {:ok, %Container{logs: HashDict.put(logs, new_hash, log_entry)}, :inserted}
        
        {:ok, %LogEntry{data: %Data{prev_hash: ^prev_hash}, new_hash: ^new_hash}} ->
          {:ok, container, :already_exists}
      end    
    else
      {:error, :missing_parent}
    end
  end
  
  def init(container)
  when is_map(container)
  do
    %Container{logs: logs} = container
    data = %Data{}
    new_hash = Data.hash(data)
    log_entry = %LogEntry{data: %Data{}, new_hash: new_hash}
    
    if HashDict.has_key?(logs, new_hash) do
      {:error, :already_initialized}
    else
      {:ok, %Container{logs: HashDict.put(logs, new_hash, log_entry)}}
    end
  end
    
  ########################################
  
  # update :
  #  - add(GroupManager.Message)
  
  # what we can get: Data, LogEntry, NodeState
  
  # lookup :
  #  - 
  
  # hashes_after(act-hash)
  # node_status(node) -> :state, :hash
  
  
  #########################################
  # GroupManager API
  
  #######################################################################################
  # TODO : implement these API functions
  
  def join(_remote_name) do
    raise "implement me"
  end
  
  def leave(_group_name) do
    raise "implement me"
  end
  
  def register(_point)
  do
    raise "implement me"
  end
  
  def release(_point)
  do
    raise "implement me"
  end
  
  def promote(_point)
  do
    raise "implement me"
  end

  def demote(_point)
  do
    raise "implement me"
  end
  
  # TODO: implement theses accessors/query/info functions
  
  def get_peers(_point)
  do
    raise "implement me"
  end
  
  def get_all_peers(_options) # :all, :ready, :gone, :busy
  do
    raise "implement me"
  end
  
  def get_ranges(_options) # {:all}, {:self}, {:nodes, [node1, node2, ...]}
  do
    raise "implement me"
  end
  
end
