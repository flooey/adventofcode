defmodule Day7 do
  def concat(a, b) do
    :math.pow(10, floor(:math.log10(b)) + 1) * a + b
  end

  def valid?(target, [item]) do
    item == target
  end

  def valid?(target, [first, second | rest]) do
    valid?(target, [first + second] ++ rest) or valid?(target, [first * second] ++ rest) or
      valid?(target, [concat(first, second)] ++ rest)
  end
end

IO.puts(
  IO.stream()
  |> Enum.map(fn l ->
    String.trim(l)
    |> String.split(" ")
    |> Enum.map(&String.trim(&1, ":"))
    |> Enum.map(&String.to_integer/1)
  end)
  |> Enum.filter(fn [target | rest] -> Day7.valid?(target, rest) end)
  |> Enum.map(fn [target | _] -> target end)
  |> Enum.sum()
)
