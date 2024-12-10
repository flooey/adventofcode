defmodule Day9 do
  def result({line, side, lcoord, lstep, rcoord, rstep, outpos, total}) do
    # IO.inspect({side, lcoord, lstep, rcoord, rstep, outpos, total})

    cond do
      lcoord > rcoord ->
        total

      lcoord == rcoord and lstep + rstep >= elem(line, lcoord) ->
        total

      true ->
        result(
          cond do
            lstep >= elem(line, lcoord) ->
              {line, if(side == :left, do: :right, else: :left), lcoord + 1, 0, rcoord, rstep,
               outpos, total}

            side == :left ->
              {line, side, lcoord, lstep + 1, rcoord, rstep, outpos + 1,
               total + outpos * div(lcoord, 2)}

            side == :right ->
              cond do
                rstep >= elem(line, rcoord) ->
                  {line, side, lcoord, lstep, rcoord - 2, 0, outpos, total}

                true ->
                  {line, side, lcoord, lstep + 1, rcoord, rstep + 1, outpos + 1,
                   total + outpos * div(rcoord, 2)}
              end
          end
        )
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
  |> List.to_tuple()

IO.puts(Day9.result({data, :left, 0, 0, tuple_size(data) - 1, 0, 0, 0}))
