defmodule Day18 do
  def next({x, y}, dir) do
    case dir do
      :up -> {x, y - 1}
      :down -> {x, y + 1}
      :left -> {x - 1, y}
      :right -> {x + 1, y}
    end
  end

  def visit(visited, board, sofar, {x, y} = pos) do
    cond do
      x < 0 or 70 < x or y < 0 or 70 < y or MapSet.member?(board, pos) ->
        visited

      Map.has_key?(visited, pos) and MapSet.size(visited[pos]) <= MapSet.size(sofar) ->
        visited

      pos == {70, 70} ->
        Map.put(visited, pos, sofar)

      true ->
        newsofar = MapSet.put(sofar, pos)

        visited
        |> Map.put(pos, sofar)
        |> visit(board, newsofar, next(pos, :up))
        |> visit(board, newsofar, next(pos, :down))
        |> visit(board, newsofar, next(pos, :left))
        |> visit(board, newsofar, next(pos, :right))
    end
  end
end

IO.inspect(
  IO.stream()
  |> Stream.map(fn l ->
    l
    |> String.trim()
    |> String.split(",")
    |> Enum.map(&String.to_integer/1)
    |> List.to_tuple()
  end)
  |> Enum.reduce_while({MapSet.new(), nil}, fn point, {board, best_path} ->
    newboard = MapSet.put(board, point)

    if best_path != nil and not MapSet.member?(best_path, point) do
      {:cont, {newboard, best_path}}
    else
      visited = Day18.visit(%{}, newboard, MapSet.new(), {0, 0})

      if Map.has_key?(visited, {70, 70}) do
        {:cont, {newboard, visited[{70, 70}]}}
      else
        {:halt, point}
      end
    end
  end)
)
