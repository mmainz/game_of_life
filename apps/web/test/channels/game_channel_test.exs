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

  defp create_game(name, width \\ 5, height \\ 5) do
    with {:ok, reply, socket} <- join(
           socket,
           GameChannel,
           "game:" <> name,
           %{"width" => width, "height" => height}),
      do: {socket, reply}
  end

  setup do
    {:ok, %{lobby: join_lobby}}
  end

  test "creating a game responds with success" do
    {_, reply} = create_game("test")

    assert reply == %{success: true}
    assert_broadcast "new_game", %{name: "test"}, 1000
  end

  test "creating a game sends updates in the games room" do
    create_game("test")
    join_game("test")

    assert_broadcast "state_updated", %{state: state}, 1000
    assert Enum.all?(state, fn row ->
      Enum.all?(row, fn cell -> is_boolean(cell) end)
    end)
  end
end
