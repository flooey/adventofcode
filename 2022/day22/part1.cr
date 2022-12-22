board = [] of Array(Char)
while line = gets
    line = line.chomp
    if line == ""
        break
    end
    board << line.chars
end

line = read_line.chomp

moves = [] of Int32 | Char

cur_num = 0
line.chars.each do |c|
    if '0' <= c && c <= '9'
        cur_num = 10 * cur_num + c.to_i
    else
        moves << cur_num
        moves << c
        cur_num = 0
    end
end
if cur_num > 0
    moves << cur_num
end

x : Int32 = board[0].index! { |c| c == '.' }
y : Int32 = 0
facing = 0

moves.each do |m|
    if m == 'R'
        facing = (facing + 1) % 4
    elsif m == 'L'
        facing = (facing - 1) % 4
    elsif m.is_a?(Int32)
        while m > 0
            nextx : Int32 = x
            nexty : Int32 = y
            case facing
            when 0
                nextx += 1
                if board[nexty].size == nextx || board[nexty][nextx] == ' '
                    nextx = board[nexty].index! { |c| c != ' ' }
                end
            when 1
                nexty += 1
                if board.size == nexty || board[nexty].size <= nextx || board[nexty][nextx] == ' '
                    nexty = board.index! { |row| row[nextx]? != ' ' }
                end
            when 2
                nextx -= 1
                if nextx < 0 || board[nexty][nextx] == ' '
                    nextx = board[nexty].size - 1
                end
            when 3
                nexty -= 1
                if nexty < 0 || board[nexty][nextx] == ' '
                    nexty = board.size - 1
                    while board[nexty].size <= nextx
                        nexty -= 1
                    end
                end
            end
            if board[nexty][nextx] != '#'
                x = nextx
                y = nexty
            end
            m -= 1
        end
    else
        raise "Huh?"
    end
end

puts 1000 * (y + 1) + 4 * (x + 1) + facing
