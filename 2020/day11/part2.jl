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
    for up in -1:1, left in -1:1
      up == 0 && left == 0 && continue
      for j in Iterators.accumulate(+, Iterators.flatten([[i], Iterators.repeated(CartesianIndex(up, left))]))
        j == i && continue
        if low[1] <= j[1] <= high[1] && low[2] <= j[2] <= high[2]
          if data[j] != '.'
            if data[j] == '#'
              neighbors += 1
            end
            break
          end
        else
          break
        end
      end
    end
    if neighbors == 0
      out[i] = '#'
    elseif neighbors >= 5
      out[i] = 'L'
    else
      out[i] = data[i]
    end
  end
  return out
end

while true
# for i in 1:5
#   display(data)
#   println()
  newdata = dothething(data)
  if data == newdata
    break
  end
  global data = newdata
end

println(count(x -> x == '#', data))