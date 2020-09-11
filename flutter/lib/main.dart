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
  String name;
  Photo({this.position, this.name});
}

class _MyHomePageState extends State<MyHomePage> {
  var photos = <Photo>[
    Photo(
      position: LatLng(51.5, -0.09),
      name: "London",
    ),
    Photo(
      position: LatLng(48.8566, 2.3522),
      name: "Paris",
    ),
  ];

  @override
  Future<void> initState() async {
    super.initState();
    var result = await pm.PhotoManager.requestPermission();
    if (result) {
      // List<pm.AssetPathEntity> list = await pm.PhotoManager.getAssetPathList();
      // photos = list.map((ape) {
      //   List<pm.AssetEntity> imageList = ape.assetList;
      //   return Photo (
      //     position: pm.LatLng(ape.),
      //   );
      // });
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
                  width: 60.0,
                  height: 30.0,
                  point: photo.position,
                  builder: (ctx) => Container(
                    child: Text(photo.name,
                        style: Theme.of(context).textTheme.bodyText1),
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
