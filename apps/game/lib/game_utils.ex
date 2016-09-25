defmodule GameUtils do
  def to_printable(state) do
    state_string = state
    |> Enum.map(fn row ->
      row_string = row
      |> Enum.map(&cell_to_printable/1)
      |> Enum.join("|")
      "|" <> row_string <> "|"
    end)
    |> Enum.join("\n")

    "\n" <> state_string <> "\n"
  end

  defp cell_to_printable(true), do: "X"
  defp cell_to_printable(false), do: " "
end
