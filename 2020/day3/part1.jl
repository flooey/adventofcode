trees = 0
coord = 1

for line in eachline(stdin)
  if line[coord] == '#'
    global trees += 1
  end
  global coord += 3
  if coord > length(line)
    global coord %= length(line)
  end
end
println(trees)
