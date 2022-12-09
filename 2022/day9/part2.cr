visited = Set(Tuple(Int32, Int32)).new

points = [{0, 0}] * 10

def follow(h : Tuple(Int32, Int32), t : Tuple(Int32, Int32))
    td = {t[0] - h[0], t[1] - h[1]}
    if td[0] == 0 && td[1].abs > 1
        return {t[0], t[1] - td[1].sign}
    elsif td[1] == 0 && td[0].abs > 1
        return {t[0] - td[0].sign, t[1]}
    elsif td[0].abs > 1 || td[1].abs > 1
        return {t[0] - td[0].sign, t[1] - td[1].sign}
    end
    return t
end

while line = gets
    line = line.chomp
    dir = line[0]
    amt = line[2..-1].to_i
    while amt > 0
        amt -= 1
        h = points[0]
        case dir
        when 'U'
            h = {h[0], h[1]+1}
        when 'D'
            h = {h[0], h[1]-1}
        when 'R'
            h = {h[0]+1, h[1]}
        when 'L'
            h = {h[0]-1, h[1]}
        end
        points[0] = h
        i = 1
        while i < points.size
            points[i] = follow(points[i-1], points[i])
            i += 1
        end
        visited.add(points[-1])
    end
end

puts visited.size