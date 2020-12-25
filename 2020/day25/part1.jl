function mod_exp(sn::Int, loop::Int)::Int
  val = 1
  for i in 1:loop
    val = (val * sn) % 20201227
  end
  val
end

INPUT1 = 10705932
INPUT2 = 12301431

val = 1
loop = 0
while val != INPUT1 && val != INPUT2
  global loop += 1
  global val = (val * 7) % 20201227
end

println("Loop: $loop")
if val == INPUT1
  println(mod_exp(INPUT2, loop))
else
  println(mod_exp(INPUT1, loop))
end