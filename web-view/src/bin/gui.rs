//#![windows_subsystem = "windows"]

#[macro_use]
extern crate serde_derive;
extern crate serde_json;
extern crate web_view;

use exif::{Reader, Tag};
use rusqlite::types::ToSql;
use rusqlite::{Connection, Error, NO_PARAMS};
use serde::ser::Serialize;
use std::env::current_dir;
use std::fs::{read_dir, File};
use std::io::BufReader;
use web_view::Content;

fn main() {
    let db = Connection::open_in_memory().unwrap();
    db.execute(
        "create table photos(name text, lat real, lon real)",
        NO_PARAMS,
    )
    .unwrap();

    let webview = web_view::builder()
        .title("Dovero")
        .content(Content::Url("http://localhost:4200/"))
        .size(800, 600)
        .resizable(true)
        .debug(true)
        .user_data(())
        .invoke_handler(|webview, arg| {
            let payload: Payload<Cmd> = serde_json::from_str(arg).unwrap();

            let json = match payload.command {
                Cmd::GetSQLiteVersion => {
                    let mut query = db.prepare("select sqlite_version() as version").unwrap();
                    let results: Result<Vec<String>, Error> = query
                        .query_and_then(NO_PARAMS, |row| row.get_checked(0))
                        .unwrap()
                        .collect();
                    to_json(&results.unwrap().concat())
                }
                Cmd::Add { a, b } => to_json(&(a + b)),
                Cmd::GetPhotos => to_json(&get_photos(&db)),
            };

            webview.eval(&format!(
                "window.{}.fn.call(window.{}.ctx ,{}); delete window.{}",
                payload.id, payload.id, json, payload.id
            ))
        })
        .build()
        .unwrap();

    webview.run().unwrap();
}

fn get_photos(db: &Connection) -> Vec<Photo> {
    let mut photos = Vec::new();
    if let Ok(mut path) = current_dir() {
        path.push("photos");

        if let Ok(files) = read_dir(path) {
            let mut insert_photo = db
                .prepare("insert into photos(name, lat, lon) values (?, ?, ?)")
                .unwrap();

            for file in files {
                let entry = file.unwrap();

                if let Ok(file_type) = entry.file_type() {
                    if file_type.is_file() {
                        let file = File::open(entry.path()).unwrap();
                        let reader = Reader::new(&mut BufReader::new(&file)).unwrap();

                        if let Some(lat) =
                            read_gps_field(&reader, Tag::GPSLatitude, Tag::GPSLatitudeRef)
                        {
                            if let Some(lon) =
                                read_gps_field(&reader, Tag::GPSLongitude, Tag::GPSLongitudeRef)
                            {
                                let name = &entry.file_name().into_string().unwrap();
                                insert_photo
                                    .execute(&[&name as &ToSql, &lat, &lon])
                                    .unwrap();
                            }
                        }
                    }
                }
            }

            let mut stmt = db.prepare("select name, lat, lon from photos").unwrap();
            let rows = stmt
                .query_map(NO_PARAMS, |row| {
                    Photo {
                        name: row.get::<_, String>(0),
                        lat: row.get::<_, f64>(1),
                        lon: row.get::<_, f64>(2),
                    }
                })
                .unwrap();

            for photo in rows {
                photos.push(photo.unwrap());
            }
        }
    }

    photos
}

fn read_gps_field(reader: &Reader, gps_tag: Tag, gps_sign_tag: Tag) -> Option<f64> {
    let mut result: Option<f64> = None;

    if let Some(field) = reader.get_field(gps_tag, false) {
        if let exif::Value::Rational(ref value) = field.value {
            if let Some(sign_field) = reader.get_field(gps_sign_tag, false) {
                let sign_str = format!("{}", sign_field.value.display_as(sign_field.tag));
                let sign = if sign_str == "S" || sign_str == "W" {
                    -1.0
                } else {
                    1.0
                };
                result = Some(to_decimal(value) * sign);
            }
        }
    }

    result
}

#[derive(Debug, Serialize)]
struct Photo {
    name: String,
    lat: f64,
    lon: f64,
}

fn to_decimal(dms: &[exif::Rational]) -> f64 {
    dms[0].to_f64() + dms[1].to_f64() / 60.0 + dms[2].to_f64() / 3600.0
}

fn to_json<T: ?Sized>(value: &T) -> String
where
    T: Serialize,
{
    serde_json::to_string(value).unwrap()
}

#[derive(Deserialize)]
struct Payload<T> {
    id: String,
    command: T,
}

#[derive(Deserialize)]
#[serde(tag = "cmd", rename_all = "camelCase")]
enum Cmd {
    GetSQLiteVersion,
    Add { a: i32, b: i32 },
    GetPhotos,
}
