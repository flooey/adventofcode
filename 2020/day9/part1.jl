nums = Int[]

for line in eachline(stdin)
  push!(nums, parse(Int, line))
end

SCOPE_LEN = 25

curindex = SCOPE_LEN + 1

function isvalid(idx::Int)
  for i in idx-SCOPE_LEN:idx-1, j in idx-SCOPE_LEN:idx-1
    if i != j && nums[i] + nums[j] == nums[idx]
      return true
    end
  end
  return false
end

for i in SCOPE_LEN+1:lastindex(nums)
  if !isvalid(i)
    println(string(i, ": ", nums[i]))
    exit(0)
  end
end
