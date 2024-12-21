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

  def score(scores, wall) do
    neighbors =
      [
        Map.get(scores, next(wall, :up)),
        Map.get(scores, next(wall, :down)),
        Map.get(scores, next(wall, :left)),
        Map.get(scores, next(wall, :right))
      ]
      |> Enum.filter(&(&1 != nil))

    if length(neighbors) < 2 do
      0
    else
      Enum.max(neighbors) - Enum.min(neighbors) - 2
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

IO.puts(
  board
  |> Enum.map(fn wall -> Day20.score(scores, wall) end)
  |> Enum.count(&(&1 >= 100))
)
