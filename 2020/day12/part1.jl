dir = CartesianIndex(1, 0)
loc = CartesianIndex(0, 0)

function turn(dir, degrees)
  if degrees < 0
    degrees += 360
  end
  if degrees == 90
    return CartesianIndex(dir[2], -1 * dir[1])
  elseif degrees == 180
    return -1 * dir
  elseif degrees == 270
    return CartesianIndex(-1 * dir[2], dir[1])
  end
  println("Unknown degrees: $degrees")
  exit(1)
end

for line in eachline(stdin)
  command, arg = line[1], parse(Int, line[2:end])
  if command == 'N'
    global loc += CartesianIndex(0, arg)
  elseif command == 'E'
    global loc += CartesianIndex(arg, 0)
  elseif command == 'S'
    global loc += CartesianIndex(0, -1 * arg)
  elseif command == 'W'
    global loc += CartesianIndex(-1 * arg, 0)
  elseif command == 'F'
    global loc += dir * arg
  elseif command == 'R'
    global dir = turn(dir, arg)
  elseif command == 'L'
    global dir = turn(dir, -1 * arg)
  else
    println("Unknown command: $command")
    exit(1)
  end
end

println(loc)
println(abs(loc[1]) + abs(loc[2]))