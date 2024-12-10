defmodule Day10 do
  def paths(data, x, y, target) do
    cond do
      y < 0 || tuple_size(data) <= y || x < 0 || tuple_size(data |> elem(y)) <= x ->
        MapSet.new()

      data |> elem(y) |> elem(x) != target ->
        MapSet.new()

      target == 9 ->
        MapSet.new([{x, y}])

      true ->
        paths(data, x - 1, y, target + 1)
        |> MapSet.union(paths(data, x + 1, y, target + 1))
        |> MapSet.union(paths(data, x, y - 1, target + 1))
        |> MapSet.union(paths(data, x, y + 1, target + 1))
    end
  end
end

data =
  IO.stream()
  |> Enum.map(fn l ->
    String.trim(l) |> String.graphemes() |> Enum.map(&String.to_integer/1) |> List.to_tuple()
  end)
  |> List.to_tuple()

IO.puts(
  data
  |> Tuple.to_list()
  |> Enum.with_index()
  |> Enum.flat_map(fn {row, y} ->
    row
    |> Tuple.to_list()
    |> Enum.with_index()
    |> Enum.map(fn {_, x} -> MapSet.size(Day10.paths(data, x, y, 0)) end)
  end)
  |> Enum.sum()
)
