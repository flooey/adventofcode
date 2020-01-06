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

  let mut tot = 0;
  for x in 0..50 {
    for y in 0..50 {
      let l = lit(&prog, x, y);
      tot += if l { 1 } else { 0 };
      if l {
        print!("#");
      } else {
        print!(".");
      }
    }
    println!();
  }
  println!("Total: {}", tot);
}
