function isvalid(d)
  if !(haskey(d, "byr") && haskey(d, "iyr") && haskey(d, "eyr") && haskey(d, "hgt") && haskey(d, "hcl") && haskey(d, "ecl") && haskey(d, "pid"))
    return false
  end
  byr = parse(Int, d["byr"])
  if byr < 1920 || 2002 < byr
    return false
  end
  iyr = parse(Int, d["iyr"])
  if iyr < 2010 || 2020 < iyr
    return false
  end
  eyr = parse(Int, d["eyr"])
  if eyr < 2020 || 2030 < eyr
    return false
  end
  hgt = d["hgt"]
  hgtunit = hgt[lastindex(hgt)-1:lastindex(hgt)]
  hgtvalue = parse(Int, hgt[1:lastindex(hgt)-2])
  if hgtunit == "cm"
    if hgtvalue < 150 || 193 < hgtvalue
      return false
    end
  elseif hgtunit == "in"
    if hgtvalue < 59 || 76 < hgtvalue
      return false
    end
  else
    return false
  end
  hcl = d["hcl"]
  if length(hcl) != 7 || hcl[1] != '#' || !occursin(r"[a-f0-9]{6}", hcl[2:7])
    return false
  end
  ecl = d["ecl"]
  if ecl != "amb" && ecl != "blu" && ecl != "brn" && ecl != "gry" && ecl != "grn" && ecl != "hzl" && ecl != "oth"
    return false
  end
  pid = d["pid"]
  if length(pid) != 9 || !occursin(r"[0-9]{9}", pid)
    return false
  end

  true
end

valid = 0
d = Dict{String,String}()
for line in eachline(stdin)
  if line == ""
    if isvalid(d)
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