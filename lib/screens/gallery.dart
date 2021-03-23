import 'package:dovero/models/map.dart';
import 'package:dovero/widgets/gallery.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class GalleryScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Consumer<MapModel>(
            builder: (context, map, child) => Text(map.title),
          ),
        ),
        body: GalleryWidget(),
      );
}
