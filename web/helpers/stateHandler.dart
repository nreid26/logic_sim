part of main;

abstract class StateHandler {
    //Data members
    static List<bool> arrowStates = [false, false, false, false];
    static List<Point<int>> arrowShifts = [new Point<int>(-SHIFT_RATE, 0), new Point<int>(0, -SHIFT_RATE), new Point<int>(SHIFT_RATE, 0), new Point<int>(0, SHIFT_RATE),];

    //Constructor
    StateHandler() {
        try {
            helpBox.innerHtml = helpText[this.runtimeType.toString()];
        } catch (e) {}
        
        redraw(this);
    }

    //Function members
    void mouseUp(MouseEvent event) {}
    void mouseDown(MouseEvent event) {}
    void mouseMove(MouseEvent event) {}
    void mouseLeave(MouseEvent event) {}

    void keyUp(int code) {
        int codeS = code - KeyCode.LEFT;
        if (codeS >= 0 && codeS <= 3) {
            arrowStates[codeS] = false;
        }
    }

    void keyDown(int code) {
        int codeS = code - KeyCode.LEFT;
        if (codeS >= 0 && codeS <= 3) {
            arrowStates[codeS] = true;
        }

        for (int i = 0; i < arrowStates.length; i++) {
            if (arrowStates[i]) {
                canvas.shift += arrowShifts[i];
            }
        }

        mouseMove(null);
        redraw();
    }

    void draw() {}
    void selectComponent(ComponentFactory cf) {}
}

class EmptyMouse extends StateHandler {
    //Function members
    void mouseDown(MouseEvent event) {
        Component tempComp = circuit.getAt(canvas.compMouse);
        if (tempComp != null) //Mouse on Component
        {
            InternalNode tempNode = tempComp.nodeSurrounding(canvas.compMouse);
            if (tempNode != null) //Mouse on Node
            {
                stateHandler = new WireMouse(tempNode.tradeWire(null));
            } else //Mouse off Node
            {
                stateHandler = new ComponentMouse(tempComp);
            }
        } else //Mouse off Component
        {
            WirePoint tempPoint;
            for (Wire w in circuit.wires) {
                tempPoint = w.mobilizePoint(canvas.compMouse);
                if (tempPoint != null) //Mouse on wire vertex
                {
                    stateHandler = new PointMouse(tempPoint);
                    break;
                }
            }
        }
    }

    void draw() {
        Set<InternalNode> nodes = new Set<InternalNode>();
        for (Component c in circuit.componentsInside(canvas.view)) {
            nodes.addAll(c.ins.values);
            nodes.addAll(c.outs.values);
        }
        canvas.drawNodes(nodes);
    }
    
    void selectComponent(ComponentFactory cf) {
    	stateHandler = new AdditionMouse(cf);
    }
}

class AdditionMouse extends StateHandler {
    //Data members
    final ComponentFactory factory;

    //Constructor
    AdditionMouse(this.factory) {
        factory.image.setAttribute('style', 'background:${SimCanvasElement.getColor('RED', 0.3)}');
    }

    //Function members
    void mouseUp(MouseEvent e) {
        Component temp = circuit.getAt(canvas.compMouse);

        if (temp != null) {
            factory.image.setAttribute('style', '');
            stateHandler = new EmptyMouse();
        } else {
            circuit.addComponent(factory.makeCopy(), canvas.compMouse);
            redraw();
        }
    }

    void mouseMove(MouseEvent e) {
        redraw();
    }

    void mouseLeave(MouseEvent e) {
        factory.image.setAttribute('style', '');
        stateHandler = new EmptyMouse();
    }

    void keyDown(int code) {
        super.keyDown(code);

        if (code == KeyCode.DELETE) {
            mouseLeave(null);
        } else if (code == KeyCode.TAB) {
            int table = int.parse(selector.value);
            var compMap = factoryMapList[table];

            if (compMap.length == 0) {
                return;
            } else if (compMap[compMap.keys.last] == factory) {
                mouseLeave(null);
                stateHandler = new AdditionMouse(compMap[compMap.keys.first]);
            } else {
                mouseLeave(null);
                var list = compMap.keys.map((String s) => compMap[s]).toList();
                stateHandler = new AdditionMouse(list[list.indexOf(factory) + 1]);
            }
        }
    }

    void draw() {
        var con = canvas.context2D;
        Point<int> dest = canvas.compMouse - circuit.cellCenter;

        con..globalAlpha = 0.3
           ..drawImage(factory.image, dest.x, dest.y)
           ..globalAlpha = 1;
    }
}

class ComponentMouse extends StateHandler {
    //Data members
    final Component component;

