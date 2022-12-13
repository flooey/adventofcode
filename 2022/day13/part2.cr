struct Arr
    getter v = Array(Int32 | Arr).new
end

def parse(s : String, i : Int32)
    if s[i] == '['
        arr = Arr.new
        i += 1
        while s[i] != ']'
            i, val = parse(s, i)
            arr.v << val
            if s[i] == ','
                i += 1
            end
        end
        return i+1, arr
    else
        start = i
        while '0' <= s[i] && s[i] <= '9'
            i += 1
        end
        return i, s[start...i].to_i
    end
end

def cmp(a : Arr | Int32, b : Arr | Int32)
    if a.is_a?(Int32) && b.is_a?(Int32)
        return a <=> b
    elsif a.is_a?(Int32)
        arr = Arr.new
        arr.v << a
        return cmp(arr, b)
    elsif b.is_a?(Int32)
        arr = Arr.new
        arr.v << b
        return cmp(a, arr)
    else
        i = 0
        while i < a.v.size && i < b.v.size
            c = cmp(a.v[i], b.v[i])
            if c != 0
                return c
            end
            i += 1
        end
        if i >= a.v.size && i >= b.v.size
            return 0
        elsif i >= a.v.size
            return -1
        else
            return 1
        end
    end
end


inputs = [] of Arr

while line = gets
    line = line.chomp
    if line == ""
        next
    end
    _, v = parse(line, 0)
    inputs << v.as(Arr)
end

sep2 = Arr.new
sep2.v << Arr.new
sep2.v[0].as(Arr).v << 2

sep6 = Arr.new
sep6.v << Arr.new
sep6.v[0].as(Arr).v << 6

inputs << sep2
inputs << sep6

inputs = inputs.sort { | a, b | cmp(a, b) }

res = 1

inputs.each_index do |i|
    if cmp(sep2, inputs[i]) == 0 || cmp(sep6, inputs[i]) == 0
        res *= (i + 1)
    end
end

puts res