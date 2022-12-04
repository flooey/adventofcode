sum = 0

while line = gets
    line = line.chomp
    a = line[0, line.size // 2]
    b = line[line.size // 2, line.size // 2]
    same = 'a'
    a.chars.each do |ac|
        b.chars.each do |bc|
            if ac == bc
                same = ac
            end
        end
    end
    if same < 'a'
        sum += same - 'A' + 27
    else
        sum += same - 'a' + 1
    end
end

puts sum