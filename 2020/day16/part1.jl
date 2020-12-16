struct Rule
  name::String
  first::Tuple{Int, Int}
  second::Tuple{Int, Int}
end

rules = Rule[]
for line in eachline()
  if line == ""
    break
  end
  m = match(r"([^:]+): (\d+)-(\d+) or (\d+)-(\d+)", line)
  push!(rules, Rule(m.captures[1], (parse(Int, m.captures[2]), parse(Int, m.captures[3])), (parse(Int, m.captures[4]), parse(Int, m.captures[5]))))
end

readline()
myticket = map(x -> parse(Int, x), split(readline(), ','))

readline()
readline()
nearby = Array{Int}[]
for line in eachline()
  push!(nearby, map(x -> parse(Int, x), split(line, ',')))
end

errorsum = 0
for ticket in [[myticket]; nearby]
  for val in ticket
    valid = false
    for r in rules
      if r.first[1] <= val <= r.first[2] || r.second[1] <= val <= r.second[2]
        valid = true
        break
      end
    end
    if !valid
      global errorsum += val
    end
  end
end

println(errorsum)
