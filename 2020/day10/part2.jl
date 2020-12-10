nums = Int[]
push!(nums, 0)

for line in eachline(stdin)
  push!(nums, parse(Int, line))
end

sort!(nums)

oneruns = Int[]
currun = 0

for i in firstindex(nums):lastindex(nums)-1
  if nums[i+1] - nums[i] == 3
    if currun > 1
      push!(oneruns, currun)
    end
    global currun = 0
  elseif nums[i+1] - nums[i] == 1
    global currun += 1
  else
    println(string("At $i, diff is ", nums[i+1] - nums[i]))
  end
end
if currun > 1
  push!(oneruns, currun)
end

function whatever(x::Int)
  if x == 2
    return 2
  elseif x == 3
    return 4
  elseif x == 4
    return 7
  end
  return 17
end

println(prod(map(whatever, oneruns)))