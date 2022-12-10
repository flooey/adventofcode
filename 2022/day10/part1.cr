x = 1
cycle = 1
total = 0

while line = gets
    line = line.chomp
    if (cycle - 20) % 40 == 0
        total += cycle * x
    end
    if line == "noop"
        cycle += 1
    else
        if (cycle - 20) % 40 == 39
            total += (cycle + 1) * x
        end
        cycle += 2
        x += line[5..-1].to_i
    end
end

puts total
