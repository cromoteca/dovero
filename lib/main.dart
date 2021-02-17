import 'package:event_bus/event_bus.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'models/map.dart';
import 'screens/map.dart';

EventBus eventBus = EventBus();

void main() {
  runApp(MapApp());
}

class MapApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) => ChangeNotifierProvider(
        create: (context) => MapModel(
          initialTitle: 'Dovero',
        ),
        child: MaterialApp(
          title: 'Dovero',
          theme: ThemeData(
            visualDensity: VisualDensity.adaptivePlatformDensity,
          ),
          home: MapScreen(),
        ),
      );
}
