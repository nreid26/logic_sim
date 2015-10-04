library logicSim;

import 'dart:html';
import 'dart:collection';
import 'dart:math';
import 'dart:async';

import 'package:logicsim/visualCircuit.dart';
import 'package:logicsim/tristate.dart';

part 'logicSim/controlGroup.dart';
part 'logicSim/simCanvasElement.dart';
part 'logicSim/timeSim.dart';
part 'logicSim/gridCircuit.dart';

//View-space: the pixel coordinates of the canvas according the the browser
//Component-space: the pixel coordinates of the Components and Canvas
//Grid-space: the cell blocks of the CircuitGrid
