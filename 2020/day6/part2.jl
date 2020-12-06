using StatsBase

tot = 0
cur = []
lines = 0

for line in eachline(stdin)
  if line == ""
    global tot += length(filter(x -> x.second == lines, countmap(cur)))
    global cur = []
    global lines = 0
  else
    push!(cur, line...)
    global lines += 1
  end
end
tot += length(filter(x -> x.second == lines, countmap(cur)))
println(tot)