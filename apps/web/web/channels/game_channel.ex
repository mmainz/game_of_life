defmodule Web.GameChannel do
  use Web.Web, :channel

  def join("game:lobby", _payload, socket) do
    {:ok, socket}
  end

  def join("game:" <> _name, _payload, socket) do
    {:ok, socket}
  end

  def handle_in("create", %{"name" => name} = payload, socket) do
    {:ok, _} = create_game(payload)
    broadcast socket, "new_game", %{name: name}

    {:reply, {:ok, %{name: name}}, socket}
  end

  defp create_game(%{"width" => width, "height" => height, "name" => name}) do
    {:ok, update_broadcaster} = UpdateBroadcaster.start_link(name)
    {:ok, _} = GameServer.start_link(
      %GameServer{state: GameUtils.random_state(width, height),
                  consumer: update_broadcaster,
                  update_interval: 500})
  end
end
