using DataStructures: DefaultDict

struct Tile
  id::Int
  data::Array{Bool,2}
end

alltiles = Tile[]

for line in eachline()
  id = parse(Int, line[6:9])
  data = Bool[]
  for i in 1:10
    push!(data, map(x -> x == '#', collect(readline()))...)
  end
  readline()  # Blank line
  push!(alltiles, Tile(id, reshape(data, 10, 10)))
end

function btoi(bits::Array{Bool})::Int
  sum(bits .* map(x -> 2^x, collect(0:9)))
end

function bits_to_int(bits::Array{Bool})::Int
  min(btoi(bits), btoi(reverse(bits)))
end

counts = DefaultDict{Int, Int}(0)
for tile in alltiles
  counts[bits_to_int(tile.data[1:10, 1])] += 1
  counts[bits_to_int(tile.data[1:10, 10])] += 1
  counts[bits_to_int(tile.data[1, 1:10])] += 1
  counts[bits_to_int(tile.data[10, 1:10])] += 1
end

mult = 1
for tile in alltiles
  numone = 0
  if counts[bits_to_int(tile.data[1:10, 1])] == 1
    numone += 1
  end
  if counts[bits_to_int(tile.data[1:10, 10])] == 1
    numone += 1
  end
  if counts[bits_to_int(tile.data[1, 1:10])] == 1
    numone += 1
  end
  if counts[bits_to_int(tile.data[10, 1:10])] == 1
    numone += 1
  end
  if numone == 2
    global mult *= tile.id
  end
end

println(mult)