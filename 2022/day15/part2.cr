struct Sensor
    property x, y, range

    def initialize(@x : Int32, @y : Int32, @range : Int32)
    end

    def covers(x : Int32, y : Int32)
        (self.x - x).abs + (self.y - y).abs <= self.range
    end
end

re = /Sensor at x=(-?\d+), y=(-?\d+): closest beacon is at x=(-?\d+), y=(-?\d+)/

max_coord = 4000000
sensors = [] of Sensor

while line = gets
    re.match(line.chomp)
    sx = $1.to_i
    sy = $2.to_i
    bx = $3.to_i
    by = $4.to_i
    man_dist = (sx - bx).abs + (sy - by).abs
    sensors << Sensor.new(sx, sy, man_dist)
end

def done(x : Int32, y : Int32)
    puts "#{x} #{y}"
    puts x.to_i64 * 4000000 + y
    exit
end

sensors.each do |s|
    x = s.x
    y = s.y - s.range - 1
    while y < s.y
        if 0 <= y && y <= max_coord && 0 <= x && x <= max_coord
            if !sensors.any? { |s2| s2.covers(x, y)}
                done(x, y)
            end
        end
        y += 1
        x += 1
    end
    while x > s.x
        if 0 <= y && y <= max_coord && 0 <= x && x <= max_coord
            if !sensors.any? { |s2| s2.covers(x, y)}
                done(x, y)
            end
        end
        y += 1
        x -= 1
    end
    while y > s.y
        if 0 <= y && y <= max_coord && 0 <= x && x <= max_coord
            if !sensors.any? { |s2| s2.covers(x, y)}
                done(x, y)
            end
        end
        y -= 1
        x -= 1
    end
    while x < s.x
        if 0 <= y && y <= max_coord && 0 <= x && x <= max_coord
            if !sensors.any? { |s2| s2.covers(x, y)}
                done(x, y)
            end
        end
        y -= 1
        x += 1
    end
end

puts "WTF?"
