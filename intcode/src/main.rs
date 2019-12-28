fn main() {
  let mut v = intcode::parse_from_std_io();
  println!("{:?}", intcode::run(&mut v, &[13]));
}
