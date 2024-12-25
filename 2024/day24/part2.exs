import Bitwise

defmodule Day24 do
  def process_gates([], vals, remaining_gates), do: {remaining_gates, vals}

  def process_gates([{id1, id2, type, out} = gate | gates], vals, remaining_gates) do
    if Map.has_key?(vals, id1) and Map.has_key?(vals, id2) do
      process_gates(
        gates,
        Map.put(
          vals,
          out,
          case type do
            "AND" -> vals[id1] &&& vals[id2]
            "OR" -> vals[id1] ||| vals[id2]
            "XOR" -> bxor(vals[id1], vals[id2])
          end
        ),
        remaining_gates
      )
    else
      process_gates(gates, vals, [gate | remaining_gates])
    end
  end

  def process([], vals), do: vals

  def process(gates, vals) do
    {newgates, newvals} = process_gates(gates, vals, [])
    process(newgates, newvals)
  end

  def add_nums(gates, x, y) do
    process(
      gates,
      for i <- 0..44 do
        [
          {"x" <> if(i < 10, do: "0", else: "") <> Integer.to_string(i), rem(x >>> i, 2)},
          {"y" <> if(i < 10, do: "0", else: "") <> Integer.to_string(i), rem(y >>> i, 2)}
        ]
      end
      |> List.flatten()
      |> Map.new()
    )
    |> znum()
  end

  def znum(vals) do
    vals
    |> Enum.map(fn {id, val} ->
      if String.starts_with?(id, "z") do
        val <<< (String.trim_leading(id, "z") |> String.to_integer())
      else
        0
      end
    end)
    |> Enum.sum()
  end

  def swap([], _, _), do: []

  def swap([{id1, id2, type, out} = gate | gates], swap1, swap2) do
    case out do
      ^swap1 -> [{id1, id2, type, swap2} | swap(gates, swap1, swap2)]
      ^swap2 -> [{id1, id2, type, swap1} | swap(gates, swap1, swap2)]
      _ -> [gate | swap(gates, swap1, swap2)]
    end
  end
end

_vals =
  IO.stream()
  |> Stream.take_while(&(&1 != "\n"))
  |> Enum.map(&Regex.run(~r"([a-z0-9]+): ([01])", &1, capture: :all_but_first))
  |> Enum.map(fn [id, val] -> {id, String.to_integer(val)} end)
  |> Map.new()

gates =
  IO.stream()
  |> Enum.map(
    &Regex.run(~r"([a-z0-9]+) (AND|OR|XOR) ([a-z0-9]+) -> ([a-z0-9]+)", &1,
      capture: :all_but_first
    )
  )
  |> Enum.map(fn [id1, type, id2, out] -> {id1, id2, type, out} end)

gates =
  Day24.swap(gates, "gws", "nnt")
  |> Day24.swap("z19", "cph")
  |> Day24.swap("z33", "hgj")
  |> Day24.swap("z13", "npf")

for i <- 0..44 do
  result = Day24.add_nums(gates, 1 <<< i, 1 <<< i)

  if result != 1 <<< (i + 1) do
    IO.puts(i)
  end
end
