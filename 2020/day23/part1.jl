function domove(data::Array{Int})::Array{Int}
  cur = data[1]
  dest = cur
  while dest in data[1:4]
    dest -= 1
    if dest < 1
      dest = 9
    end
  end
  destloc = findfirst(x -> x == dest, data)
  [data[5:destloc]; data[2:4]; data[destloc+1:end]; data[1]]
end

INPUT = "137826495"
data = map(x -> parse(Int, x), collect(INPUT))
for i in 1:100
  global data = domove(data)
end

data = circshift(data, -1 * (findfirst(x -> x == 1, data) - 1))

println(join(data[2:end]))