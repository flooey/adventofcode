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

println(length(black))