use std::sync::mpsc;
use std::thread;

fn perms(k: usize, v: &mut Vec<i32>, res: &mut Vec<Vec<i32>>) -> () {
	if k == 1 {
		res.push(v.clone());
		return
	}
	perms(k-1, v, res);
	for i in 0..k-1 {
		if k % 2 == 0 {
			v.swap(i, k-1);
		} else {
			v.swap(0, k-1);
		}
		perms(k-1, v, res);
	}
}

fn permutations(mut v: Vec<i32>) -> Vec<Vec<i32>> {
	let mut res = Vec::new();
	perms(v.len(), &mut v, &mut res);
	return res;
}

fn run(mut prog: Vec<i32>, mut input: Vec<i32>, phase: i32) -> Vec<i32> {
	input.insert(0, phase);
	return intcode::run(&mut prog, &input);
}

fn main() {
	let prog = intcode::parse_from_std_io();
	let mut max = 0;
	let mut maxv = vec![];
	for perm in permutations(vec![5, 6, 7, 8, 9]) {
		let (out1, in2) = mpsc::channel();
		let (out2, in3) = mpsc::channel();
		let (out3, in4) = mpsc::channel();
		let (out4, in5) = mpsc::channel();
		let (out5, in1) = mpsc::channel();
		let (res_tx, res_rx) = mpsc::channel();
		out5.send(perm[0]).unwrap();
		out1.send(perm[1]).unwrap();
		out2.send(perm[2]).unwrap();
		out3.send(perm[3]).unwrap();
		out4.send(perm[4]).unwrap();
		out5.send(0).unwrap();
		let mut children = Vec::new();
		let mut p1 = prog.clone();
		children.push(thread::spawn(move || {
			intcode::run_chans(&mut p1, &in1, out1);
			res_tx.send(in1.recv().unwrap()).unwrap();
		}));
		let mut p2 = prog.clone();
		children.push(thread::spawn(move || {
			intcode::run_chans(&mut p2, &in2, out2);
		}));
		let mut p3 = prog.clone();
		children.push(thread::spawn(move || {
			intcode::run_chans(&mut p3, &in3, out3);
		}));
		let mut p4 = prog.clone();
		children.push(thread::spawn(move || {
			intcode::run_chans(&mut p4, &in4, out4);
		}));
		let mut p5 = prog.clone();
		children.push(thread::spawn(move || {
			intcode::run_chans(&mut p5, &in5, out5);
		}));
		let val = res_rx.recv().unwrap();
		if val > max {
			max = val;
			maxv = perm;
		}
	}
	println!("{:?} {:?}", max, maxv);
}
