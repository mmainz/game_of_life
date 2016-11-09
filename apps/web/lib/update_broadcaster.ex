defmodule UpdateBroadcaster do
  @moduledoc false

  use GenServer

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, %{}, opts)
  end

  def handle_info({:state_updated, name, state}, %{}) do
    Web.Endpoint.broadcast!("game:" <> name, "state_updated", %{state: state})

    {:noreply, %{}}
  end

  def handle_info({:game_finished, name}, %{}) do
    Web.Endpoint.broadcast!("game:" <> name, "game_finished", %{})

    {:noreply, %{}}
  end
end
