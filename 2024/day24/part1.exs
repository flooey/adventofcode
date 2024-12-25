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
end

vals =
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

IO.inspect(
  Day24.process(gates, vals)
  |> Enum.map(fn {id, val} ->
    if String.starts_with?(id, "z") do
      val <<< (String.trim_leading(id, "z") |> String.to_integer())
    else
      0
    end
  end)
  |> Enum.sum()
)
