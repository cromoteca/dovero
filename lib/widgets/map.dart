import 'package:dovero/models/map.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:latlong/latlong.dart';
import 'package:provider/provider.dart';

class Map extends Consumer<MapModel> {
  Map()
      : super(
          builder: (context, map, child) => FlutterMap(
            options: MapOptions(
              minZoom: 1,
              maxZoom: 18,
              bounds: map.photos.isEmpty
                  ? LatLngBounds(LatLng(50.5, -4.5), LatLng(37.5, 19))
                  : LatLngBounds.fromPoints(
                      map.photos.map((e) => e.position).toList()),
              boundsOptions: FitBoundsOptions(padding: EdgeInsets.all(50)),
              plugins: [
                MarkerClusterPlugin(),
              ],
            ),
          ),
        );
}
