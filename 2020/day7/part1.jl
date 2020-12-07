using DataStructures: DefaultDict

conns = DefaultDict{String,Array{String}}(() -> String[])
lineregex = r"^(\w+ \w+) bags contain (.*)$"
bagregex = r"^ ?\d (\w+ \w+) bags?[.]?$"

for line in eachline(stdin)
  m = match(lineregex, line)
  dest = m.captures[1]
  if m.captures[2] == "no other bags."
    continue
  end
  for bag in split(m.captures[2], ',')
    m = match(bagregex, bag)
    push!(conns[m.captures[1]], dest)
  end
end

function visit(val::String, sofar::Set{String})
  for x in conns[val]
    push!(sofar, x)
    visit(x, sofar)
  end
end

canreach = Set{String}()
visit("shiny gold", canreach)
println(length(canreach))