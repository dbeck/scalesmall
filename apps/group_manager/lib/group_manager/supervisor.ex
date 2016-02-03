defmodule GroupManager.Supervisor do

  use Supervisor

  alias GroupManager.Chatter
  alias GroupManager.MemberDB
  alias GroupManager.TopologyDB
  alias GroupManager.Receiver

  def start_link(opts \\ []) do
    case opts do
      [name: name] ->
        Supervisor.start_link(__MODULE__, :no_args, opts)
      _ ->
        Supervisor.start_link(__MODULE__, :no_args, [name: id_atom()] ++ opts)
    end
  end

  def init(:no_args) do
    children = [
      supervisor(Receiver,   [[name: Receiver.id_atom()]]),
      supervisor(MemberDB,   [[name: MemberDB.id_atom()]]),
      supervisor(TopologyDB, [[name: TopologyDB.id_atom()]]),
      supervisor(Chatter,    [[name: Chatter.id_atom()]])
    ]
    {:ok, pid} = supervise(children, strategy: :one_for_one)
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
