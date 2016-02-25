defmodule StreamPipe do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = []

    opts = [strategy: :one_for_one, name: StreamPipe.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # publisher interface
  # - publish("group_name", message)

  # subscriber interface
  # - first_positon
  # - last_position
  # - subscribe("group_name", fun)
  # - subscribe("group_name", fun, start_position)
  # - unsubscribe("group_name", fun)

  # server interface
  # - start("group_name")
end
