defmodule Web.GameChannel do
  @moduledoc false
  @game_timeout Application.get_env(:web, :game_timeout, 600_000)

  use Web.Web, :channel

  alias Experimental.DynamicSupervisor

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
    {:ok, _} = DynamicSupervisor.start_child(
      GameSupervisor, [%GameServer{state: GameUtils.random_state(width, height),
                                   name: name,
                                   timeout: @game_timeout,
                                   consumer: UpdateBroadcaster,
                                   update_interval: 200}])
  end
end
