part of visualCircuit;

abstract class InternalNode extends Object with Tristate {
    //Data members
    final Point<int> _offset; //The relative position of this node to it's owner; should not contain negatives

    Wire _wire = null; //The Wire connected to this node
    final Component _owner; //The Component this node is within

    //Constructor
    InternalNode._internal(this._owner, this._offset);

    //Function members
    bool containsPoint(Point<int> p) => p.squaredDistanceTo(_owner.position + _offset) <= NODE_RADIUS * NODE_RADIUS; //p is within the radius givin

    bool get connected => _wire != null;
    Point<int> get position => _owner.position + _offset;
    Wire get wire => _wire;

    Wire tradeWire(Wire held);
}

//////////////////////////

class Input extends InternalNode {
    //Constructor; no external
    Input._internal(Component owner, Point<int> offset) : super._internal(owner, offset);

    //Function members
    Tri get asTri => (_wire == null) ? Tri.BOTH : _wire.asTri;

  /*
   * Attempts to trade the supplied Wire with _wire
   * Returns -null if there is no Wire to pick up
   *         -the same Wire if n is an inappropriate subtype (including null)
   *         -a new Wire if the supplied Wire is null
   * Handles all connctions and disconnections internally
   */
    Wire tradeWire(Wire held) {
        Wire old = _wire;
        _wire = held; //Connect the node to the held wire - disconnect the node from the old wire; held may be null

        if (held == null) //If a nothing is held
        {
            if (old == null) //And the node was not connected
            {
                old = new Wire(this); //Make a new wire
                _wire = old; //Link the wire to the node
            } 
            else //And the wire is connected
            {
                old._tip = null;
            }
            return old; //Send the old Wire back
        } 
        else if (held.connection == Wire.ROOT_CON) //If the held wire has a root
        {
            held._tip = this; //Connect the held wire to the node
            if (old != null) {old._tip = null;} //Disconnect the old wire from the node
            return old;
        }

        _wire = old; //If none of the above conditions match, reconnect the node to it's original wire
        return held;
    }
}

/////////////////////////

class Output extends InternalNode {
    //Data members
    Queue<Tri> _stateQueue = new Queue<Tri>(); //Buffers for inernal state; root of 'get state' chains; past, present, future

    //Constructor; no external
    Output._internal(Component owner, Point<int> offset) : super._internal(owner, offset) {
        _reset();
    }

    //Function members
    Tri get asTri => _stateQueue.first;

    void _queue(Tri t) => _stateQueue.addLast(t);

    Component get dependant {
        if (_wire != null && _wire._tip != null) {
            return _wire._tip._owner;
        } 
        else {
            return null;
        }
    }

    Tri _advanceState() {
        if (_stateQueue.length == 1) {
            _stateQueue.addLast(Tri.BOTH);
        }
        return _stateQueue.removeFirst();
    }

    void _reset() {
        _stateQueue..clear()
                   ..addLast(Tri.BOTH);
    }

  /*
   * Attempts to trade the supplied Wire with the one on InternalNode n
   * Returns -null if there is no Wire to pick up
   *         -the same Wire if n is an inappropriate subtype (including null)
   *         -a new Wire if the supplied Wire is null
   * Handles all connctions and disconnections internally
   */
    Wire tradeWire(Wire held) {
        Wire old = _wire;
        _wire = held; //Connect the node to the held wire - disconnect the node from the old wire; held may be null

        if (held == null) //If a nothing is held
        {
            if (old == null) //And the node was not connected
            {
                old = new Wire(this); //Make a new wire
                _wire = old; //Link the wire to the node
            } 
            else //And the wire is connected
            {
                old._root = null; //Disconnect wire from node
            }
            return old; //Send the old Wire back
        } 
        else if (held.connection == Wire.TIP_CON) //If the held wire has a tip
        {
            held._root = this; //Connect the held wire to the node
            if (old != null) {old._root = null;} //Disconnect the old wire from the node
            return old;
        }

        _wire = old; //If none of the above conditions match, reconnect the node to it's original wire
        return held;
    }
}
