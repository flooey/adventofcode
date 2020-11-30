use std::io;
use std::io::BufRead;

fn blocks(blocker: &(i32, i32), blockee: &(i32, i32)) -> bool {
  if blocker.0 == 0 {
    if blockee.0 != 0 {
      return false;
    }
    return blockee.1.abs() > blocker.1.abs() && blockee.1.signum() == blocker.1.signum();
  } else if blocker.1 == 0 {
    if blockee.1 != 0 {
      return false;
    }
    return blockee.0.abs() > blocker.0.abs() && blockee.0.signum() == blocker.0.signum();
  } else {
    return blockee.0 as f64 / blocker.0 as f64 == blockee.1 as f64 / blocker.1 as f64
        && blockee.0 as f64 / blocker.0 as f64 > 1.0;
  }
}

fn main() {
  let mut x: i32;
  let mut y: i32 = 0;
  let mut asteroids = Vec::new();
  for line in io::stdin().lock().lines() {
    let line = line.unwrap();
    x = 0;
    for c in line.chars() {
      if c == '#' || c == 'X' {
        asteroids.push((x, y));
      }
      x += 1;
    }
    y += 1;
  }
  let mut maxcount = 0;
  let mut maxloc = &(0, 0);
  let mut with_angle = Vec::new();
  for a in &asteroids {
    if a != &(14, 17) {
      continue;
    }
    let mut count = 0;
    for b in &asteroids {
      if b == a {
        continue;
      }
      let mut blocked = false;
      let b_re = (b.0 - a.0, b.1 - a.1);
      for c in &asteroids {
        if c == a || c == b {
          continue;
        }
        let c_re = (c.0 - a.0, c.1 - a.1);
        if blocks(&c_re, &b_re) {
          blocked = true;
          break;
        }
      }
      if !blocked {
        count += 1;
        let mut val = (b_re.1 as f64 / b_re.0 as f64).atan();
        if b_re.0 < 0 {
          val += 4.0;
        }
        with_angle.push((b, val));
      }
    }
    if count > maxcount {
      maxcount = count;
      maxloc = a;
    }
  }
  with_angle.sort_by(|a, b| a.1.partial_cmp(&b.1).unwrap());
  let mut i = 1;
  for x in &with_angle {
    println!("{:?}: {:?}", i, x);
    i += 1;
  }
  println!("{:?}", with_angle[199]);
  println!("{:?} {:?}", maxcount, maxloc);
}
