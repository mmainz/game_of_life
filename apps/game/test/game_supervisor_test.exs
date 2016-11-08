defmodule GameSupervisorTest do
  use ExUnit.Case, async: true

  alias Experimental.DynamicSupervisor

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

    DynamicSupervisor.start_child(pid, [%GameServer{state: [],
                                                    name: "test",
                                                    consumer: self,
                                                    update_interval: 10}])

    assert_receive {:state_updated, "test", []}
    assert_receive {:state_updated, "test", []}
  end
end
