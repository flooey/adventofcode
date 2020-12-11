input = Char[]
lines = 0

for line in eachline(stdin)
  push!(input, line...)
  global lines += 1
end

data = reshape(input, length(input) ÷ lines, lines)

s = size(data)

function dothething(data)
  out = similar(data)
  range = CartesianIndices(data)
  low, high = first(range), last(range)
  for i in range
    if data[i] == '.'
      out[i] = '.'
      continue
    end
    neighbors = 0
    for j in max(low, i-CartesianIndex(1,1)):min(high, i+CartesianIndex(1,1))
      if i != j && data[j] == '#'
        neighbors += 1
      end
    end
    if neighbors == 0
      out[i] = '#'
    elseif neighbors >= 4
      out[i] = 'L'
    else
      out[i] = data[i]
    end
  end
  return out
end

while true
  # display(data)
  # println()
  newdata = dothething(data)
  if data == newdata
    break
  end
  global data = newdata
end

println(count(x -> x == '#', data))