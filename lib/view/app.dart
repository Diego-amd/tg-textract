import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'foto.view.dart';

class App extends StatefulWidget {
  @override
  _App createState() => _App();
}

class _App extends State<App> {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.green,
          primaryColor: Colors.grey,
          brightness: Brightness.dark,
        ),
        routes: {
          '/': (context) => FotoView(),
        },
        initialRoute: '/');
  }
}
