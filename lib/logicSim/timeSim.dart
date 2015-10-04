part of logicSim;

typedef void Impotent();

//Represents the logical asspects of the simulation as time passes

class TimeSim {
    //Data members
    Timer _auto = null;
    Impotent _afterStep;

    //Internal circular queue indexed by component propagation delay
    List<Set<Component>> _queue;
    Set<Component> _forced = new Set<Component>();
    int _access = 0;

    //Constructor
    TimeSim(this._afterStep, Set<Component> fullSet) {
        var temp = new Set<Component>();
        int sets = 0;

        fullSet.forEach((Component c) //Find max propagation delay and selfDependent components
        {
            if (c.selfDependent) {
                c.calcAndQueue();
                temp.add(c);
            }
            if (c.propagationDelay > sets) {
                sets = c.propagationDelay;
            }
        });

        _queue = new List<Set<Component>>.generate(sets + 1, (int i) => new Set<Component>(), growable: false);
        _setQueue(temp);

    }

    //Function members
    void step() //Defenition of step within required closure
    {
        //Prepare and queue any components that were forced to update
        _forced.forEach((Component c) {
            c.calcAndQueue();
            _getQueue().add(c);
        });
        _forced.clear();

        Set<Component> nonZeros = new Set<Component>();

        while (true) {
            var current = _getQueue(); //Pull out current components
            _setQueue(new Set<Component>()); //Put a new holder in the queue

            current.forEach((Component outer) {
                outer.advanceState().forEach((Component inner) {
                    _getQueue(inner.propagationDelay).add(inner);
                    if (inner.propagationDelay > 0) {
                        nonZeros.add(inner);
                    }
                });
            });

            if (_getQueue().length == 0) {
                break;
            } //If there are no more components with a 0 delay

            //Propagate signals through components without delays after they're all located
            _getQueue().forEach((Component c) => c.calcAndQueue());
        }

        //Recalculate the delayed components only once at the end
        nonZeros.forEach((Component c) => c.calcAndQueue());
        _advanceQueue();

        if (_afterStep != null) {
            _afterStep();
        }
    }

    void automate(int frequency) {
        _auto = new Timer.periodic(new Duration(milliseconds: 1000 ~/ frequency), (Timer t) //Create a timer with a duration based on the duration function
        {
            step();
        });
    }

    void halt() {
        if (_auto != null) //Prevent call on null object; once from button, again from internal check
        {
            _auto.cancel();
            _auto = null;
        }
    }

    void forceUpdate(Component c) //Add a component to the waitlist for updating
    {
        if (c == null) {
            return;
        }
        _forced.add(c);
    }

    Set<Component> _getQueue([int i = 0]) => _queue[(_access + i) % _queue.length];
    void _setQueue(Set<Component> s, [int i = 0]) {
        _queue[(_access + i) % _queue.length] = s;
    }
    void _advanceQueue() {
        _access = (_access + 1) % _queue.length;
    }
}
