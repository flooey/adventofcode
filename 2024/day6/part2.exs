defmodule Day6 do
  def turn(dir) do
    case dir do
      :left -> :up
      :up -> :right
      :right -> :down
      :down -> :left
    end
  end

  def move({x, y}, dir) do
    case dir do
      :left -> {x - 1, y}
      :right -> {x + 1, y}
      :up -> {x, y - 1}
      :down -> {x, y + 1}
    end
  end

  def next(pos, dir, obstacles) do
    x = move(pos, dir)

    if MapSet.member?(obstacles, x) do
      next(pos, turn(dir), obstacles)
    else
      {x, dir}
    end
  end

  def loops?(pos, dir, obstacles, visited, bounds) do
    {x, y} = pos
    {bx, by} = bounds

    cond do
      x < 0 or y < 0 or x >= bx or y >= by ->
        false

      MapSet.member?(visited, {x, y, dir}) ->
        true

      true ->
        {npos, ndir} = next(pos, dir, obstacles)
        loops?(npos, ndir, obstacles, MapSet.put(visited, {x, y, dir}), bounds)
    end
  end
end

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

obstacles =
  Enum.filter(points, fn {_, _, c} -> c == "#" end) |> Enum.map(fn {x, y, _} -> {x, y} end)

pos =
  Enum.filter(points, fn {_, _, c} -> c == "^" end)
  |> Enum.map(fn {x, y, _} -> {x, y} end)
  |> List.first()

maxx = Enum.map(points, fn {x, _, _} -> x end) |> Enum.max()
maxy = Enum.map(points, fn {y, _, _} -> y end) |> Enum.max()

IO.puts(
  Enum.count(
    for x <- 0..maxx,
        y <- 0..maxy,
        {x, y} != pos,
        Day6.loops?(
          pos,
          :up,
          MapSet.new(obstacles ++ [{x, y}]),
          MapSet.new(),
          {maxx + 1, maxy + 1}
        ),
        do: 1
  )
)
