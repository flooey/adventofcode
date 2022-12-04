sum = 0

line1 = gets
line2 = gets
line3 = gets
while line1 && line2 && line3
    line1 = line1.chomp
    line2 = line2.chomp
    line3 = line3.chomp
    same = 'a'
    line1.chars.each do |ac|
        line2.chars.each do |bc|
            line3.chars.each do |cc|
                if ac == bc && bc == cc
                    same = ac
                end
            end
        end
    end
    if same < 'a'
        sum += same - 'A' + 27
    else
        sum += same - 'a' + 1
    end
    line1 = gets
    line2 = gets
    line3 = gets
end

puts sum