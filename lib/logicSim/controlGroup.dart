part of logicSim;

typedef void Callback(Event e);

//Represents the time input elemnts on the page

class ControlGroup {
    //Data members
    final InputElement _playButton;
    final InputElement _stepButton;
    final InputElement _stopButton;
    final InputElement _pauseButton;
    final InputElement _unpauseButton;

    final InputElement _fRange;

    //User defined callbacks
    Callback play;
    Callback step;
    Callback pause;
    Callback stop;
    Callback unpause;

    int get frequency => _fRange.valueAsNumber.round();

    //Constructor
    ControlGroup(this._playButton, this._unpauseButton, this._stopButton, this._fRange)
            : this._stepButton = new InputElement(type: 'button'),
              this._pauseButton = new InputElement(type: 'button') {
        _playButton
                ..onClick.listen(_play)
                ..value = "Play"
                ..disabled = false;

        _stepButton
                ..onClick.listen(_step)
                ..value = "Step"
                ..disabled = false;

        _stopButton
                ..onClick.listen(_stop)
                ..value = "Stop"
                ..disabled = true;

        _pauseButton
                ..onClick.listen(_pause)
                ..value = "Pause"
                ..disabled = false;

        _unpauseButton
                ..onClick.listen(_unpause)
                ..value = "Unpause"
                ..disabled = true;

        //Speed Range
        _fRange
                ..min = '1'
                ..max = '20'
                ..value = '11'
                ..disabled = true
                ..text = 'Frequency'
                ..onChange.listen((Event e) {
                    if (pause != null) {
                        pause(e);
                    }
                    if (unpause != null) {
                        unpause(e);
                    }
                });
    }

    //Function members
    void _play(Event e) {
        _playButton.replaceWith(_stepButton);
        _stopButton.disabled = false;
        _unpauseButton.disabled = false;

        if (play != null) {
            play(e);
        }
    }

    void _step(Event e) {
        if (step != null) {
            step(e);
        }
    }

    void _pause(Event e) {
        _pauseButton.replaceWith(_unpauseButton);

        _fRange.disabled = true;

        if (pause != null) {
            pause(e);
        }
    }

    void _stop(Event e) {
        _stopButton.disabled = true;
        _stepButton.replaceWith(_playButton);
        _pauseButton.replaceWith(_unpauseButton); //May not always happen
        _unpauseButton.disabled = true;

        _fRange
                ..value = '11'
                ..disabled = true;

        if (stop != null) {
            stop(e);
        }
    }

    void _unpause(Event e) {
        _unpauseButton.replaceWith(_pauseButton);

        _fRange.disabled = false;

        if (unpause != null) {
            unpause(e);
        }
    }
}
