IO.puts(
  Enum.sum(
    IO.stream()
    |> Enum.map(fn line -> line |> String.trim() |> String.graphemes() |> List.to_tuple() end)
    |> List.to_tuple()
    |> then(fn data ->
      for x <- 1..(tuple_size(data) - 2),
          y <- 1..(tuple_size(elem(data, 0)) - 2) do
        cond do
          data |> elem(y) |> elem(x) != "A" ->
            0

          Enum.sum(
            for {{mdx, mdy}, {sdx, sdy}} <- [
                  {{-1, -1}, {1, 1}},
                  {{-1, 1}, {1, -1}},
                  {{1, -1}, {-1, 1}},
                  {{1, 1}, {-1, -1}}
                ] do
              if data |> elem(y + mdy) |> elem(x + mdx) == "M" and
                     data |> elem(y + sdy) |> elem(x + sdx) == "S" do
                1
              else
                0
              end
            end
          ) == 2 ->
            1

          true ->
            0
        end
      end
    end)
  )
)
