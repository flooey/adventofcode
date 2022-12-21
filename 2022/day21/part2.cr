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

def has_humn(monkeys, name : String)
    if name == "humn"
        return true
    else
        val = monkeys[name]
        case val
        when Int64
            return false
        when Tuple(String, Char, String)
            return has_humn(monkeys, val[0]) || has_humn(monkeys, val[2])
        end
    end
    return false
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
    return 0_i64
end

def decalc(monkeys, target : Int64, name) : Int64
    if name == "humn"
        return target
    end
    val = monkeys[name].as(Tuple(String, Char, String))
    if has_humn(monkeys, val[0])
        humn_side = val[0]
        other_side = calc(monkeys, val[2])
        case val[1]
        when '+'
            new_target = target - other_side
        when '-'
            new_target = target + other_side
        when '*'
            new_target = target // other_side
        when '/'
            new_target = target * other_side
        else
            raise "Nope"
        end
    else
        humn_side = val[2]
        other_side = calc(monkeys, val[0])
        case val[1]
        when '+'
            new_target = target - other_side
        when '-'
            # target = other_side - x => x = other_side - target
            new_target = other_side - target
        when '*'
            new_target = target // other_side
        when '/'
            # target = other_side / x => x = other_side / target
            new_target = other_side // target
        else
            raise "Nope"
        end
    end
    decalc(monkeys, new_target, humn_side)
end

root_val = monkeys["root"].as(Tuple(String, Char, String))

if has_humn(monkeys, root_val[0])
    humn_val = decalc(monkeys, calc(monkeys, root_val[2]), root_val[0])
else
    humn_val = decalc(monkeys, calc(monkeys, root_val[0]), root_val[2])
end

puts humn_val
