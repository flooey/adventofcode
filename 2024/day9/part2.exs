defmodule Day9 do
  def find_gap(items, size, i, max) do
    if i >= max do
      nil
    else
      case elem(items, i) do
        {:gap, len, _} when size <= len -> i
        _ -> find_gap(items, size, i + 1, max)
      end
    end
  end

  def defrag(items, i) do
    cond do
      i == 0 ->
        items

      true ->
        case elem(items, i) do
          {:gap, _, _} ->
            defrag(items, i - 1)

          {:file, len, id} ->
            gap = find_gap(items, len, 0, i)

            if gap == nil do
              defrag(items, i - 1)
            else
              {:gap, gap_len, _} = elem(items, gap)

              newitems =
                put_elem(items, i, {:gap, len, 0})
                |> Tuple.insert_at(gap, {:file, len, id})
                |> put_elem(gap + 1, {:gap, gap_len - len, 0})

              defrag(newitems, i)
            end
        end
    end
  end

  def checksum({[], _, total}), do: total

  def checksum({[{:gap, len, _} | tail], outpos, total}),
    do: checksum({tail, outpos + len, total})

  def checksum({[{:file, len, id} | tail], outpos, total}),
    do: checksum({tail, outpos + len, total + div((outpos * 2 + len - 1) * len, 2) * id})
end

data =
  IO.stream()
  |> Enum.into([])
  |> List.first()
  |> String.trim()
  |> String.graphemes()
  |> Enum.map(&String.to_integer/1)
  |> Enum.with_index()
  |> Enum.map(fn {x, i} -> if rem(i, 2) == 1, do: {:gap, x, 0}, else: {:file, x, div(i, 2)} end)
  |> List.to_tuple()

IO.inspect(Day9.checksum({Tuple.to_list(Day9.defrag(data, tuple_size(data) - 1)), 0, 0}))
