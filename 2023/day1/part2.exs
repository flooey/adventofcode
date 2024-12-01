defmodule Day1 do
  def lastnum(line) do
    case String.reverse(line) do
      "eno" <> _ -> 1
      "1" <> _ -> 1
      "owt" <> _ -> 2
      "2" <> _ -> 2
      "eerht" <> _ -> 3
      "3" <> _ -> 3
      "ruof" <> _ -> 4
      "4" <> _ -> 4
      "evif" <> _ -> 5
      "5" <> _ -> 5
      "xis" <> _ -> 6
      "6" <> _ -> 6
      "neves" <> _ -> 7
      "7" <> _ -> 7
      "thgie" <> _ -> 8
      "8" <> _ -> 8
      "enin" <> _ -> 9
      "9" <> _ -> 9
      <<_::binary-1>> <> rest -> lastnum(String.reverse(rest))
    end
  end

  def firstnum(line) do
    case line do
      "one" <> _ ->
        1

      "two" <> _ ->
        2

      "three" <> _ ->
        3

      "four" <> _ ->
        4

      "five" <> _ ->
        5

      "six" <> _ ->
        6

      "seven" <> _ ->
        7

      "eight" <> _ ->
        8

      "nine" <> _ ->
        9

      line ->
        case String.next_grapheme(line) do
          {head, _} when "0" <= head and head <= "9" -> String.to_integer(head)
          {_, tail} -> firstnum(tail)
        end
    end
  end

  def calc(line) do
    # IO.puts("#{line} -> #{firstnum(line)} + #{lastnum(line)}")
    firstnum(line) * 10 + lastnum(line)
  end
end

IO.puts(
  IO.stream(:stdio, :line)
  |> Enum.filter(fn x -> String.length(x) > 0 end)
  |> Enum.map(&Day1.calc/1)
  |> Enum.sum()
)
