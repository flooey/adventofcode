defmodule Day13 do
  def find_best(problem, a, b, cache) do
    {ax, ay, bx, by, tx, ty} = problem

    cond do
      Map.has_key?(cache, {a, b}) ->
        {result, val} = cache[{a, b}]
        {result, val, cache}

      ax * a + bx * b == tx and ay * a + by * b == ty ->
        {:found, a * 3 + b, Map.put(cache, {a, b}, {:found, a * 3 + b})}

      ax * a + bx * b > tx or ay * a + by * b > ty or a > 100 or b > 100 ->
        {:not_found, nil, Map.put(cache, {a, b}, {:not_found, nil})}

      true ->
        {aresult, aval, cache} = find_best(problem, a + 1, b, cache)
        {bresult, bval, cache} = find_best(problem, a, b + 1, cache)

        case {{aresult, aval}, {bresult, bval}} do
          {{:found, s1}, {:found, s2}} ->
            {:found, min(s1, s2), Map.put(cache, {a, b}, {:found, min(s1, s2)})}

          {{:not_found, _}, {:found, s2}} ->
            {:found, s2, Map.put(cache, {a, b}, {:found, s2})}

          {{:found, s1}, {:not_found, _}} ->
            {:found, s1, Map.put(cache, {a, b}, {:found, s1})}

          {{:not_found, _}, {:not_found, _}} ->
            {:not_found, nil, Map.put(cache, {a, b}, {:not_found, nil})}
        end
    end
  end
end

IO.inspect(
  IO.stream()
  |> Enum.chunk_every(3, 4, :discard)
  |> Enum.map(fn l ->
    t = l |> List.to_tuple()

    [ax, ay] =
      Regex.run(~r"X[+]([0-9]+), Y[+]([0-9]+)", elem(t, 0), capture: :all_but_first)
      |> Enum.map(&String.to_integer/1)

    [bx, by] =
      Regex.run(~r"X[+]([0-9]+), Y[+]([0-9]+)", elem(t, 1), capture: :all_but_first)
      |> Enum.map(&String.to_integer/1)

    [tx, ty] =
      Regex.run(~r"X=([0-9]+), Y=([0-9]+)", elem(t, 2), capture: :all_but_first)
      |> Enum.map(&String.to_integer/1)

    case Day13.find_best({ax, ay, bx, by, tx, ty}, 0, 0, %{}) do
      {:found, result, _} -> result
      {:not_found, _, _} -> 0
    end
  end)
  |> Enum.sum()
)
