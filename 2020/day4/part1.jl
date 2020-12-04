valid = 0
d = Dict{String,String}()
for line in eachline(stdin)
  if line == ""
    if haskey(d, "byr") && haskey(d, "iyr") && haskey(d, "eyr") && haskey(d, "hgt") && haskey(d, "hcl") && haskey(d, "ecl") && haskey(d, "pid")
      global valid += 1
    end
    global d = Dict{String,String}()
  else
    keyvals = split(line)
    for keyval in keyvals
      comps = split(keyval, ':')
      d[comps[1]] = comps[2]
    end
  end
end
println(valid)