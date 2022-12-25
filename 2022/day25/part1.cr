def to_snafu(num : Int64) : String
    items = [] of Char
    while num > 0
        case num % 5
        when 0
            items << '0'
        when 1
            items << '1'
            num -= 1
        when 2
            items << '2'
            num -= 2
        when 3
            items << '='
            num += 2
        when 4
            items << '-'
            num += 1
        end
        num = num // 5
    end
    return items.reverse.join
end

def from_snafu(s : String) : Int64
    result = 0_i64
    pos = 1_i64
    s.chars.reverse.each do |c|
        case c
        when '1'
            result += pos
        when '2'
            result += 2_i64 * pos
        when '-'
            result += -1_i64 * pos
        when '='
            result += -2_i64 * pos
        end
        pos *= 5_i64
    end
    return result
end

total = 0_i64

while line = gets
    total += from_snafu(line.chomp)
end

puts to_snafu(total)