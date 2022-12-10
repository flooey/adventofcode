x = 1
cycle = 1

def p(cycle : Int32, x : Int32)
    pos = (cycle - 1) % 40
    if pos - 1 <= x && x <= pos + 1
        print '#'
    else
        print '.'
    end
    if pos == 39
        puts
    end
end

while line = gets
    line = line.chomp
    p(cycle, x)
    if line == "noop"
        cycle += 1
    else
        p(cycle + 1, x)
        cycle += 2
        x += line[5..-1].to_i
    end
end

puts
