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
    if pc > lastindex(program)
      return (true, acc)
    end
    if visited[pc]
      return (false, acc)
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
      exit(1)
    end
  end
end

program = read()
for i in 1:lastindex(program)
  if program[i].code == "nop" || program[i].code == "jmp"
    originst = program[i]
    program[i] = Inst(program[i].code == "nop" ? "jmp" : "nop", program[i].arg)
    result = runprogram(program)
    if result[1]
      println(string("Success at $i ! ", result[2]))
      exit(0)
    end
    program[i] = originst
  end
end