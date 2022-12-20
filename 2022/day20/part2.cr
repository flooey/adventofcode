class Node
    @n = uninitialized Node
    @p = uninitialized Node
    property n, p, value

    def initialize(@value : Int64)
        @n = uninitialized Node
        @p = uninitialized Node
        @n = self
        @p = self
    end

    def append(node : Node)
        node.p = self
        node.n = @n
        @n.p = node
        @n = node
    end
end

key = 811589153_i64

cur = Node.new(read_line.chomp.to_i64 * key)
nodes = [cur]
while line = gets
    cur.append(Node.new(line.chomp.to_i64 * key))
    nodes << cur.n
    cur = cur.n
end

num_nodes = nodes.size

(0..9).each do |x|
    nodes.each do |n|
        to_move = n.value % (num_nodes - 1)
        if to_move != 0
            dest = n
            while to_move > 0
                dest = dest.n
                to_move -= 1
            end
            n.p.n = n.n
            n.n.p = n.p
            dest.n.p = n
            n.p = dest
            n.n = dest.n
            dest.n = n
            n.p = dest
        end
    end
end

cur = nodes[0]
while cur.value != 0
    cur = cur.n
end

sum = 0_i64
i = 0
while i <= 3000
    i += 1
    cur = cur.n
    if i % 1000 == 0
        sum += cur.value
    end
end

puts sum
