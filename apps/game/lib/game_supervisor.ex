defmodule GameSupervisor do
  alias Experimental.DynamicSupervisor
  use DynamicSupervisor

  def start_link(opts \\ []) do
    DynamicSupervisor.start_link(__MODULE__, [], opts)
  end

  def init([]) do
    children = [
      worker(GameServer, [])
    ]
    {:ok, children, strategy: :one_for_one}
  end
end
