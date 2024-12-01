data =
  IO.stream(:stdio, :line)
  |> Enum.map(&String.split/1)
  |> Enum.map(&{String.to_integer(List.first(&1)), String.to_integer(List.last(&1))})

left = data |> Enum.map(&elem(&1, 0)) |> Enum.sort()
right = data |> Enum.map(&elem(&1, 1)) |> Enum.sort()

right_freqs = Enum.frequencies(right)

IO.puts(left |> Enum.map(&(&1 * (right_freqs[&1] || 0))) |> Enum.sum())
