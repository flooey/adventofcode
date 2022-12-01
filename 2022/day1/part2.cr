elves = [] of Int32

cur_elf = 0
while line = gets
    line = line.chomp
    if line == ""
        elves << cur_elf
        cur_elf = 0
    else
        cur_elf += line.to_i
    end
end
if cur_elf > 0
    elves << cur_elf
end

puts elves.sort.reverse[0..2].sum