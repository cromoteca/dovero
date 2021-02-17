import 'dart:io';

import 'package:dovero/models/map.dart';
import 'package:dovero/widgets/desktop.dart';
import 'package:dovero/widgets/drawer.dart';
import 'package:dovero/widgets/map.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
