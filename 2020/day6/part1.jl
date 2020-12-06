tot = 0
cur = Set()

for line in eachline(stdin)
  if line == "" 
    global tot += length(cur)
    global cur = Set()
  else
    push!(cur, line...)
  end
end
tot += length(cur)
println(tot)