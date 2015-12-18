defmodule GroupManager.Chatter.PeerDB do

  use ExActor.GenServer

  defstart start_link([], opts),
    gen_server_opts: opts
  do
    name = Keyword.get(opts, :name, id_atom())
    :ets.new(name, [:named_table, :set, :protected])
    initial_state([])
  end

  #defcall foo, do: set_and_reply(new_state, response)

  defcast stop, do: stop_server(:normal)  

  def locate, do: Process.whereis(id_atom())
  
  def locate! do
    case Process.whereis(id_atom()) do
      pid when is_pid(pid) ->
        pid
    end
  end
  
  def id_atom, do: __MODULE__
end
