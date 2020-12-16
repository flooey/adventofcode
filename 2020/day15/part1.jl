nums = [9,12,1,4,17,0,18]
while length(nums) < 2020
  ind = findprev(x -> x == nums[end], nums, lastindex(nums) - 1)
  if ind === nothing
    push!(nums, 0)
  else
    push!(nums, lastindex(nums) - ind)
  end
end

println(nums[2020])