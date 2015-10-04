part of visualCircuit;

class ComponentFactory {
    //Data members
    static HashSet<String> _existingTypes = new HashSet<String>(); //Record all active types so there can be no overlap

    ImageElement _image; //Library locked image
    final Map<String, Point> _ins = new Map<String, Point>(); //List of Input nodes
    final Map<String, Point> _outs = new Map<String, Point>(); //List of Ouput nodes
    Point<int> _dimensions = null;

    LogicFunc _logicFunc;
    DrawFunc _drawFunc; //Externalized drawing behaviour for CopyComponents
    String _type;
    bool _selfDependent = false;
    int _propagationDelay = 1;

    ComponentFactory _mod;
    bool get inProduction => _mod == null;

    //Constructor
    ComponentFactory() {
        _mod = this;
    }

    //Function members
    void addInput(String name, int x, int y) {
        _mod._ins[name] = new Point<int>(x, y);
    }

    void addOutput(String name, int x, int y) {
        _mod._outs[name] = new Point<int>(x, y);
    }

    ImageElement get image => _image;
    set image(ImageElement i) => _mod._image = i;

    String get type => _type;
    set type(String s) {
        s = s.toLowerCase();
        if (_existingTypes.contains(s)) {
            throw 'type "$s" already exists';
        } else {
            _existingTypes.remove(_mod._type); //Delist the outgoing type
            _mod._type = s; //Update
            _existingTypes.add(s); //List the new type
        }
    }

    LogicFunc get logicFunc => _logicFunc;
    set logicFunc(LogicFunc l) => _mod._logicFunc = l;

    bool get selfDependent => _selfDependent;
    set selfDependent(bool b) => _mod._selfDependent = b;

    int get propagationDelay => _propagationDelay;
    set propagationDelay(int i) {
        if (i >= 0) {
            _mod._propagationDelay = i;
        }
    }

    DrawFunc get drawFunc => _drawFunc;
    set drawFunc(DrawFunc d) => _mod._drawFunc = d;

    Point<int> get dimensions {
        //If dimensions have not been set explicitly, defer to the '_image'
        if (_dimensions == null && _image != null) {
            return new Point<int>(_image.height, _image.width);
        } else {
            return _dimensions;
        }
    }
    set dimensions(Point<int> d) => _mod._dimensions = d;


    Component makeCopy() {
        _mod = null;

        Component c = new Component._internal(this, dimensions.x, dimensions.y); //Submit the programatically determined dimensions

        //Deep copy Inputs and Outputs into 'cc'
        _ins.forEach((String k, Point v) {
            c._ins[k] = new Input._internal(c, v);
        });
        _outs.forEach((String k, Point v) {
            c._outs[k] = new Output._internal(c, v);
        });

        return c;
    }
}
