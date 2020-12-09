nums = Int[]

for line in eachline(stdin)
  push!(nums, parse(Int, line))
end

TARGET_SUM = 14144619

low = 1
high = 1

while true
  s = sum(@view(nums[low:high]))
  if s == TARGET_SUM
    println(sort(@view(nums[low:high])))
    st = sort(@view(nums[low:high]))
    println(st[begin] + st[end])
    exit(0)
  elseif s < TARGET_SUM
    global high += 1
  elseif s > TARGET_SUM
    global low += 1
  end
end
