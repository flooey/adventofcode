trees = zeros(Int, 5)
coord = ones(Int, 5)
linenum = 0

for line in eachline(stdin)
  for i in 1:4
    if line[coord[i]] == '#'
      trees[i] += 1
    end
    coord[i] += 2*i - 1
    if coord[i] > length(line)
      coord[i] %= length(line)
    end
  end
  if linenum % 2 == 0
    if line[coord[5]] == '#'
      trees[5] += 1
    end
    coord[5] += 1
    if coord[5] > length(line)
      coord[5] %= length(line)
    end
  end
  global linenum += 1
end
println(trees)
println(reduce(*, trees))
