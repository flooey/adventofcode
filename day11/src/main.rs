use std::thread;
use std::sync::mpsc;
use std::cmp::min;
use std::cmp::max;

enum Dir {
	UP,
	DOWN,
	LEFT,
	RIGHT,
}

fn left(d: Dir) -> Dir {
	match d {
		Dir::UP => Dir::LEFT,
		Dir::LEFT => Dir::DOWN,
		Dir::DOWN => Dir::RIGHT,
		Dir::RIGHT => Dir::UP,
	}
}

fn right(d: Dir) -> Dir {
	match d {
		Dir::UP => Dir::RIGHT,
		Dir::RIGHT => Dir::DOWN,
		Dir::DOWN => Dir::LEFT,
		Dir::LEFT => Dir::UP,
	}
}

fn color(paints: &Vec<((i32, i32), i64)>, loc: &(i32, i32)) -> i64 {
	for paint in paints.iter().rev() {
		if paint.0 == *loc {
			return paint.1;
		}
	}
	return 0;
}

fn main() {
	let mut prog = intcode::parse_from_std_io();
	let (in_tx, in_rx) = mpsc::channel();
	let (out_tx, out_rx) = mpsc::channel();
	thread::spawn(move || {
		intcode::run_chans(&mut prog, &in_rx, out_tx);
	});
	let mut paints = Vec::new();
	let mut loc = (0, 0);
	let mut dir = Dir::UP;
	in_tx.send(1).unwrap();
	loop {
		match out_rx.recv() {
			Ok(p) => {
				// println!("Painting {:?} at {:?}", p, loc);
				paints.push((loc, p));
				let turn = out_rx.recv().unwrap();
				if turn == 0 {
					dir = left(dir);
				} else {
					dir = right(dir);
				}
				match dir {
					Dir::UP => { loc = (loc.0, loc.1-1); },
					Dir::LEFT => { loc = (loc.0-1, loc.1); },
					Dir::DOWN => { loc = (loc.0, loc.1+1); },
					Dir::RIGHT => { loc = (loc.0+1, loc.1); },
				}
				in_tx.send(color(&paints, &loc));
			},
			Err(_) => {
				break;
			}
		}
	}
	let mut min_x = paints.iter().fold(100, |v, p| min(v, (p.0).0));
	let mut min_y = paints.iter().fold(100, |v, p| min(v, (p.0).1));
	let mut max_x = paints.iter().fold(-100, |v, p| max(v, (p.0).0));
	let mut max_y = paints.iter().fold(-100, |v, p| max(v, (p.0).1));
	println!("min_x: {}, min_y: {}, max_x: {}, max_y: {}", min_x, min_y, max_x, max_y);
	for y in min_y..=max_y {
		for x in min_x..=max_x {
			if color(&paints, &(x, y)) == 0 {
				print!(" ");
			} else {
				print!("X");
			}
		}
		println!("");
	}
	// let locs: HashSet<(i32, i32)> = paints.iter().map(|v| v.0).collect();
	// println!("{:?}", locs.len());
}
