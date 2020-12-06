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

ids = sort(map(s -> s.row * 8 + s.col, seats))

for i in firstindex(ids):lastindex(ids)-1
  if ids[i+1] != ids[i] + 1
    println(ids[i]+1)
  end
end