library visualCircuit;

/*
 * This library is desiged to represent logical circuit components in an integer graphical space.
 * It has facilities for defining component inputs, output, and logic, as well connections through the use of graphical wires.
 * 
 * For the purposes of this library, each input has 0 or 1 outputs and vice versa.
 */

//Imports for all parts
import 'dart:math';
import 'dart:collection';
import 'dart:html';

import 'package:logicsim/tristate.dart';

//Parts
part 'visualCircuit/nodes.dart';
part 'visualCircuit/component.dart';
part 'visualCircuit/wire.dart';
part 'visualCircuit/componentFactory.dart';
part 'visualCircuit/circuit.dart';


//Library properties
num _NODE_RADIUS = 0;
num _NODE_RADIUS_SQUARED = 0;

num get NODE_RADIUS => _NODE_RADIUS;
    set NODE_RADIUS(num r)
    {
      _NODE_RADIUS = r;
      _NODE_RADIUS_SQUARED = r * r;
    }
    
num WIRE_SLOPE = 0.1;
num WIRE_OFFSET = 0;


typedef Map<String, Tristate> LogicFunc(Component c);
typedef void DrawFunc(Component c, dynamic context);

List pointToJson(Point p) => new List.generate(2, (int i) => (i == 0) ? p.x : p.y);
Point pointFromJson(List l) => new Point(l[0], l[1]);


//Return whether the distance from 'b' to the line between 'a' and 'c' subceeds 'diff'
bool _colinearWithinDiff(Point<int> a, Point<int> b, Point<int> c, num diff)
{
  Point<int> vec1 = c - a; //Vectors from 'a' to other points
  Point<int> vec2 = b - a;
  
  int crossMag = ((vec1.x * vec2.y) - (vec1.y * vec2.x)).abs(); //Simplified cross product
  double distanceToLine = crossMag / sqrt(vec1.x * vec1.x + vec1.y * vec1.y);
  return distanceToLine < diff;
}

//Return whether angle 'abc' is larger than 'angle'
bool _internalAngleExceeds(Point<int> a, Point<int> b, Point<int> c, num cosAngle)
{
  Point<int> vec1 = a - b; //Vectors from 'b' to other points
  Point<int> vec2 = c - b;
  
  int dot = (vec1.x * vec2.x) + (vec1.y * vec2.y); //Simplified dot product
  double cosInter = dot / sqrt(b.squaredDistanceTo(a) * b.squaredDistanceTo(c));
  return cosInter < cosAngle;
}
