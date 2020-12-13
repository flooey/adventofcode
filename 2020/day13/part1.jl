target = parse(Int, readline())
ids = map(x -> parse(Int, x), filter(x -> x != "x", split(readline(), ',')))

best = 0
diff = 1000000

for id in ids
  x = (target ÷ id) * id + id
  if x - target < diff
    global diff = x - target
    global best = id
  end
end
println(string("$diff * $best: ", diff * best))
