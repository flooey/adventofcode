readline()
ids = map(x -> (parse(Int, x[2]), x[1]-1), filter(x -> x[2] != "x", collect(enumerate(split(readline(), ',')))))

println(ids)

function validate(t, ids)
  for i in ids
    if (t + i[2]) % i[1] != 0
      return false
    end
  end
  true
end

while length(ids) > 1
  s = ids[1:2]
  m = maximum(s)
  i = 1
  while true
    t = i * m[1] - m[2]
    if validate(t, s)
      popfirst!(ids)
      popfirst!(ids)
      pushfirst!(ids, (s[1][1] * s[2][1], s[1][1] * s[2][1] - t))
      break
    end
    i += 1
  end
  println(ids)
end

println(ids[1][1] - ids[1][2])