IO.puts(
  IO.stream(:stdio, :line)
  |> Enum.map(&String.split/1)
  |> Enum.map(fn x -> Enum.map(x, &String.to_integer/1) end)
  |> Enum.map(&List.zip([&1, List.delete_at(&1, 0)]))
  |> Enum.map(&Enum.map(&1, fn {a, b} -> a - b end))
  |> List.foldl(0, fn l, acc ->
    if Enum.all?(l, &(1 <= &1 and &1 <= 3)) or Enum.all?(l, &(-3 <= &1 and &1 <= -1)) do
      acc + 1
    else
      acc
    end
  end)
)
