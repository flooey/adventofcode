use std::io;
use std::io::BufRead;
use std::collections::HashMap;

#[derive(Debug, Clone, PartialEq, Eq, Hash)]
struct Quantity {
  amt: i64,
  name: String,
}

impl Quantity {
  fn mul(&self, n: i64) -> Quantity {
    return Quantity{amt: self.amt * n, name: self.name.clone()}
  }
}

fn parse_quant(s: &str) -> Quantity {
  let segments: Vec<String> = s.split(" ").map(String::from).collect();
  let amt: i64 = segments[0].parse().unwrap();
  return Quantity{amt, name: segments[1].clone()};
}

fn make(productions: &HashMap<Quantity, Vec<Quantity>>, types: &HashMap<String, Quantity>, inv: &mut HashMap<String, i64>, q: &Quantity) -> i64 {
  // println!("Trying to make {:?}, inv is {:?}", q, inv);
  if q.name == "ORE" {
    return q.amt;
  }
  let needed = q.amt - inv.get(&q.name).unwrap_or(&0);
  if needed < 0 {
    inv.insert(q.name.clone(), *inv.get(&q.name).unwrap() - q.amt);
    return 0;
  }
  let unit = types.get(&q.name).unwrap();
  let mult = ((needed as f64) / (unit.amt as f64)).ceil() as i64;
  let overmake = mult * unit.amt - needed;
  if overmake > 0 {
    inv.insert(q.name.clone(), overmake);
  } else {
    inv.remove(&q.name);
  }
  let mut tot: i64 = 0;
  for p in productions.get(unit).unwrap() {
    tot += make(productions, types, inv, &p.mul(mult));
  }
  return tot;
}

fn main() {
  let mut productions = HashMap::new();
  let mut types = HashMap::new();
  for line in io::stdin().lock().lines() {
    let line = line.unwrap();
    let sections: Vec<&str> = line.split(" => ").collect();
    let result = parse_quant(sections[1]);
    types.insert(result.name.clone(), result.clone());
    let mut comps = Vec::new();
    for comp in sections[0].split(", ") {
      comps.push(parse_quant(comp));
    }
    productions.insert(result, comps);
  }
  // println!("{:?}", make(&productions, &types, &mut HashMap::new(), &Quantity{amt: 1, name: "FUEL".to_string()}));
  for i in 1670000..1678000 {
    let amt = make(&productions, &types, &mut HashMap::new(), &Quantity{amt: i, name: "FUEL".to_string()});
    println!("{:?}: {:?}", i, amt);
    if amt > 1000000000000 {
      println!("{:?}", i-1);
      break;
    }
  }
}
