class Monkey
    property items, op, test_div, true_dest, false_dest
    property throws = 0

    def initialize(@items : Array(Int32), @op : Proc(Int32, Int32), @test_div : Int32, @true_dest : Int32, @false_dest : Int32)
    end

    def throw_all
        results = [] of Tuple(Int32, Int32)
        while !self.items.empty?
            self.throws += 1
            item = self.items.shift
            item = self.op.call(item) // 3
            if item % test_div == 0
                results << {item, true_dest}
            else
                results << {item, false_dest}
            end
        end
        return results
    end
end

monkeys = [] of Monkey

def make_op(line)
    if line[23] == '*'
        if line[25..-1] == "old"
            return Proc(Int32, Int32).new { |x| x * x }
        else
            val = line[25..-1].to_i
            return Proc(Int32, Int32).new { |x| x * val }
        end
    else
        val = line[25..-1].to_i
        return Proc(Int32, Int32).new { |x| x + val }
    end
end

while line = gets
    line = read_line.chomp
    items = line[18..-1].split(',').map {|n| n.to_i}
    line = read_line.chomp
    op = make_op(line)
    test_div = read_line.chomp[21..-1].to_i
    true_dest = read_line.chomp[29..-1].to_i
    false_dest = read_line.chomp[30..-1].to_i
    gets
    monkeys << Monkey.new(items, op, test_div, true_dest, false_dest)
end

i = 0
while i < 20
    monkeys.each do |m|
        todo = m.throw_all
        todo.each do |t|
            monkeys[t[1]].items << t[0]
        end
    end
    i += 1
end

best = 0
not_best = 0

monkeys.each do |m|
    if m.throws > best
        not_best = best
        best = m.throws
    elsif m.throws > not_best
        not_best = m.throws
    end
end

puts best * not_best
