defmodule Day25 do
  def count_row([]), do: [-1, -1, -1, -1, -1]

  def count_row([row | rows]) do
    Enum.zip([
      row
      |> String.graphemes()
      |> Enum.map(fn x ->
        case x do
          "." -> 0
          "#" -> 1
        end
      end),
      count_row(rows)
    ])
    |> Enum.map(fn {x, y} -> x + y end)
  end

  def count(rows) do
    {case List.first(rows) do
       "#####" -> :lock
       "....." -> :key
     end, count_row(rows)}
  end

  def match(keys, locks) do
    Enum.sum(
      for k <- keys, l <- locks do
        if Enum.zip([k, l]) |> Enum.map(fn {x, y} -> x + y end) |> Enum.any?(&(&1 > 5)) do
          0
        else
          1
        end
      end
    )
  end
end

items =
  IO.stream()
  |> Stream.chunk_while(
    [],
    fn el, acc ->
      el = String.trim(el)

      if el == "" do
        {:cont, Enum.reverse(acc), []}
      else
        {:cont, [el | acc]}
      end
    end,
    fn acc -> {:cont, Enum.reverse(acc), []} end
  )
  |> Enum.map(&Day25.count/1)
  |> Enum.group_by(&elem(&1, 0), &elem(&1, 1))

IO.puts(Day25.match(items[:key], items[:lock]))
