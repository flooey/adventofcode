towels =
  IO.read(:line)
  |> String.split(", ")
  |> Enum.map(&String.trim/1)
  |> Enum.join("|")
  |> then(fn x -> Regex.compile!("^(#{x})+$") end)

IO.read(:line)

IO.puts(
  IO.stream()
  |> Enum.map(&String.trim/1)
  |> Enum.map(fn l -> Regex.match?(towels, l) end)
  |> Enum.count(fn x -> x end)
)
