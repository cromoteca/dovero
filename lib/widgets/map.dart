import 'package:dovero/models/map.dart';
import 'package:flutter/material.dart';
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

class Map extends Consumer<MapModel> {
  Map()
      : super(
          builder: (context, model, child) => FlutterMap(
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
                markers: model.photos.map((photo) {
                  return PhotoMarker(
                    point: photo.position,
                    builder: (ctx) => FloatingActionButton(
                      child: Text("1"),
                      onPressed: () {
                        model.selectedPhotos = [photo];
                      },
                    ),
                    photo: photo,
                  );
                }).toList(),
                builder: (context, markers) => FloatingActionButton(
                  child: Text(markers.length.toString()),
                  onPressed: () {
                    model.selectedPhotos =
                        markers.map((m) => (m as PhotoMarker).photo).toList();
                  },
                ),
              ),
            ],
          ),
        );
}
