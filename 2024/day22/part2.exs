defmodule Day22 do
  def next(num, 0), do: [num]

  def next(onum, n) do
    num = rem(Bitwise.bxor(onum * 64, onum), 16_777_216)
    num = rem(Bitwise.bxor(div(num, 32), num), 16_777_216)
    num = rem(Bitwise.bxor(num * 2048, num), 16_777_216)

    [rem(onum, 10) | next(num, n - 1)]
  end

  def to_price_map(nums) do
    Enum.zip([
      nums,
      Enum.drop(nums, 1),
      Enum.drop(nums, 2),
      Enum.drop(nums, 3),
      Enum.drop(nums, 4)
    ])
    |> Enum.map(fn {a, b, c, d, e} -> {{b - a, c - b, d - c, e - d}, e} end)
    |> Enum.reverse()
    |> Map.new()
  end
end

price_maps =
  IO.stream()
  |> Enum.map(&String.trim/1)
  |> Enum.map(&String.to_integer/1)
  |> Enum.map(&Day22.next(&1, 2000))
  |> Enum.map(&Day22.to_price_map/1)

IO.puts(
  Enum.max(
    for a <- -9..9, b <- -9..9, c <- -9..9, d <- -9..9 do
      price_maps |> Enum.map(&Map.get(&1, {a, b, c, d}, 0)) |> Enum.sum()
    end
  )
)
