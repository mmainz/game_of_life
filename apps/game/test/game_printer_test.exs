defmodule GamePrinterTest do
  use ExUnit.Case

  import Mock

  @state [[false, true, false],
          [true, false, true],
          [false, true, false]]

  defp mocks do
    parent = self
    [{IO, [], [puts: fn _ ->
                send parent, :done
                :ok
              end]}]
  end

  test "can be started" do
    {:ok, pid} = GamePrinter.start_link

    assert Process.alive?(pid)
  end

  test "can be named", %{test: test} do
    name = Module.concat(__MODULE__, test)
    {:ok, _} = GamePrinter.start_link(name: name)

    assert name |> Process.whereis |> Process.alive?
  end

  test "it prints the state when sent" do
    with_mocks mocks do
      {:ok, pid} = GamePrinter.start_link
      send pid, {:state_updated, @state}

      assert_receive :done
      assert called IO.puts("\n| |X| |\n|X| |X|\n| |X| |\n")
    end
  end
end
