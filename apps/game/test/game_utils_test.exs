defmodule GameUtilsTest do
  use ExUnit.Case

  @state [[false, true, false],
          [true, false, true],
          [false, true, false]]

  test "transforms state into a text representation" do
    expected_result = "\n| |X| |\n|X| |X|\n| |X| |\n"

    assert expected_result == GameUtils.to_printable(@state)
  end
end
