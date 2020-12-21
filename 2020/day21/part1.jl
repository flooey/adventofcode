function parse_line(s::String)::Tuple{Array{String}, Array{String}}
  bits = split(s, " (contains ")
  return (split(bits[1], " "), split(bits[2][1:end-1], ", "))
end

could_be = Dict{String, Set{String}}()
all_ingredients = Array{String, 1}()

for line in eachline()
  ing, allergens = parse_line(line)
  push!(all_ingredients, ing...)
  for a in allergens
    if haskey(could_be, a)
      intersect!(could_be[a], ing)
    else
      push!(could_be, a => Set(ing))
    end
  end
end

all_coulds = Iterators.flatten(values(could_be))

println(length(filter(x -> !(x in all_coulds), all_ingredients)))
