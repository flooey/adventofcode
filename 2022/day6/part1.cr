line = gets
if !line
    raise "Nope"
end
line = line.chomp
i = 0
while true
    if line[i] != line[i+1] && line[i] != line[i+2] && line[i] != line[i+3] && line[i+1] != line[i+2] && line[i+1] != line[i+3] && line[i+2] != line[i+3]
        puts i+4
        break
    end
    i += 1
end