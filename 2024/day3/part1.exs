IO.puts(
  IO.stream(:stdio, :line)
  |> Enum.map(fn l ->
    Regex.scan(~r"mul[(](\d{1,3}),(\d{1,3})[)]", l, capture: :all_but_first)
    |> Enum.map(fn [a, b] -> String.to_integer(a) * String.to_integer(b) end)
    |> Enum.sum()
  end)
  |> Enum.sum()
)
