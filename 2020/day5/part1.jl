struct Seat
  row::Int
  col::Int
end

seats = Seat[]

for line in eachline(stdin)
  line = replace(replace(line, ['B', 'R'] => '1'), ['F', 'L'] => 0)
  num = parse(Int, line, base=2)
  push!(seats, Seat(num ÷ 8, num % 8))
end

println(maximum(map(s -> s.row * 8 + s.col, seats)))