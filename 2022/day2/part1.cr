
score = 0

def result(a : Char, b : Char)
    if (a == 'A' && b == 'X') || (a == 'B' && b == 'Y') || (a == 'C' && b == 'Z')
        return 3
    elsif (a == 'A' && b == 'Y') || (a == 'B' && b == 'Z') || (a == 'C' && b == 'X')
        return 6
    else
        return 0
    end
end

while line = gets
    score += result(line[0], line[2])
    score += line[2] - 'W'
end

puts score
