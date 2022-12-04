
score = 0

def result(a : Char, b : Char)
    if (a == 'A' && b == 'X') || (a == 'B' && b == 'Z') || (a == 'C' && b == 'Y')
        return 3
    elsif (a == 'A' && b == 'Y') || (a == 'B' && b == 'X') || (a == 'C' && b == 'Z')
        return 1
    else
        return 2
    end
end

while line = gets
    score += result(line[0], line[2])
    score += (line[2] - 'X') * 3
end

puts score
