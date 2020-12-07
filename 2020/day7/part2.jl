using DataStructures: DefaultDict

conns = DefaultDict{String,Array{Tuple{String, Int}}}(() -> Tuple{String, Int}[])
lineregex = r"^(\w+ \w+) bags contain (.*)$"
bagregex = r"^ ?(\d) (\w+ \w+) bags?[.]?$"

for line in eachline(stdin)
  m = match(lineregex, line)
  dest = m.captures[1]
  if m.captures[2] == "no other bags."
    continue
  end
  for bag in split(m.captures[2], ',')
    m = match(bagregex, bag)
    push!(conns[dest], (m.captures[2], parse(Int, m.captures[1])))
  end
end

function visit(val::String)
  tot = 1
  for x in conns[val]
    tot += x[2] * visit(x[1])
  end
  return tot
end

x = visit("shiny gold")
println(x-1)