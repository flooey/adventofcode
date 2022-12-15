ranges = [] of Range(Int32, Int32)
beacon_pos = Set(Int32).new

re = /Sensor at x=(-?\d+), y=(-?\d+): closest beacon is at x=(-?\d+), y=(-?\d+)/

test_y = 2000000

while line = gets
    re.match(line.chomp)
    sx = $1.to_i
    sy = $2.to_i
    bx = $3.to_i
    by = $4.to_i
    man_dist = (sx - bx).abs + (sy - by).abs
    y_dist = man_dist - (sy - test_y).abs
    if y_dist < 0
        next
    end
    ranges << ((sx - y_dist)..(sx + y_dist))
    if by == test_y
        beacon_pos.add(bx)
    end
end

puts ranges.map { |x| x.to_set }.reduce { |x, y| x + y }.size - beacon_pos.size
