defmodule Day16 do
  def next({x, y}, dir) do
    case dir do
      :up -> {x, y - 1}
      :down -> {x, y + 1}
      :left -> {x - 1, y}
      :right -> {x + 1, y}
    end
  end

  def visit(visited, board, score, {x, y} = pos, dir) do
    cond do
      board[pos] == :wall ->
        visited

      board[pos] == :end ->
        if visited[:end] > score do
          Map.put(visited, :end, score)
        else
          visited
        end

      visited[{x, y, dir}] <= score ->
        visited

      true ->
        visited
        |> Map.put({x, y, dir}, score)
        |> visit(board, if(dir == :up, do: score + 1, else: score + 1001), next(pos, :up), :up)
        |> visit(
          board,
          if(dir == :down, do: score + 1, else: score + 1001),
          next(pos, :down),
          :down
        )
        |> visit(
          board,
          if(dir == :left, do: score + 1, else: score + 1001),
          next(pos, :left),
          :left
        )
        |> visit(
          board,
          if(dir == :right, do: score + 1, else: score + 1001),
          next(pos, :right),
          :right
        )
    end
  end
end

items =
  IO.stream()
  |> Stream.take_while(&(&1 != "\n"))
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

board =
  (items[:wall] ++ items[:end]) |> Enum.map(fn {x, y, type} -> {{x, y}, type} end) |> Map.new()

IO.puts(Day16.visit(Map.new(), board, 0, start, :right) |> Map.get(:end))
