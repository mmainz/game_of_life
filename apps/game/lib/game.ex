defmodule Game do
  def tick(state) do
    state
    |> Enum.with_index
    |> Enum.map(fn {row, y} ->
      row
      |> Enum.with_index
      |> Enum.map(fn {_, x} ->
        new_cell_state(state, {x, y})
      end)
    end)
  end

  def get_cell(state, {x, y}) do
    state
    |> get_row_by_index(y)
    |> get_cell_by_index(x)
  end

  def get_neighbors(state, {x, y}) do
    {x, y}
    |> neighbor_coordinates
    |> Enum.map(fn coordinates -> get_cell(state, coordinates) end)
    |> Enum.filter(fn cell_value -> cell_value != nil end)
  end

  defp new_cell_state(state, coordinates) do
    current_state = get_cell(state, coordinates)
    live_neighbors = get_neighbors(state, coordinates)
    |> Enum.filter(fn cell_state -> cell_state end)
    |> Enum.count

    cond do
      current_state && live_neighbors < 2 -> false
      current_state && live_neighbors > 3 -> false
      !current_state && live_neighbors == 3 -> true
      true -> current_state
    end
  end

  defp neighbor_coordinates({x, y}) do
    for neighbor_x <- [x - 1, x, x + 1],
        neighbor_y <- [y - 1, y, y + 1],
        neighbor_coordinates = {neighbor_x, neighbor_y},
        neighbor_coordinates != {x, y},
      do: neighbor_coordinates
  end

  defp get_row_by_index(nil, _index), do: nil
  defp get_row_by_index(_, index) when index < 0, do: nil
  defp get_row_by_index(field, index), do: Enum.at(field, index)

  defp get_cell_by_index(nil, _index), do: nil
  defp get_cell_by_index(_, index) when index < 0, do: nil
  defp get_cell_by_index(row, index), do: Enum.at(row, index)
end
