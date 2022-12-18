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

valves.values.each do |v|
    if v.flow_rate == 0 && v.connections.size == 2
        dest_conn = valves[v.connections[0].dest].connections
        old = dest_conn.find { |c2| c2.dest == v.name }
        if !old
            exit 1
        end
        dest_conn.reject! { |c2| c2.dest == v.name }
        dest_conn << Connection.new(v.connections[1].dest, old.dist + v.connections[1].dist)
        # puts "From #{v.connections[0].dest} replaced #{old.dest} / #{old.dist} with #{dest_conn[-1].dest} / #{dest_conn[-1].dist}"
        
        dest_conn = valves[v.connections[1].dest].connections
        old = dest_conn.find { |c2| c2.dest == v.name }
        if !old
            exit 1
        end
        dest_conn.reject! { |c2| c2.dest == v.name }
        dest_conn << Connection.new(v.connections[0].dest, old.dist + v.connections[0].dist)
        # puts "From #{v.connections[1].dest} replaced #{old.dest} / #{old.dist} with #{dest_conn[-1].dest} / #{dest_conn[-1].dist}"

        valves.reject!(v.name)
    end
end

puts "digraph g {"

valves.values.each do |v|
    puts "#{v.name} [label=\"#{v.name}\\n#{v.flow_rate}\"];"
    v.connections.each { |v2| puts "#{v.name} -> #{v2.dest} [label=\"#{v2.dist}\"];"}
end
puts "}"
