defmodule Web.GameChannelTest do
  use Web.ChannelCase

  alias Web.GameChannel

  defp join_lobby do
    with {:ok, _, socket} <- subscribe_and_join(
           socket, GameChannel, "game:lobby"),
      do: socket
  end

  defp join_game(name) do
    with {:ok, _, socket} <- subscribe_and_join(
           socket, GameChannel, "game:" <> name),
      do: socket
  end

  setup do
    {:ok, %{lobby: join_lobby}}
  end

  test "creating a game responds with success", %{lobby: socket} do
    ref = push socket, "create", %{width: 5, height: 5, name: "test"}

    assert_reply ref, :ok, %{name: "test"}
    assert_broadcast "new_game", %{name: "test"}
  end

  test "creating a game sends updates in the games room", %{lobby: socket} do
    push socket, "create", %{width: 5, height: 5, name: "test"}
    join_game("test")

    assert_broadcast "state_updated", %{state: state}, 1000
    assert Enum.all?(state, fn row ->
      Enum.all?(row, fn cell -> is_boolean(cell) end)
    end)
  end
end
