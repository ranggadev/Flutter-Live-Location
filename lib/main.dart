import 'package:flutter/material.dart';
import 'package:live_location/model/UserLocation.dart';
import 'package:live_location/services/LocationService.dart';
import 'package:live_location/ui/MainMenu.dart';
import 'package:provider/provider.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return StreamProvider<UserLocation>(
      builder: (context) => LocationService().locationStream,
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: MainMenu(),
      ),
    );
  }
}