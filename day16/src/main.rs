use std::io::stdin;
use std::io::Read;

fn main() {
  let mut data = String::new();
  stdin().lock().read_to_string(&mut data).unwrap();
  let mut l: Vec<i64> = data.trim().chars().map(|c| c as i64 - '0' as i64).collect();
  for phase in 1..=100 {
    let mut newlist = Vec::new();
    for i in 0..l.len() {
      let pat = [0].iter().cycle().take(i+1)
          .chain([1].iter().cycle().take(i+1))
          .chain([0].iter().cycle().take(i+1))
          .chain([-1].iter().cycle().take(i+1))
          .cycle().skip(1);
      let val: i64 = pat.zip(l.iter()).map(|x| x.0 * x.1).sum();
      newlist.push((val % 10).abs());
    }
    println!("Phase {}: {:?}", phase, newlist);
    l = newlist;
  }
}
