defmodule Day19 do
  def solve(cache, towels, target) do
    cond do
      Map.has_key?(cache, target) ->
        cache

      true ->
        {newcache, count} =
          Enum.reduce(towels, {cache, 0}, fn towel, {cache, count} ->
            cond do
              String.starts_with?(target, towel) ->
                newtarget = target |> String.slice(String.length(towel)..-1//1)
                newcache = Day19.solve(cache, towels, newtarget)
                {newcache, count + newcache[newtarget]}

              true ->
                {cache, count}
            end
          end)

        Map.put(newcache, target, count)
    end
  end
end

towels =
  IO.read(:line)
  |> String.split(", ")
  |> Enum.map(&String.trim/1)

IO.read(:line)

IO.puts(
  IO.stream()
  |> Enum.map(&String.trim/1)
  |> Enum.map(fn l -> Map.get(Day19.solve(%{"" => 1}, towels, l), l) end)
  |> Enum.sum()
)
