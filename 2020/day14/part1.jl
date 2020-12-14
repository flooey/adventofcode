mem = Dict{Int,Int}()
mask = ""
memsetline = r"^mem[[](\d+)] = (\d+)$"

function domask(v::Int, m::String)
  v = v & parse(Int, replace(m, 'X' => '1'), base=2)
  v = v | parse(Int, replace(m, 'X' => '0'), base=2)
  return v
end

for line in eachline(stdin)
  if line[begin:7] == "mask = "
    global mask = line[8:end]
  else
    m = match(memsetline, line)
    if m === nothing
      println("WTF? $line")
      exit(1)
    end
    mem[parse(Int, m.captures[1])] = domask(parse(Int, m.captures[2]), mask)
  end
end

println(sum(values(mem)))
