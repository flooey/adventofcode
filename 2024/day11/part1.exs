defmodule Day11 do
  def transform([]), do: []

  def transform([0 | tail]), do: [1] ++ transform(tail)

  def transform([head | tail]) do
    if rem(floor(:math.log10(head)) + 1, 2) == 0 do
      split = floor(:math.pow(10, div(floor(:math.log10(head)) + 1, 2)))
      [div(head, split), rem(head, split)] ++ transform(tail)
    else
      [head * 2024] ++ transform(tail)
    end
  end

  def transformN(l, 0), do: l
  def transformN(l, n), do: transformN(transform(l), n - 1)
end

IO.read(:line)
|> String.trim()
|> String.split(" ")
|> Enum.map(&String.to_integer/1)
|> Day11.transformN(25)
|> length()
|> IO.puts()
