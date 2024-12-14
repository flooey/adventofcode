IO.inspect(
  IO.stream()
  |> Enum.map(fn l ->
    Regex.run(~r"p=(-?[0-9]+),(-?[0-9]+) v=(-?[0-9]+),(-?[0-9]+)", l, capture: :all_but_first)
    |> Enum.map(&String.to_integer/1)
    |> then(fn [px, py, vx, vy] ->
      {x, y} = {rem(px + vx * 100, 101), rem(py + vy * 100, 103)}
      {if(x < 0, do: x + 101, else: x), if(y < 0, do: y + 103, else: y)}
    end)
  end)
  |> Enum.group_by(fn {x, y} ->
    {cond do
       x < 50 -> -1
       x == 50 -> 0
       x > 50 -> 1
     end,
     cond do
       y < 51 -> -1
       y == 51 -> 0
       y > 50 -> 1
     end}
  end)
  |> Map.filter(fn {{qx, qy}, _} -> qx != 0 and qy != 0 end)
  |> Map.values()
  |> Enum.map(&length/1)
  |> Enum.product()
)
