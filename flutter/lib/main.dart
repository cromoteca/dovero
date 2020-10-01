import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
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
  String info = "";
  Uint8List thumbnail;
  Photo({this.position, this.info, this.thumbnail});
}

class _MyHomePageState extends State<MyHomePage> {
  final markerSize = 40.0;
  var photos = <Photo>[];
  var paths = <pm.AssetPathEntity>[];
  MapController mapController;

  @override
  void initState() {
    super.initState();
    mapController = MapController();
    loadAlbums();
  }

  @override
  void didUpdateWidget(MyHomePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    loadAlbums();
  }

  Future<void> loadAlbums() async {
    var result = await pm.PhotoManager.requestPermission();
    if (result) {
      var paths = await pm.PhotoManager.getAssetPathList();
      setState(() {
        this.paths = paths;
      });
    }
  }

  Future<void> loadPhotos(pm.AssetPathEntity ape) async {
    var imageList = await ape.assetList;

    var photos = await Future.wait(imageList.map((image) async {
      var ll = await image.latlngAsync();
      var thumb = await image.thumbData;
      return Photo(
          position: LatLng(ll.latitude, ll.longitude),
          info: image.createDateTime.toString(),
          thumbnail: thumb);
    }));

    photos.removeWhere((el) => el.position.longitude == 0);
    setState(() {
      this.photos = photos;
    });

    mapController.fitBounds(
        LatLngBounds.fromPoints(photos.map((e) => e.position).toList()));
    mapController.move(mapController.center, mapController.zoom / 1.1);
  }

  void setAlbum(pm.AssetPathEntity ape) {
    loadPhotos(ape);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      drawer: Drawer(
        child: ListView(
          // Important: Remove any padding from the ListView.
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              child: Text('Albums: ${paths.length}'),
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
            ),
            ...paths
                .map((ape) => ListTile(
                      title: Text(ape.name),
                      onTap: () {
                        setAlbum(ape);
                        Navigator.pop(context);
                      },
                    ))
                .toList(),
          ],
        ),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: FlutterMap(
          mapController: mapController,
          options: MapOptions(
            minZoom: 1,
            maxZoom: 18,
            bounds: photos.isEmpty
                ? LatLngBounds(LatLng(50.5, -4.5), LatLng(37.5, 19))
                : LatLngBounds.fromPoints(
                    photos.map((e) => e.position).toList()),
            boundsOptions: FitBoundsOptions(padding: EdgeInsets.all(50)),
            plugins: [
              MarkerClusterPlugin(),
            ],
          ),
          layers: [
            TileLayerOptions(
                urlTemplate:
                    "https://{s}.tile.openstreetmap.fr/osmfr/{z}/{x}/{y}.png",
                subdomains: ['a', 'b', 'c']),
            MarkerClusterLayerOptions(
              centerMarkerOnClick: false,
              size: Size(markerSize, markerSize),
              onClusterTap: (m) {
                return false;
              },
              markers: photos.map((photo) {
                return Marker(
                  width: markerSize,
                  height: markerSize,
                  point: photo.position,
                  builder: (ctx) => FloatingActionButton(
                    child: Text("1"),
                    onPressed: null,
                  ),
                );
              }).toList(),
              builder: (context, markers) {
                return FloatingActionButton(
                  child: Text(markers.length.toString()),
                  onPressed: null,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
