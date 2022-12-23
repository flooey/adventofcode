elves = Set(Tuple(Int32, Int32)).new

linenum = 0
while line = gets
    line.chomp.chars.each_with_index do |c, i|
        if c == '#'
            elves << {linenum, i}
        end
    end
    linenum += 1
end

def bounds(e : Set(Tuple(Int32, Int32)))
    min_x = 10000
    max_x = 0
    min_y = 10000
    max_y = 0

    e.each do |e|
        min_x = Math.min(min_x, e[1])
        min_y = Math.min(min_y, e[0])
        max_x = Math.max(max_x, e[1])
        max_y = Math.max(max_y, e[0])
    end
    return {min_x, max_x, min_y, max_y}
end

def dump(e : Set(Tuple(Int32, Int32)))
    puts bounds(e)
    min_x, max_x, min_y, max_y = bounds(e)
    (min_y..max_y).each do |y|
        (min_x..max_x).each do |x|
            if e.includes?({y, x})
                print '#'
            else    
                print '.'
            end
        end
        print '\n'
    end
    puts
end

def plus(a : Tuple(Int32, Int32), b : Tuple(Int32, Int32))
    {a[0] + b[0], a[1] + b[1]}
end

dirs = [ { {-1, 0}, {-1, -1}, {-1, 1} },
         { {1, 0}, {1, -1}, {1, 1} },
         { {0, -1}, {1, -1}, {-1, -1} }, 
         { {0, 1}, {1, 1}, {-1, 1} } ]

ALL_DIRS = { {1, 1}, {1, 0}, {1, -1}, {0, 1}, {0, -1}, {-1, -1}, {-1, 0}, {-1, 1} }

round = 1
while true
    new_elves = Set(Tuple(Int32, Int32)).new
    elves.each do |e|
        if (elves & ALL_DIRS.map { |d| plus(d, e) }.to_set).empty?
            new_elves << e
        else
            moved = false
            dirs.each do |dir|
                if !moved
                    if (elves & dir.map { |d| plus(d, e) }.to_set).empty?
                        moved = true
                        if new_elves.includes?(plus(dir[0], e))
                            new_elves << e
                            new_elves.subtract([plus(dir[0], e)]) << plus(plus(dir[0], e), dir[0])
                        else
                            new_elves << plus(dir[0], e)
                        end
                    end
                end
            end
            if !moved
                new_elves << e
            end
        end
    end
    if elves == new_elves
        break
    end
    round += 1
    elves = new_elves
    dirs.rotate!
    # dump(elves)
end

puts round
