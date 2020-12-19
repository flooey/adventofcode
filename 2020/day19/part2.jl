
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

rules[8] = Array{Int}[]
push!(rules[8], [42, 8])
push!(rules[8], [42])

rules[11] = Array{Int}[]
push!(rules[11], [42, 11, 31])
push!(rules[11], [42, 31])

function matches(rules::Dict{Int, Union{Char, Array{Array{Int}}}}, rulenum::Int, s::String)::Tuple{Bool, String}
  if length(s) == 0
    return (false, "")
  end
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
  for i in firstindex(line):lastindex(line)-1
    eight = matches(rules, 8, line[begin:i])
    eleven = matches(rules, 11, line[i+1:end])
    if eight[1] && eight[2] == "" && eleven[1] && eleven[2] == ""
      global numgood += 1
      break
    end
  end
end
println(numgood)