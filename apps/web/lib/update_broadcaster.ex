defmodule UpdateBroadcaster do
  use GenServer

  def start_link(name, opts \\ []) do
    GenServer.start_link(__MODULE__, %{name: name}, opts)
  end

  def handle_info({:state_updated, state}, %{name: name}) do
    Web.Endpoint.broadcast!("game:" <> name, "state_updated", %{state: state})

    {:noreply, %{name: name}}
  end
end
