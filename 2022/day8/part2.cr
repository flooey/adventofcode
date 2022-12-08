grid = [] of Array(Char)

while line = gets
    line = line.chomp
    grid.push(line.chars)
end

def visible_score(grid : Array(Array(Char)), i : Int32, j : Int32)
    val = grid[i][j]
    up = 0
    down = 0
    left = 0
    right = 0
    i2 = i - 1
    while i2 >= 0
        up += 1
        if grid[i2][j] >= val
            break
        end
        i2 -= 1
    end
    i2 = i + 1
    while i2 < grid.size
        down += 1
        if grid[i2][j] >= val
            break
        end
        i2 += 1
    end
    j2 = j - 1
    while j2 >= 0
        left += 1
        if grid[i][j2] >= val
            break
        end
        j2 -= 1
    end
    j2 = j + 1
    while j2 < grid[0].size
        right += 1
        if grid[i][j2] >= val
            break
        end
        j2 += 1
    end
    return up * down * left * right
end

max_score = 0

grid.each_index do |i|
    grid.each_index do |j|
        max_score = Math.max(max_score, visible_score(grid, i, j))
    end
end

puts max_score