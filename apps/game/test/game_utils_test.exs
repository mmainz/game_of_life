defmodule GameUtilsTest do
  use ExUnit.Case

  @state [[false, true, false],
          [true, false, true],
          [false, true, false]]

  test "transforms state into a text representation" do
    expected_result = "\n| |X| |\n|X| |X|\n| |X| |\n"

    assert expected_result == GameUtils.to_printable(@state)
  end

  test "creates random states with specified size" do
    state = GameUtils.random_state(3)

    assert 3 == length(state)
    assert Enum.all?(state, fn row -> length(row) == 3 end)
  end

  test "creates random states with specified width and height" do
    state = GameUtils.random_state(2, 4)

    assert 4 == length(state)
    assert Enum.all?(state, fn row -> length(row) == 2 end)
  end
end
