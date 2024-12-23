defmodule Day23 do
  def bron_kerbosh_inner(_network, _r, _p, _x, []), do: []

  def bron_kerbosh_inner(network, r, p, x, [v | rest]) do
    bron_kerbosh(
      network,
      MapSet.put(r, v),
      MapSet.intersection(p, network[v]),
      MapSet.intersection(x, network[v])
    ) ++ bron_kerbosh_inner(network, r, MapSet.delete(p, v), MapSet.put(x, v), rest)
  end

  def bron_kerbosh(network, r, p, x) do
    if p == MapSet.new() and x == MapSet.new() do
      [r]
    else
      bron_kerbosh_inner(network, r, p, x, MapSet.to_list(p))
    end
  end
end

pairs = IO.stream() |> Enum.map(&String.trim/1) |> Enum.map(&String.split(&1, "-"))

network =
  Map.new(
    Map.merge(
      pairs |> Enum.group_by(fn [a, _b] -> a end, fn [_a, b] -> b end),
      pairs |> Enum.group_by(fn [_a, b] -> b end, fn [a, _b] -> a end),
      fn _k, v1, v2 -> v1 ++ v2 end
    )
    |> Enum.map(fn {k, v} -> {k, MapSet.new(v)} end)
  )

IO.puts(
  Day23.bron_kerbosh(network, MapSet.new(), MapSet.new(Map.keys(network)), MapSet.new())
  |> Enum.max_by(&MapSet.size/1)
  |> Enum.sort()
  |> Enum.join(",")
)
