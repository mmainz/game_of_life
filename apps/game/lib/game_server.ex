defmodule GameServer do
  use GenServer

  defstruct [:state, :consumer, :update_interval]

  def start_link(gameserver, opts \\ []) do
    GenServer.start_link(__MODULE__, gameserver, opts)
  end

  def init(gameserver) do
    queue_next_update(gameserver.update_interval)

    {:ok, gameserver}
  end

  def handle_info(:update_state, gameserver) do
    new_state = Game.tick(gameserver.state)
    send gameserver.consumer, {:state_updated, new_state}
    queue_next_update(gameserver.update_interval)

    {:noreply, Map.put(gameserver, :state, new_state)}
  end

  defp queue_next_update(interval) do
    Process.send_after(self, :update_state, interval)
  end
end
