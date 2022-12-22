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

BLOCK_SIZE = 50

def okay(board : Array(Array(Char)), x : Int32, y : Int32)
    0 <= y && y < board.size && 0 <= x && x < board[y].size && board[y][x] != ' '
end

def rotate_left(x : Int32, y : Int32)
    {x - (x % BLOCK_SIZE) + (y % BLOCK_SIZE), y - (y % BLOCK_SIZE) + BLOCK_SIZE - (x % BLOCK_SIZE) - 1}
end

def rotate_right(x : Int32, y : Int32)
    {x - (x % BLOCK_SIZE) + BLOCK_SIZE - (y % BLOCK_SIZE) - 1, y - (y % BLOCK_SIZE) + (x % BLOCK_SIZE)}
end

x : Int32 = board[0].index! { |c| c == '.' }
y : Int32 = 0
facing = 0

moves.each do |m|
    # puts "#{x} #{y} #{facing} - Executing #{m}"
    if m == 'R'
        facing = (facing + 1) % 4
    elsif m == 'L'
        facing = (facing - 1) % 4
    elsif m.is_a?(Int32)
        while m > 0
            nextx : Int32 = x
            nexty : Int32 = y
            next_facing : Int32 = facing
            case facing
            when 0
                if okay(board, x + 1, y)
                    nextx = x + 1
                else
                    if okay(board, x, y + BLOCK_SIZE) && okay(board, x + BLOCK_SIZE, y + BLOCK_SIZE)
                        nextx, nexty = rotate_right(x, y)
                        nextx += BLOCK_SIZE
                        nexty += 1
                        next_facing = 1
                    elsif okay(board, x, y - BLOCK_SIZE) && okay(board, x + BLOCK_SIZE, y - BLOCK_SIZE)
                        nextx, nexty = rotate_left(x, y)
                        nextx += BLOCK_SIZE
                        nexty -= 1
                        next_facing = 3
                    elsif okay(board, x, y + BLOCK_SIZE) && okay(board, x + BLOCK_SIZE, y + 2 * BLOCK_SIZE)
                        nextx, nexty = rotate_left(x, y)
                        nextx, nexty = rotate_left(nextx, nexty)
                        nextx += 2 * BLOCK_SIZE - 1
                        nexty += 2 * BLOCK_SIZE
                        next_facing = 2
                    elsif okay(board, x, y - BLOCK_SIZE) && okay(board, x + BLOCK_SIZE, y - 2 * BLOCK_SIZE)
                        nextx, nexty = rotate_left(x, y)
                        nextx, nexty = rotate_left(nextx, nexty)
                        nextx += 2 * BLOCK_SIZE - 1
                        nexty -= 2 * BLOCK_SIZE
                        next_facing = 2
                    elsif !okay(board, x, y + BLOCK_SIZE) && okay(board, x - BLOCK_SIZE, y + 2 * BLOCK_SIZE)
                        nextx, nexty = rotate_left(x, y)
                        nextx, nexty = rotate_left(nextx, nexty)
                        nextx -= 1
                        nexty += 2 * BLOCK_SIZE
                        next_facing = 2
                    elsif !okay(board, x, y - BLOCK_SIZE) && okay(board, x - BLOCK_SIZE, y - 2 * BLOCK_SIZE)
                        nextx, nexty = rotate_left(x, y)
                        nextx, nexty = rotate_left(nextx, nexty)
                        nextx -= 1
                        nexty -= 2 * BLOCK_SIZE
                        next_facing = 2
                    elsif !okay(board, x - BLOCK_SIZE, y + BLOCK_SIZE) && okay(board, x - 3 * BLOCK_SIZE, y + BLOCK_SIZE)
                        nextx, nexty = rotate_left(x, y)
                        nextx -= 3 * BLOCK_SIZE
                        nexty += 2 * BLOCK_SIZE - 1
                        next_facing = 1
                    elsif !okay(board, x - BLOCK_SIZE, y - BLOCK_SIZE) && okay(board, x - 3 * BLOCK_SIZE, y - BLOCK_SIZE)
                        nextx, nexty = rotate_right(x, y)
                        nextx -= 3 * BLOCK_SIZE
                        nexty -= 2 * BLOCK_SIZE - 1
                        next_facing = 3
                    elsif okay(board, x - BLOCK_SIZE, y + 3 * BLOCK_SIZE)
                        nextx, nexty = rotate_left(x, y)
                        nextx -= BLOCK_SIZE
                        nexty += 4 * BLOCK_SIZE - 1
                        next_facing = 3
                    elsif okay(board, x - BLOCK_SIZE, y - 3 * BLOCK_SIZE)
                        nextx, nexty = rotate_right(x, y)
                        nextx -= BLOCK_SIZE
                        nexty -= 4 * BLOCK_SIZE - 1
                        next_facing = 1
                    elsif okay(board, x - 3 * BLOCK_SIZE, y + 2 * BLOCK_SIZE)
                        nextx -= 4 * BLOCK_SIZE - 1
                        nexty += 2 * BLOCK_SIZE
                        next_facing = 0
                    elsif okay(board, x - 3 * BLOCK_SIZE, y - 2 * BLOCK_SIZE)
                        nextx -= 4 * BLOCK_SIZE - 1
                        nexty -= 2 * BLOCK_SIZE
                        next_facing = 0
                    else
                        raise "Uh oh"
                    end
                end
            when 1
                if okay(board, x, y + 1)
                    nexty = y + 1
                else
                    if okay(board, x + BLOCK_SIZE, y) && okay(board, x + BLOCK_SIZE, y + BLOCK_SIZE)
                        nextx, nexty = rotate_left(x, y)
                        nextx += 1
                        nexty += BLOCK_SIZE
                        next_facing = 0
                    elsif okay(board, x - BLOCK_SIZE, y) && okay(board, x - BLOCK_SIZE, y + BLOCK_SIZE)
                        nextx, nexty = rotate_right(x, y)
                        nextx -= 1
                        nexty += BLOCK_SIZE
                        next_facing = 2
                    elsif okay(board, x + BLOCK_SIZE, y) && okay(board, x + 2 * BLOCK_SIZE, y + BLOCK_SIZE)
                        nextx, nexty = rotate_left(x, y)
                        nextx, nexty = rotate_left(nextx, nexty)
                        nextx += 2 * BLOCK_SIZE
                        nexty += 2 * BLOCK_SIZE - 1
                        next_facing = 3
                    elsif okay(board, x - BLOCK_SIZE, y) && okay(board, x - 2 * BLOCK_SIZE, y + BLOCK_SIZE)
                        nextx, nexty = rotate_left(x, y)
                        nextx, nexty = rotate_left(nextx, nexty)
                        nextx -= 2 * BLOCK_SIZE
                        nexty += 2 * BLOCK_SIZE - 1
                        next_facing = 3
                    elsif !okay(board, x + BLOCK_SIZE, y) && okay(board, x + 2 * BLOCK_SIZE, y - BLOCK_SIZE)
                        nextx, nexty = rotate_left(x, y)
                        nextx, nexty = rotate_left(nextx, nexty)
                        nextx += 2 * BLOCK_SIZE
                        nexty -= 1
                        next_facing = 3
                    elsif !okay(board, x - BLOCK_SIZE, y) && okay(board, x - 2 * BLOCK_SIZE, y - BLOCK_SIZE)
                        nextx, nexty = rotate_left(x, y)
                        nextx, nexty = rotate_left(nextx, nexty)
                        nextx -= 2 * BLOCK_SIZE
                        nexty -= 1
                        next_facing = 3
                    elsif !okay(board, x + BLOCK_SIZE, y - BLOCK_SIZE) && okay(board, x + BLOCK_SIZE, y - 3 * BLOCK_SIZE)
                        nextx, nexty = rotate_right(x, y)
                        nextx += 2 * BLOCK_SIZE - 1
                        nexty -= 3 * BLOCK_SIZE
                        next_facing = 2
                    elsif !okay(board, x - BLOCK_SIZE, y - BLOCK_SIZE) && okay(board, x - BLOCK_SIZE, y - 3 * BLOCK_SIZE)
                        nextx, nexty = rotate_left(x, y)
                        nextx -= 2 * BLOCK_SIZE - 1
                        nexty -= 3 * BLOCK_SIZE
                        next_facing = 0
                    elsif okay(board, x + 3 * BLOCK_SIZE, y - BLOCK_SIZE)
                        nextx, nexty = rotate_left(x, y)
                        nextx += 4 * BLOCK_SIZE - 1
                        nexty -= BLOCK_SIZE
                        next_facing = 2
                    elsif okay(board, x - 3 * BLOCK_SIZE, y - BLOCK_SIZE)
                        nextx, nexty = rotate_right(x, y)
                        nextx -= 4 * BLOCK_SIZE - 1
                        nexty -= BLOCK_SIZE
                        next_facing = 0
                    elsif okay(board, x + 2 * BLOCK_SIZE, y - 3 * BLOCK_SIZE)
                        nextx += 2 * BLOCK_SIZE
                        nexty -= 4 * BLOCK_SIZE - 1
                        next_facing = 1
                    elsif okay(board, x - 2 * BLOCK_SIZE, y - 3 * BLOCK_SIZE)
                        nextx -= 2 * BLOCK_SIZE
                        nexty -= 4 * BLOCK_SIZE - 1
                        next_facing = 1
                    else
                        raise "Uh oh"
                    end
                end
            when 2
                if okay(board, x - 1, y)
                    nextx = x - 1
                else
                    if okay(board, x, y - BLOCK_SIZE) && okay(board, x - BLOCK_SIZE, y - BLOCK_SIZE)
                        nextx, nexty = rotate_right(x, y)
                        nextx -= BLOCK_SIZE
                        nexty -= 1
                        next_facing = 3
                    elsif okay(board, x, y + BLOCK_SIZE) && okay(board, x - BLOCK_SIZE, y + BLOCK_SIZE)
                        nextx, nexty = rotate_left(x, y)
                        nextx -= BLOCK_SIZE
                        nexty += 1
                        next_facing = 1
                    elsif okay(board, x, y - BLOCK_SIZE) && okay(board, x - BLOCK_SIZE, y - 2 * BLOCK_SIZE)
                        nextx, nexty = rotate_left(x, y)
                        nextx, nexty = rotate_left(nextx, nexty)
                        nextx -= 2 * BLOCK_SIZE - 1
                        nexty -= 2 * BLOCK_SIZE
                        next_facing = 0
                    elsif okay(board, x, y + BLOCK_SIZE) && okay(board, x - BLOCK_SIZE, y + 2 * BLOCK_SIZE)
                        nextx, nexty = rotate_left(x, y)
                        nextx, nexty = rotate_left(nextx, nexty)
                        nextx -= 2 * BLOCK_SIZE - 1
                        nexty += 2 * BLOCK_SIZE
                        next_facing = 0
                    elsif !okay(board, x, y - BLOCK_SIZE) && okay(board, x + BLOCK_SIZE, y - 2 * BLOCK_SIZE)
                        nextx, nexty = rotate_left(x, y)
                        nextx, nexty = rotate_left(nextx, nexty)
                        nextx += 1
                        nexty -= 2 * BLOCK_SIZE
                        next_facing = 0
                    elsif !okay(board, x, y + BLOCK_SIZE) && okay(board, x + BLOCK_SIZE, y + 2 * BLOCK_SIZE)
                        nextx, nexty = rotate_left(x, y)
                        nextx, nexty = rotate_left(nextx, nexty)
                        nextx += 1
                        nexty += 2 * BLOCK_SIZE
                        next_facing = 0
                    elsif !okay(board, x + BLOCK_SIZE, y - BLOCK_SIZE) && okay(board, x + 3 * BLOCK_SIZE, y - BLOCK_SIZE)
                        nextx, nexty = rotate_left(x, y)
                        nextx += 3 * BLOCK_SIZE
                        nexty -= 2 * BLOCK_SIZE - 1
                        next_facing = 3
                    elsif !okay(board, x + BLOCK_SIZE, y + BLOCK_SIZE) && okay(board, x + 3 * BLOCK_SIZE, y + BLOCK_SIZE)
                        nextx, nexty = rotate_right(x, y)
                        nextx += 3 * BLOCK_SIZE
                        nexty += 2 * BLOCK_SIZE - 1
                        next_facing = 1
                    elsif okay(board, x + BLOCK_SIZE, y - 3 * BLOCK_SIZE)
                        nextx, nexty = rotate_left(x, y)
                        nextx += BLOCK_SIZE
                        nexty -= 4 * BLOCK_SIZE - 1
                        next_facing = 1
                    elsif okay(board, x + BLOCK_SIZE, y + 3 * BLOCK_SIZE)
                        nextx, nexty = rotate_right(x, y)
                        nextx += BLOCK_SIZE
                        nexty += 4 * BLOCK_SIZE - 1
                        next_facing = 3
                    elsif okay(board, x + 3 * BLOCK_SIZE, y - 2 * BLOCK_SIZE)
                        nextx += 4 * BLOCK_SIZE - 1
                        nexty -= 2 * BLOCK_SIZE
                        next_facing = 2
                    elsif okay(board, x + 3 * BLOCK_SIZE, y + 2 * BLOCK_SIZE)
                        nextx += 4 * BLOCK_SIZE - 1
                        nexty += 2 * BLOCK_SIZE
                        next_facing = 2
                    else
                        raise "Uh oh"
                    end
                end
            when 3
                if okay(board, x, y - 1)
                    nexty = y - 1
                else
                    if okay(board, x + BLOCK_SIZE, y) && okay(board, x + BLOCK_SIZE, y - BLOCK_SIZE)
                        nextx, nexty = rotate_right(x, y)
                        nextx += 1
                        nexty -= BLOCK_SIZE
                        next_facing = 0
                    elsif okay(board, x - BLOCK_SIZE, y) && okay(board, x - BLOCK_SIZE, y - BLOCK_SIZE)
                        nextx, nexty = rotate_left(x, y)
                        nextx -= 1
                        nexty -= BLOCK_SIZE
                        next_facing = 2
                    elsif okay(board, x + BLOCK_SIZE, y) && okay(board, x + 2 * BLOCK_SIZE, y - BLOCK_SIZE)
                        nextx, nexty = rotate_left(x, y)
                        nextx, nexty = rotate_left(nextx, nexty)
                        nextx += 2 * BLOCK_SIZE
                        nexty -= 2 * BLOCK_SIZE - 1
                        next_facing = 1
                    elsif okay(board, x - BLOCK_SIZE, y) && okay(board, x - 2 * BLOCK_SIZE, y - BLOCK_SIZE)
                        nextx, nexty = rotate_left(x, y)
                        nextx, nexty = rotate_left(nextx, nexty)
                        nextx -= 2 * BLOCK_SIZE
                        nexty -= 2 * BLOCK_SIZE - 1
                        next_facing = 1
                    elsif !okay(board, x + BLOCK_SIZE, y) && okay(board, x + 2 * BLOCK_SIZE, y + BLOCK_SIZE)
                        nextx, nexty = rotate_left(x, y)
                        nextx, nexty = rotate_left(nextx, nexty)
                        nextx += 2 * BLOCK_SIZE
                        nexty += 1
                        next_facing = 1
                    elsif !okay(board, x - BLOCK_SIZE, y) && okay(board, x - 2 * BLOCK_SIZE, y + BLOCK_SIZE)
                        nextx, nexty = rotate_left(x, y)
                        nextx, nexty = rotate_left(nextx, nexty)
                        nextx -= 2 * BLOCK_SIZE
                        nexty += 1
                        next_facing = 1
                    elsif !okay(board, x + BLOCK_SIZE, y + BLOCK_SIZE) && okay(board, x + BLOCK_SIZE, y + 3 * BLOCK_SIZE)
                        nextx, nexty = rotate_left(x, y)
                        nextx += 2 * BLOCK_SIZE - 1
                        nexty += 3 * BLOCK_SIZE
                        next_facing = 2
                    elsif !okay(board, x - BLOCK_SIZE, y + BLOCK_SIZE) && okay(board, x - BLOCK_SIZE, y + 3 * BLOCK_SIZE)
                        nextx, nexty = rotate_right(x, y)
                        nextx -= 2 * BLOCK_SIZE - 1
                        nexty += 3 * BLOCK_SIZE
                        next_facing = 0
                    elsif okay(board, x + 3 * BLOCK_SIZE, y + BLOCK_SIZE)
                        nextx, nexty = rotate_left(x, y)
                        nextx += 4 * BLOCK_SIZE - 1
                        nexty += BLOCK_SIZE
                        next_facing = 3
                    elsif okay(board, x - 3 * BLOCK_SIZE, y + BLOCK_SIZE)
                        nextx, nexty = rotate_right(x, y)
                        nextx -= 4 * BLOCK_SIZE - 1
                        nexty += BLOCK_SIZE
                        next_facing = 1
                    elsif okay(board, x + 2 * BLOCK_SIZE, y + 3 * BLOCK_SIZE)
                        nextx += 2 * BLOCK_SIZE
                        nexty += 4 * BLOCK_SIZE - 1
                        next_facing = 3
                    elsif okay(board, x - 2 * BLOCK_SIZE, y + 3 * BLOCK_SIZE)
                        nextx -= 2 * BLOCK_SIZE
                        nexty += 4 * BLOCK_SIZE - 1
                        next_facing = 3
                    else
                        raise "Uh oh"
                    end
                end
            end
            # if (nextx - x).abs + (nexty - y).abs > 1
            #     puts "Jump"
            # end
            # puts "Moving #{x} #{y} -> #{nextx} #{nexty}"
            if board[nexty][nextx] != '#'
                x = nextx
                y = nexty
                facing = next_facing
            # else
            #     puts "Blocked by wall"
            end
            m -= 1
        end
    else
        raise "Huh?"
    end
end

# puts "#{x} #{y} #{facing}"
puts 1000 * (y + 1) + 4 * (x + 1) + facing
