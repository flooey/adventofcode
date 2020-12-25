function process(line::String)::CartesianIndex{2}
  cur = CartesianIndex(0, 0)
  while length(line) > 0
    if line[1] == 'e'
      cur += CartesianIndex(1, 0)
      line = line[2:end]
    elseif line[1] == 'w'
      cur += CartesianIndex(-1, 0)
      line = line[2:end]
    elseif line[1:2] == "nw"
      if cur[2] % 2 == 0
        cur += CartesianIndex(-1, 1)
      else
        cur += CartesianIndex(0, 1)
      end
      line = line[3:end]
    elseif line[1:2] == "sw"
      if cur[2] % 2 == 0
        cur += CartesianIndex(-1, -1)
      else
        cur += CartesianIndex(0, -1)
      end
      line = line[3:end]
    elseif line[1:2] == "ne"
      if cur[2] % 2 == 0
        cur += CartesianIndex(0, 1)
      else
        cur += CartesianIndex(1, 1)
      end
      line = line[3:end]
    elseif line[1:2] == "se"
      if cur[2] % 2 == 0
        cur += CartesianIndex(0, -1)
      else
        cur += CartesianIndex(1, -1)
      end
      line = line[3:end]
    end
  end
  return cur
end

black = Set{CartesianIndex{2}}()

for line in eachline()
  loc = process(line)
  if loc in black
    delete!(black, loc)
  else
    push!(black, loc)
  end
end

function willbeactive(active::Set{CartesianIndex{2}}, loc::CartesianIndex{2})::Bool
  neighbors = 0
  if (loc + CartesianIndex(-1, 0)) in active
    neighbors += 1
  end
  if (loc + CartesianIndex(1, 0)) in active
    neighbors += 1
  end
  others = (loc[2] % 2 == 0) ? [CartesianIndex(-1, 1), CartesianIndex(-1, -1), CartesianIndex(0, 1), CartesianIndex(0, -1)] : [CartesianIndex(1, 1), CartesianIndex(1, -1), CartesianIndex(0, 1), CartesianIndex(0, -1)]
  for x in others
    if loc + x in active
      neighbors += 1
    end
  end
  if in(loc, active)
    return neighbors == 1 || neighbors == 2
  else
    return neighbors == 2
  end
end

ONE = one(CartesianIndex{2})

function doit(active::Set{CartesianIndex{2}})
  newactive = Set{CartesianIndex{2}}()
  for i in minimum(active)-ONE:maximum(active)+ONE
    if willbeactive(active, i)
      push!(newactive, i)
    end
  end
  newactive
end

for i in 1:100
  global black = doit(black)
end

println(length(black))