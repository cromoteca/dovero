import 'package:dovero/models/map.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:provider/provider.dart';

class GalleryWidget extends Consumer<MapModel> {
  GalleryWidget()
      : super(
          builder: (context, model, child) => PhotoViewGallery.builder(
            itemCount: model.selectedPhotos.length,
            builder: (context, index) {
              return PhotoViewGalleryPageOptions.customChild(
                child: Stack(
                  alignment: Alignment.bottomRight,
                  children: <Widget>[
                    PhotoView(
                      loadingBuilder: (context, event) =>
                          model.selectedPhotos[index].thumbnail == null
                              ? Container()
                              : Center(
                                  child: Image(
                                    image: MemoryImage(
                                        model.selectedPhotos[index].thumbnail),
                                    fit: BoxFit.contain,
                                    height: double.infinity,
                                    width: double.infinity,
                                    alignment: Alignment.center,
                                  ),
                                ),
                      imageProvider:
                          FileImage(model.selectedPhotos[index].file),
                    ),
                    Container(
                      padding: const EdgeInsets.all(10.0),
                      child: Text(
                        DateFormat.yMMMd(
                                AppLocalizations.of(context).localeName)
                            .format(model.selectedPhotos[index].created),
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
