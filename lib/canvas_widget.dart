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
                drawData.generateWalls(areaWidth, areaHeight);
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
            userY = details.localPosition.dy;
            drawData.particle = Particle(math.Vector2(userX, userY));
            if (drawData.walls.isEmpty) drawData.generateWalls(areaWidth, areaHeight);
          });
        },
        child: CustomPaint(
          size: Size(areaWidth, areaHeight),
          painter: RayPainter(userX, userY, drawData),
        ),
      )),
    );
  }
}

class RayPainter extends CustomPainter {
  double userX;
  double userY;
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

  RayPainter(this.userX, this.userY, this.drawData);

  @override
  void paint(Canvas canvas, Size size) {
    //background
    canvas.drawColor(Colors.black, BlendMode.clear);

    //draw all walls
    drawData.walls.forEach((b) {
      canvas.drawLine(Offset(b.a.x, b.a.y), Offset(b.b.x, b.b.y), wallPaint);
    });

    if (drawData.particle != null) {
      drawData.particle.intersect(drawData.walls).forEach((rAndI) {
        Offset startPoint = Offset(rAndI.ray.pos.x, rAndI.ray.pos.y);
        Offset endPoint;
        if (rAndI.intersectPoint == null) {
          endPoint = Offset(rAndI.ray.dir.x, rAndI.ray.dir.y);
        } else {
          endPoint = Offset(rAndI.intersectPoint.x, rAndI.intersectPoint.y);
        }
        canvas.drawLine(startPoint, endPoint, rayPaint);
      });
    }

    canvas.drawCircle(Offset(userX, userY), 20, pointerPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
