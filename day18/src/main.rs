use std::io::stdin;
use std::io::prelude::*;
use std::collections::HashMap;

enum Dir {
  UP,
  DOWN,
  LEFT,
  RIGHT,
}

#[derive(Debug, Clone, Hash, PartialEq, Eq)]
struct State {
  row: usize,
  col: usize,
  keys: u32,
}

impl State {
  fn has(&self, c: u8) -> bool {
    (self.keys & (1 << (c - 'a' as u8))) != 0
  }
  fn keys_with(&self, c: u8) -> u32 {
    self.keys | (1 << (c - 'a' as u8))
  }
}

fn mv(locations: &Vec<Vec<u8>>, s: &State, d: &Dir) -> Option<State> {
  let (new_row, new_col) = match d {
    Dir::UP => {
      if s.row == 0 {
        return None
      } else {
        (s.row - 1, s.col)
      }
    },
    Dir::DOWN => {
      if s.row == locations.len() - 1 {
        return None
      } else {
        (s.row + 1, s.col)
      }
    },
    Dir::LEFT => {
      if s.col == 0 {
        return None
      } else {
        (s.row, s.col - 1)
      }
    },
    Dir::RIGHT => {
      if s.col == locations[0].len() - 1 {
        return None
      } else {
        (s.row, s.col+1)
      }
    },
  };
  let cell = locations[new_row][new_col];
  match cell {
    b'#' => None,
    b'.' | b'@' => Some(State{row: new_row, col: new_col, keys: s.keys}),
    b'a'..=b'z' => Some(State{row: new_row, col: new_col, keys: s.keys_with(cell)}),
    b'A'..=b'Z' => {
      if s.has(cell + (b'a' - b'A')) {
        Some(State{row: new_row, col: new_col, keys: s.keys})
      } else {
        None
      }
    }
    _ => panic!(),
  }
}

fn main() {
  let mut locations = Vec::new();
  for l in stdin().lock().lines() {
    let mut row = Vec::new();
    for c in l.unwrap().chars() {
      row.push(c as u8);
    }
    locations.push(row);
  }
  let mut start_state = State{row: 0, col: 0, keys: 0};
  let mut biggest_key = b'a';
  for i in 0..locations.len() {
    for j in 0..locations[i].len() {
      if locations[i][j] == b'@' {
        start_state.row = i;
        start_state.col = j;
      } else if biggest_key <= locations[i][j] && locations[i][j] <= b'z' {
        biggest_key = locations[i][j];
      }
    }
  }
  let all_keys = (1 << (biggest_key - b'a' + 1)) - 1;
  if start_state.row == 0 || start_state.col == 0 {
    panic!();
  }
  let mut states = HashMap::new();
  let mut to_visit = Vec::new();
  states.insert(start_state.clone(), 0);
  to_visit.push(start_state);
  while !to_visit.is_empty() {
    let loc = to_visit.pop().unwrap();
    let steps = *states.get(&loc).unwrap();
    for d in &[Dir::UP, Dir::DOWN, Dir::LEFT, Dir::RIGHT] {
      match mv(&locations, &loc, d) {
        Some(new_state) => {
          match states.get(&new_state) {
            Some(steps2) => {
              if *steps2 > steps + 1 {
                if new_state.keys != all_keys {
                  to_visit.push(new_state.clone());
                }
                states.insert(new_state, steps+1);
              }
            }
            None => {
              if new_state.keys != all_keys {
                to_visit.push(new_state.clone());
              }
              states.insert(new_state, steps+1);
              if states.len() % 1000 == 0 {
                println!("States: {}", states.len());
              }
            }
          };
        },
        None => {},
      };
    }
  }
  let best = states.iter().filter(|s| s.0.keys == all_keys).map(|s| s.1).min();
  println!("{:?}", best);
}
