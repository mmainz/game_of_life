defmodule Web.GameChannel do
  use Web.Web, :channel

  def join("game:lobby", _payload, socket) do
    {:ok, socket}
  end

  def join("game:" <> name, %{"width" => _, "height" => _} = payload, socket) do
    {:ok, _} = payload
    |> Map.put("name", name)
    |> create_game

    send self, {:new_game, name}
    {:ok, %{success: true}, socket}
  end
  def join("game:" <> _name, _payload, socket) do
    {:ok, socket}
  end

  def handle_info({:new_game, name}, socket) do
    Web.Endpoint.broadcast!("game:lobby", "new_game", %{name: name})
    {:noreply, socket}
  end

  defp create_game(%{"width" => width, "height" => height, "name" => name}) do
    {:ok, update_broadcaster} = UpdateBroadcaster.start_link(name)
    {:ok, _} = GameServer.start_link(
      %GameServer{state: GameUtils.random_state(width, height),
                  consumer: update_broadcaster,
                  update_interval: 500})
  end
end