    //Constructor
    ComponentMouse(this.component) {
        circuit.lift(component);
        component.position = canvas.compMouse - circuit.cellCenter;
    }

    //Function members
    void mouseUp(MouseEvent event) {
        circuit.addComponent(component, canvas.compMouse);
        for (Wire w in component.wires) {
            w.finalizePath();
        }
        stateHandler = new EmptyMouse();
    }

    void mouseMove(MouseEvent event) {
        component.position = canvas.compMouse - circuit.cellCenter;
        redraw();
    }

    void mouseLeave(MouseEvent event) {
        circuit.removeComponent(component);
        stateHandler = new EmptyMouse();
    }

    void keyUp(int code) {
        super.keyUp(code);

        if (code == KeyCode.DELETE) {
            mouseLeave(null);
        }
    }

    void draw() {
        var context = canvas.context2D;

        context.globalAlpha = 0.5;
        component.draw(context);
        context.globalAlpha = 1;
    }
}

class WireMouse extends StateHandler {
    //Data members
    final Wire wire;
    bool canAdd = false; //Flag

    //Constructor
    WireMouse(this.wire);

    //Function members
    void mouseUp(MouseEvent event) {
        canAdd = true;
    }

    void mouseDown(MouseEvent event) {
    	if(!canAdd) {return;}
    	
        Component tempComp = circuit.getAt(canvas.compMouse);
        if (tempComp != null) //Mouse on Component
        {
            InternalNode tempNode = tempComp.nodeSurrounding(canvas.compMouse);
            if (tempNode != null) //Mouse on Node
            {
                Wire oldWire = tempNode.tradeWire(wire);
                circuit.addWire(wire);
                wire.finalizePath();

                stateHandler = (oldWire == null) ? new EmptyMouse() : new WireMouse(oldWire);
                return;
            }
        }

        //Happens as long as a node wasn't clicked
        wire.addPoint(canvas.compMouse);
        canAdd = false;
    }

    void mouseMove(MouseEvent e) {
        redraw();
    }

    void mouseLeave(MouseEvent event) {
        circuit.removeWire(wire);
        stateHandler = new EmptyMouse();
    }

    void keyUp(int code) {
        super.keyUp(code);

        if (code == KeyCode.DELETE) {
            //Call to removePoint() has an essect regardless of return value
            if (wire.removePoint() == null) {
                stateHandler = new EmptyMouse();
            }
            redraw();
        }
    }

    void draw() {
        canvas.drawWires([wire]);

        List<Point<int>> path = wire.path;
        Iterable<InternalNode> nodes;
        
        var context = canvas.context2D;
        context.beginPath(); //If connected at tip, move to first point

        if (wire.connection == Wire.TIP_CON) {
            context.moveTo(path.first.x, path.first.y);
            nodes = circuit.componentsInside(canvas.view).expand((Component c) => c.outs.values).toSet();
        }
        else {
            context.moveTo(path.last.x, path.last.y);
            nodes = circuit.componentsInside(canvas.view).expand((Component c) => c.ins.values);
        }
        
        context..lineTo(canvas.compMouse.x, canvas.compMouse.y) //Draw the floating line
               ..stroke();

        canvas.drawNodes(nodes);
        canvas.drawCrosshair();
    }
}

class PointMouse extends StateHandler {
    //Data members
    final WirePoint wirePoint;

    //Constructor
    PointMouse(this.wirePoint);

    //Function members
    void mouseUp(MouseEvent event) {
        wirePoint.lock();
        stateHandler = new EmptyMouse();
    }

    void mouseMove(MouseEvent event) {
        wirePoint.set(canvas.compMouse);
        redraw();
    }

    void mouseLeave(MouseEvent event) {
        wirePoint.delete();
        stateHandler = new EmptyMouse();
    }

    void keyUp(int code) {
        super.keyUp(code);

        if (code == KeyCode.DELETE) {
            mouseLeave(null);
        }
    }

    void draw() {
        canvas.drawCrosshair();
    }
}

class SimulationMouse extends StateHandler {
    //Constructor
    SimulationHandler() {
        stateHandler.mouseLeave(null); //Reset any internal variables before assigning the new Handler
    }

    //Function members
    void mouseDown(MouseEvent event) {
        //Super ungeneralized, but the application is limited for now
        Component comp = circuit.getAt(canvas.compMouse); //If a source is clicked during simulation

        if (comp == null) {} else if (comp.type == 'source') {
            comp.storage['state'] = (comp.storage['state'] == null) ? Tri.FALSE : -comp.storage['state']; //Toggle source internal state
            simulation.forceUpdate(comp);
            redraw();
        }
    }

    void keyDown(int code) {
        super.keyDown(code);

        if (code == KeyCode.SPACE) {
            simulation.step();
        }
    }
}
