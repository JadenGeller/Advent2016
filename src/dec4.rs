use std::fs::File;
use std::io::{BufRead, BufReader};
use std::str::FromStr;
use std::error::Error;
use std::fmt;
use std::process::exit;
use std::collections::HashMap;
use std::cmp::Ordering;

#[allow(dead_code)]
struct Room {
    name: String,
    id: i32,
}

#[derive(Debug)]
enum ParseRoomError {
    InvalidFormat,
    IncorrectChecksum,
}

impl fmt::Display for ParseRoomError {
    fn fmt(&self, fmt: &mut fmt::Formatter) -> fmt::Result {
        fmt.write_str(self.description())
    }
}

impl Error for ParseRoomError {
    fn description(&self) -> &str {
        match self {
            &ParseRoomError::InvalidFormat     => "invalid room identifier format",
            &ParseRoomError::IncorrectChecksum => "room identifier checksum doesn't match",
        }
    }
}

impl FromStr for Room {
    type Err = ParseRoomError;
    fn from_str(x: &str) -> Result<Room, ParseRoomError> {
        let (head, checksum) = x.split_at(x.find('[').ok_or(ParseRoomError::InvalidFormat)?);
        
        let end = checksum.len();        
        if checksum.chars().nth(0) != Some('[') || checksum.chars().nth(end - 1) != Some(']') { 
            Err(ParseRoomError::InvalidFormat)? 
        };
        let checksum = checksum[1..end - 1].to_string();
                
        let mut components = head.split('-');
        let id = components.next_back().ok_or(ParseRoomError::InvalidFormat)?
                           .parse::<i32>().map_err(|_| { ParseRoomError::InvalidFormat })?;
        
        let mut name: Vec<String> = vec![];
        let mut freqs: HashMap<char, u32> = HashMap::new();
        for comp in components {
            for letter in comp.chars().by_ref() {
                if !letter.is_alphabetic() || !letter.is_lowercase() { Err(ParseRoomError::InvalidFormat)? };
                let new_value = freqs.get(&letter).map(|c| *c).unwrap_or(0) + 1;
                freqs.insert(letter, new_value);
            };
            name.push(comp.to_string());
        };
        
        let mut freqs = freqs.iter().collect::<Vec<_>>();
        freqs.sort_by(|&(l1, c1), &(l2, c2)| {
            let count_ordering = c1.cmp(c2).reverse();
            match count_ordering {
                Ordering::Equal => l1.cmp(l2),
                _               => count_ordering,
            }
        });
        let expected_checksum = freqs[0..5].iter().map(|x| *x.0).collect::<String>();
        if expected_checksum != checksum { Err(ParseRoomError::IncorrectChecksum)? };
        
        let name = name.iter()
                       .map(|comp| comp.chars().map(|letter| rotate(letter, id)).collect::<String>())
                       .collect::<Vec<_>>()
                       .join(" ");
        
        Ok(Room {
            name: name,
            id: id,
        })
    }
}

fn rotate(c: char, n: i32) -> char {
    assert!(c.is_alphabetic() && c.is_lowercase());
    let mut index = ((c as u8) - ('a' as u8)) as i32;
    index += n;
    index %= (('z' as u8) - ('a' as u8)) as i32 + 1;
    (index + ('a' as i32)) as u8 as char
}

fn main() {
    let file = File::open("input.txt").unwrap();
    let file = BufReader::new(file);
    let _ = Room::from_str("aaaaa-bbb-z-y-x-123[abxyz]");
    let rooms = file.lines()
                    .map(|s| Room::from_str(&s.unwrap()));
    
    let mut sum = 0;
    for room in rooms {
        match room {
            Ok(room) => {
                sum += room.id;
                if room.name == "northpole object storage" {
                    println!("The North Pole objects are stored in room #{}.", room.id);
                }
            }
            Err(ParseRoomError::IncorrectChecksum) => (),
            Err(error) => {
                println!("{}", error);
                exit(-1)
            },
        }
    };
    println!("The sum of valid ids is {}.", sum)
}