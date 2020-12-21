function parse_line(s::String)::Tuple{Array{String}, Array{String}}
  bits = split(s, " (contains ")
  return (split(bits[1], " "), split(bits[2][1:end-1], ", "))
end

could_be = Dict{String, Set{String}}()

for line in eachline()
  ing, allergens = parse_line(line)
  for a in allergens
    if haskey(could_be, a)
      intersect!(could_be[a], ing)
    else
      push!(could_be, a => Set(ing))
    end
  end
end

allergens = Dict{String, String}()

function remove_from(could_be::Dict{String, Set{String}}, ing::String)
  for a in values(could_be)
    setdiff!(a, [ing])
  end
end

while length(could_be) > 0
  for a in keys(could_be)
    if length(could_be[a]) == 1
      allergens[a] = collect(could_be[a])[1]
      remove_from(could_be, allergens[a])
      delete!(could_be, a)
      continue
    end
  end
end

println(join(map(x -> allergens[x], sort(collect(keys(allergens)))), ","))