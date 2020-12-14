using Base.Iterators

mem = Dict{Int,Int}()
mask = ""
memsetline = r"^mem[[](\d+)] = (\d+)$"

function domask(v::Int, m::String)::Array{Int}
  sofar = [v | parse(Int, replace(m, 'X' => '0'), base=2)]
  for i in findall(x -> x == 'X', reverse(m))
    sofar = collect(Iterators.flatten(map(x -> [x | 1 << (i - 1), x & ~(1 << (i - 1))], sofar)))
  end
  sofar
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
    for loc in domask(parse(Int, m.captures[1]), mask)
      mem[loc] = parse(Int, m.captures[2])
    end
  end
end

println(sum(values(mem)))
