use std::thread;
use std::sync::mpsc;
use std::io::stdin;
use std::io::stdout;
use std::io::Read;
use std::io::Write;
use std::fs::File;
use std::collections::HashMap;
use termios::*;
use std::cmp::max;

enum Dir {
  UP,
  DOWN,
  LEFT,
  RIGHT,
}

fn mv(d: Dir, loc: &(i32, i32)) -> (i32, i32) {
  match d {
    Dir::UP => (loc.0, loc.1-1),
    Dir::LEFT => (loc.0-1, loc.1),
    Dir::DOWN => (loc.0, loc.1+1),
    Dir::RIGHT => (loc.0+1, loc.1),
  }
}

fn write_at(loc: &(i32, i32), c: char) -> () {
  print!("\x1B[{};{}H{}\x1B[50;0H", loc.1+1, loc.0+1, c);
  stdout().flush().unwrap();
}


// Can do this super quickly with
// cat /dev/random | LC_CTYPE=C tr -dc 'asdw' | cargo run
fn main() {
  let mut f = File::open("input.txt").unwrap();
  let mut data = String::new();
  f.read_to_string(&mut data).unwrap();
  let mut prog = intcode::parse(&data);

  // let mut termios = Termios::from_fd(0).unwrap();
  // termios.c_lflag &= !(ICANON | ECHO);
  // tcsetattr(0, TCSANOW, &termios).unwrap();

  let (in_tx, in_rx) = mpsc::channel();
  let (out_tx, out_rx) = mpsc::channel();

  print!("\x1B[2J");
  stdout().flush().unwrap();
  thread::spawn(move || {
    intcode::run_chans(&mut prog, &in_rx, out_tx);
  });
  let mut generator = (-1, -1);
  let mut distance = HashMap::new();
  let mut loc = (30, 25);
  write_at(&loc, 'D');

  let mut s = stdin();
  let mut buf: [u8; 1] = [0; 1];
  loop {
    print!("{}", distance.values().max().unwrap_or(&0));
    match s.read_exact(&mut buf) {
      Ok(_) => {
        let dir = match buf[0] as char {
          'a' => Dir::LEFT,
          's' => Dir::DOWN,
          'd' => Dir::RIGHT,
          'w' => Dir::UP,
          _ => continue,
        };
        in_tx.send(match dir {
          Dir::LEFT => 3,
          Dir::DOWN => 2,
          Dir::RIGHT => 4,
          Dir::UP => 1,
          _ => panic!(),
        }).unwrap();
        match out_rx.recv() {
          Ok(0) => {
            write_at(&mv(dir, &loc), '#');
          },
          Ok(1) => {
            let newloc = mv(dir, &loc);
            if generator != (-1, -1) {
              match distance.get(&newloc) {
                Some(d) => {
                  if distance.get(&loc).unwrap() + 1 < *d {
                    distance.insert(newloc.clone(), distance.get(&loc).unwrap() + 1);
                  }
                },
                None => {
                  distance.insert(newloc.clone(), distance.get(&loc).unwrap() + 1);
                }
              }
            }
            write_at(&loc, '.');
            loc = newloc;
            write_at(&loc, 'D');
          },
          Ok(2) => {
            loc = mv(dir, &loc);
            generator = loc.clone();
            distance.insert(generator.clone(), 0);
            write_at(&loc, '=');
          },
          Ok(_) => panic!(),
          Err(_) => {
            break;
          }
        }
      }
      Err(_) => {
        break;
      }
    }
  }
}
