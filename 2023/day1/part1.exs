{:ok, data} = File.read("input.txt")

defmodule Day1 do
  def firstnum(line) do
    case String.next_grapheme(line) do
      {head, _} when "0" <= head and head <= "9" -> String.to_integer(head)
      {_, tail} -> firstnum(tail)
    end
  end

  def calc(line) do
    firstnum(line) * 10 + firstnum(String.reverse(line))
  end
end

IO.puts(
  data
  |> String.split("\n")
  |> Enum.filter(fn x -> String.length(x) > 0 end)
  |> Enum.map(&Day1.calc/1)
  |> Enum.sum()
)
