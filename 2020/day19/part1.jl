
rules = Dict{Int, Union{Char, Array{Array{Int}}}}()

for line in eachline()
  if line == ""
    break
  end
  bits = split(line, ": ")
  rulenum = parse(Int, bits[1])
  if bits[2][1] == '"'
    rules[rulenum] = bits[2][2]
  else
    newrules = Array{Int}[]
    for r in split(bits[2], " | ")
      push!(newrules, map(x -> parse(Int, x), split(r)))
    end
    rules[rulenum] = newrules
  end
end

function matches(rules::Dict{Int, Union{Char, Array{Array{Int}}}}, rulenum::Int, s::String)::Tuple{Bool, String}
  rule = rules[rulenum]
  if isa(rule, Char)
    if s[1] == rule
      return (true, s[2:end])
    end
  else
    for option in rule
      a = (true, s)
      for x in option
        if !a[1]
          break
        end
        a = matches(rules, x, a[2])
      end
      if a[1]
        return a
      end
    end
  end
  return (false, "")
end

numgood = 0
for line in eachline()
  x = matches(rules, 0, line)
  if x[1] && x[2] == ""
    global numgood += 1
  end
end
println(numgood)