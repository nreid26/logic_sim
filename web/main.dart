library main;

import 'dart:html';
import 'dart:convert';
import 'dart:async';
import 'dart:math';

import 'package:logicsim/logicSim.dart';
import 'package:logicsim/visualCircuit.dart';
import 'package:logicsim/tristate.dart';

part 'helpers/stateHandler.dart';
part 'helpers/canvasParentListeners.dart';
part 'helpers/generalListeners.dart';
part 'helpers/defineComps.dart';

const int SHIFT_RATE = 15;


//DOM Elements
final TableElement compTable = querySelector('#compTable');
final SimCanvasElement canvas = (() {
	CanvasElement can = querySelector('#simCanvas');
	SimCanvasElement ret = new SimCanvasElement(circuit.cellCenter, can);
	can.replaceWith(ret);
	return ret;
})();

final SelectElement selector = querySelector('#selector');
final InputElement loadButton = querySelector('#loadFile_button');
final AnchorElement dummyAnchor = querySelector('#dummyAnchor');
final ControlGroup timeControls = new ControlGroup(querySelector('#playStep'), querySelector('#pauseUnpause'), querySelector('#stop'), querySelector('#frequ'));

final DivElement helpBox = querySelector('#helpBox');

//Storage
GridCircuit circuit = new GridCircuit(75); //Component grid
List<Map<String, ComponentFactory>> factoryMapList = new List<Map<String, ComponentFactory>>();
Map helpText = new Map();

StateHandler stateHandler = new EmptyMouse();
TimeSim simulation;
	bool get simulationActive => simulation != null;


void main() {	
	visualCricuit:NODE_RADIUS = 7;
	visualCricuit:WIRE_OFFSET = 10;
	visualCricuit:WIRE_SLOPE = 1 / 6;
	
	canvas
		..width = canvas.view.width
		..height = canvas.view.height;
	
	loadHelp();
	applyGeneralListeners();
	applyCanvasParentListeners();
	  
	defineComps();
}

void loadHelp() {
  try {
      HttpRequest.getString('helpText.json')..then((String data) {
          helpText.addAll(JSON.decode(data));
          helpBox.innerHtml = helpText[stateHandler.runtimeType.toString()];
      });
  } 
  catch (e) {
      window.console.log('Request Failed: Help data unavailable');
  }
}

void redraw([StateHandler sh]) {
    canvas
    	..clear()
      	..drawGrid(circuit.cellSize)

		..drawWires(circuit.wires, simulationActive)
		..drawComponents(circuit.componentsInside(canvas.view));

  ((sh == null) ? stateHandler : sh).draw();
}

Map get factories {
	Map res = {};
	for(Map m in factoryMapList) {
		for(ComponentFactory cf in m.values) {res[cf.type] = cf;}
	}
	return res;
}