import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:latlong/latlong.dart';

class Photo {
  LatLng position;
  DateTime created;
  Uint8List thumbnail;
  File file;

  Photo({this.position, this.created, this.thumbnail, this.file});
}

class MapModel extends ChangeNotifier {
  MapModel({@required String initialTitle}) {
    this._title = initialTitle;
  }

  String _title;
  String get title => _title;
  set title(String newTitle) {
    if (newTitle != _title) {
      _title = newTitle;
      notifyListeners();
    }
  }

  List<Photo> _photos = [];
  List<Photo> get photos => _photos;
  set photos(List<Photo> newPhotos) {
    if (newPhotos != _photos) {
      _photos = newPhotos;
      notifyListeners();
    }
  }

  List<Photo> _selectedPhotos = [];
  List<Photo> get selectedPhotos => _selectedPhotos;
  set selectedPhotos(List<Photo> newPhotos) {
    if (newPhotos != _selectedPhotos) {
      _selectedPhotos = newPhotos;
      notifyListeners();
    }
  }
}
