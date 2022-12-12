grid = [] of Array(Char)

while line = gets
    grid.push(line.chomp.chars)
end

e = {0, 0}

grid.each_index do |x|
    grid[x].each_index do |y|
        if grid[x][y] == 'S'
            grid[x][y] = 'a'
        elsif grid[x][y] == 'E'
            e = {x, y}
            grid[x][y] = 'z'
        end
    end
end

dist = Array(Array(Int32)).new
grid.each { |x| dist << [1000000] * x.size }
dist[e[0]][e[1]] = 0

updated = true

while updated
    updated = false
    grid.each_index do |x|
        grid[x].each_index do |y|
            if (x > 0 && grid[x-1][y] <= grid[x][y] + 1 && dist[x-1][y] < dist[x][y] - 1)
                dist[x][y] = dist[x-1][y] + 1
                updated = true
            end
            if (x < grid.size - 1 && grid[x+1][y] <= grid[x][y] + 1 && dist[x+1][y] < dist[x][y] - 1)
                dist[x][y] = dist[x+1][y] + 1
                updated = true
            end
            if (y > 0 && grid[x][y-1] <= grid[x][y] + 1 && dist[x][y-1] < dist[x][y] - 1)
                dist[x][y] = dist[x][y-1] + 1
                updated = true
            end
            if (y < grid[x].size - 1 && grid[x][y+1] <= grid[x][y] + 1 && dist[x][y+1] < dist[x][y] - 1)
                dist[x][y] = dist[x][y+1] + 1
                updated = true
            end
        end
    end
end

best = 1000000

grid.each_index do |x|
    grid[x].each_index do |y|
        if grid[x][y] == 'a' && dist[x][y] < best
            best = dist[x][y]
        end
    end
end

puts best
