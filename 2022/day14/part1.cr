a = [] of Array(Char)

([0] * 600).each do |_|
    a << ['.'] * 200
end

while line = gets
    steps = line.chomp.split(" -> ")
    x = -1
    y = -1
    steps.each do |step|
        coords = step.split(',')
        sx = coords[0].to_i
        sy = coords[1].to_i
        if x == -1
            x = sx
            y = sy
        else
            if x == sx
                while y != sy
                    a[x][y] = '#'
                    y -= y <=> sy
                end
            else
                while x != sx
                    a[x][y] = '#'
                    x -= x <=> sx
                end
            end
        end
        a[x][y] = '#'
    end
end

landed = 0

while true
    sx = 500
    sy = 0

    while true
        if sy == 199
            break
        elsif a[sx][sy+1] == '.'
            sy += 1
        elsif a[sx-1][sy+1] == '.'
            sx -= 1
            sy += 1
        elsif a[sx+1][sy+1] == '.'
            sx += 1
            sy += 1
        else
            a[sx][sy] = 'o'
            landed += 1
            break
        end
    end
    if sy == 199
        break
    end
end

puts landed
