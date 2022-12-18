re = /Valve (..) has flow rate=(\d+); tunnels? leads? to valves? (..(, ..)*)/

class Valve
    property name, flow_rate, connections

    def initialize(@name : String, @flow_rate : Int32, @connections : Array(String))
    end
end

class Visited
    property loc, open, steps

    def initialize(@loc : String, @open : Set(String), @steps : Int32)
    end

    def ==(other : Visited)
        return other.loc == self.loc && other.open == self.open && self.steps == other.steps
    end

    def_hash @loc, @open, @steps
end

valves = Hash(String, Valve).new

while line = gets
    re.match(line.chomp)
    valves[$1] = Valve.new($1, $2.to_i, $3.split(", "))
end

def visit(valves : Hash(String, Valve), visited : Hash(Visited, Int32), loc : String, steps : Int32, score : Int32, open : Set(String))
    if steps == 0
        return score
    end
    this_visit = Visited.new(loc, open, steps)
    if visited.has_key?(this_visit) && visited[this_visit] >= score
        return 0
    end
    visited[this_visit] = score
    v = valves[loc]
    max = 0
    if v.flow_rate > 0 && !open.includes?(loc)
        new_open = open.clone()
        new_open.add(loc)
        max = Math.max(max, visit(valves, visited, loc, steps - 1, score + v.flow_rate * (steps - 1), new_open))
    end
    v.connections.each do |c|
        max = Math.max(max, visit(valves, visited, c, steps - 1, score, open))
    end
    return max
end

puts visit(valves, {} of Visited => Int32, "AA", 30, 0, Set(String).new)
