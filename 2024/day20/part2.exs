defmodule Day20 do
  def next({x, y}, dir) do
    case dir do
      :up -> {x, y - 1}
      :down -> {x, y + 1}
      :left -> {x - 1, y}
      :right -> {x + 1, y}
    end
  end

  def visit(visited, board, score, stop, pos) do
    cond do
      MapSet.member?(board, pos) ->
        visited

      visited[pos] <= score ->
        visited

      pos == stop ->
        Map.put(visited, pos, score)

      true ->
        visited
        |> Map.put(pos, score)
        |> visit(board, score + 1, stop, next(pos, :up))
        |> visit(board, score + 1, stop, next(pos, :down))
        |> visit(board, score + 1, stop, next(pos, :left))
        |> visit(board, score + 1, stop, next(pos, :right))
    end
  end

  def score(scores, {startx, starty} = skipstart, {endx, endy} = skipend) do
    dist = abs(startx - endx) + abs(starty - endy)

    if dist > 20 or not Map.has_key?(scores, skipstart) or not Map.has_key?(scores, skipend) do
      0
    else
      scores[skipend] - scores[skipstart] - dist
    end
  end
end

items =
  IO.stream()
  |> Enum.with_index()
  |> Enum.flat_map(fn {row, y} ->
    String.trim(row)
    |> String.graphemes()
    |> Enum.with_index()
    |> Enum.map(fn {c, x} ->
      case c do
        "#" -> {x, y, :wall}
        "E" -> {x, y, :end}
        "S" -> {x, y, :start}
        "." -> nil
      end
    end)
    |> Enum.filter(&(&1 != nil))
  end)
  |> Enum.group_by(fn {_, _, type} -> type end)

start = items[:start] |> List.first() |> then(fn {x, y, :start} -> {x, y} end)
stop = items[:end] |> List.first() |> then(fn {x, y, :end} -> {x, y} end)
board = items[:wall] |> Enum.map(fn {x, y, :wall} -> {x, y} end) |> MapSet.new()

scores = Day20.visit(%{}, board, 0, stop, start)

minx = scores |> Map.keys() |> Enum.map(fn {x, _} -> x end) |> Enum.min()
maxx = scores |> Map.keys() |> Enum.map(fn {x, _} -> x end) |> Enum.max()
miny = scores |> Map.keys() |> Enum.map(fn {_, y} -> y end) |> Enum.min()
maxy = scores |> Map.keys() |> Enum.map(fn {_, y} -> y end) |> Enum.max()

IO.puts(
  for startx <- minx..maxx, starty <- miny..maxy, endx <- minx..maxx, endy <- miny..maxy do
    Day20.score(scores, {startx, starty}, {endx, endy})
  end
  |> Enum.count(&(&1 >= 100))
)
