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
        if a > b
            return 1
        elsif a < b
            return -1
        else
            return 0
        end
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

i = 1
inorder = 0

while line = gets
    i1, v1 = parse(line.chomp, 0)
    i2, v2 = parse(read_line.chomp, 0)
    gets
    c = cmp(v1.as(Arr), v2.as(Arr))
    if c == -1
        inorder += i
    end
    i += 1
end

puts inorder
