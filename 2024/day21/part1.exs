defmodule Day21 do
  def path_it([_], _) do
    []
  end

  def path_it([a, b | rest], hole) do
    shortest_path(a, b, hole) ++ path_it([b | rest], hole)
  end

  def full_path(path, hole) do
    [{2, 0} | path_it(path, hole)]
  end

  def shortest_path_right_first({sx, sy}, {tx, ty}) do
    if(sx <= tx, do: List.duplicate({2, 1}, abs(tx - sx)), else: []) ++
      List.duplicate(if(sy <= ty, do: {1, 1}, else: {1, 0}), abs(ty - sy)) ++
      if(sx > tx, do: List.duplicate({0, 1}, abs(tx - sx)), else: []) ++ [{2, 0}]
  end

  def shortest_path_left_first({sx, sy}, {tx, ty}) do
    if(sx > tx, do: List.duplicate({0, 1}, abs(tx - sx)), else: []) ++
      List.duplicate(if(sy <= ty, do: {1, 1}, else: {1, 0}), abs(ty - sy)) ++
      if(sx <= tx, do: List.duplicate({2, 1}, abs(tx - sx)), else: []) ++ [{2, 0}]
  end

  def shortest_path({sx, sy} = s, {tx, ty} = t, {hx, hy}) do
    if (sx == hx or tx == hx) and (sy == hy or ty == hy) do
      shortest_path_right_first(s, t)
    else
      shortest_path_left_first(s, t)
    end
  end

  def debug_val([]), do: ""

  def debug_val([item | rest]) do
    case item do
      {1, 0} -> "^"
      {2, 0} -> "A"
      {0, 1} -> "<"
      {1, 1} -> "v"
      {2, 1} -> ">"
    end <> debug_val(rest)
  end

  def debug(path) do
    IO.puts(debug_val(path))
    path
  end
end

IO.inspect(
  IO.stream()
  |> Enum.map(fn l ->
    l
    |> String.trim()
    |> then(fn l ->
      String.to_integer(String.trim(l, "A")) *
        ((("A" <> l)
          |> String.graphemes()
          |> Enum.map(fn x ->
            case x do
              "7" -> {0, 0}
              "8" -> {1, 0}
              "9" -> {2, 0}
              "4" -> {0, 1}
              "5" -> {1, 1}
              "6" -> {2, 1}
              "1" -> {0, 2}
              "2" -> {1, 2}
              "3" -> {2, 2}
              "0" -> {1, 3}
              "A" -> {2, 3}
            end
          end)
          |> Day21.full_path({0, 3})
          # |> Day21.debug()
          |> Day21.full_path({0, 0})
          # |> Day21.debug()
          |> Day21.full_path({0, 0})
          # |> Day21.debug()
          |> length()) - 1)
    end)
  end)
  |> Enum.sum()
)
