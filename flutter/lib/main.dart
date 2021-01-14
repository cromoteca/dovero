import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import 'models/map.dart';

void main() {
  runApp(MapApp());
}

class MapApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MapModel(
        initialTitle: 'Dovero',
      ),
      child: MaterialApp(
        title: 'Dovero',
        theme: ThemeData(
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: Scaffold(
          appBar: AppBar(
            title: Consumer<MapModel>(
              builder: (context, map, child) => Text(map.title),
            ),
          ),
          drawer: Drawer(),
          body: IndexedStack(
            children: [],
          ),
        ),
      ),
    );
  }
}
