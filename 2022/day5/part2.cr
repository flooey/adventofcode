stacks = [] of Array(Char)
index = 0
while index < 9
    stacks.push([] of Char)
    index += 1
end

while line = gets
    line = line.chomp
    if line[1] == '1'
        break
    end
    index = 0
    while index < 9
        if line[4 * index + 1] != ' '
            stacks[index].push(line[4 * index + 1])
        end
        index += 1
    end
end

stacks.each { |s| s.reverse! }

gets

while line = gets
    line = line.chomp
    match = /move (\d+) from (\d) to (\d)/.match(line)
    if !match
        raise "WTF"
    end
    to_move = match[1].to_i
    stacks[match[2].to_i-1].pop(to_move).each { |e| stacks[match[3].to_i-1].push(e)}
end

puts stacks.map{ |s| s[-1] }.join
