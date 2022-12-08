struct DirList
    getter value = Hash(String, Int32 | DirList).new
end

root = DirList.new

cur = root

while line = gets
    line = line.chomp
    if line == "$ cd /"
        cur = root
    elsif line.starts_with?("$ cd")
        cur = cur.value[line[5..-1]].as(DirList)
    elsif line.starts_with?("$ ls")
        # ignore
    else # dir listing
        pieces = line.split(' ')
        name = pieces[1]
        if pieces[0] == "dir"
            if !cur.value.has_key?(name)
                cur.value[name] = DirList.new
                cur.value[name].as(DirList).value[".."] = cur
            end
        else
            cur.value[name] = pieces[0].to_i
        end
    end
end

def sizes(dir : DirList)
    mysize = 0
    myresults = [] of Int32
    dir.value.each do |key, value|
        if key != ".."
            if value.is_a?(Int32)
                mysize += value
            elsif value.is_a?(DirList)
                size, results = sizes(value)
                mysize += size
                myresults += results
            end
        end
    end
    myresults += [mysize]
    return {mysize, myresults}
end

size, results = sizes(root)

needed_size = size - 40000000

best = 100000000
results.each do |value|
    if value >= needed_size && value < best
        best = value
    end
end

puts best