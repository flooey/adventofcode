count = 0

while line = gets
    line = line.chomp
    pieces = line.split(',').map {|p| p.split('-').map { |i| i.to_i }}
    if pieces[0][0] <= pieces[1][0] && pieces[1][1] <= pieces[0][1]
        count += 1
    elsif pieces[1][0] <= pieces[0][0] && pieces[0][1] <= pieces[1][1]
        count += 1
    end
end

puts count
