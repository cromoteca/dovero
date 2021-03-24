import 'package:dovero/main.dart';
import 'package:dovero/models/map.dart';
import 'package:dovero/screens/gallery.dart';
import 'package:dovero/widgets/mapzoom.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:latlong/latlong.dart';
import 'package:provider/provider.dart';

const MARKER_SIZE = 40.0;

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

MapController _controller = MapController();

class MapWidget extends Consumer<MapModel> {
  final BuildContext context;

  MapWidget(this.context)
      : super(
          builder: (context, model, child) => FlutterMap(
            mapController: _controller,
            options: MapOptions(
              minZoom: 1,
              maxZoom: 18,
              bounds: model.photos.isEmpty
                  ? LatLngBounds(LatLng(50.5, -4.5), LatLng(37.5, 19))
                  : LatLngBounds.fromPoints(
                      model.photos.map((e) => e.position).toList()),
              boundsOptions: FitBoundsOptions(padding: EdgeInsets.all(50)),
              plugins: [
                MarkerClusterPlugin(),
                ZoomButtonsPlugin(),
              ],
            ),
            layers: [
              TileLayerOptions(
                urlTemplate: _osmURL(AppLocalizations.of(context).localeName),
                subdomains: ['a', 'b', 'c'],
              ),
              MarkerClusterLayerOptions(
                centerMarkerOnClick: false,
                size: Size(MARKER_SIZE, MARKER_SIZE),
                onClusterTap: (m) {
                  return false;
                },
                markers: model.photos.map((photo) {
                  return PhotoMarker(
                    point: photo.position,
                    builder: (ctx) => FloatingActionButton(
                      child: Text("1"),
                      onPressed: () {
                        model.selectedPhotos = [photo];
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => GalleryScreen()),
                        );
                      },
                    ),
                    photo: photo,
                  );
                }).toList(),
                builder: (context, markers) => FloatingActionButton(
                  child: Text(markers.length.toString()),
                  onPressed: () {
                    var selectedPhotos =
                        markers.map((m) => (m as PhotoMarker).photo).toList();
                    selectedPhotos
                        .sort((a, b) => b.created.compareTo(a.created));
                    model.selectedPhotos = selectedPhotos;
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => GalleryScreen()),
                    );
                  },
                ),
              ),
              ZoomButtonsPluginOption(
                alignment: Alignment.bottomRight,
                zoomInColor: Theme.of(context).buttonColor,
                zoomOutColor: Theme.of(context).buttonColor,
              ),
            ],
          ),
        ) {
    eventBus.on<PhotosLoadedEvent>().listen((event) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(AppLocalizations.of(context)
            .loadedImagesCount(event.photos.length)),
      ));

      _controller.fitBounds(LatLngBounds.fromPoints(
          event.photos.map((e) => e.position).toList()));
      _controller.move(_controller.center, _controller.zoom / 1.1);
    });
  }
}

// would like to use i18n for this, but curly braces are a mess in ARB files
String _osmURL(String locale) {
  if (locale == 'fr') {
    return 'https://{s}.tile.openstreetmap.fr/osmfr/{z}/{x}/{y}.png';
  }

  return 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png';
}
