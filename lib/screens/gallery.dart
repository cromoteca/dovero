import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/map.dart';
import '../widgets/gallery.dart';

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
