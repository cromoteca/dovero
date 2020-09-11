import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong/latlong.dart';
import 'package:photo_manager/photo_manager.dart' as pm;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dovero',
      theme: ThemeData(
        // This makes the visual density adapt to the platform that you run
        // the app on. For desktop platforms, the controls will be smaller and
        // closer together (more dense) than on mobile platforms.
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Dovero'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class Photo {
  LatLng position;
  String name = "unnamed";
  Uint8List thumbnail;
  Photo({this.position, this.name, this.thumbnail});
}

class _MyHomePageState extends State<MyHomePage> {
  var photos = <Photo>[];

  @override
  void initState() {
    super.initState();
    loadPhotos();
  }

  @override
  void didUpdateWidget(MyHomePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    loadPhotos();
  }

  Future<void> loadPhotos() async {
    var result = await pm.PhotoManager.requestPermission();
    if (result) {
      var list = await pm.PhotoManager.getAssetPathList();
      var allPhotos = await Future.wait(list
          .map((ape) async {
            try {
              var imageList = await ape.assetList;
              var ll = await imageList[0].latlngAsync();
              var thumb = await imageList[0].thumbData;
              return Photo(
                  position: LatLng(ll.latitude, ll.longitude),
                  name: ll.toString(), thumbnail: thumb);
            } catch (err) {
              return null;
            }
          })
          .where((el) => el != null)
          .toList());
      setState(() {
        photos = allPhotos;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: FlutterMap(
          options: MapOptions(
            center: LatLng(51.5, -0.09),
            zoom: 13.0,
          ),
          layers: [
            TileLayerOptions(
                urlTemplate:
                    "https://{s}.tile.openstreetmap.fr/osmfr/{z}/{x}/{y}.png",
                subdomains: ['a', 'b', 'c']),
            MarkerLayerOptions(
              markers: photos.map((photo) {
                return Marker(
                  width: 120.0,
                  height: 120.0,
                  point: photo.position,
                  builder: (ctx) => Container(
                    child: Image(image: MemoryImage(photo.thumbnail)),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
