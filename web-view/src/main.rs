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
        .user_data(UserData {
            ..Default::default()
        })
        .invoke_handler(|webview, arg| {
            let userdata = webview.user_data_mut();
            let payload: Payload = serde_json::from_str(arg).unwrap();
            println!("{}", arg);

            match payload.command {
                Cmd::GetSQLiteVersion => {
                    let db = Connection::open_in_memory().unwrap();
                    let mut query = db.prepare("select sqlite_version() as version").unwrap();
                    let results: Result<Vec<String>, Error> = query
                        .query_and_then(NO_PARAMS, |row| row.get_checked(0))
                        .unwrap()
                        .collect();
                    userdata.sqlite_version = results.unwrap().concat();
                }
                Cmd::Add { a, b } => {
                    userdata.sum = a + b;
                }
            };
            let json = serde_json::to_string(userdata).unwrap();
            webview.eval(&format!(
                "window.{}.fn.call(window.{}.ctx ,{}); delete window.{}",
                payload.id, payload.id, json, payload.id
            ))
            //webview.eval(&arg.replace("{}", &results.unwrap().concat()))
        })
        .build()
        .unwrap();

    webview.run().unwrap();

    let path = "/home/luciano/BlueXML/Documents/Images/wallpapers/DSC06771.JPG";
    let file = File::open(path).unwrap();
    let reader = Reader::new(&mut BufReader::new(&file)).unwrap();

    for _field in reader.fields().iter() {
        // println!("{:?}", field);
    }
}

#[derive(Debug, Serialize, Deserialize, Default)]
struct UserData {
    sqlite_version: String,
    sum: i32,
}

#[derive(Deserialize)]
struct Payload {
    id: String,
    command: Cmd,
}

#[derive(Deserialize)]
#[serde(tag = "cmd", rename_all = "camelCase")]
enum Cmd {
    GetSQLiteVersion,
    Add { a: i32, b: i32 },
}
