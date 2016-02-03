defmodule GroupManager.Receiver do

  use ExActor.GenServer
  require GroupManager
  require GroupManager.Data.Message
  require GroupManager.Data.WorldClock
  require GroupManager.Data.TimedSet
  alias GroupManager.Data.Message
  alias GroupManager.TopologyDB

  defstart start_link(opts \\ []),
    gen_server_opts: opts
  do
    initial_state(opts)
  end

  # Convenience API

  def handle(pid, message)
  when is_pid(pid) and
       Message.is_valid(message)
  do
    GenServer.call(pid, {:handle, message})
  end

  # GenServer

  defcast stop, do: stop_server(:normal)

  def handle_call({:handle, message}, _from, state)
  when Message.is_valid(message)
  do
    topo_db = TopologyDB.locate!
    :ok = TopologyDB.add(topo_db, message)
    {:ok, new_message} = TopologyDB.get(topo_db, Message.group_name(message))
  	{:reply, {:ok, new_message}, state}
  end

  def locate, do: Process.whereis(id_atom())

  def locate! do
    case Process.whereis(id_atom()) do
      pid when is_pid(pid) ->
        pid
    end
  end

  def id_atom, do: __MODULE__
end
