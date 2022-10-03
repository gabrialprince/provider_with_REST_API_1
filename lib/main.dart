import 'package:flutter/material.dart';
import 'package:flutter_application/providers/homepageproviders.dart';
import 'package:provider/provider.dart';
import './page/homepages.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Provider REST Practice 2 ',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: ChangeNotifierProvider<HomePageProvider>(
        create: (context) => HomePageProvider(),
        child: HomePage(),
      ),
    );
  }
}
