import 'package:flutter/material.dart';
import 'package:flutter_ray_canvas/canvas_widget.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: CanvasWidget(title: 'Flutter Demo Home Page'),
    );
  }
}
