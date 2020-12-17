active = Set{CartesianIndex{3}}()

ONE = one(CartesianIndex{3})

for (i, line) in enumerate(eachline())
  for (j, letter) in enumerate(line)
    if letter == '#'
      push!(active, CartesianIndex(i, j, 0))
    end
  end
end

function willbeactive(active::Set{CartesianIndex{3}}, loc::CartesianIndex{3})::Bool
  neighbors = 0
  for i in loc-ONE:loc+ONE
    if i != loc
      if in(i, active)
        neighbors += 1
        if neighbors >= 4
          break
        end
      end
    end
  end
  if in(loc, active)
    return neighbors == 2 || neighbors == 3
  else
    return neighbors == 3
  end
end

function doit(active::Set{CartesianIndex{3}})
  newactive = Set{CartesianIndex{3}}()
  for i in minimum(active)-ONE:maximum(active)+ONE
    if willbeactive(active, i)
      push!(newactive, i)
    end
  end
  newactive
end

for i in 1:6
  global active = doit(active)
end

println(length(active))