IO.puts(
  IO.stream(:stdio, :line)
  |> Enum.map(fn l ->
    Regex.scan(~r"mul[(](\d{1,3}),(\d{1,3})[)]|(do)[(][)]|(don't)[(][)]", l,
      capture: :all_but_first
    )
  end)
  |> Enum.concat()
  |> Enum.reduce({true, 0}, fn l2, {enabled, total} ->
    case {l2, enabled} do
      {["", "", "", "don't"], _} -> {false, total}
      {["", "", "do"], _} -> {true, total}
      {_, false} -> {enabled, total}
      {[a, b], true} -> {enabled, total + String.to_integer(a) * String.to_integer(b)}
    end
  end)
  |> then(fn {_, total} -> total end)
)
