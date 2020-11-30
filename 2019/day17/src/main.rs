use std::io::stdin;
use std::io::stdout;
use std::io::Read;
use std::io::Write;
use std::fs::File;

fn interp(s: String) -> Vec<i64> {
  let mut res = Vec::new();
  for c in s.chars() {
    res.push(c as i64);
  }
  return res;
}

fn main() {
  let mut f = File::open("input.txt").unwrap();
  let mut data = String::new();
  f.read_to_string(&mut data).unwrap();
  let mut prog = intcode::parse(&data);
  prog[0] = 2;

  let out = intcode::run(&mut prog, &interp("A,B,A,C,A,C,B,C,C,B\nL,4,L,4,L,10,R,4\nR,4,L,4,L,4,R,8,R,10\nR,4,L,10,R,10\nn\n".to_string()));

  print!("\x1B[2J");
  stdout().flush().unwrap();
  // let out = intcode::run(&mut prog, &[]);
  // let mut rlen = 0;
  // let mut tot = 0;
  // for i in 0..out.len() {
  //   if rlen == 0 && out[i] == 10 {
  //     rlen = i+1;
  //   }
  //   if rlen == 0 {
  //     continue;
  //   }
  //   if i > out.len() - rlen {
  //     break;
  //   }
  //   if out[i] == '#' as i64 {
  //     if out[i+1] == '#' as i64
  //         && out[i-1] == '#' as i64
  //         && out[i+rlen] == '#' as i64
  //         && out[i-rlen] == '#' as i64 {
  //       tot += (i % rlen) * (i / rlen);
  //     }
  //   }
  // }
  for i in out.iter().take(out.len() - 1) {
    print!("{}", *i as u8 as char);
  }
  println!("{:?}", out[out.len()-1]);
}
