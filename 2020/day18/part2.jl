function number(s::String)::Tuple{String, Int}
  if s[1] == ')'
    s, v = mult(s[2:end])
    return s[2:end], v
  else
    return s[2:end], parse(Int, s[1])
  end
end

function add(s::String)::Tuple{String, Int}
  s, v = number(s)
  while length(s) > 0 && s[1] == '+'
    next = number(s[2:end])
    s, v = next[1], v + next[2]
  end
  return s, v
end

function mult(s::String)::Tuple{String, Int}
  s, v = add(s)
  while length(s) > 0 && s[1] == '*'
    next = add(s[2:end])
    s, v = next[1], v * next[2]
  end
  return s, v
end

tot = 0
for line in eachline()
  global tot += mult(reverse(replace(line, " "=>"")))[2]
end
println(tot)