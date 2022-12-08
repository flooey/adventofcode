grid = [] of Array(Char)

while line = gets
    line = line.chomp
    grid.push(line.chars)
end

def is_visible?(grid : Array(Array(Char)), i : Int32, j : Int32)
    visible = true
    val = grid[i][j]
    grid.each_index(start: 0, count: i) do |i2|
        if val <= grid[i2][j]
            visible = false
        end
    end
    if visible
        return true
    end
    visible = true
    grid.each_index(start: i+1, count: grid.size - i) do |i2|
        if val <= grid[i2][j]
            visible = false
        end
    end
    if visible
        return true
    end
    visible = true
    grid[0].each_index(start: 0, count: j) do |j2|
        if val <= grid[i][j2]
            visible = false
        end
    end
    if visible
        return true
    end
    visible = true
    grid[0].each_index(start: j+1, count: grid[0].size - j) do |j2|
        if val <= grid[i][j2]
            visible = false
        end
    end
    return visible
end

visible = 0

grid.each_index do |i|
    grid.each_index do |j|
        if is_visible?(grid, i, j)
            visible += 1
        end
    end
end

puts visible