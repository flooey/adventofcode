defmodule Day11 do
  def transform(0, x), do: %{1 => x}

  def transform(n, x) do
    if rem(floor(:math.log10(n)) + 1, 2) == 0 do
      split = floor(:math.pow(10, div(floor(:math.log10(n)) + 1, 2)))
      a = div(n, split)
      b = rem(n, split)

      if a == b do
        %{a => x * 2}
      else
        %{a => x, b => x}
      end
    else
      %{(n * 2024) => x}
    end
  end

  def transformMap(m) do
    Map.keys(m)
    |> Enum.reduce(%{}, fn k, acc ->
      Map.merge(acc, transform(k, m[k]), fn _k, v1, v2 -> v1 + v2 end)
    end)
  end

  def transformN(m, 0), do: m

  def transformN(m, n) do
    transformN(transformMap(m), n - 1)
  end
end

IO.read(:line)
|> String.trim()
|> String.split(" ")
|> Enum.map(&String.to_integer/1)
|> Enum.frequencies()
|> Day11.transformN(75)
|> Map.values()
|> Enum.sum()
|> IO.puts()
