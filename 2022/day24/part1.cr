map = [] of Array(Char)

while line = gets
    if line[3] != '#'
        map << line.chomp.chars[1...-1]
    end
end

def okay(map : Array(Array(Char)), row : Int32, col : Int32)
    0 <= row && row < map.size && 0 <= col && col < map[0].size
end

def occupied(map : Array(Array(Char)), round : Int32, row : Int32, col : Int32)
    map[row][(col + round) % map[0].size] == '<' || map[row][(col - round) % map[0].size] == '>' || map[(row + round) % map.size][col] == '^' || map[(row - round) % map.size][col] == 'v'
end

class State
    getter round, row, col

    def initialize(@round : Int32, @row : Int32, @col : Int32)
    end

    def to_s(io : IO)
        io << "State{round: #{@round}, row: #{@row}, col: #{@col}"
    end

    def ==(other : State)
        @round == other.round && @row == other.row && @col == other.col
    end

    def_hash @round, @row, @col
end

states = [State.new(0, -1, 0)]
visited = Set(State).new

while true
    state = states.shift
    if visited.includes?(state)
        next
    end
    visited << state
    if state.row == map.size - 1 && state.col == map[0].size - 1
        puts state.round + 1
        break
    end
    # puts state
    if state.row == -1 || !occupied(map, state.round + 1, state.row, state.col)
        states << State.new(state.round + 1, state.row, state.col)
    end
    if okay(map, state.row + 1, state.col) && !occupied(map, state.round + 1, state.row + 1, state.col)
        states << State.new(state.round + 1, state.row + 1, state.col)
    end
    if okay(map, state.row - 1, state.col) && !occupied(map, state.round + 1, state.row - 1, state.col)
        states << State.new(state.round + 1, state.row - 1, state.col)
    end
    if okay(map, state.row, state.col + 1) && !occupied(map, state.round + 1, state.row, state.col + 1)
        states << State.new(state.round + 1, state.row, state.col + 1)
    end
    if okay(map, state.row, state.col - 1) && !occupied(map, state.round + 1, state.row, state.col - 1)
        states << State.new(state.round + 1, state.row, state.col - 1)
    end
end
