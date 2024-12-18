defmodule Day18 do
  def next({x, y}, dir) do
    case dir do
      :up -> {x, y - 1}
      :down -> {x, y + 1}
      :left -> {x - 1, y}
      :right -> {x + 1, y}
    end
  end

  def visit(visited, board, score, {x, y} = pos) do
    cond do
      x < 0 or 70 < x or y < 0 or 70 < y or MapSet.member?(board, pos) ->
        visited

      visited[pos] <= score ->
        visited

      pos == {70, 70} ->
        Map.put(visited, pos, score)

      true ->
        visited
        |> Map.put(pos, score)
        |> visit(board, score + 1, next(pos, :up))
        |> visit(board, score + 1, next(pos, :down))
        |> visit(board, score + 1, next(pos, :left))
        |> visit(board, score + 1, next(pos, :right))
    end
  end
end

IO.puts(
  Map.get(
    Day18.visit(
      %{},
      IO.stream()
      |> Stream.take(1024)
      |> Enum.map(fn l ->
        l
        |> String.trim()
        |> String.split(",")
        |> Enum.map(&String.to_integer/1)
        |> List.to_tuple()
      end)
      |> MapSet.new(),
      0,
      {0, 0}
    ),
    {70, 70}
  )
)
