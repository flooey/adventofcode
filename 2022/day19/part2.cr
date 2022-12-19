class Blueprint
    @number : Int32
    @ore_cost : Int32
    @clay_cost : Int32
    @obsidian_cost_ore : Int32
    @obsidian_cost_clay : Int32
    @geode_cost_ore : Int32
    @geode_cost_obsidian : Int32

    @max_ore : Int32
    
    getter number, ore_cost, clay_cost, obsidian_cost_ore, obsidian_cost_clay, geode_cost_ore, geode_cost_obsidian, max_ore

    def initialize(line : String)
        re = /Blueprint (\d+): Each ore robot costs (\d+) ore. Each clay robot costs (\d+) ore. Each obsidian robot costs (\d+) ore and (\d+) clay. Each geode robot costs (\d+) ore and (\d+) obsidian./
        re.match(line)
        @number = $1.to_i
        @ore_cost = $2.to_i
        @clay_cost = $3.to_i
        @obsidian_cost_ore = $4.to_i
        @obsidian_cost_clay = $5.to_i
        @geode_cost_ore = $6.to_i
        @geode_cost_obsidian = $7.to_i

        @max_ore = [@ore_cost, @clay_cost, @obsidian_cost_ore, @geode_cost_ore].max
    end
end

blueprints = [] of Blueprint

while line = gets
    blueprints << Blueprint.new(line.chomp)
end

if blueprints.size > 3
    blueprints = blueprints[0..2]
end

def run(blueprint : Blueprint, target : Int32, time_left : Int32, ore : Int32, clay : Int32, obsidian : Int32, geodes : Int32, ore_robots : Int32, clay_robots : Int32, obsidian_robots : Int32, geode_robots : Int32) : Int32
    if time_left == 0
        return geodes
    end
    if target == 0 && ore >= blueprint.ore_cost || target == 1 && ore >= blueprint.clay_cost || target == 2 && ore >= blueprint.obsidian_cost_ore && clay >= blueprint.obsidian_cost_clay || target == 3 && ore >= blueprint.geode_cost_ore && obsidian >= blueprint.geode_cost_obsidian
        max = 0
        [target - 1, target, target + 1].each do |new_target|
            if !(new_target < 0 || new_target > 3 || new_target == 2 && clay_robots == 0 || new_target == 3 && obsidian_robots == 0)
                case target
                when 0
                    if ore_robots < blueprint.max_ore
                        max = Math.max(max, run(blueprint, new_target, time_left - 1, ore - blueprint.ore_cost + ore_robots, clay + clay_robots, obsidian + obsidian_robots, geodes + geode_robots, ore_robots + 1, clay_robots, obsidian_robots, geode_robots))
                    end
                when 1
                    if clay_robots < blueprint.obsidian_cost_clay
                        max = Math.max(max, run(blueprint, new_target, time_left - 1, ore - blueprint.clay_cost + ore_robots, clay + clay_robots, obsidian + obsidian_robots, geodes + geode_robots, ore_robots, clay_robots + 1, obsidian_robots, geode_robots))
                    end
                when 2
                    if obsidian_robots < blueprint.geode_cost_obsidian
                        max = Math.max(max, run(blueprint, new_target, time_left - 1, ore - blueprint.obsidian_cost_ore + ore_robots, clay - blueprint.obsidian_cost_clay + clay_robots, obsidian + obsidian_robots, geodes + geode_robots, ore_robots, clay_robots, obsidian_robots + 1, geode_robots))
                    end
                when 3
                    max = Math.max(max, run(blueprint, new_target, time_left - 1, ore - blueprint.geode_cost_ore + ore_robots, clay + clay_robots, obsidian - blueprint.geode_cost_obsidian + obsidian_robots, geodes + geode_robots, ore_robots, clay_robots, obsidian_robots, geode_robots + 1))
                end
            end
        end
        return max
    else
        return run(blueprint, target, time_left - 1, ore + ore_robots, clay + clay_robots, obsidian + obsidian_robots, geodes + geode_robots, ore_robots, clay_robots, obsidian_robots, geode_robots)
    end
    return 0
end

total = 1

blueprints.each do |b|
    amt = Math.max(run(b, 0, 32, 0, 0, 0, 0, 1, 0, 0, 0), run(b, 1, 32, 0, 0, 0, 0, 1, 0, 0, 0))
    puts "#{b.number} : #{amt}"
    total *= amt
end

puts total