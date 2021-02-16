import 'dart:io';

import 'package:dovero/widgets/desktop.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/map.dart';
import '../widgets/drawer.dart';
import '../widgets/map.dart';

class MapScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Consumer<MapModel>(
            builder: (context, map, child) => Text(map.title),
          ),
        ),
        drawer: Platform.isLinux ? DesktopWidget() : DrawerWidget(),
        body: MapWidget(),
      );
}
