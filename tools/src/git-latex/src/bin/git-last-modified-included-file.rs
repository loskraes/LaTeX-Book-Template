use std::str;
use std::{env, path::Path, process::Command};

use chrono::{DateTime, Local};

fn main() {
    let path = env::args().nth(1).unwrap_or_else(|| {
        let output = Command::new("git")
            .args(["rev-parse", "--show-toplevel"])
            .output()
            .expect("Can't be run git");
        if !output.stderr.is_empty() || !output.status.success() {
            let err = String::from_utf8(output.stderr).unwrap();
            panic!("{err}");
        }
        str::from_utf8(&output.stdout).unwrap().trim().to_string()
    });

    let output = Command::new("git")
        .arg("ls-files")
        .arg("--exclude-standard")
        .arg(path)
        .output()
        .expect("Cant be run git");
    if !output.stderr.is_empty() || !output.status.success() {
        let err = String::from_utf8(output.stderr).unwrap();
        panic!("{err}");
    }
    let files = String::from_utf8(output.stdout).unwrap();
    let last_mod = files
        .lines()
        .map(Path::new)
        .map(Path::metadata)
        .map(Result::unwrap)
        .map(|m| m.modified())
        .map(Result::unwrap)
        .max()
        .unwrap();
    let last_mod = DateTime::<Local>::from(last_mod);
    print!("{}", last_mod.format("%FT%T%:z"));
}
