correct = 0
for line in eachline(stdin)
  components = split(line)
  range = split(components[1], '-')
  lowerbound, upperbound = parse(Int, range[1]), parse(Int, range[2])
  target = components[2][1]
  numfound = count(i->i == target, components[3])
  println("$line -> $lowerbound - $upperbound, found $numfound")
  if lowerbound <= numfound <= upperbound
    global correct += 1
  end
end
println(correct)