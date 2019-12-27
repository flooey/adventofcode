use std::cell;

#[derive(Debug, Clone, PartialEq)]
struct Moon {
	pos: Vec<i32>,
	vel: Vec<i32>,
}

impl Moon {
	fn mv(&mut self) -> () {
		self.pos[0] += self.vel[0];
		self.pos[1] += self.vel[1];
		self.pos[2] += self.vel[2];
	}

	fn gravity(&mut self, other: &Moon) -> () {
		for i in 0..3 {
			if self.pos[i] < other.pos[i] {
				self.vel[i] += 1;
			} else if self.pos[i] > other.pos[i] {
				self.vel[i] -= 1;
			}
		}
	}

	fn energy(&self) -> i32 {
		let pn = self.pos[0].abs() + self.pos[1].abs() + self.pos[2].abs();
		let kn = self.vel[0].abs() + self.vel[1].abs() + self.vel[2].abs();
		return pn * kn;
	}
}


fn new_moon(x: i32, y: i32, z: i32) -> Moon {
	return Moon {
		pos: vec![x, y, z],
		vel: vec![0,0,0],
	}
}

fn run(orig: Vec<cell::RefCell<Moon>>, comp: usize) -> i32 {
	let moons = orig.clone();
	let mut step = 0;
	loop {
		for i in 0..moons.len() {
			for j in 0..moons.len() {
				if i != j {
					let mut m = moons[i].borrow_mut();
					let n = moons[j].borrow();
					m.gravity(&n);
				}
			}
		}
		for m in &moons {
			m.borrow_mut().mv();
		}
		step += 1;
		let mut eq = true;
		for i in 0..moons.len() {
			if moons[i].borrow().pos[comp] != orig[i].borrow().pos[comp] {
				eq = false;
				break;
			}
			if moons[i].borrow().vel[comp] != 0 {
				eq = false;
				break;
			}
		}
		if eq {
			return step;
		}
	}
}

fn main() {
	let moons = vec![
		cell::RefCell::new(new_moon(-1, -4, 0)),
		cell::RefCell::new(new_moon(4, 7, -1)),
		cell::RefCell::new(new_moon(-14, -10, 9)),
		cell::RefCell::new(new_moon(1, 2, 17)),
	];
	// let moons = vec![
	// 	cell::RefCell::new(new_moon(-1, 0, 2)),
	// 	cell::RefCell::new(new_moon(2, -10, -7)),
	// 	cell::RefCell::new(new_moon(4, -8, 8)),
	// 	cell::RefCell::new(new_moon(3, 5, -1)),
	// ];
	println!("x: {}", run(moons.clone(), 0));
	println!("y: {}", run(moons.clone(), 1));
	println!("z: {}", run(moons.clone(), 2));
	// let orig = moons.clone();
	// let mut step = 0;
	// loop {
	// 	for i in 0..moons.len() {
	// 		for j in 0..moons.len() {
	// 			if i != j {
	// 				let mut m = moons[i].borrow_mut();
	// 				let n = moons[j].borrow();
	// 				m.gravity(&n);
	// 			}
	// 		}
	// 	}
	// 	for m in &moons {
	// 		m.borrow_mut().mv();
	// 	}
	// 	step += 1;
	// 	// if step % 10000 == 0 {
	// 	// 	println!("Step {}", step);
	// 	// 	for m in &moons {
	// 	// 		println!("{:?}", m.borrow());
	// 	// 	}
	// 	// 	// println!("Total energy: {}", moons.iter().fold(0, |v, m| v+m.borrow().energy()));
	// 	// }

	// 	if moons == orig {
	// 		println!("Ended equal on step {}", step);
	// 		break;
	// 	}
	// }
}
