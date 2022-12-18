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

cubes.each do |c|
    dirs.each do |d|
        if !cubes.includes?(add(c, d))
            total += 1
        end
    end
end

puts total
