IO.puts(
  Enum.sum(
    IO.stream()
    |> Enum.map(fn line -> line |> String.trim() |> String.graphemes() |> List.to_tuple() end)
    |> List.to_tuple()
    |> then(fn data ->
      for x <- 0..(tuple_size(data) - 1),
          y <- 0..(tuple_size(elem(data, 0)) - 1),
          {dx, dy} <- [{0, 1}, {1, 0}, {0, -1}, {-1, 0}, {1, 1}, {1, -1}, {-1, 1}, {-1, -1}] do
        cond do
          x + 3 * dx < 0 or x + 3 * dx >= tuple_size(data) or y + 3 * dy < 0 or
              y + 3 * dy >= tuple_size(elem(data, 0)) ->
            0

          data |> elem(y) |> elem(x) == "X" and data |> elem(y + dy) |> elem(x + dx) == "M" and
            data |> elem(y + 2 * dy) |> elem(x + 2 * dx) == "A" and
              data |> elem(y + 3 * dy) |> elem(x + 3 * dx) == "S" ->
            1

          true ->
            0
        end
      end
    end)
  )
)
