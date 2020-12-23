INPUT = "137826495"
TOTAL_LENGTH = 1000000
ROUNDS = 10000000

mutable struct Node
  val::Int
  next::Union{Node, Nothing}
end

startval = parse(Int, INPUT[1])
start = Node(startval, nothing)
nodes = Dict{Int, Node}(startval => start)

cur = start
for i in [map(x -> parse(Int, x), collect(INPUT[2:end])); collect(10:TOTAL_LENGTH)]
  newnode = Node(i, nothing)
  cur.next = newnode
  push!(nodes, i => newnode)
  global cur = newnode
end
cur.next = start

function printem()
  one = nodes[1]
  cur = one.next
  while cur != one
    print(cur.val)
    cur = cur.next
  end
  println()
end

function domove(cur::Node)
  nogood = [cur.val, cur.next.val, cur.next.next.val, cur.next.next.next.val]
  dest = cur.val
  while dest in nogood
    dest -= 1
    if dest < 1
      dest = TOTAL_LENGTH
    end
  end
  destnode = nodes[dest]
  lifted = cur.next
  cur.next = cur.next.next.next.next
  lifted.next.next.next = destnode.next
  destnode.next = lifted
end

cur = start
for i in 1:ROUNDS
  if i % 10000 == 0
    println(i)
  end
  domove(cur)
  global cur = cur.next
end

println(nodes[1].next.val * nodes[1].next.next.val)