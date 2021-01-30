import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:provider/provider.dart';

import '../models/map.dart';

class GalleryWidget extends Consumer<MapModel> {
  GalleryWidget()
      : super(
          builder: (context, model, child) => PhotoViewGallery.builder(
            itemCount: model.photos.length,
            builder: (context, index) {
              return PhotoViewGalleryPageOptions.customChild(
                child: Stack(
                  alignment: Alignment.bottomRight,
                  children: <Widget>[
                    PhotoView(
                      imageProvider: FileImage(model.photos[index].file),
                    ),
                    Container(
                      padding: const EdgeInsets.all(10.0),
                      child: Text(
                        DateFormat.yMMMd().format(model.photos[index].created),
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
        );
}
