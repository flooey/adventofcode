data =
  IO.stream(:stdio, :line)
  |> Enum.map(&String.split/1)
  |> Enum.map(&{String.to_integer(List.first(&1)), String.to_integer(List.last(&1))})

left = data |> Enum.map(&elem(&1, 0)) |> Enum.sort()
right = data |> Enum.map(&elem(&1, 1)) |> Enum.sort()

IO.puts(List.zip([left, right]) |> Enum.map(&abs(elem(&1, 0) - elem(&1, 1))) |> Enum.sum())
