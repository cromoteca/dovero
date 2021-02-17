import 'dart:core';
import 'dart:io';

import 'package:dovero/models/map.dart';
import 'package:exifdart/exifdart.dart';
import 'package:exifdart/exifdart_io.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:latlong/latlong.dart';
import 'package:provider/provider.dart';

class DesktopWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _GalleryState();
}

class _GalleryState extends State<DesktopWidget> {
  @override
  Widget build(BuildContext context) => Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              child: Text('Albums: 1'),
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
            ),
            ListTile(
              title: Text("Load photos"),
              onTap: () async {
                await loadPhotos();
                Navigator.pop(context);
              },
            ),
          ],
        ),
      );

  Future<void> loadPhotos() async {
    var myDir = new Directory('/home/luciano/VerCias/foto/2021-01');
    var images =
        myDir.list(recursive: true, followLinks: false).asyncMap(isImage);
    var imageList = <File>[];

    await for (var image in images) {
      if (image != null) {
        imageList.add(image);
      }
    }

    var photos = await Future.wait(imageList.map((image) async {
      var data = await readExifFromFile(image);
      return data == null
          ? null
          : Photo(
              position: LatLng(data.extract("Latitude") ?? 0,
                  data.extract("Longitude") ?? 0),
              created: data.extractDateTime() ?? image.lastModifiedSync(),
              file: image,
            );
    }));

    photos
      ..removeWhere((el) => el == null)
      ..removeWhere((el) => el.position.longitude == 0);
    Provider.of<MapModel>(context, listen: false).photos = photos;
  }

  Future<File> isImage(FileSystemEntity f) async {
    return f is File && f.path.endsWith(".jpg") && (await f.stat()).size > 0
        ? f
        : null;
  }
}

extension CoordinateExtracting on Map<String, dynamic> {
  double extract(String coord) {
    var value = this["GPS" + coord] as List<Rational>;
    var sign = this["GPS" + coord + "Ref"] as String;
    print("Coordinate $coord: $value $sign");

    if (value == null || sign == null) {
      return null;
    }

    return value.parseCoordinatesWithSign(sign);
  }

  DateTime extractDateTime() {
    var value = this["DateTime"] as String;
    print("DateTime: $value");

    if (value == null) {
      return null;
    }

    try {
      return DateTime.parse(value);
    } on FormatException {
      return null;
    }
  }
}

extension CoordinateParsing on List<Rational> {
  double parseCoordinatesWithSign(String sign) {
    var result = 0.0;
    var fraction = 1;

    for (var r in this) {
      result += r.toDouble() / fraction;
      fraction *= 60;
    }

    if ("WwSs".contains(sign)) {
      result = -result;
    }

    print("${this}: $result");
    return result;
  }
}
