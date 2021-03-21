import 'package:dovero/models/map.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:latlong/latlong.dart' as ll;
import 'package:photo_manager/photo_manager.dart';
import 'package:provider/provider.dart';

class DrawerWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _GalleryState();
}

class _GalleryState extends State<DrawerWidget> {
  var _paths = <AssetPathEntity>[];

  @override
  void initState() {
    super.initState();
    loadAlbums();
  }

  @override
  Widget build(BuildContext context) => Drawer(
        child: ListView(
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
                      onTap: () async {
                        await loadPhotos(ape);
                        Navigator.pop(context);
                      },
                    ))
                .toList(),
          ],
        ),
      );

  Future<void> loadAlbums() async {
    var result = await PhotoManager.requestPermission();
    if (result) {
      var paths = await PhotoManager.getAssetPathList();
      setState(() {
        this._paths = paths;
      });
    }
  }

  Future<void> loadPhotos(AssetPathEntity ape) async {
    var imageList = await ape.assetList;

    var photos = await Future.wait(imageList
        .where((image) => image.type == AssetType.image)
        .map((image) async {
      var latlng = await image.latlngAsync();
      var file = await image.file;
      var thumb = await image.thumbData;
      return Photo(
        position: ll.LatLng(latlng.latitude, latlng.longitude),
        created: image.createDateTime ?? file.lastModifiedSync(),
        thumbnail: thumb,
        file: file,
      );
    }));

    photos.removeWhere((el) => el.position.longitude == 0);
    Provider.of<MapModel>(context, listen: false).photos = photos;
  }
}
