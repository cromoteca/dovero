//#![windows_subsystem = "windows"]

#[macro_use]
extern crate serde_derive;
extern crate serde_json;
extern crate web_view;

use exif::Reader;
use rusqlite::{Connection, Error, NO_PARAMS};
use std::fs::File;
use std::io::BufReader;
use web_view::Content;

fn main() {
    let webview = web_view::builder()
        .title("Timer example")
        .content(Content::Url("http://localhost:4200/"))
        .size(800, 600)
        .resizable(true)
        .debug(true)
        .user_data("")
        .invoke_handler(|webview, arg| {
            let db = Connection::open_in_memory().unwrap();
            let mut query = db.prepare("select sqlite_version() as version").unwrap();
            let results: Result<Vec<String>, Error> = query
                .query_and_then(NO_PARAMS, |row| row.get_checked(0))
                .unwrap()
                .collect();
            webview.eval(&arg.replace("{}", &results.unwrap().concat()))
        })
        .build()
        .unwrap();

    webview.run().unwrap();

    let path = "/home/luciano/BlueXML/Documents/Images/wallpapers/DSC06771.JPG";
    let file = File::open(path).unwrap();
    let reader = Reader::new(&mut BufReader::new(&file)).unwrap();

    for field in reader.fields().iter() {
        println!("{:?}", field);
    }
}

#[derive(Debug, Serialize, Deserialize)]
struct SQLiteVersion {
    number: String,
}

#[derive(Deserialize)]
#[serde(tag = "cmd", rename_all = "camelCase")]
enum Cmd {
    GetSQLiteVersion,
}
