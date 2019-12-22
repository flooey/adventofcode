use intcode::parse_from_std_io;
use intcode::run;

fn calc(mut v: Vec<i32>, noun: i32, verb: i32) -> i32 {
	v[1] = noun;
	v[2] = verb;
	run(&mut v, &[]);
	v[0]
}

fn main() {
	let v = parse_from_std_io();
	let result = calc(v.clone(), 12, 2);
	println!("Result: {}", result);
	for noun in 1..100 {
		for verb in 1..100 {
			if calc(v.clone(), noun, verb) == 19690720 {
				println!("Found {}, {}", noun, verb);
				return;
			}
		}
	}
}
