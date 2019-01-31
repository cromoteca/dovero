//#![windows_subsystem = "windows"]

#[macro_use]
extern crate serde_derive;
extern crate serde_json;
extern crate web_view;

use web_view::*;

fn main() {
    let webview = web_view::builder()
        .title("Timer example")
        .content(Content::Url("http://localhost:4200/"))
        .size(800, 600)
        .resizable(true)
        .debug(true)
        .user_data("")
        .invoke_handler(|webview, arg| {
            // let tasks = webview.user_data_mut();

            // match serde_json::from_str(arg).unwrap() {
            //     Cmd::GetSQLiteVersion => tasks.push(String::from("Rust does not know")),
            // }

            // let rendered_json = format!("rpc.render({})", serde_json::to_string(tasks).unwrap());
            // webview.eval(&rendered_json)
            webview.eval(&arg.replace("{}", "Rust does not know"))
        })
        .build()
        .unwrap();

    webview.run().unwrap();
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
