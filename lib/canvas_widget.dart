import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_ray_canvas/data.dart';
import 'package:vector_math/vector_math.dart' as math;

class CanvasWidget extends StatefulWidget {
  CanvasWidget({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _CanvasWidgetState createState() => _CanvasWidgetState();
}

class _CanvasWidgetState extends State<CanvasWidget> {
  var dots = [math.Vector2(0, 0)];
  var generator = DotGenerator(
      [
        math.Vector2(0, 0),
        math.Vector2(0, 1080),
        math.Vector2(720, 1080),
      ],
      math.Vector2(720 / 4, 1080 / 4));


  @override
  Widget build(BuildContext context) {
    double areaWidth = MediaQuery
        .of(context)
        .size
        .width;
    double areaHeight = MediaQuery
        .of(context)
        .size
        .height;

    Future.value(generator.generate()).then((list){
      setState(() {
        dots = list;
      });
    });


    return Scaffold(
      appBar: AppBar(
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              setState(() {});
            },
          )
        ],
        title: Text(widget.title),
      ),
      body: Center(
          child: Listener(
            onPointerMove: (PointerEvent details) {
              // setState(() {});
            },
            child: CustomPaint(
              size: Size(areaWidth, areaHeight),
              painter: RayPainter(dots),
            ),
          )),
    );
  }
}

class RayPainter extends CustomPainter {
  List<math.Vector2> dots;

  final Paint wallPaint = Paint()
    ..strokeWidth = 2
    ..color = Colors.white;

  RayPainter(this.dots);

  @override
  void paint(Canvas canvas, Size size) {
    //background
    canvas.drawColor(Colors.black, BlendMode.clear);
    var offsets = dots.map((d) {
      return Offset(d.x, d.y);
    }).toList();

    dots.forEach((d) {
      canvas.drawPoints(PointMode.points, offsets, wallPaint);
    });
  }


  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
