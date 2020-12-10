nums = Int[]

for line in eachline(stdin)
  push!(nums, parse(Int, line))
end

sort!(nums)

one = 0
three = 1

for i in firstindex(nums):lastindex(nums)-1
  if nums[i+1] - nums[i] == 3
    global three += 1
  elseif nums[i+1] - nums[i] == 1
    global one += 1
  else
    println(string("At $i, diff is ", nums[i+1] - nums[i]))
  end
end
if nums[1] == 1
  global one += 1
elseif nums[1] == 3
  global three += 1
end

println(one * three)