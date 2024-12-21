defmodule Day21 do
  def path_it([_], _) do
    []
  end

  def path_it([a, b | rest], hole) do
    shortest_path(a, b, hole) ++ path_it([b | rest], hole)
  end

  def full_path(path, hole) do
    path_it(path, hole)
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

  def chunk_seq(seq) do
    seq
    |> Enum.chunk_while(
      [],
      fn el, acc ->
        if el == {2, 0} do
          {:cont, Enum.reverse([el | acc]), []}
        else
          {:cont, [el | acc]}
        end
      end,
      fn _ -> {:cont, []} end
    )
    |> Enum.frequencies()
  end

  def freq_path(items, 0), do: items

  def freq_path(items, n) do
    freq_path(items, n - 1)
    |> Enum.map(fn {path, count} ->
      full_path([{2, 0} | path], {0, 0})
      |> chunk_seq()
      |> Enum.map(fn {k, v} -> {k, v * count} end)
      |> Map.new()
    end)
    |> Enum.reduce(fn a, b -> Map.merge(a, b, fn _k, v1, v2 -> v1 + v2 end) end)
  end
end

IO.inspect(
  IO.stream()
  |> Enum.map(fn l ->
    l
    |> String.trim()
    |> then(fn l ->
      String.to_integer(String.trim(l, "A")) *
        (("A" <> l)
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
         |> Day21.chunk_seq()
         |> Day21.freq_path(25)
         |> Enum.map(fn {k, v} -> length(k) * v end)
         |> Enum.sum())
    end)
  end)
  |> Enum.sum()
)
