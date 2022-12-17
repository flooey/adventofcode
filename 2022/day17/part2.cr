pattern = read_line.chomp.chars.map { |c| c == '>' ? 1 : -1}
pattern_i = 0

rocks = Array(Array(Bool)).new

def hit(rocks : Array(Array(Bool)), up : Int32, right : Int32, shape : Int64)
    if up < 0
        return true
    end
    if right < 0
        return true
    end
    if shape == 0
       if right >= 4
            return true
       end
       if rocks.size <= up
            return false
        end
       return rocks[up][right] || rocks[up][right+1] || rocks[up][right+2] || rocks[up][right+3]
    elsif shape == 1
        if right >= 5
            return true
        end
        if rocks.size <= up
             return false
         end
        return (rocks[up][right + 1] || ((rocks.size > up + 1) && (rocks[up+1][right] || rocks[up+1][right+1] || rocks[up+1][right+2])) || ((rocks.size > up + 2) && (rocks[up+2][right+1])))
    elsif shape == 2
        if right >= 5
            return true
        end
        if rocks.size <= up
             return false
         end
        return (rocks[up][right] || rocks[up][right+1] || rocks[up][right+2] || ((rocks.size > up + 1) && (rocks[up+1][right+2])) || ((rocks.size > up + 2) && (rocks[up+2][right+2])))
    elsif shape == 3
        if right >= 7
            return true
        end
        if rocks.size <= up
             return false
         end
        return (rocks[up][right] || ((rocks.size > up + 1) && (rocks[up+1][right])) || ((rocks.size > up + 2) && (rocks[up+2][right])) || ((rocks.size > up + 3) && (rocks[up+3][right])))
    else shape == 4
        if right >= 6
            return true
        end
        if rocks.size <= up
             return false
         end
        return (rocks[up][right] || rocks[up][right+1] || ((rocks.size > up + 1) && (rocks[up+1][right] || rocks[up+1][right+1])))
    end
end

def resize(rocks : Array(Array(Bool)), up : Int32, shape : Int64)
    height = 1
    if shape == 1 || shape == 2
        height = 3
    elsif shape == 3
        height = 4
    elsif shape == 4
        height = 2
    end
    while up + height - 1 >= rocks.size
        rocks << [false] * 7
    end
end

def dump(rocks : Array(Array(Bool)))
    rocks.reverse.each do |r|
        puts r.map { |c| c ? '#' : '.'}.join("")
    end
    puts
end

def do_rock(rocks, shape, pattern, pattern_i)
    up = rocks.size + 3
    right = 2
    while true
        if !hit(rocks, up, right + pattern[pattern_i], shape)
            right += pattern[pattern_i]
        end
        pattern_i = (pattern_i + 1) % pattern.size
        if hit(rocks, up - 1, right, shape)
            resize(rocks, up, shape)
            if shape == 0
                rocks[up][right] = true
                rocks[up][right+1] = true
                rocks[up][right+2] = true
                rocks[up][right+3] = true
            elsif shape == 1
                rocks[up][right+1] = true
                rocks[up+1][right] = true
                rocks[up+1][right+1] = true
                rocks[up+1][right+2] = true
                rocks[up+2][right+1] = true
            elsif shape == 2
                rocks[up][right] = true
                rocks[up][right+1] = true
                rocks[up][right+2] = true
                rocks[up+1][right+2] = true
                rocks[up+2][right+2] = true
            elsif shape == 3
                rocks[up][right] = true
                rocks[up+1][right] = true
                rocks[up+2][right] = true
                rocks[up+3][right] = true
            else
                rocks[up][right] = true
                rocks[up][right+1] = true
                rocks[up+1][right] = true
                rocks[up+1][right+1] = true
            end
            return pattern_i
        else
            up -= 1
        end
    end
end

# General approach:
# 1. Run for a while to make sure the floor doesn't matter
# 2. Note what shape / pattern_i combo we're on
# 3. Run until that combo reappears
# 4. Math out how many times that operation repeats
# 5. Run a little longer until we're at the right i

target_num = 1000000000000_i64

i = 0_i64
while i < 2022
    shape = i % 5
    pattern_i = do_rock(rocks, shape, pattern, pattern_i)
    i += 1
end

start_i = i
start_pattern_i = pattern_i
start_height = rocks.size

while true
    shape = i % 5
    pattern_i = do_rock(rocks, shape, pattern, pattern_i)
    i += 1
    if i % 5 == start_i % 5 && pattern_i == start_pattern_i
        break
    end
end

loop_len = i - start_i
loop_height = (rocks.size - start_height).to_i64

puts "Loop len: #{loop_len}, loop height: #{loop_height}"

# So every loop_len loops we add loop_height height

skipped_loops = (target_num - i) // loop_len

puts "Skipping #{skipped_loops}"

while i < target_num - (loop_len * skipped_loops)
    shape = i % 5
    pattern_i = do_rock(rocks, shape, pattern, pattern_i)
    i += 1
end

puts skipped_loops * loop_len + i

puts rocks.size.to_i64 + (loop_height * skipped_loops)
