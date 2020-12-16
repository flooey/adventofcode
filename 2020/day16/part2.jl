struct Rule
  name::String
  first::Tuple{Int, Int}
  second::Tuple{Int, Int}
  couldbe::Set{Int}
end

rules = Rule[]
for line in eachline()
  if line == ""
    break
  end
  m = match(r"([^:]+): (\d+)-(\d+) or (\d+)-(\d+)", line)
  push!(rules, Rule(m.captures[1], (parse(Int, m.captures[2]), parse(Int, m.captures[3])), (parse(Int, m.captures[4]), parse(Int, m.captures[5])), Set()))
end

readline()
myticket = map(x -> parse(Int, x), split(readline(), ','))

readline()
readline()
alltix = Array{Int}[myticket]
for line in eachline()
  push!(alltix, map(x -> parse(Int, x), split(line, ',')))
end

alltix = filter(tick -> !any(map(f -> all(map(r -> (f < r.first[1] || r.first[2] < f) && (f < r.second[1] || r.second[2] < f), rules)), tick)), alltix)

for r in rules
  push!(r.couldbe, 1:length(myticket)...)
end

for t in alltix
  for (i, f) in enumerate(t)
    for r in rules
      if (f < r.first[1] || r.first[2] < f) && (f < r.second[1] || r.second[2] < f)
        delete!(r.couldbe, i)
      end
    end
  end
end

while !all(map(r -> length(r.couldbe) == 1, rules))
  for r in rules
    if length(r.couldbe) == 1
      removing = first(r.couldbe)
      for r2 in rules
        if r != r2
          delete!(r2.couldbe, removing)
        end
      end
    end
  end
end

println(prod(map(r -> myticket[first(r.couldbe)], filter(r -> startswith(r.name, "departure"), rules))))