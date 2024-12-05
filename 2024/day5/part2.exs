rules =
  IO.stream()
  |> Stream.take_while(&(&1 != "\n"))
  |> Enum.map(fn x ->
    String.trim(x)
    |> String.split("|")
    |> Enum.map(&String.to_integer/1)
    |> List.to_tuple()
  end)
  |> MapSet.new()

pages =
  IO.stream()
  |> Enum.map(fn l ->
    String.trim(l) |> String.split(",") |> Enum.map(&String.to_integer/1)
  end)

defmodule Day5 do
  def pairs([_]), do: []
  def pairs([head | tail]), do: (tail |> Enum.map(&{&1, head})) ++ Day5.pairs(tail)
end

IO.puts(
  Enum.sum(
    pages
    |> Enum.filter(fn p ->
      MapSet.size(Day5.pairs(p) |> MapSet.new() |> MapSet.intersection(rules)) > 0
    end)
    |> Enum.map(fn p ->
      Enum.sort(p, &MapSet.member?(rules, {&1, &2}))
    end)
    |> Enum.map(fn p -> List.to_tuple(p) |> then(&elem(&1, div(tuple_size(&1) - 1, 2))) end)
  )
)
