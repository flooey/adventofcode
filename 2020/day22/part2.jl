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

function play(p1::Array{Int}, p2::Array{Int})::Int
  seen = Tuple{Array{Int}, Array{Int}}[]
  while length(p1) > 0 && length(p2) > 0
    if (p1, p2) in seen
      return 1
    end
    push!(seen, (copy(p1), copy(p2)))
    winner = 0
    if length(p1) > p1[1] && length(p2) > p2[1]
      winner = play(copy(p1[2:p1[1]+1]), copy(p2[2:p2[1]+1]))
    elseif p1[1] > p2[1]
      winner = 1
    else
      winner = 2
    end
    if winner == 1
      push!(p1, p1[1])
      push!(p1, p2[1])
    else
      push!(p2, p2[1])
      push!(p2, p1[1])
    end
    popfirst!(p1)
    popfirst!(p2)
  end
  if length(p1) > 0
    return 1
  end
  return 2
end

w = play(p1, p2)
println(w)
winner = w == 1 ? p1 : p2

println(sum(map(x -> (length(winner) - x[1] + 1) * x[2], enumerate(winner))))