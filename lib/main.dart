import 'package:dovero/models/map.dart';
import 'package:dovero/screens/map.dart';
import 'package:event_bus/event_bus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

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
          localizationsDelegates: [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
        ),
      );
}
