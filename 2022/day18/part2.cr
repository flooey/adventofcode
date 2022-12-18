cubes = Set(Tuple(Int32, Int32, Int32)).new

while line = gets
    coords = line.chomp.split(',').map { |x| x.to_i }
    cubes.add({coords[0], coords[1], coords[2]})
end

def add(x : Tuple(Int32, Int32, Int32), y : Tuple(Int32, Int32, Int32))
    return { x[0] + y[0], x[1] + y[1], x[2] + y[2] }
end

total = 0

dirs = { {-1, 0, 0} , {1, 0, 0} , {0, -1, 0} , {0, 1, 0} , {0, 0, -1} , {0, 0, 1} }

def is_free(visited : Set(Tuple(Int32, Int32, Int32)), cubes : Set(Tuple(Int32, Int32, Int32)), pos : Tuple(Int32, Int32, Int32), dirs)
    if visited.size > 2000
        return true
    end
    if cubes.includes?(pos)
        return false
    end
    if visited.includes?(pos)
        return false
    end
    visited.add(pos)
    i = 0
    while i < 6
        if is_free(visited, cubes, add(pos, dirs[i]), dirs)
            return true
        end
        i += 1
    end
    return false
end

cubes.each do |c|
    dirs.each do |d|
        if is_free(Set(Tuple(Int32, Int32, Int32)).new, cubes, add(c, d), dirs)
            total += 1
        end
    end
end

puts total
