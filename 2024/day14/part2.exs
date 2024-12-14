defmodule Day14 do
  def draw(i, robots) do
    m = MapSet.new(robots)
    IO.puts("******")
    IO.puts(i)

    for x <- 0..101, y <- 0..103 do
      IO.write(if MapSet.member?(m, {y, x}), do: ~c"X", else: ~c" ")
      if y == 103, do: IO.puts("")
    end
  end

  def move([px, py, vx, vy], x) do
    {x, y} = {rem(px + vx * x, 101), rem(py + vy * x, 103)}
    {if(x < 0, do: x + 101, else: x), if(y < 0, do: y + 103, else: y)}
  end
end

IO.stream()
|> Enum.map(fn l ->
  Regex.run(~r"p=(-?[0-9]+),(-?[0-9]+) v=(-?[0-9]+),(-?[0-9]+)", l, capture: :all_but_first)
  |> Enum.map(&String.to_integer/1)
end)
|> then(fn robots ->
  for i <- 64..10000//103, do: Day14.draw(i, robots |> Enum.map(&Day14.move(&1, i)))
end)
