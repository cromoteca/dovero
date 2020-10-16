import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:intl/intl.dart';
import 'package:latlong/latlong.dart';
import 'package:photo_manager/photo_manager.dart' as pm;
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

const MARKER_SIZE = 40.0;

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
  DateTime created;
  Uint8List thumbnail;
  File file;
  Photo({this.position, this.created, this.thumbnail, this.file});
}

class PhotoMarker extends Marker {
  final Photo photo;

  PhotoMarker({
    point,
    builder,
    this.photo,
  }) : super(
          point: point,
          builder: builder,
          width: MARKER_SIZE,
          height: MARKER_SIZE,
        );
}

class _MyHomePageState extends State<MyHomePage> {
  var _photos = <Photo>[];
  var _selectedPhotos = <Photo>[];
  var _paths = <pm.AssetPathEntity>[];
  var _displayIndex = 0;

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
        this._paths = paths;
      });
    }
  }

  Future<void> loadPhotos(pm.AssetPathEntity ape) async {
    var imageList = await ape.assetList;

    var photos = await Future.wait(imageList.map((image) async {
      var ll = await image.latlngAsync();
      var thumb = await image.thumbData;
      var file = await image.file;
      return Photo(
        position: LatLng(ll.latitude, ll.longitude),
        created: image.createDateTime ?? file.lastModifiedSync(),
        thumbnail: thumb,
        file: file,
      );
    }));

    photos.removeWhere((el) => el.position.longitude == 0);
    setState(() {
      this._photos = photos;
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
    return new WillPopScope(
      onWillPop: () async {
        if (this._displayIndex == 1) {
          setState(() {
            this._displayIndex = 0;
          });

          return false;
        } else {
          return true;
        }
      },
      child: Scaffold(
        appBar: AppBar(
          // Here we take the value from the MyHomePage object that was created by
          // the App.build method, and use it to set our appbar title.
          title: Text(widget.title),
          leading: this._displayIndex > 0 ? BackButton() : null,
        ),
        drawer: Drawer(
          child: ListView(
            // Important: Remove any padding from the ListView.
            padding: EdgeInsets.zero,
            children: <Widget>[
              DrawerHeader(
                child: Text('Albums: ${_paths.length}'),
                decoration: BoxDecoration(
                  color: Colors.blue,
                ),
              ),
              ..._paths
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
        body: IndexedStack(
          index: _displayIndex,
          children: [
            FlutterMap(
              mapController: mapController,
              options: MapOptions(
                minZoom: 1,
                maxZoom: 18,
                bounds: _photos.isEmpty
                    ? LatLngBounds(LatLng(50.5, -4.5), LatLng(37.5, 19))
                    : LatLngBounds.fromPoints(
                        _photos.map((e) => e.position).toList()),
                boundsOptions: FitBoundsOptions(padding: EdgeInsets.all(50)),
                plugins: [
                  MarkerClusterPlugin(),
                ],
              ),
              layers: [
                TileLayerOptions(
                  urlTemplate:
                      "https://{s}.tile.openstreetmap.fr/osmfr/{z}/{x}/{y}.png",
                  subdomains: ['a', 'b', 'c'],
                ),
                MarkerClusterLayerOptions(
                  centerMarkerOnClick: false,
                  size: Size(MARKER_SIZE, MARKER_SIZE),
                  onClusterTap: (m) {
                    return false;
                  },
                  markers: _photos.map((photo) {
                    return PhotoMarker(
                      point: photo.position,
                      builder: (ctx) => FloatingActionButton(
                        child: Text("1"),
                        onPressed: () {
                          setState(() {
                            this._selectedPhotos = [photo];
                            this._displayIndex = 1;
                          });
                        },
                      ),
                      photo: photo,
                    );
                  }).toList(),
                  builder: (context, markers) {
                    return FloatingActionButton(
                      child: Text(markers.length.toString()),
                      onPressed: () {
                        setState(() {
                          this._selectedPhotos = markers
                              .map((m) => (m as PhotoMarker).photo)
                              .toList();
                          this._displayIndex = 1;
                        });
                      },
                    );
                  },
                ),
              ],
            ),
            PhotoViewGallery.builder(
              itemCount: _selectedPhotos.length,
              builder: (context, index) {
                return PhotoViewGalleryPageOptions.customChild(
                  child: Stack(
                    alignment: Alignment.bottomRight,
                    children: <Widget>[
                      PhotoView(
                        imageProvider: FileImage(_selectedPhotos[index].file),
                      ),
                      Container(
                        padding: const EdgeInsets.all(10.0),
                        child: Text(
                          DateFormat.yMMMd()
                              .format(_selectedPhotos[index].created),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 17.0,
                            shadows: [
                              Shadow(
                                color: Colors.black,
                                blurRadius: 5,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
