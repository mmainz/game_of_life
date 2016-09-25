defmodule GameUtils do
  def to_printable(state) do
    "\n" <> state_string(state) <> "\n"
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
