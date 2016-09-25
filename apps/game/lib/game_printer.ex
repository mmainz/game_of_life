defmodule GamePrinter do
  use GenServer

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, %{}, opts)
  end

  def handle_info({:state_updated, state}, %{}) do
    state
    |> GameUtils.to_printable
    |> IO.puts

    {:noreply, %{}}
  end
end
