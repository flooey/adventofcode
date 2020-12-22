p1 = Int[]
p2 = Int[]

readline()
for line in eachline()
  if line == ""
    break
  end
  push!(p1, parse(Int, line))
end

readline()
for line in eachline()
  if line == ""
    break
  end
  push!(p2, parse(Int, line))
end

while length(p1) > 0 && length(p2) > 0
  if p1[1] > p2[1]
    push!(p1, p1[1])
    push!(p1, p2[1])
  else
    push!(p2, p2[1])
    push!(p2, p1[1])
  end
  popfirst!(p1)
  popfirst!(p2)
end

winner = p1
if length(winner) == 0
  winner = p2
end

println(sum(map(x -> (length(winner) - x[1] + 1) * x[2], enumerate(winner))))