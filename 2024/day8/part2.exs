points =
  IO.stream()
  |> Enum.with_index()
  |> Enum.flat_map(fn {line, y} ->
    String.trim(line)
    |> String.graphemes()
    |> Enum.with_index()
    |> Enum.filter(fn {c, _} -> c != "." end)
    |> Enum.map(fn {c, x} -> {x, y, c} end)
  end)

maxx = Enum.map(points, fn {x, _, _} -> x end) |> Enum.max()
maxy = Enum.map(points, fn {_, y, _} -> y end) |> Enum.max()

by_type = Enum.group_by(points, fn {_, _, c} -> c end, fn {x, y, _} -> {x, y} end)

IO.inspect(
  by_type
  |> Enum.flat_map(fn {_, ps} ->
    Enum.concat(
      for p1 <- ps, p2 <- ps, p1 != p2 do
        {x1, y1} = p1
        {x2, y2} = p2
        dx = x1 - x2
        dy = y1 - y2
        g = Integer.gcd(abs(dx), abs(dy))
        dx = dx / g
        dy = dy / g

        Enum.to_list(
          0..100
          |> Stream.map(&{x1 + dx * &1, y1 + dy * &1})
          |> Stream.take_while(fn {x, y} -> 0 <= x && x <= maxx && 0 <= y && y <= maxy end)
        ) ++
          Enum.to_list(
            0..100
            |> Stream.map(&{x1 - dx * &1, y1 - dy * &1})
            |> Stream.take_while(fn {x, y} -> 0 <= x && x <= maxx && 0 <= y && y <= maxy end)
          )
      end
    )
  end)
  |> MapSet.new()
  |> MapSet.size()
)
