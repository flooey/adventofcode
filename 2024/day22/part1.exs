defmodule Day22 do
  def next(num, 0), do: num

  def next(num, n) do
    num = rem(Bitwise.bxor(num * 64, num), 16_777_216)
    num = rem(Bitwise.bxor(div(num, 32), num), 16_777_216)
    num = rem(Bitwise.bxor(num * 2048, num), 16_777_216)

    next(num, n - 1)
  end
end

IO.puts(
  IO.stream()
  |> Enum.map(&String.trim/1)
  |> Enum.map(&String.to_integer/1)
  |> Enum.map(&Day22.next(&1, 2000))
  |> Enum.sum()
)
