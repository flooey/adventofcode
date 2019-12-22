use std::collections::HashMap;
use std::collections::HashSet;
use std::iter::FromIterator;
use std::io;

fn calc(v: Vec<&str>) -> HashMap<(i32, i32), i32> {
	let mut res = HashMap::new();
	let mut pos = (0, 0);
	let mut step = 0;
	for val in &v {
		let amt = String::from_utf8(val.as_bytes()[1..].to_vec()).unwrap().parse::<i32>().unwrap();
		pos = match val.as_bytes()[0] as char {
			'R' => {
				for r in pos.0+1 ..= pos.0 + amt {
					step += 1;
					res.insert((r, pos.1), step);
				}
				(pos.0 + amt, pos.1)
			}
			'L' => {
				for r in pos.0 - amt .. pos.0 {
					step += 1;
					res.insert((r, pos.1), step);
				}
				(pos.0 - amt, pos.1)
			}
			'U' => {
				for r in pos.1+1 ..= pos.1 + amt {
					step += 1;
					res.insert((pos.0, r), step);
				}
				(pos.0, pos.1 + amt)
			}
			'D' => {
				for r in pos.1 - amt .. pos.1 {
					step += 1;
					res.insert((pos.0, r), step);
				}
				(pos.0, pos.1 - amt)
			}
			_ => panic!(),
		}
	}
	return res;
}

fn main() {
	let mut line = String::new();

	let stdin = io::stdin();
	stdin.read_line(&mut line).unwrap();
	line.retain(|c| !c.is_whitespace());
	let s1 = calc(line.split(",").collect::<Vec<&str>>());
	
	line.clear();
	stdin.read_line(&mut line).unwrap();
	line.retain(|c| !c.is_whitespace());
	let s2 = calc(line.split(",").collect::<Vec<&str>>());

	let p1: HashSet<&(i32, i32)> = HashSet::from_iter(s1.keys());
	let p2: HashSet<&(i32, i32)> = HashSet::from_iter(s2.keys());

	let mut min = 1000000;
	for p in p1.intersection(&p2) {
		let len = s1[p] + s2[p];
		if len < min {
			min = len;
		}
	}
	println!("{:?}", min);
}
