use core::panic;
use core::str;
use regex::Captures;
use regex::Regex;
use std::collections::HashMap;
use std::process::Command;
use wildcard_ex::ex::Pattern;

use chrono::DateTime;
use chrono::Datelike;
use chrono::Timelike;

const FIELD_SEP: &str = "\x1b\x1f";
//const FIELD_SEP: &str = "§";
const KEYS_GIT: [&str; 14] = [
    "%H",
    "%h",
    "%aN",
    "%aE",
    "%aI",
    "%(describe:tags=true,match=v[0-9]*)",
    "%D",
    "%s",
    "%b%-",
    "%G?",
    "%GS",
    "%GK",
    "%GF",
    "%GP",
    //"%(trailers)",
];

fn main() {
    let tag_format = "v[0-9]*";
    let tag_match = Pattern::new(tag_format);

    let regex_fixes = Regex::new(
        r#"(?:[cC]lose[sd]|[fF]ix(?:e[sd]?)|[rR]esolve[sd]?)[ \t]+(?<repo>(?:[A-Za-z0-9_\.-]+/)?[A-Za-z0-9_\.-]+)?#(?<id>[0-9]+)"#,
    ).unwrap();

    let format = KEYS_GIT.join(FIELD_SEP);
    let output = Command::new("git")
        .arg("log")
        .arg("--reverse")
        .arg(format!("--pretty=format:{format}{FIELD_SEP}"))
        .arg("-z")
        .arg("--shortstat")
        .output()
        .expect("Can be run git");
    eprintln!("git log --reverse --pretty=format:{format}");
    if !output.stderr.is_empty() || !output.status.success() {
        let err = String::from_utf8(output.stderr).unwrap();
        panic!("{err}");
    }
    //println!("\\begin{{gitlog}}%");
    println!("%");
    let mut first_entry = true;
    for (i, entry) in output.stdout.split(|&c| c == 0).enumerate() {
        let s = str::from_utf8(entry).unwrap();
        let s = s.split(FIELD_SEP).collect::<Vec<_>>();
        assert_eq!(s.len(), KEYS_GIT.len() + 1);
        let (stat_files, stat_line_added, stat_line_del) = {
            let l = s[KEYS_GIT.len()].trim();
            let data: HashMap<&str, u64> = l
                .trim()
                .split(", ")
                .map(|s| s.split_once(char::is_whitespace).unwrap())
                .map(|(v, k)| (k, v.parse().unwrap()))
                .collect();
            (
                data.get("files changed").copied().unwrap_or_default(),
                data.get("insertions(+)").copied().unwrap_or_default(),
                data.get("deletions(-)").copied().unwrap_or_default(),
            )
        };
        let hash_long = s[0];
        let hash = s[1];
        let version_tags = s[6]
            .split(", ")
            .filter_map(|s| s.strip_prefix("tag: "))
            .filter(|t| tag_match.clone().is_match(t))
            .collect::<Vec<_>>();
        let notversion_tags = s[6]
            .split(", ")
            .filter_map(|s| s.strip_prefix("tag: "))
            .filter(|t| !tag_match.clone().is_match(t))
            .collect::<Vec<_>>();
        let author_name = s[2];
        let author_mail = s[3];
        let dt = DateTime::parse_from_rfc3339(s[4]).unwrap();
        let title = s[7];
        let description = s[8];
        let description = regex_fixes.replace(description, |cap: &Captures| {
            let id = &cap["id"];
            if let Some(repo) = cap.name("repo") {
                let repo = repo.as_str();
                format!("\\gitlogFixes[{repo}]{{{id}}}")
            } else {
                format!("\\gitlogFixes{{{id}}}")
            }
        });
        let modified_files = 0;
        let added_lines = 0;
        let deleted_lines = 0;
        let sign_status_code = s[9];
        let sign_status = match sign_status_code {
            "G" => "Good",
            "B" => "Bad",
            "U" => "Good with unknown validity",
            "X" => "Good but expired",
            "Y" => "Good but mad by expired key",
            "R" => "Good by a revokes key",
            "E" => "Cannot by checked",
            _ => panic!("Can be parse"),
        };
        let sign_author = s[10];
        let (sign_authorname, sign_authormail) =
            if sign_author.ends_with('>') && sign_author.contains('<') {
                let (name, mail) = sign_author
                    .strip_suffix('>')
                    .unwrap()
                    .split_once('<')
                    .unwrap();
                (name.trim(), mail.trim())
            } else if sign_author.contains('@') {
                ("", sign_author.trim())
            } else {
                (sign_author.trim(), "")
            };
        let sign_key = s[11];
        let sign_key_fingerprint = s[12];
        let sign_primary_key = s[13];
        eprintln!();
        dbg!(
            hash_long,
            hash,
            &version_tags,
            author_name,
            author_mail,
            dt,
            title,
            &description,
            sign_status_code,
            sign_status,
            sign_author,
            sign_key,
            sign_key_fingerprint,
            sign_primary_key
        );
        if i != 0 {
            println!("\\betweengitlogEntry%");
        }
        println!("\\startgitlogEntry%");
        println!("\\gitlogHash[{hash_long}]{{{hash}}}%");
        println!("\\gitlogAuthor{{{author_name}}}{{{author_mail}}}%");
        for tag in &version_tags {
            println!("\\gitlogTagVersion{{{tag}}}%");
        }
        if version_tags.is_empty() {
            println!("\\gitlogNoTagVersion%");
        }
        for tag in &notversion_tags {
            println!("\\gitlogTag{{{tag}}}%");
        }
        println!(
            "\\gitlogDateTime{{{y:04}}}{{{m:02}}}{{{d:02}}}{{{hh:02}}}{{{mm:02}}}{{{ss:02}}}{{{tzh:02}}}{{{tzm:02}}}%",
            y = dt.year(),
            m = dt.month(),
            d = dt.day(),
            hh = dt.hour(),
            mm = dt.minute(),
            ss = dt.second(),
            tzh = dt.offset().local_minus_utc() / (60 * 60),
            tzm = (dt.offset().local_minus_utc() / 60) % 60,
        );
        println!("\\gitlogMessage{{{title}}}{{{description}}}%");
        println!("\\gitlogChanges{{{stat_files}}}{{{stat_line_added}}}{{{stat_line_del}}}%");
        println!("\\gitlogSign{{{sign_status_code}}}{{{sign_authorname}}}{{{sign_authormail}}}{{{sign_key}}}{{{sign_key_fingerprint}}}{{{sign_primary_key}}}%");
        println!("\\stopgitlogEntry%");
        println!("%")
        //println!("\\paragraph{{{title}}}");
        //println!("{author_name}");
    }
    //println!("\\end{{gitlog}}%");
    //git log --reverse --pretty='tformat:\logentry{%H}{%h}{%aN}{%aE}{%as}{%(describe:tags=true,match=v[0-9]*)}{%D}{%s}{%b%-}{%G? by %GS with %GK %GF %GP %(trailers)} -- %D'
    //println!("Hello, world!");
}
