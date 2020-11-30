use std::sync::mpsc::{Sender, Receiver};
use std::sync::mpsc;
use std::io;
use std::convert::TryInto;

const DEBUG: bool = false;

fn digit(n: i64, i: usize) -> i64 {
  (n / 10_i64.pow(i.try_into().unwrap())) % 10
}

fn ensure(mem: &mut Vec<i64>, i: usize) -> () {
  if mem.len() <= i {
    mem.resize(i+1, 0);
  }
}

trait VecExt {
  fn val(&mut self, i: usize) -> i64;
  fn set(&mut self, i: usize, v: i64) -> ();
}

impl VecExt for Vec<i64> {
  fn val(&mut self, i: usize) -> i64 {
    ensure(self, i);
    return self[i];
  }
  fn set(&mut self, i: usize, v: i64) -> () {
    ensure(self, i);
    self[i] = v;
  }
}

fn refindex(mem: &mut Vec<i64>, pc: usize, sp: i64, i: usize) -> usize {
  match digit(mem[pc], i+1) {
    0 => mem[pc+i] as usize,
    1 => pc+i,
    2 => (sp as i64 + mem[pc+i]) as usize,
    _ => panic!(),
  }
}

fn calcref(mem: &mut Vec<i64>, pc: usize, sp: i64, i: usize) -> i64 {
  let index = refindex(mem, pc, sp, i);
  return mem.val(index);
}

pub fn run_chans(mem: &mut Vec<i64>, input: &Receiver<i64>, output: Sender<i64>) -> () {
  if DEBUG {
    println!("{:?}", mem);
  }
  let mut pc = 0;
  let mut sp = 0;
  loop {
    match mem[pc] % 100 {
      1 => {
        let op1 = calcref(mem, pc, sp, 1);
        let op2 = calcref(mem, pc, sp, 2);
        let dest = refindex(mem, pc, sp, 3);
        mem.set(dest, op1 + op2);
        pc += 4;
      }
      2 => {
        let op1 = calcref(mem, pc, sp, 1);
        let op2 = calcref(mem, pc, sp, 2);
        let dest = refindex(mem, pc, sp, 3);
        mem.set(dest, op1 * op2);
        pc += 4;
      }
      3 => {
        let dest = refindex(mem, pc, sp, 1) as usize;
        mem.set(dest, input.recv().unwrap());
        pc += 2;
      }
      4 => {
        output.send(calcref(mem, pc, sp, 1)).unwrap();
        pc += 2;
      }
      5 => {
        if calcref(mem, pc, sp, 1) != 0 {
          pc = calcref(mem, pc, sp, 2) as usize;
        } else {
          pc += 3;
        }
      }
      6 => {
        if calcref(mem, pc, sp, 1) == 0 {
          pc = calcref(mem, pc, sp, 2) as usize;
        } else {
          pc += 3;
        }
      }
      7 => {
        let dest = refindex(mem, pc, sp, 3);
        if calcref(mem, pc, sp, 1) < calcref(mem, pc, sp, 2) {
          mem.set(dest, 1);
        } else {
          mem.set(dest, 0);
        }
        pc += 4;
      }
      8 => {
        let dest = refindex(mem, pc, sp, 3);
        if calcref(mem, pc, sp, 1) == calcref(mem, pc, sp, 2) {
          mem.set(dest, 1);
        } else {
          mem.set(dest, 0);
        }
        pc += 4;
      }
      9 => {
        sp += calcref(mem, pc, sp, 1);
        pc += 2;
      }
      99 => {
        drop(output);
        break
      }
      _ => panic!()
    }
    if DEBUG {
      println!("pc: {:?}, sp: {:?}, mem: {:?}", pc, sp, mem);
    }
  }
}

pub fn run(mem: &mut Vec<i64>, input: &[i64]) -> Vec<i64> {
  let (in_tx, in_rx) = mpsc::channel();
  let (out_tx, out_rx) = mpsc::channel();
  for i in input {
    in_tx.send(*i).unwrap();
  }
  drop(in_tx);
  run_chans(mem, &in_rx, out_tx);
  let mut output = Vec::new();
  for o in out_rx {
    output.push(o);
  }
  return output;
}

pub fn parse(s: &str) -> Vec<i64> {
  let r = s.trim();
  return r.split(",").map(|val| val.parse::<i64>().unwrap()).collect();
}

pub fn parse_from_std_io() -> Vec<i64> {
  let mut line = String::new();

  let stdin = io::stdin();
  stdin.read_line(&mut line).unwrap();
  return parse(&line);
}

#[cfg(test)]
mod tests {
  use crate::run;

  #[test]
  fn ex_5_1() {
    let mut v = vec![1002,4,3,4,33];
    run(&mut v, &[]);
    assert_eq!(v[4], 99);
  }

  #[test]
  fn ex_5_2() {
    let mut v = vec![1101,100,-1,4,0];
    run(&mut v, &[]);
    assert_eq!(v[4], 99);
  }

  #[test]
  fn ex_5_3() {
    let mut v = vec![3,0,4,0,99];
    let out = run(&mut v, &[78]);
    assert_eq!(out, [78]);
  }

