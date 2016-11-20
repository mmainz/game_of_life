defmodule Utilities do
  def pmap(enum, fun) do
    enum
    |> Enum.map(fn i -> Task.async(fn -> fun.(i) end) end)
    |> Enum.map(&Task.await/1)
  end
end
