import 'dart:math';

import 'package:vector_math/vector_math.dart';

const int WALLS_COUNT = 4;
const double RAY_ANGLE_DELTA = 2;

class DrawData {
  DrawData._internal();

  static final DrawData instance = DrawData._internal();

  List<Wall> walls = [];
  Particle particle;

  void generateWalls(double areaWidth, double areaHeight) {
    walls.clear();
    for (int i = 0; i < WALLS_COUNT; i++) {
      Vector2 random1 = Vector2.random();
      Vector2 random2 = Vector2.random();
      walls.add(Wall(Vector2(areaWidth * random1.x, areaWidth * random1.y),
          Vector2(areaWidth * random2.x, areaWidth * random2.y)));
    }
  }
}

class Particle {
  Vector2 pos;
  List<Ray> rays = [];

  Particle(this.pos) {
    for (double i = 0; i < 360; i += RAY_ANGLE_DELTA) {
      rays.add(Ray(Vector2(pos.x, pos.y), i));
    }
  }

  List<RayAndIntersectPoint> intersect(List<Wall> walls) {
    var rayAndIntersectPoint = rays.map((r) {
      return RayAndIntersectPoint(r, r.intersectionPointWithNearestWall(walls));
    }).toList();
    return rayAndIntersectPoint;
  }
}

class Wall {
  final Vector2 a;
  final Vector2 b;

  Wall(this.a, this.b);
}

class Ray {
  Vector2 pos;
  Vector2 dir;
  double angle;

  Ray(this.pos, this.angle) {
    num rad = angle * pi / 180;
    dir = Vector2(cos(rad) * 10000, sin(rad) * 10000); // 10000 just for make ray larger
  }

  Vector2 intersect(Wall wall) {
    double x1 = pos.x;
    double y1 = pos.y;
    double x2 = dir.x;
    double y2 = dir.y;

    double x3 = wall.a.x;
    double y3 = wall.a.y;
    double x4 = wall.b.x;
    double y4 = wall.b.y;

    // it can be 0 if ray and wall are parallel || or has no intersection
    double den = (x1 - x2) * (y3 - y4) - (y1 - y2) * (x3 - x4);
    if (den != 0) {
      double t = ((x1 - x3) * (y3 - y4) - (y1 - y3) * (x3 - x4)) / den;
      double u = -((x1 - x2) * (y1 - y3) - (y1 - y2) * (x1 - x3)) / den;

      final hasIntersectionWithWall = t > 0 && t < 1 && u > 0 && u < 1;
      if (hasIntersectionWithWall) {
        double x = x1 + t * (x2 - x1);
        double y = y1 + t * (y2 - y1);
        return Vector2(x, y);
      } else
        null;
    } else
      return null;
  }

  /// returns distance between ray star position and [intersectPoint]
  double distanceToRayStartFrom(Vector2 intersectPoint) {
    double length;
    if (intersectPoint == null) {
      length = null;
    } else {
      length = sqrt(pow(intersectPoint.x - pos.x, 2) + pow(intersectPoint.y - pos.y, 2));
    }
    return length;
  }

  /// return intersectPoint with nearest wall that ray will intersect
  Vector2 intersectionPointWithNearestWall(List<Wall> walls) {
    var list = walls.map((w) {
      Vector2 intersectPoint = intersect(w); // intersect point with wall
      double d = distanceToRayStartFrom(intersectPoint); // distance between ray start and intersect point
      return IntersectPointAndDistanceFromRayStart(intersectPoint, d);
    }).toList();
    list.sort(); // after sort - first element will be intersect point with nearest wall
    return list.first.intersectPoint;
  }
}

// Help objects --------------------------------------------------------------------------------------------------------
class RayAndIntersectPoint {
  final Ray ray;
  final Vector2 intersectPoint;

  RayAndIntersectPoint(this.ray, this.intersectPoint);
}

class IntersectPointAndDistanceFromRayStart extends Comparable<IntersectPointAndDistanceFromRayStart> {
  final Vector2 intersectPoint;
  final double d;

  IntersectPointAndDistanceFromRayStart(this.intersectPoint, this.d);

  @override
  int compareTo(other) {
    if (d == null) return 100;
    if (other.d == null) return -100;
    if (d < other.d)
      return -1;
    else
      return 1;
  }
}
