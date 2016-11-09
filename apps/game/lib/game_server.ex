defmodule GameServer do
  @moduledoc false

  use GenServer

  defstruct [:name, :state, :consumer, :update_interval, :timeout]

  def start_link(gameserver, opts \\ []) do
    GenServer.start_link(__MODULE__, gameserver, opts)
  end

  def init(gameserver) do
    queue_next_update(gameserver.update_interval)
    queue_timeout(gameserver.timeout)

    {:ok, gameserver}
  end

  def handle_info(:update_state, gameserver) do
    new_state = Game.tick(gameserver.state)
    send gameserver.consumer, {:state_updated, gameserver.name, new_state}
    queue_next_update(gameserver.update_interval)

    {:noreply, Map.put(gameserver, :state, new_state)}
  end

  def handle_info(:timeout, gameserver) do
    send gameserver.consumer, {:game_finished, gameserver.name}
    Process.exit(self, :normal)
  end

  defp queue_next_update(interval) do
    Process.send_after(self, :update_state, interval)
  end

  defp queue_timeout(nil), do: nil
  defp queue_timeout(timeout) do
    Process.send_after(self, :timeout, timeout)
  end
end
