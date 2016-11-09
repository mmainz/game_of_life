defmodule GameSupervisorTest do
  use ExUnit.Case, async: true

  test "can be started" do
    {:ok, pid} = GameSupervisor.start_link

    assert Process.alive?(pid)
  end

  test "can be named", %{test: test} do
    name = Module.concat(__MODULE__, test)
    {:ok, _} = GameSupervisor.start_link(name: name)

    assert name |> Process.whereis |> Process.alive?
  end

  test "can start a game server" do
    {:ok, pid} = GameSupervisor.start_link

    GameSupervisor.start_gameserver(pid, [%GameServer{state: [],
                                                      name: "test",
                                                      consumer: self,
                                                      update_interval: 10}])

    assert_receive {:state_updated, "test", []}
    assert_receive {:state_updated, "test", []}
  end

  test "does not restart a game server that times out" do
    {:ok, pid} = GameSupervisor.start_link

    {:ok, gameserver_pid} = GameSupervisor.start_gameserver(
      pid, [%GameServer{state: [],
                        name: "test",
                        consumer: self,
                        update_interval: 10,
                        timeout: 100}])
    ref = Process.monitor(gameserver_pid)

    assert 1 == Enum.count(Supervisor.which_children(pid))
    assert_receive {:DOWN, ^ref, :process, ^gameserver_pid, :normal}, 2000
    assert 0 == Enum.count(Supervisor.which_children(pid))
  end
end
