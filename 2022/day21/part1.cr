monkeys = Hash(String, Int64 | Tuple(String, Char, String)).new

while line = gets
    line = line.chomp
    name = line[0..3]
    line = line[6..-1]
    if /\d+/.match(line)
        monkeys[name] = line.to_i64
    else
        monkeys[name] = {line[0..3], line[5], line[7..10]}
    end
end

def calc(monkeys, name : String)
    val = monkeys[name]
    case val
    when Int64
        return val
    when Tuple(String, Char, String)
        m1 = calc(monkeys, val[0])
        m2 = calc(monkeys, val[2])
        case val[1]
        when '+'
            return m1 + m2
        when '-'
            return m1 - m2
        when '*'
            return m1 * m2
        when '/'
            return m1 // m2
        end
    end
    return 0
end

puts calc(monkeys, "root")
