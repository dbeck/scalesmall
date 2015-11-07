defmodule GroupManager do
  use Application

  def start(_type, _args) do
    GroupManager.Master.start_link
  end
end
