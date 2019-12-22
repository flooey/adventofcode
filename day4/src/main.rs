fn digit(n: i32, i: u32) -> i32 {
	(n / 10_i32.pow(i)) % 10
}

fn good(n: i32) -> bool {
	let mut prev = 10;
	let mut equal = false;
	let mut currun = 1;
	for i in 0..6 {
		let d = digit(n, i);
		if d > prev {
			prev = -1;
			break
		} else if d == prev {
			currun += 1;
		} else {
			if currun == 2 {
				equal = true;
			}
			currun = 1;
		}
		prev = d;
	}
	if currun == 2 {
		equal = true;
	}
	return prev > -1 && equal;
}

fn main() {
	let mut count = 0;
	for n in 152085..=670283 {
		if good(n) {
			// println!("good: {}", n);
			count += 1;
		} else {
			// println!("bad: {}", n);
		}
	}
	println!("{:?}", count);
}
