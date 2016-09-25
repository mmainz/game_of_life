defmodule GameUtils do
  def to_printable(state) do
    "\n" <> state_string(state) <> "\n"
  end

  def random_state(size), do: random_state(size, size)
  def random_state(width, height) do
    fn -> generate_row(width) end
    |> Stream.repeatedly
    |> Enum.take(height)
  end

  defp generate_row(width) do
    fn -> Enum.random([true, false]) end
    |> Stream.repeatedly
    |> Enum.take(width)
  end

  defp state_string(state) do
    state
    |> Enum.map(fn row -> "|" <> row_string(row) <> "|" end)
    |> Enum.join("\n")
  end

  defp row_string(row) do
    row
    |> Enum.map(&cell_to_printable/1)
    |> Enum.join("|")
  end

  defp cell_to_printable(true), do: "X"
  defp cell_to_printable(false), do: " "
end
