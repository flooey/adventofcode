use std::io::stdin;
use std::io::Read;
use std::convert::TryInto;

fn calc(l: &Vec<i64>, i: usize) -> i64 {
  let mut tot = 0;
  for j in i..l.len() {
    tot += l[j];
  }
  return (tot % 10).abs();
}

fn main() {
  let mut data = String::new();
  stdin().lock().read_to_string(&mut data).unwrap();
  let mut l: Vec<i64> = data.trim().chars().map(|c| c as i64 - '0' as i64).collect();
  let size = l.len();
  println!("Read input");
  l = l.iter().cycle().take(size * 10000).cloned().collect();
  println!("Extended input");
  let skips: usize = (l[0] * 1000000 + l[1] * 100000 + l[2] * 10000 + l[3] * 1000 + l[4] * 100 + l[5] * 10 + l[6]).try_into().unwrap();
  println!("Len is {}, skips is {}", l.len(), skips);
  for phase in 1..=100 {
    let mut newlist: Vec<i64> = [0].iter().cycle().take(skips).cloned().collect();
    let mut sum: i64 = l.iter().skip(skips).sum();
    for i in skips..l.len() {
      newlist.push((sum % 10).abs());
      sum -= l[i];
      if i % 1000 == 0 {
        println!("i: {}", i);
      }
    }
    println!("Phase {}", phase);
    l = newlist;
  }
  println!("{:?}", &l[skips..skips+8]);
}
