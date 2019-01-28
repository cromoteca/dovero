//#![windows_subsystem = "windows"]

extern crate web_view;
extern crate serde;
extern crate serde_json;

use web_view::*;
use serde::*;
use serde_json::*;

fn main() {
    let webview = web_view::builder()
        .title("Timer example")
        .content(Content::Url("http://localhost:4200/"))
        .size(800, 600)
        .resizable(true)
        .debug(true)
        .user_data("unknown")
        .invoke_handler(|webview, arg| {
            use Cmd::*;

            let tasks_len = {
                let tasks = webview.user_data_mut();

                match serde_json::from_str(arg).unwrap() {
                    GetSQLiteVersion => (),
                    Log { text } => println!("{}", text),
                    AddTask { name } => tasks.push(Task { name, done: false }),
                    MarkTask { index, done } => tasks[index].done = done,
                    ClearDoneTasks => tasks.retain(|t| !t.done),
                }

                tasks.len()
            };

            webview.set_title(&format!("Rust Todo App ({} Tasks)", tasks_len))?;
            render(webview)
        })
        .build()
        .unwrap();

    webview.run().unwrap();
}

#[derive(Debug, Serialize, Deserialize)]
struct SQLiteVersion {
    number: String,
}

#[serde(tag = "cmd", rename_all = "camelCase")]
enum Cmd {
    GetSQLiteVersion,
}
