part of main;

void applyCanvasParentListeners() {
    Element around = canvas.parent.parent;

    around.onMouseUp.listen((MouseEvent e) {
        e.preventDefault();

        stateHandler.mouseUp(e);
    });

    around.onMouseDown.listen((MouseEvent e) {
        e.preventDefault();

        stateHandler.mouseDown(e);

        canvas.focus();
        return false;
    });

    around.onMouseMove.listen((MouseEvent e) {
        e.preventDefault();

        stateHandler.mouseMove(e);
    });

    around.onMouseLeave.listen((MouseEvent e) {
        e.preventDefault();

        stateHandler.mouseLeave(e);
    });

    around.onKeyUp.listen((KeyboardEvent e) {
        e.preventDefault();

        int code = (new KeyEvent.wrap(e)).keyCode;
        stateHandler.keyUp(code);
    });

    around.onKeyDown.listen((KeyboardEvent e) {
        e.preventDefault();

        int code = (new KeyEvent.wrap(e)).keyCode;
        stateHandler.keyDown(code);
    });

    //Automatic
    Rectangle<int> oldView = canvas.view;
    new Timer.periodic(new Duration(milliseconds: 100), (Timer t) {
        if (oldView.width != canvas.view.width || oldView.height != canvas.view.height) {
            oldView = canvas.view;

            canvas.width = canvas.view.width;
            canvas.height = canvas.view.height;

            redraw();
        }
    });
}
