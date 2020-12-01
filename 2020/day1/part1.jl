data = Int32[]

for line in eachline(stdin)
  push!(data, parse(Int32, line))
end

for i in 1:length(data), j in 1:length(data)
  if data[i] + data[j] == 2020
    println(string(data[i], ", ", data[j], ": ", data[i] * data[j]))
    break
  end
end