use std::io::stdin;
use std::io::prelude::*;
use std::collections::HashMap;
use std::collections::HashSet;

enum Dir {
  UP,
  DOWN,
  LEFT,
  RIGHT,
}

#[derive(Debug, Copy, Clone, Hash, PartialEq, Eq)]
struct Loc {
  row: usize,
  col: usize,
}

#[derive(Debug, Clone, Hash, PartialEq, Eq)]
struct State {
  locs: [Loc; 4],
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

fn simple_mv(locations: &Vec<Vec<u8>>, loc: &Loc, d: &Dir) -> Option<Loc> {
  let (new_row, new_col) = match d {
    Dir::UP => (loc.row - 1, loc.col),
    Dir::DOWN => (loc.row + 1, loc.col),
    Dir::LEFT => (loc.row, loc.col - 1),
    Dir::RIGHT => (loc.row, loc.col+1),
  };
  let cell = locations[new_row][new_col];
  match cell {
    b'#' => None,
    b'.' | b'@' => {
      Some(Loc{row: new_row, col: new_col})
    },
    b'a'..=b'z' => {
      Some(Loc{row: new_row, col: new_col})
    },
    b'A'..=b'Z' => {
      Some(Loc{row: new_row, col: new_col})
    }
    _ => panic!(),
  }
}

fn visit(locations: &Vec<Vec<u8>>, l: &Loc, visited: &mut HashSet<Loc>, okay: &mut Vec<Vec<bool>>) {
  visited.insert(l.clone());
  let cell = locations[l.row][l.col];
  if b'a' <= cell && cell <= b'z' {
    for l in visited.iter() {
      okay[l.row][l.col] = true;
    }
  }
  for d in &[Dir::UP, Dir::DOWN, Dir::LEFT, Dir::RIGHT] {
    match simple_mv(locations, l, d) {
      None => {},
      Some(new_loc) => {
        if !visited.contains(&new_loc) {
          visit(locations, &new_loc, visited, okay);
        }
      }
    }
  }
  visited.remove(&l);
}

fn mv(locations: &Vec<Vec<u8>>, s: &State, d: &Dir, i: usize) -> Option<State> {
  let loc = &s.locs[i];
  let (new_row, new_col) = match d {
    Dir::UP => (loc.row - 1, loc.col),
    Dir::DOWN => (loc.row + 1, loc.col),
    Dir::LEFT => (loc.row, loc.col - 1),
    Dir::RIGHT => (loc.row, loc.col+1),
  };
  let cell = locations[new_row][new_col];
  match cell {
    b'#' => None,
    b'.' | b'@' => {
      let mut newlocs = s.locs.clone();
      newlocs[i] = Loc{row: new_row, col: new_col};
      Some(State{locs: newlocs, keys: s.keys})
    },
    b'a'..=b'z' => {
      let mut newlocs = s.locs.clone();
      newlocs[i] = Loc{row: new_row, col: new_col};
      Some(State{locs: newlocs, keys: s.keys_with(cell)})
    },
    b'A'..=b'Z' => {
      if s.has(cell + (b'a' - b'A')) {
        let mut newlocs = s.locs.clone();
        newlocs[i] = Loc{row: new_row, col: new_col};
        Some(State{locs: newlocs, keys: s.keys})
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
  let mut start_state = State{locs: [Loc{row: 0, col: 0}; 4], keys: 0};
  let mut biggest_key = b'a';
  let mut loc_i = 0;
  for i in 0..locations.len() {
    for j in 0..locations[i].len() {
      if locations[i][j] == b'@' {
        start_state.locs[loc_i] = Loc{row: i, col: j};
        loc_i += 1;
      } else if biggest_key <= locations[i][j] && locations[i][j] <= b'z' {
        biggest_key = locations[i][j];
      }
    }
  }
  let all_keys = (1 << (biggest_key - b'a' + 1)) - 1;
  if start_state.locs[3].row == 0 || start_state.locs[3].col == 0 {
    panic!();
  }
  // First, walk the map using all the keys and mark the portions that don't lead to any key
  let mut visited = HashSet::new();
  let mut okay = vec![vec![false; locations[0].len()]; locations.len()];
  let mut walk_start = start_state.clone();
  walk_start.keys = !0;
  for i in 0..4 {
    visit(&locations, &start_state.locs[i], &mut visited, &mut okay);
  }

  for r in 0..okay.len() {
    for c in 0..okay[r].len() {
      if !okay[r][c] {
        locations[r][c] = b'#';
      }
      print!("{}", locations[r][c] as char);
    }
    println!();
  }

  // Now, use the modified map to find the shortest path to all the keys
  let mut states = HashMap::new();
  let mut to_visit = Vec::new();
  states.insert(start_state.clone(), 0);
  to_visit.push(start_state);
  while !to_visit.is_empty() {
    let loc = to_visit.pop().unwrap();
    let steps = *states.get(&loc).unwrap();
    for d in &[Dir::UP, Dir::DOWN, Dir::LEFT, Dir::RIGHT] {
      for i in 0..4 {
        match mv(&locations, &loc, d, i) {
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
                if states.len() % 1000000 == 0 {
                  println!("States: {}", states.len());
                }
              }
            };
          },
          None => {},
        };
      }
    }
  }
  let best = states.iter().filter(|s| s.0.keys == all_keys).map(|s| s.1).min();
  println!("{:?}", best);
}
