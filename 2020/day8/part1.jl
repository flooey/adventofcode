struct Inst
  code::String
  arg::Int
end

function read()
  program = Inst[]
  for line in eachline(stdin)
    parts = split(line)
    push!(program, Inst(parts[1], parse(Int, parts[2])))
  end
  return program
end

function runprogram(program::Array{Inst})
  visited = zeros(Bool, length(program))
  acc = 0
  pc = 1
  while true
    if visited[pc]
      println(acc)
      return
    end
    visited[pc] = true
    inst = program[pc]
    if inst.code == "nop"
      pc += 1
    elseif inst.code == "acc"
      acc += inst.arg
      pc += 1
    elseif inst.code == "jmp"
      pc += inst.arg
    else
      println("Invalid opcode: $inst")
    end
  end
end

runprogram(read())