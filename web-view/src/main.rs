//#![windows_subsystem = "windows"]

extern crate web_view;
extern crate serde_json;

use web_view::*;
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
            match arg {
                "getSQLiteVersion" => {
                    *webview.user_data_mut() = "ciao";
                    webview.eval("boh")?;
                }
                "exit" => {
                    webview.terminate();
                }
                _ => unimplemented!(),
            };
            Ok(())
        })
        .build()
        .unwrap();

    webview.run().unwrap();
}

struct SQLiteVersion {
    number: String,
}
