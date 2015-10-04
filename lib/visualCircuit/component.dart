part of visualCircuit;

class Component extends MutableRectangle<int> {
	static final StateError _LOCKED_ERROR = new StateError('Component cannot be modified inside draw or logic function.');
    //Data members
    bool _locked = false;
    
    final ComponentFactory _fact; //The factory that made this component
    final Map<String, Input> _ins = new Map<String, Input>(); //List of Input nodes
    final Map<String, Output> _outs = new Map<String, Output>(); //List of Ouput nodes

    String get type => _fact._type;
    ImageElement get image => _fact._image;
    bool get selfDependent => _fact._selfDependent;
    int get propagationDelay => _fact._propagationDelay;

    Point<int> get position => new Point<int>(left, top);
    void set position(Point<int> p) {
        left = p.x;
        top = p.y;
    }

    Point<int> get dimensions => new Point<int>(width, height);

    UnmodifiableMapView<String, Input> ins;
    UnmodifiableMapView<String, Output> outs;
    
    final Map<String, dynamic> storage = new Map<String, dynamic>();


    //Constructor
    Component._internal(this._fact, int w, int l) : super(0, 0, w, l) {
        ins = new UnmodifiableMapView<String, Input>(_ins);
        outs = new UnmodifiableMapView<String, Output>(_outs);
    }

    //Function members
    Map toJson() {
    	Map<String, dynamic> result = new Map();
    		result[Circuit.TYPE_KEY] = type;
    		result[Circuit.POSITION_KEY] = pointToJson(position);
    	return result;
    }

    void calcAndQueue() {
        if(_locked) {throw _LOCKED_ERROR;}
        _locked = true;

        Map<String, Tristate> futureStates = _fact._logicFunc(this); //Run the factory logic function
        if (futureStates == null) { //If changes are reported
            futureStates = new Map();
        }

        _outs.forEach((String key, Output o) {
            o._queue(
                (futureStates[key] == null) ? o._stateQueue.last : futureStates[key].asTri //Queue an update if specified or copy the last state
            );
        });
        
        _locked = false;
    }

    void draw(dynamic context) //Excecute the factory's drawing function with access to the individual component's public data and inputs
    {
        if(_locked) {throw _LOCKED_ERROR;}
        _locked = true;

        if (_fact._drawFunc != null) {
            _fact._drawFunc(this, context);
        }
        
        _locked = false;
    }

    InternalNode nodeSurrounding(Point<int> p) {
        for (Input i in _ins.values) {
            if (i.containsPoint(p)) {
                return i;
            }
        }
        for (Output o in _outs.values) {
            if (o.containsPoint(p)) {
                return o;
            }
        }
        return null;
    }

    Set<Wire> get wires { //Return all wires on this Component
        Set<Wire> result = new Set<Wire>();
        result.addAll(_ins.values.map((i) => i._wire));
        result.addAll(_outs.values.map((o) => o._wire));

        result.remove(null); //Prempt null pointer exception
        return result;
    }

    Set<Component> get dependants {
        Set<Component> result = _outs.values.map((o) => o.dependant);
        result.remove(null); //Prempt null pointer exceptions
        return result;
    }

    Set<Component> advanceState() {
        if(_locked) {throw _LOCKED_ERROR;}

        Set<Component> result = new Set<Component>();

        for (Output o in _outs.values) {
            //Advance output and detect state change
            if (o._advanceState() != o.asTri) {
                result.add(o.dependant);
            }
        }

        result.remove(null);
        if (selfDependent) {
            result.add(this);
        }
        return result;
    }

    void reset() {
        if(_locked) {throw _LOCKED_ERROR;}
        
        for (Output o in _outs.values) {
            o._reset();
        }
        storage.clear();
    }    
}
