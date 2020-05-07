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
  double userX = 0;
  double userY = 0;
  DrawData drawData = DrawData.instance; // need to be crated only once

  @override
  Widget build(BuildContext context) {
    double areaWidth = MediaQuery.of(context).size.width;
    double areaHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                drawData.generateWalls(areaWidth, areaHeight / 2);
              });
            },
          )
        ],
        title: Text(widget.title),
      ),
      body: Center(
          child: Listener(
        onPointerMove: (PointerEvent details) {
          setState(() {
            userX = details.localPosition.dx;
            if (details.localPosition.dy > 0 && details.localPosition.dy < areaHeight / 2)
              userY = details.localPosition.dy;
            else
              userY = areaHeight / 2;
            drawData.particle = Particle(math.Vector2(userX, userY));
            if (drawData.walls.isEmpty) drawData.generateWalls(areaWidth, areaHeight / 2);
          });
        },
        child: CustomPaint(
          size: Size(areaWidth, areaHeight),
          painter: RayPainter(userX, userY, drawData, areaWidth, areaHeight),
        ),
      )),
    );
  }
}

class RayPainter extends CustomPainter {
  double userX;
  double userY;
  double areaWidth;
  double areaHeight;
  DrawData drawData;
  final Paint wallPaint = Paint()
    ..strokeWidth = 2
    ..color = Colors.white;
  final Paint rayPaint = Paint()
    ..strokeWidth = 1
    ..color = Color.fromRGBO(255, 255, 255, 20);
  final Paint pointerPaint = Paint()
    ..strokeWidth = 4
    ..style = PaintingStyle.stroke
    ..color = Colors.redAccent;

  RayPainter(this.userX, this.userY, this.drawData, this.areaWidth, this.areaHeight);

  @override
  void paint(Canvas canvas, Size size) {
    //background
    canvas.drawColor(Colors.black, BlendMode.clear);

    //draw all walls
    drawData.walls.forEach((b) {
      canvas.drawLine(Offset(b.a.x, b.a.y), Offset(b.b.x, b.b.y), wallPaint);
    });

    if (drawData.particle != null) {
      //rays 2D---------------------------------------------------------------------------------------------------------
      drawData.particle.intersect(drawData.walls).forEach((rAndI) {
        Offset startPoint = Offset(rAndI.ray.pos.x, rAndI.ray.pos.y);
        Offset endPoint;
        if (rAndI.intersectPoint == null) {
          endPoint = Offset(rAndI.ray.dir.x, rAndI.ray.dir.y);
//          endPoint = startPoint;
        } else {
          endPoint = Offset(rAndI.intersectPoint.x, rAndI.intersectPoint.y);
        }
        canvas.drawLine(startPoint, endPoint, rayPaint);
      });

      canvas.drawCircle(Offset(userX, userY), 20, pointerPaint);

      //walls 3D--------------------------------------------------------------------------------------------------------
      List<double> scene = drawData.particle.intersect(drawData.walls).map((rAndI) {
        return rAndI.intersectPoint?.distanceTo(math.Vector2(userX, userY)) ?? -1;
      }).toList();

      double sceneH = areaHeight / 2;
      double sceneW = areaWidth;
      for (int i = 0; i < scene.length; i++) {
        double h = map(scene[i], 0, sceneW, sceneH, 0);
        if (scene[i] == -1) h = 0; // no intersection with wall - need to set 0

        Rect r = Rect.fromCenter(
            center: Offset(sceneW / scene.length * i, sceneH * 1.5),
            width: sceneW / scene.length,
            height: h);

        int col = 255 - map(scene[i].toInt(), 0, sceneW, 0, 255).toInt();
        canvas.drawRect(
            r,
            Paint()
              ..strokeWidth = 4
              ..style = PaintingStyle.fill
              ..color = Color.fromARGB(255, col, col, col));
      }
    }
  }

  double map(n, start1, stop1, start2, stop2) {
    return (n - start1) / (stop1 - start1) * (stop2 - start2) + start2;
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
