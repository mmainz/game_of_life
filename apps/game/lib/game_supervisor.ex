defmodule GameSupervisor do
  @moduledoc false

  use Supervisor

  def start_link(opts \\ []) do
    Supervisor.start_link(__MODULE__, [], opts)
  end

  def init([]) do
    children = [
      worker(GameServer, [], restart: :transient)
    ]

    supervise(children, strategy: :simple_one_for_one)
  end

  def start_gameserver(pid, gameserver) do
    Supervisor.start_child(pid, gameserver)
  end
end
