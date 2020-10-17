import 'dart:math';

import 'package:vector_math/vector_math.dart';


class DotGenerator {
  List<Vector2> _vertexrs;
  Vector2 _point;
  List<Vector2> dots = [];

  final _random = new Random();

  DotGenerator(this._vertexrs, this._point){
    dots = [_point];
  }

  List<Vector2> generate() {
    for (int i = 0; i < 100; i++) {
      var lastElem = dots.last;
      var randomVertex = _vertexrs[_random.nextInt(_vertexrs.length)];
      var delta = (lastElem - randomVertex) / 2;
      _point = lastElem - delta;
      dots.add(_point);
    }
    return dots;
  }
}
