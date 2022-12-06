line = gets
if !line
    raise "Nope"
end
line = line.chomp

def all_distinct(s : String)
    return s.chars.to_set.size == s.size
end

i = 0
while true
    if all_distinct(line[i, 14])
        puts i+14
        break
    end
    i += 1
end