part of logicSim;

class GridCircuit extends Circuit {
	static final String CELLSIZE_KEY = 'cellSize';
	
    //Data members
    final int cellSize;
    final Point<int> cellCenter;
    
    final SplayTreeMap<Point<int>, Component> _grid = new SplayTreeMap<Point<int>, Component>((Point a, Point b) => (a.x - b.x != 0) ? a.x - b.x : a.y - b.y); //Maps grid coordinates to inhabiting Component
    Set<Component> get components => _grid.values.toSet();

    final Set<Wire> _wires = new Set();
    Set<Wire> get wires => new Set<Wire>.from(_wires);
    
    //Constructor
    GridCircuit(int d) : cellSize = d, cellCenter = new Point<int>(d ~/ 2, d ~/ 2);
              
    GridCircuit.fromJson(Map data, Map factories) : super.fromJson(data, factories),
													cellCenter = new Point<int>(data['cellSize'] ~/ 2, data[CELLSIZE_KEY] ~/ 2)
    				,								cellSize = data[CELLSIZE_KEY];

    //Function members
    Map toJson() {
    	Map res = super.toJson();
    	res[CELLSIZE_KEY] = cellSize;
    	return res;
    }
	
    void addComponent(Component comp, [Point<int> position]) { //Reference a component in all cells it visually inhabits, and
        if (position == null) {position = comp.position;}
        comp.position = new Point<int>(position.x - position.x % cellSize, position.y - position.y % cellSize); //Snap the component position to the grid

        Point<int> cellCoords = new Point<int>((position.x / cellSize).floor(), (position.y / cellSize).floor()); //Determine the cell this position maps to
        Point<int> cellDim = new Point<int>((comp.width / cellSize).ceil(), (comp.height / cellSize).ceil()); //Get the cell dimensions of the Component

        bool forRegion(Function f) {
        	for (int col = 0; col < cellDim.x; col++) {
                for (int row = 0; row < cellDim.y; row++) {
                	if(f(new Point<int>(col + cellCoords.x, row + cellCoords.y))) {return false;}
                }
        	}
        	return true;
        }
        
        while(!forRegion(_grid.containsKey)) {
        	comp.position += new Point<int>(cellSize, 0); //Move the component graphically past the failing column
            cellCoords += new Point<int>(1, 0); //Shift the cell space of 'comp' past the failing column
        }
        
        forRegion((Point<int> p) {_grid[p] = comp; return false;});
    }

    void lift(Component comp) { //Lift a component from all cells it may inhabit
        if (!_grid.containsValue(comp)) {return;}

        List<Point<int>> cells = [];
        void test(Point<int> k, Component c) { //Define a local testing function using the list above
            if (c == comp) {cells.add(k);}
        }
        
        _grid.forEach(test); //Run that function against all the nodes in the tree
        for (Point<int> cell in cells) { _grid.remove(cell);} //Remove the keys put in the list
    }
    
    void removeComponent(Component comp) {
    	lift(comp);
    	comp.wires.forEach(removeWire);
    }

    Component getAt(Point<int> pos) { //Determine what, if any, Component inhabits graphical position 'pos'
        Point<int> cell = new Point<int>((pos.x / cellSize).floor(), (pos.y / cellSize).floor()); //Determine the cell this position maps to
        return _grid[cell];
    }

    Set<Component> componentsInside([Rectangle<int> r]) { //Return a set of the components in the grid
        if (r == null) {return _grid.values.toSet();}

        Set<Component> result = new Set<Component>();

        Point<int> ul = new Point<int>((r.left / cellSize).floor(), (r.top / cellSize).floor()); //Convert to cell coordinates
        Point<int> br = new Point<int>((r.right / cellSize).ceil(), (r.bottom / cellSize).ceil());

        Point<int> key = ul - new Point<int>(0, 1);
        key = _grid.firstKeyAfter(key);

        while (key != null && key.x <= br.x) //While the key is at or before the bottom right
        {
            if (key.y >= ul.y && key.y <= br.y) //if key is in the y range
            {
                result.add(_grid[key]); //Otherwise add the cooresponding value
            }
            key = _grid.firstKeyAfter(key); //Advance the key to the next available
        }

        result.remove(null);
        return result;
    }

    void clear() {
        _grid.clear();
        _wires.clear();
    }
    
    void addWire(Wire w) {_wires.add(w);}
    
    void removeWire(Wire w) {
    	w.disconnect();
    	_wires.remove(w);
    }
}
