part of visualCircuit;

class Wire extends Object with Tristate {
	
	static String NO_CON = 'no con';
	static String ROOT_CON = 'root con';
	static String TIP_CON = 'tip con';
	static String BOTH_CON = 'both con';
	
    //Data members
    Output _root = null; //The Output this Wire draws from
    Input _tip = null; //The Input this wire connects

    List<Point<int>> _points; //The absolute graphical point that define this wire visually, excluding its root and tip

    //Constructor
    Wire(InternalNode n) {
		//Decide what end to initialize based on the type of the node
        if (n is Input) {_tip = n;}
        else {_root = n;}
        
        _points = [];
    }

    Wire.fromJson(this._root, this._tip, List<List<int>> ps) { //Throws error on null nodes (is good)
        _root._wire = this;
        _tip._wire = this;
        
        _points = new List<Point<int>>.generate(ps.length, (int i) => pointFromJson(ps[i]));
    }

    //Function members
    Tri get asTri => (_root == null) ? Tri.BOTH : _root.asTri;

    List<List<int>> toJson() => new List<List<int>>.generate(_points.length, (int i) => pointToJson(_points[i]));

    List<Point<int>> get path //Get a list of points to draw on this wire
    {
        List<Point<int>> result = new List<Point<int>>();

        if (_root != null) {
            result.add(_root.position);
        }
        result.addAll(_points);
        if (_tip != null) {
            result.add(_tip.position);
        }

        return result;
    }

    void addPoint(Point<int> p) {
        if (_root == null) { //No root
            p = _withinSlope((_points.length == 0) ? _tip.position : _points.first, p);
            _points.insert(0, p);
        } 
        else if (_tip == null) { //No tip
            p = _withinSlope((_points.length == 0) ? _root.position : _points.last, p);
            _points.add(p);
        }
        else {
            _points.add(p);
        }
    }

    Wire removePoint() {
        if (_points.length == 0) { //The only point is and endpoint
            disconnect();
            return null;
        } 
        else if (_root == null) {
            _points.removeAt(0);
        } 
        else if (_tip == null) {
            _points.removeLast();
        }

        return this;
    }

    void disconnect() //Disconnect the wire from its anchor nodes; prepare it for destruction
    {
        if (_root != null) {
            _root._wire = null; //Break the root's connection to the wire
            _root = null; //And the wire's connection to the root
        }

        if (_tip != null) {
            _tip._wire = null; //Break the tip's connection to the wire
            _tip = null; //And the wire's connection to the tip
        }

        _points.clear(); //Eliminate the intermeidate points; this wire should never be used again
    }

    void finalizePath() //Confirm the ends of the wire have right angles if need be
    {
		//Preempt null pointers
        if (_points.length == 0 || _root == null || _tip == null) {
            return;
        }

        _points.insert(0, _root.position);
        _points.add(_tip.position);

        //Clean up near colinears at the ends
        Point<int> calc;
        for (int i = 0; i < _points.length - 1; i++) //From root
        {
            calc = _withinSlope(_points[i], _points[i + 1]);
            if (calc == _points[i + 1]) {
                break;
            } else {
                _points[i + 1] = calc;
            }
        }
        for (int i = _points.length - 1; i > 1; i--) //From tip
        {
            calc = _withinSlope(_points[i], _points[i - 1]);
            if (calc == _points[i - 1]) {
                break;
            } else {
                _points[i - 1] = calc;
            }
        }

        //Remove colinear extras
        for (int i = 1; i < _points.length - 1; i++) {
            if (_colinearWithinDiff(_points[i - 1], _points[i], _points[i + 1], WIRE_OFFSET)) {
                _points.removeAt(i--);
            }
        }

        _points.removeAt(0);
        _points.removeAt(_points.length - 1);
    }

    String get connection {
        if (_root == null && _tip == null) {
            return NO_CON;
        } 
        else if (_root != null && _tip == null) {
            return ROOT_CON;
        } 
        else if (_tip != null && _root == null) {
            return TIP_CON;
        } 
        else {
            return BOTH_CON;
        }
    }

    WirePoint mobilizePoint(Point<int> p) {
        for (int i = 0; i < _points.length; i++) {
            if (_points[i].squaredDistanceTo(p) < _NODE_RADIUS_SQUARED) {
                _points[i] = new WirePoint._internal(this, i, _points[i].x, _points[i].y);
                return _points[i];
            }
        }
        return null;
    }

    static Point<int> _withinSlope(Point<int> from, Point<int> to) {
        num slope = (to.y - from.y) / (to.x - from.x);

        if (slope.abs() < WIRE_SLOPE) //If the slope is too close to horizontal
        {
            to = new Point<int>(to.x, from.y);
        } else if (slope.abs() > 1 / WIRE_SLOPE) //if the slope is too close to vertical
        {
            to = new Point<int>(from.x, to.y);
        }

        return to;
    }
}

class WirePoint implements Point<int> {
    //Data members
    int x;
    int y;
    final Wire w;
    final int index;

    //Constructor
    WirePoint._internal(this.w, this.index, this.x, this.y);

    //Function members
    Point<int> operator +(Point<int> p) => new Point<int>(p.x + x, p.y + y);
    Point<int> operator -(Point<int> p) => new Point<int>(p.x - x, p.y - y);
    Point<int> operator *(num n) => new Point<int>(x * n, y * n);

    num squaredDistanceTo(Point<int> p) {
        num dx = p.x - x;
        num dy = p.y - y;
        return dx * dx + dy * dy;
    }

    num distanceTo(Point<int> p) => sqrt(squaredDistanceTo(p));

    num get magnitude => distanceTo(new Point<int>(0, 0));

    void lock() {
        List<Point<int>> path = w.path;
        Point<int> newLoc = new Point<int>(x, y);

        //Remove the point if it is colinear between its neighbours
        if (_colinearWithinDiff(path[index], path[index + 1], path[index + 2], WIRE_OFFSET)) {
            delete();
            return;
        }

        newLoc = Wire._withinSlope(path[index], newLoc); //Correct from root end
        newLoc = Wire._withinSlope(path[index + 2], newLoc); //Correct from tip end

        w._points[index] = newLoc; //Place point in
    }

    void delete() {
        w._points.removeAt(index);
    }

    void set(Point<int> p) {
        x = p.x;
        y = p.y;
    }
}
