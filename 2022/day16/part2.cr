re = /Valve (..) has flow rate=(\d+); tunnels? leads? to valves? (..(, ..)*)/

class Connection
    property dest, dist

    def initialize(@dest : String, @dist : Int32)
    end
end

class Valve
    property name, flow_rate, connections

    def initialize(@name : String, @flow_rate : Int32, @connections : Array(Connection))
    end
end

valves = Hash(String, Valve).new

while line = gets
    re.match(line.chomp)
    valves[$1] = Valve.new($1, $2.to_i, $3.split(", ").map { |c| Connection.new(c, 1) })
end

# valves.values.each do |v|
#     if v.flow_rate == 0 && v.connections.size == 2
#         dest_conn = valves[v.connections[0].dest].connections
#         old = dest_conn.find { |c2| c2.dest == v.name }
#         if !old
#             exit 1
#         end
#         dest_conn.reject! { |c2| c2.dest == v.name }
#         dest_conn << Connection.new(v.connections[1].dest, old.dist + v.connections[1].dist)
#         # puts "From #{v.connections[0].dest} replaced #{old.dest} / #{old.dist} with #{dest_conn[-1].dest} / #{dest_conn[-1].dist}"
        
#         dest_conn = valves[v.connections[1].dest].connections
#         old = dest_conn.find { |c2| c2.dest == v.name }
#         if !old
#             exit 1
#         end
#         dest_conn.reject! { |c2| c2.dest == v.name }
#         dest_conn << Connection.new(v.connections[0].dest, old.dist + v.connections[0].dist)
#         # puts "From #{v.connections[1].dest} replaced #{old.dest} / #{old.dist} with #{dest_conn[-1].dest} / #{dest_conn[-1].dist}"

#         valves.reject!(v.name)
#     end
# end

class Visited
    @loc : String
    @loc2 : String
    getter loc, loc2, open

    def initialize(loc : String, loc2 : String, @open : Set(String))
        if loc > loc2
            @loc = loc2
            @loc2 = loc
        else
            @loc = loc
            @loc2 = loc2
        end
    end

    def ==(other : Visited)
        return other.loc == @loc && other.loc2 == @loc2 && other.open == @open
    end

    def_hash @loc, @loc2, @open

    def to_s(io : IO)
        io << "#{@loc} #{@loc2} open: #{@open}"
    end
end


all_valves = valves.values.map { |v| v.flow_rate > 0 ? 1 : 0 }.sum

def visit1(valves : Hash(String, Valve), visited : Hash(Visited, Tuple(Int32, Int32)), loc : String, loc2 : String, last : String, last2 : String, steps : Int32, score : Int32, open : Set(String), all_valves : Int32)
    if steps == 0 || open.size == all_valves
        # puts "#{score}: #{open}"
        return score
    end
    this_visit = Visited.new(loc, loc2, open)
    if visited[this_visit][0] >= steps && visited[this_visit][1] >= score
        # puts "Skipping #{steps} / #{score} because of #{visited[this_visit]} at #{this_visit}"
        return 0
    end
    # while visited[this_visit] < score && this_visit.steps > 0
        visited[this_visit] = {steps, score}
    #     this_visit = Visited.new(loc, loc2, open, this_visit.steps - 1)
    # end
    v = valves[loc]
    max = 0
    if v.flow_rate > 0 && !open.includes?(loc)
        new_open = open.clone()
        new_open.add(loc)
        max = Math.max(max, visit2(valves, visited, loc, loc2, "", last2, steps, score + v.flow_rate * (steps - 1), new_open, all_valves))
        if v.flow_rate > 10
            return max
        end
    end
    v.connections.each do |c|
        if c.dest != last
            max = Math.max(max, visit2(valves, visited, c.dest, loc2, loc, last2, steps, score, open, all_valves))
        end
    end
    return max
end

def visit2(valves : Hash(String, Valve), visited : Hash(Visited, Tuple(Int32, Int32)), loc : String, loc2 : String, last : String, last2 : String, steps : Int32, score : Int32, open : Set(String), all_valves : Int32)
    v = valves[loc2]
    max = 0
    if v.flow_rate > 0 && !open.includes?(loc2)
        new_open = open.clone()
        new_open.add(loc2)
        max = Math.max(max, visit1(valves, visited, loc, loc2, last, "", steps - 1, score + v.flow_rate * (steps - 1), new_open, all_valves))
        if v.flow_rate > 10
            return max
        end
    end
    v.connections.each do |c|
        if c.dest != last2
            max = Math.max(max, visit1(valves, visited, loc, c.dest, last, loc2, steps - 1, score, open, all_valves))
        end
    end
    return max
end

puts visit1(valves, Hash(Visited, Tuple(Int32, Int32)).new { {100, -1} }, "AA", "AA", "", "", 26, 0, Set(String).new, all_valves)
