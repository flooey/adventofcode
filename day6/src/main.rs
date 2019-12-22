use std::collections::HashMap;
use std::io;
use std::io::BufRead;

fn main() {
	let mut orbits = HashMap::new();
	for line in io::stdin().lock().lines() {
		let line = line.unwrap();
		let comps: Vec<&str> = line.trim().split(')').collect();
		orbits.insert(comps[1].to_string(), comps[0].to_string());
	}
	let mut you = Vec::new();
	let mut c = &orbits[&"YOU".to_string()];
	you.push(c);
	while c != "COM" {
		c = &orbits[c];
		you.push(c);
	}
	let mut san = Vec::new();
	c = &orbits[&"SAN".to_string()];
	san.push(c);
	while c != "COM" {
		c = &orbits[c];
		san.push(c);
	}
	you.reverse();
	san.reverse();
	// println!("{:?}\n{:?}", you, san);
	let mut i = 0;
	while you[i] == san[i] {
		i += 1;
	}
	println!("{:?}", you.len() + san.len() - 2*i);
	// First half solution:
	// let mut total = 0;
	// for mut k in orbits.keys() {
	// 	loop {
	// 		if k == "COM" {
	// 			break;
	// 		}
	// 		total += 1;
	// 		k = &orbits[k];
	// 	}
	// }
	// println!("{:?}", total);
}
