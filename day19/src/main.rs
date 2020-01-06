use std::io::Read;
use std::fs::File;

fn lit(prog: &Vec<i64>, x: i64, y: i64) -> bool {
  let out = intcode::run(&mut prog.clone(), &[x, y]);
  return out[0] == 1;
}

fn main() {
  let mut f = File::open("input.txt").unwrap();
  let mut data = String::new();
  f.read_to_string(&mut data).unwrap();
  let prog = intcode::parse(&data);

  let mut x = 100;
  let mut y = 110;
  if !lit(&prog, x, y) {
    println!("Didn't start lit");
    return;
  }
  loop {
    while lit(&prog, x, y) {
      y += 1;
    }
    if lit(&prog, x + 99, y - 100) {
      while lit(&prog, x + 99, y - 101) {
        y -= 1;
      }
      println!("X: {}, y: {}", x, y - 100);
      return;
    }
    x += 1;
  }
}
