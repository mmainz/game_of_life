defmodule GameServerTest do
  use ExUnit.Case

  setup do
    {:ok, %{gameserver: %GameServer{state: [],
                                    name: "test",
                                    consumer: self,
                                    update_interval: 10}}}
  end

  test "can be started", %{gameserver: gameserver} do
    {:ok, pid} = GameServer.start_link(gameserver)

    assert Process.alive?(pid)
  end

  test "can be named", %{test: test, gameserver: gameserver} do
    name = Module.concat(__MODULE__, test)
    {:ok, _} = GameServer.start_link(gameserver, name: name)

    assert name |> Process.whereis |> Process.alive?
  end

  test "it sends new states to the consumer", %{gameserver: gameserver} do
    {:ok, _} = GameServer.start_link(gameserver)

    assert_receive {:state_updated, "test", []}
    assert_receive {:state_updated, "test", []}
  end

  test "it correctly updates the game state", %{gameserver: gameserver} do
    gameserver = %{gameserver | state: [[true, false, false],
                                        [false, true, false],
                                        [false, false, true]]}
    {:ok, _} = GameServer.start_link(gameserver)

    assert_receive {:state_updated, "test", [[false, false, false],
                                             [false, true, false],
                                             [false, false, false]]}
    assert_receive {:state_updated, "test", [[false, false, false],
                                             [false, false, false],
                                             [false, false, false]]}
  end
end
