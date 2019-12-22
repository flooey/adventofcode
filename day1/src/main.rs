use std::io;

fn fuel(x: i32) -> i32 {
	let f = x / 3 - 2;
	if f <= 0 {
		return 0
	}
	return f + fuel(f)
}

fn main() {
  let mut line = String::new();
  let mut total = 0;

  let stdin = io::stdin();
  loop {
  	line.clear();
  	let res = stdin.read_line(&mut line);
  	match res {
  		Err(_) => {
  			println!("Breaking");
  			break
  		},
  		Ok(count) => {
  			if count == 0 {
  				println!("Count is zero");
  				break
  			}
  			line.retain(|c| !c.is_whitespace());
  			match line.parse::<i32>() {
  				Err(_) => (),
  				Ok(num) => {
  					total = total + fuel(num);
  					println!("Total is {}", total);
  				}
  			}
  		}
  	}
  }
  println!("Total: {}", total)
}
