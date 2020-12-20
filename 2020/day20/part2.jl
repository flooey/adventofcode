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

SIZE = floor(Int, sqrt(length(alltiles)))

function btoi(bits::Array{Bool})::Int
  sum(bits .* map(x -> 2^x, collect(0:9)))
end

function bits_to_int(bits::Array{Bool})::Int
  min(btoi(bits), btoi(reverse(bits)))
end

side_to_tiles = DefaultDict{Int, Array{Tile}}(() -> Tile[])
for tile in alltiles
  push!(side_to_tiles[bits_to_int(tile.data[1:10, 1])], tile)
  push!(side_to_tiles[bits_to_int(tile.data[1:10, 10])], tile)
  push!(side_to_tiles[bits_to_int(tile.data[1, 1:10])], tile)
  push!(side_to_tiles[bits_to_int(tile.data[10, 1:10])], tile)
end

function find_start(side_to_tiles::AbstractDict{Int, Array{Tile}})::Tuple{Tile, Array{Int}}
  for tile in alltiles
    numone = 0
    ones = []
    if length(side_to_tiles[bits_to_int(tile.data[1:10, 1])]) == 1
      numone += 1
      push!(ones, bits_to_int(tile.data[:, 1]))
    end
    if length(side_to_tiles[bits_to_int(tile.data[1:10, 10])]) == 1
      numone += 1
      push!(ones, bits_to_int(tile.data[:, 10]))
    end
    if length(side_to_tiles[bits_to_int(tile.data[1, 1:10])]) == 1
      numone += 1
      push!(ones, bits_to_int(tile.data[1, :]))
    end
    if length(side_to_tiles[bits_to_int(tile.data[10, :])]) == 1
      numone += 1
      push!(ones, bits_to_int(tile.data[10, :]))
    end
    if numone == 2
      return (tile, ones)
    end
  end
end


function rotate(data::Array{Bool, 2})::Array{Bool, 2}
  t = permutedims(data, [2, 1])
  reverse(t, dims=2)
end

function rotate_to_left(tile::Tile, val::Int)::Tile
  d = tile.data
  if btoi(d[:, 1]) == val
    return tile
  end
  d = rotate(d)
  if btoi(d[:, 1]) == val
    return Tile(tile.id, d)
  end
  d = rotate(d)
  if btoi(d[:, 1]) == val
    return Tile(tile.id, d)
  end
  d = rotate(d)
  if btoi(d[:, 1]) == val
    return Tile(tile.id, d)
  end
  d = reverse(d, dims=2)
  if btoi(d[:, 1]) == val
    return Tile(tile.id, d)
  end
  d = rotate(d)
  if btoi(d[:, 1]) == val
    return Tile(tile.id, d)
  end
  d = rotate(d)
  if btoi(d[:, 1]) == val
    return Tile(tile.id, d)
  end
  d = rotate(d)
  if btoi(d[:, 1]) == val
    return Tile(tile.id, d)
  end
end

firsttile, onesides = find_start(side_to_tiles)
firsttile = rotate_to_left(firsttile, onesides[1])
if bits_to_int(firsttile.data[1, :]) != onesides[2]
  global firsttile = Tile(firsttile.id, reverse(firsttile.data, dims=1))
end

tilegrid = [firsttile]
used = Set{Int}(tilegrid[1].id)

for i in 2:SIZE*SIZE
  if i % SIZE == 1
    newtiles = side_to_tiles[bits_to_int(tilegrid[i - SIZE].data[10, :])]
    newtile = newtiles[1]
    if newtile.id in used
      newtile = newtiles[2]
      if newtile.id in used
        println("$newtile is already used??")
        exit(1)
      end
    end
    newtile = rotate_to_left(newtile, btoi(reverse(tilegrid[i - SIZE].data[10, :])))
    newtile = Tile(newtile.id, rotate(newtile.data))
    push!(tilegrid, newtile)
    push!(used, newtile.id)
  else
    newtiles = side_to_tiles[bits_to_int(tilegrid[end].data[:, 10])]
    newtile = newtiles[1]
    if newtile.id in used
      newtile = newtiles[2]
      if newtile.id in used
        println("$newtile is already used??")
        exit(1)
      end
    end
    newtile = rotate_to_left(newtile, btoi(tilegrid[end].data[:, 10]))
    push!(tilegrid, newtile)
    push!(used, newtile.id)
  end
end

tilegrid = permutedims(reshape(tilegrid, (SIZE, SIZE)), [2, 1])

datagrid = zeros(Bool, 8*SIZE, 8*SIZE)
for i in 1:SIZE, j in 1:SIZE
  datagrid[(i-1)*8+1:i*8, (j-1)*8+1:j*8] = tilegrid[i, j].data[2:9, 2:9]
end

datagrid = rotate(datagrid)

function ismonster(a::AbstractArray{Bool, 2})
  return (a[1, 19]
    && a[2, 1] && a[2, 6] && a[2, 7] && a[2, 12] && a[2, 13] && a[2, 18] && a[2, 19] && a[2, 20]
    && a[3, 2] && a[3, 5] && a[3, 8] && a[3, 11] && a[3, 14] && a[3, 17])
end

c = count(map(x -> ismonster(@view datagrid[x:x+CartesianIndex(3, 20)]), CartesianIndices((1:8*SIZE-3, 1:8*SIZE-20))))
if c == 0
  datagrid = rotate(datagrid)
  c = count(map(x -> ismonster(@view datagrid[x:x+CartesianIndex(3, 20)]), CartesianIndices((1:8*SIZE-3, 1:8*SIZE-20))))
  if c == 0
    datagrid = rotate(datagrid)
    c = count(map(x -> ismonster(@view datagrid[x:x+CartesianIndex(3, 20)]), CartesianIndices((1:8*SIZE-3, 1:8*SIZE-20))))
    if c == 0
      datagrid = rotate(datagrid)
      c = count(map(x -> ismonster(@view datagrid[x:x+CartesianIndex(3, 20)]), CartesianIndices((1:8*SIZE-3, 1:8*SIZE-20))))
      if c == 0
        datagrid = reverse(datagrid, dims=2)
        c = count(map(x -> ismonster(@view datagrid[x:x+CartesianIndex(3, 20)]), CartesianIndices((1:8*SIZE-3, 1:8*SIZE-20))))
        if c == 0
          datagrid = rotate(datagrid)
          c = count(map(x -> ismonster(@view datagrid[x:x+CartesianIndex(3, 20)]), CartesianIndices((1:8*SIZE-3, 1:8*SIZE-20))))
          if c == 0
            datagrid = rotate(datagrid)
            c = count(map(x -> ismonster(@view datagrid[x:x+CartesianIndex(3, 20)]), CartesianIndices((1:8*SIZE-3, 1:8*SIZE-20))))
            if c == 0
              datagrid = rotate(datagrid)
              c = count(map(x -> ismonster(@view datagrid[x:x+CartesianIndex(3, 20)]), CartesianIndices((1:8*SIZE-3, 1:8*SIZE-20))))
              if c == 0
                println("No monsters, bro")
                exit(1)
              end
            end
          end
        end
      end
    end
  end
end
println(count(datagrid) - c*15)
