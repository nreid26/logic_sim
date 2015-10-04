part of visualCircuit;

abstract class Circuit {
	
	static final String COMPONENTS_KEY = 'components';
	static final String TYPE_KEY = 'type';
	static final String POSITION_KEY = 'position';
	static final String WIRES_KEY = 'wires';
	static final String ROOTLINKS_KEY = 'rootLinks';
	static final String TIPLINKS_KEY = 'tipLinks';
	static final String COMPONENTINDEX_KEY = 'componentIndex';
	static final String NODEKEY_KEY = 'nodeKey';
	
    //Constructor
	Circuit();
	
    Circuit.fromJson(Map data, Map<String, ComponentFactory> factories) {
        List<Component> comps = new List<Component>();

        //Methods below may throw errors, this is intentional

        //Create components
        for (dynamic c in data[COMPONENTS_KEY]) {
            try {
            	Component comp = factories[c[TYPE_KEY]].makeCopy()
            					..position = pointFromJson(c[POSITION_KEY]);
            	comps.add(comp); 
                addComponent(comp);
            } 
            catch(e) {
            	comps.add(null);
                window.console.log('component corrupted; skipping');
            }
        }

        //Create wires
        for (int w = 0; w < data[WIRES_KEY].length; w++) {
            int rootCompIndex = data[ROOTLINKS_KEY][w][COMPONENTINDEX_KEY];
            String rootNodeKey = data[ROOTLINKS_KEY][w][NODEKEY_KEY];

            int tipCompIndex = data[TIPLINKS_KEY][w][COMPONENTINDEX_KEY];
            String tipNodeKey = data[TIPLINKS_KEY][w][NODEKEY_KEY];

            try {
            	//Throws error on null nodes (is good)
                Wire wire = new Wire.fromJson(comps[rootCompIndex].outs[rootNodeKey], comps[tipCompIndex].ins[tipNodeKey], data[WIRES_KEY][w]);
                addWire(wire);
            } 
            catch (e) {
                window.console.log('wire data corrupted; skipping');
            }
        }
    }

    //Function members
    Set<Wire> get wires;
    Set<Component> get components;
    
    Component getAt(Point<int> pos) {
        for (Component c in components) {
            if (c.containsPoint(pos)) {
                return c;
            }
        }
        return null;
    }

    Set<Component> componentsInside([Rectangle<int> r]) //Return a set of the components in the grid
    {
        Set<Component> result = new Set<Component>();

        for (Component c in components) {
            if (c.intersects(r)) {
                result.add(c);
            }
        }

        return result;
    }

    void reset() {
        for (Component c in components) {
            c.reset();
        }
    }

    void clear();
    
    void addWire(Wire w);
    
    void removeWire(Wire w);
    
    void addComponent(Component c);
    
    void removeComponent(Component c);
    
    Map toJson() {
        Map<String, dynamic> result = new Map();

        List<Component> comps = components.toList(); //Get a list of components
        List<Wire> _wires = wires.toList();

        List<_ConnectionTemp> rootLinks = [];
        List<_ConnectionTemp> tipLinks = [];
        
        //Compile connection information
        int index = 0;
        List workWith;
        void toApply(String k, InternalNode n) {
        	int i = _wires.indexOf(n.wire);
        	if(i >= 0) {workWith.add(new _ConnectionTemp(index, k, i));}
		}
       	for(Component c in comps) {
       		workWith = rootLinks;
        		c.outs.forEach(toApply);
        	workWith = tipLinks;
        		c.ins.forEach(toApply);
        	index++;
        };
       
        //Sort links by wire index so that connections to the same wire will be parallel in each list
        rootLinks.sort();
        tipLinks.sort();

        result[COMPONENTS_KEY] = comps;
        result[WIRES_KEY] = _wires;
        result[ROOTLINKS_KEY] = rootLinks;
        result[TIPLINKS_KEY] = tipLinks;

        return result;
    }
}

class _ConnectionTemp implements Comparable {
    int componentIndex;
    String nodeKey;
    int wireIndex;

    _ConnectionTemp(this.componentIndex, this.nodeKey, this.wireIndex);

    int compareTo(_ConnectionTemp ct) => wireIndex - ct.wireIndex; //All wire indecies are unique

    Map toJson() {
    	Map<String, dynamic> result = new Map();
	    	result[Circuit.COMPONENTINDEX_KEY] = componentIndex;
	    	result[Circuit.NODEKEY_KEY] = nodeKey;
    	return result;
    }
}