  #[test]
  fn ex_5_4() {
    let mut v = vec![3,9,8,9,10,9,4,9,99,-1,8];
    let out = run(&mut v, &[8]);
    assert_eq!(out, [1]);
  }

  #[test]
  fn ex_5_5() {
    let mut v = vec![3,9,8,9,10,9,4,9,99,-1,8];
    let out = run(&mut v, &[7]);
    assert_eq!(out, [0]);
  }

  #[test]
  fn ex_5_6() {
    let mut v = vec![3,9,7,9,10,9,4,9,99,-1,8];
    let out = run(&mut v, &[7]);
    assert_eq!(out, [1]);
  }

  #[test]
  fn ex_5_7() {
    let mut v = vec![3,9,7,9,10,9,4,9,99,-1,8];
    let out = run(&mut v, &[8]);
    assert_eq!(out, [0]);
  }

  #[test]
  fn ex_5_8() {
    let mut v = vec![3,9,7,9,10,9,4,9,99,-1,8];
    let out = run(&mut v, &[9]);
    assert_eq!(out, [0]);
  }

  #[test]
  fn ex_5_9() {
    let mut v = vec![3,3,1108,-1,8,3,4,3,99];
    let out = run(&mut v, &[8]);
    assert_eq!(out, [1]);
  }

  #[test]
  fn ex_5_10() {
    let mut v = vec![3,3,1108,-1,8,3,4,3,99];
    let out = run(&mut v, &[7]);
    assert_eq!(out, [0]);
  }

  #[test]
  fn ex_5_11() {
    let mut v = vec![3,3,1108,-1,8,3,4,3,99];
    let out = run(&mut v, &[9]);
    assert_eq!(out, [0]);
  }

  #[test]
  fn ex_5_12() {
    let mut v = vec![3,3,1107,-1,8,3,4,3,99];
    let out = run(&mut v, &[7]);
    assert_eq!(out, [1]);
  }

  #[test]
  fn ex_5_13() {
    let mut v = vec![3,3,1107,-1,8,3,4,3,99];
    let out = run(&mut v, &[8]);
    assert_eq!(out, [0]);
  }

  #[test]
  fn ex_5_14() {
    let mut v = vec![3,3,1107,-1,8,3,4,3,99];
    let out = run(&mut v, &[9]);
    assert_eq!(out, [0]);
  }

  #[test]
  fn ex_5_15() {
    let mut v = vec![3,12,6,12,15,1,13,14,13,4,13,99,-1,0,1,9];
    let out = run(&mut v, &[0]);
    assert_eq!(out, [0]);
  }

  #[test]
  fn ex_5_16() {
    let mut v = vec![3,12,6,12,15,1,13,14,13,4,13,99,-1,0,1,9];
    let out = run(&mut v, &[5]);
    assert_eq!(out, [1]);
  }

  #[test]
  fn ex_5_17() {
    let mut v = vec![3,3,1105,-1,9,1101,0,0,12,4,12,99,1];
    let out = run(&mut v, &[0]);
    assert_eq!(out, [0]);
  }

  #[test]
  fn ex_5_18() {
    let mut v = vec![3,3,1105,-1,9,1101,0,0,12,4,12,99,1];
    let out = run(&mut v, &[5]);
    assert_eq!(out, [1]);
  }

  #[test]
  fn ex_5_19() {
    let mut v = vec![3,21,1008,21,8,20,1005,20,22,107,8,21,20,1006,20,31,
        1106,0,36,98,0,0,1002,21,125,20,4,20,1105,1,46,104,
        999,1105,1,46,1101,1000,1,20,4,20,1105,1,46,98,99];
    let out = run(&mut v, &[1]);
    assert_eq!(out, [999]);
  }

  #[test]
  fn ex_5_20() {
    let mut v = vec![3,21,1008,21,8,20,1005,20,22,107,8,21,20,1006,20,31,
        1106,0,36,98,0,0,1002,21,125,20,4,20,1105,1,46,104,
        999,1105,1,46,1101,1000,1,20,4,20,1105,1,46,98,99];
    let out = run(&mut v, &[8]);
    assert_eq!(out, [1000]);
  }

  #[test]
  fn ex_5_21() {
    let mut v = vec![3,21,1008,21,8,20,1005,20,22,107,8,21,20,1006,20,31,
        1106,0,36,98,0,0,1002,21,125,20,4,20,1105,1,46,104,
        999,1105,1,46,1101,1000,1,20,4,20,1105,1,46,98,99];
    let out = run(&mut v, &[63]);
    assert_eq!(out, [1001]);
  }

  #[test]
  fn ex_9_1() {
    let mut v = vec![109,1,204,-1,1001,100,1,100,1008,100,16,101,1006,101,0,99];
    let out = run(&mut v, &[]);
    assert_eq!(out, [109,1,204,-1,1001,100,1,100,1008,100,16,101,1006,101,0,99]);
  }

  #[test]
  fn ex_9_2() {
    let mut v = vec![1102,34915192,34915192,7,4,7,99,0];
    let out = run(&mut v, &[]);
    assert_eq!(out, [1219070632396864]);
  }

  #[test]
  fn ex_9_3() {
    let mut v = vec![104,1125899906842624,99];
    let out = run(&mut v, &[]);
    assert_eq!(out, [1125899906842624]);
  }
}
