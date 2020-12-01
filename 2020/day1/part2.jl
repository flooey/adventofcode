data = Int32[]

for line in eachline(stdin)
  push!(data, parse(Int32, line))
end

for i in 1:length(data), j in 1:length(data), k in 1:length(data)
  if data[i] + data[j] + data[k] == 2020
    println(string(data[i], ", ", data[j], ", ", data[k], ": ", data[i] * data[j] * data[k]))
    break
  end
end