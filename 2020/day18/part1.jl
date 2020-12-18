function expression(s::String)::Tuple{String, Int}
  v = 0
  if s[1] == ')'
    s, v = expression(s[2:end])
  else
    v = parse(Int, s[1])
  end
  s = s[2:end]
  if length(s) == 0 || s[1] == '('
    return s, v
  end
  op = (s[1] == '+') ? (+) : (*)
  next = expression(s[2:end])
  return next[1], op(v, next[2])
end

tot = 0
for line in eachline()
  global tot += expression(reverse(replace(line, " "=>"")))[2]
end
println(tot)