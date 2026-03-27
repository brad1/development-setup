use std::collections::HashMap;
use std::env;
use std::thread;

fn main() {
    let args: Vec<String> = env::args().skip(1).collect();
    if args.is_empty() || args[0] == "--help" || args[0] == "-h" {
        print_help();
        return;
    }

    if args[0] == "--list" {
        println!("Available demos:");
        for demo in demos::all() {
            println!("  --{demo}");
        }
        return;
    }

    if let Some(flag) = args[0].strip_prefix("--") {
        match flag {
            "ownership" => demos::ownership::run(),
            "structs" => demos::structs_traits::run(),
            "enums" => demos::enums_match::run(),
            "iterators" => demos::iterators::run(),
            "generics" => demos::generics::run(),
            "collections" => demos::collections::run(),
            "error-handling" => demos::error_handling::run(),
            "closures" => demos::closures::run(),
            "threads" => demos::threads::run(),
            _ => {
                eprintln!("Unknown demo: --{flag}");
                print_help();
            }
        }
    } else {
        eprintln!("Expected a flag like --ownership");
        print_help();
    }
}

fn print_help() {
    println!(
        "rs-util: run demo snippets for Rust language features\n\
         Usage:\n\
           rustc rust/rs-util.rs -o rust/rs-util.rst\n\
           ./rust/rs-util.rst --name-of-a-demo\n\
           ./rust/rs-util.rst --list\n\
         Example:\n\
           ./rust/rs-util.rst --iterators"
    );
}

mod demos {
    pub fn all() -> [&'static str; 9] {
        [
            "ownership",
            "structs",
            "enums",
            "iterators",
            "generics",
            "collections",
            "error-handling",
            "closures",
            "threads",
        ]
    }

    pub mod ownership {
        pub fn run() {
            let greeting = String::from("hello");
            consume(greeting.clone());
            borrow(&greeting);
            println!("ownership demo finished with: {greeting}");
        }

        fn consume(value: String) {
            println!("consumed value: {value}");
        }

        fn borrow(value: &str) {
            println!("borrowed value: {value}");
        }
    }

    pub mod structs_traits {
        pub fn run() {
            let user = User {
                name: "Ari".to_string(),
                id: 7,
            };
            println!("{}", user.describe());
        }

        struct User {
            name: String,
            id: u32,
        }

        trait Describe {
            fn describe(&self) -> String;
        }

        impl Describe for User {
            fn describe(&self) -> String {
                format!("struct + trait demo: {} #{}", self.name, self.id)
            }
        }
    }

    pub mod enums_match {
        pub fn run() {
            let states = [
                ConnectionState::Disconnected,
                ConnectionState::Connecting,
                ConnectionState::Connected(120),
            ];

            for state in states {
                let msg = match state {
                    ConnectionState::Disconnected => "offline".to_string(),
                    ConnectionState::Connecting => "connecting".to_string(),
                    ConnectionState::Connected(ms) => format!("connected, latency={ms}ms"),
                };
                println!("enum + match demo: {msg}");
            }
        }

        enum ConnectionState {
            Disconnected,
            Connecting,
            Connected(u32),
        }
    }

    pub mod iterators {
        pub fn run() {
            let nums = vec![1, 2, 3, 4, 5, 6];
            let squares_of_evens: Vec<i32> = nums
                .into_iter()
                .filter(|n| n % 2 == 0)
                .map(|n| n * n)
                .collect();
            println!("iterator demo: {squares_of_evens:?}");
        }
    }

    pub mod generics {
        pub fn run() {
            println!("generic max demo: {}", max(11, 9));
            println!("generic max demo: {}", max('b', 'q'));
        }

        fn max<T: PartialOrd + Copy>(a: T, b: T) -> T {
            if a > b { a } else { b }
        }
    }

    pub mod collections {
        use super::super::HashMap;

        pub fn run() {
            let mut scores = HashMap::new();
            scores.insert("team-a", 10);
            scores.insert("team-b", 15);
            scores.entry("team-a").and_modify(|s| *s += 2);
            println!("hashmap demo: {scores:?}");
        }
    }

    pub mod error_handling {
        pub fn run() {
            for sample in ["42", "abc"] {
                match parse_positive(sample) {
                    Ok(v) => println!("parsed value: {v}"),
                    Err(e) => println!("error: {e}"),
                }
            }
        }

        fn parse_positive(input: &str) -> Result<u32, String> {
            let value: i32 = input
                .parse()
                .map_err(|_| format!("'{input}' is not a number"))?;

            if value < 0 {
                Err(format!("'{input}' must be positive"))
            } else {
                Ok(value as u32)
            }
        }
    }

    pub mod closures {
        pub fn run() {
            let base = 3;
            let multiply = |n: i32| n * base;
            println!("closure demo: {}", multiply(7));
        }
    }

    pub mod threads {
        use super::super::thread;

        pub fn run() {
            let handle = thread::spawn(|| {
                let mut sum = 0;
                for n in 1..=5 {
                    sum += n;
                }
                sum
            });

            match handle.join() {
                Ok(total) => println!("thread demo total: {total}"),
                Err(_) => println!("thread demo failed"),
            }
        }
    }
}
