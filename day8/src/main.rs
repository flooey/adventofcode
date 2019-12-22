use std::io;

fn vectorize(x: &str) -> Vec<u8> {
	let mut v = Vec::new();
	for i in x.chars() {
		match i {
			'0' => { v.push(0); },
			'1' => { v.push(1); },
			'2' => { v.push(2); },
			_ => panic!(),
		}
	}
	v
}

fn merge(v: &mut Vec<u8>, v2: Vec<u8>) {
	for i in 0..v.len() {
		if v[i] == 2 {
			v[i] = v2[i];
		}
	}
}

fn main() {
	let mut line = String::new();

	let stdin = io::stdin();
	stdin.read_line(&mut line).unwrap();
	let mut l = line.trim();
	let mut x: &str;
	let mut v: Vec<u8> = Vec::new();
	for i in 0..25*6 {
		v.push(2);
	}
	while l.len() > 0 {
		let tups = l.split_at(25 * 6);
		x = tups.0;
		l = tups.1;
		let v2 = vectorize(&x);
		merge(&mut v, v2);
	}
	for i in 0..6 {
		for j in 0..25 {
			if v[i*25+j] == 1 {
				print!("X");
			} else {
				print!(" ");
			}
		}
		println!("");
	}
}
