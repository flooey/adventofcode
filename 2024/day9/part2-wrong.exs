defmodule Day9 do
  def gap_size(line, coord) do
    cond do
      coord >= tuple_size(line) -> 0
      elem(line, coord) > 0 -> 0
      true -> -1 * elem(line, coord) + gap_size(line, coord + 1)
    end
  end

  def fits_gap(line, gap_size, lcoord, rcoord) do
    cond do
      lcoord >= rcoord -> nil
      0 < elem(line, rcoord) && elem(line, rcoord) <= gap_size -> rcoord
      true -> fits_gap(line, gap_size, lcoord, rcoord - 1)
    end
  end

  def result({line, lcoord, lstep, outpos, total}) do
    IO.inspect({lcoord, lstep, outpos, total})

    cond do
      lcoord >= tuple_size(line) ->
        total

      elem(line, lcoord) > 0 and lstep >= elem(line, lcoord) ->
        result({line, lcoord + 1, 0, outpos, total})

      elem(line, lcoord) > 0 ->
        result({line, lcoord, lstep + 1, outpos + 1, total + outpos * div(lcoord, 2)})

      lstep >= elem(line, lcoord) * -1 ->
        result({line, lcoord + 1, lstep + elem(line, lcoord), outpos, total})

      true ->
        g = gap_size(line, lcoord) - lstep
        f = fits_gap(line, g, lcoord, tuple_size(line) - 1)
        IO.inspect({"gap", g, f})

        cond do
          f == nil ->
            result({line, lcoord + 1, 0, outpos, total})

          true ->
            fill_size = elem(line, f)
            newline = put_elem(line, f, fill_size * -1)

            result(
              {newline, lcoord, lstep + fill_size, outpos + fill_size,
               total + div((outpos * 2 + fill_size - 1) * fill_size, 2) * div(f, 2)}
            )
        end
    end
  end
end

data =
  IO.stream()
  |> Enum.into([])
  |> List.first()
  |> String.trim()
  |> String.graphemes()
  |> Enum.map(&String.to_integer/1)
  |> Enum.with_index()
  |> Enum.map(fn {x, i} -> if rem(i, 2) == 1, do: -1 * x, else: x end)
  |> List.to_tuple()

IO.puts(Day9.result({data, 0, 0, 0, 0}))
