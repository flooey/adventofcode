IO.puts(
  IO.stream(:stdio, :line)
  |> Enum.map(fn l ->
    String.split(l)
    |> Enum.map(&String.to_integer/1)
    |> then(fn l2 ->
      for i <- 0..(Enum.count(l2) - 1) do
        List.delete_at(l2, i)
      end
    end)
    |> Enum.map(fn l2 ->
      List.zip([l2, List.delete_at(l2, 0)])
      |> Enum.map(fn {a, b} -> a - b end)
      |> then(fn l3 ->
        Enum.all?(l3, &(1 <= &1 and &1 <= 3)) or Enum.all?(l3, &(-3 <= &1 and &1 <= -1))
      end)
    end)
    |> Enum.any?()
  end)
  |> Enum.count(&Function.identity/1)
)
