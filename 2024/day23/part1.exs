defmodule Day23 do
  def find_triplets(_network, _target, [_]), do: MapSet.new()

  def find_triplets(network, target, [a, b | rest]) do
    if MapSet.member?(network[a], b) do
      MapSet.new([Enum.sort([target, a, b]) |> List.to_tuple()])
    else
      MapSet.new()
    end
    |> MapSet.union(find_triplets(network, target, [a | rest]))
    |> MapSet.union(find_triplets(network, target, [b | rest]))
  end

  def find_triplets(network) do
    Map.keys(network)
    |> Enum.filter(&String.starts_with?(&1, "t"))
    |> Enum.map(fn x -> find_triplets(network, x, MapSet.to_list(network[x])) end)
    |> Enum.reduce(fn a, b -> MapSet.union(a, b) end)
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

IO.puts(MapSet.size(Day23.find_triplets(network)))
