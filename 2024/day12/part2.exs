defmodule Day12 do
  def visit(data, x, y, dir, target, {visited, size, boundaries}) do
    cond do
      y < 0 or tuple_size(data) <= y or x < 0 or tuple_size(data |> elem(y)) <= x or
          data |> elem(y) |> elem(x) != target ->
        {visited, size, MapSet.put(boundaries, {x, y, dir})}

      MapSet.member?(visited, {x, y}) ->
        {visited, size, boundaries}

      true ->
        visited = MapSet.put(visited, {x, y})
        size = size + 1

        {visited, size, boundaries} =
          visit(data, x + 1, y, :right, target, {visited, size, boundaries})

        {visited, size, boundaries} =
          visit(data, x - 1, y, :left, target, {visited, size, boundaries})

        {visited, size, boundaries} =
          visit(data, x, y + 1, :up, target, {visited, size, boundaries})

        visit(data, x, y - 1, :down, target, {visited, size, boundaries})
    end
  end

  def remove_all(boundaries, x, y, dir) do
    if not MapSet.member?(boundaries, {x, y, dir}) do
      boundaries
    else
      boundaries
      |> MapSet.delete({x, y, dir})
      |> remove_all(
        if(dir == :up or dir == :down, do: x + 1, else: x),
        if(dir == :left or dir == :right, do: y + 1, else: y),
        dir
      )
      |> remove_all(
        if(dir == :up or dir == :down, do: x - 1, else: x),
        if(dir == :left or dir == :right, do: y - 1, else: y),
        dir
      )
    end
  end

  def sides(boundaries) do
    if MapSet.size(boundaries) == 0 do
      0
    else
      {x, y, dir} = Enum.at(boundaries, 0)
      1 + (boundaries |> remove_all(x, y, dir) |> sides())
    end
  end

  def visit_all(data, x, y, visited, total) do
    if y >= tuple_size(data) do
      total
    else
      nexty = if x >= tuple_size(data |> elem(y)) - 1, do: y + 1, else: y
      nextx = if x >= tuple_size(data |> elem(y)) - 1, do: 0, else: x + 1

      if MapSet.member?(visited, {x, y}) do
        visit_all(data, nextx, nexty, visited, total)
      else
        {visited, size, boundaries} =
          visit(data, x, y, :up, data |> elem(y) |> elem(x), {visited, 0, MapSet.new()})

        visit_all(data, nextx, nexty, visited, total + size * sides(boundaries))
      end
    end
  end
end

data =
  IO.stream()
  |> Enum.map(fn l ->
    String.trim(l) |> String.graphemes() |> List.to_tuple()
  end)
  |> List.to_tuple()

IO.puts(Day12.visit_all(data, 0, 0, MapSet.new(), 0))
