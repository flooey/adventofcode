correct = 0
for line in eachline(stdin)
  components = split(line)
  range = split(components[1], '-')
  first, second = parse(Int, range[1]), parse(Int, range[2])
  target = components[2][1]
  if (components[3][first] == target) !== (components[3][second] == target)
    global correct += 1
    println("$line -> true")
  else
    println("$line -> false")
  end
end
println(correct)