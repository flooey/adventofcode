visited = Set(Tuple(Int32, Int32)).new

h = {0, 0}
t = {0, 0}

while line = gets
    line = line.chomp
    dir = line[0]
    amt = line[2..-1].to_i
    while amt > 0
        amt -= 1
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
        td = {t[0] - h[0], t[1] - h[1]}
        if td[0] == 0 && td[1].abs > 1
            t = {t[0], t[1] - td[1].sign}
        elsif td[1] == 0 && td[0].abs > 1
            t = {t[0] - td[0].sign, t[1]}
        elsif td[0].abs > 1 || td[1].abs > 1
            t = {t[0] - td[0].sign, t[1] - td[1].sign}
        end
        visited.add(t)
    end
end

puts visited.size