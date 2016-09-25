defmodule GameTest do
  use ExUnit.Case

  @dead_field [[false, false, false],
               [false, false, false],
               [false, false, false]]

  test "can access field by index" do
    state = [[true, false, false],
             [false, true, false],
             [false, false, true]]

    assert true == Game.get_cell(state, {0, 0})
    assert true == Game.get_cell(state, {1, 1})
    assert true == Game.get_cell(state, {2, 2})
  end

  test "returns nil when coordinates are out of bounds" do
    assert nil == Game.get_cell(@dead_field, {3, 0})
    assert nil == Game.get_cell(@dead_field, {0, 3})
    assert nil == Game.get_cell(@dead_field, {3, 3})
    assert nil == Game.get_cell(@dead_field, {-1, 0})
    assert nil == Game.get_cell(@dead_field, {0, -1})
    assert nil == Game.get_cell(@dead_field, {-1, -1})
  end

  test "returns neighbors of specified cell" do
    state = [[true, false, false],
             [false, true, false],
             [false, false, true]]

    assert [true, false, false,
            false, false,
            false, false, true] == Game.get_neighbors(state, {1, 1})
  end

  test "skips out of bounds neighbors" do
    state = [[true, false, false],
             [false, true, false],
             [false, false, true]]

    assert [false, false, true] == Game.get_neighbors(state, {0, 0})
    assert [true, false, false] == Game.get_neighbors(state, {2, 2})
  end

  test "cells die due to underpopulation" do
    state = [[true, false, false],
             [false, true, false],
             [false, false, true]]
    expected_result = [[false, false, false],
                       [false, true, false],
                       [false, false, false]]

    assert expected_result == Game.tick(state)
  end

  test "cells revive due to population" do
    state = [[false, false, true],
             [false, false, true],
             [false, false, true]]
    expected_result = [[false, false, false],
                       [false, true, true],
                       [false, false, false]]

    assert expected_result == Game.tick(state)
  end

  test "cells die due to overpopulation" do
    state = [[true, true, true],
             [true, true, true],
             [true, true, true]]
    expected_result = [[true, false, true],
                       [false, false, false],
                       [true, false, true]]

    assert expected_result == Game.tick(state)
  end

  test "cells keep their state if no population effect present" do
    state = [[true, true, true],
             [false, false, false],
             [true, true, true]]
    expected_result = [[false, true, false],
                       [false, false, false],
                       [false, true, false]]

    assert expected_result == Game.tick(state)
  end
end
