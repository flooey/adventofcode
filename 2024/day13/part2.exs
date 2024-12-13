defmodule Day13 do
  def find_best(problem) do
    {ax, ay, bx, by, tx, ty} = problem

    bnum = ty * ax - ay * tx
    bdenom = ax * by - ay * bx

    if rem(bnum, bdenom) != 0 do
      {:not_found, nil}
    else
      b = div(bnum, bdenom)
      anum = tx - bx * b
      adenom = ax

      if rem(anum, adenom) != 0 do
        {:not_found, nil}
      else
        a = div(anum, adenom)
        {:found, a * 3 + b}
      end
    end
  end
end

IO.inspect(
  IO.stream()
  |> Enum.chunk_every(3, 4, :discard)
  |> Enum.map(fn l ->
    t = l |> List.to_tuple()

    [ax, ay] =
      Regex.run(~r"X[+]([0-9]+), Y[+]([0-9]+)", elem(t, 0), capture: :all_but_first)
      |> Enum.map(&String.to_integer/1)

    [bx, by] =
      Regex.run(~r"X[+]([0-9]+), Y[+]([0-9]+)", elem(t, 1), capture: :all_but_first)
      |> Enum.map(&String.to_integer/1)

    [tx, ty] =
      Regex.run(~r"X=([0-9]+), Y=([0-9]+)", elem(t, 2), capture: :all_but_first)
      |> Enum.map(&String.to_integer/1)

    case Day13.find_best({ax, ay, bx, by, 10_000_000_000_000 + tx, 10_000_000_000_000 + ty}) do
      {:found, result} -> result
      {:not_found, _} -> 0
    end
  end)
  |> Enum.sum()
)
