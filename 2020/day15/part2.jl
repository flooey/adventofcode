input = [9,12,1,4,17,0,18]
last_index = 30000000
nums = Dict{Int,Int}(map(x -> x[2] => x[1], enumerate(input[begin:end-1])))
l = input[end]
for i in lastindex(input):last_index-1
  newl = 0
  if haskey(nums, l)
    newl = i - nums[l]
  end
  nums[l] = i
  global l = newl
end

println(l)