part of main;

void applyGeneralListeners() {
    window.onScroll.listen((Event e) => window.scrollTo(0, 0)); //Lock the window
    
    document.body.onMouseMove.listen((MouseEvent e) {
        e.preventDefault();
        canvas.viewMouse = e.client - canvas.documentOffset;
    });

    ////////////////////////////////////

    timeControls
            ..play = ((Event e) {
                circuit.reset();
                simulation = new TimeSim(redraw, circuit.components);
                stateHandler = new SimulationMouse();
                loadButton.disabled = true;
            })
            ..unpause = ((Event e) => simulation.automate(timeControls.frequency))
            ..pause = ((Event e) => simulation.halt())
            ..step = ((Event e) => simulation.step())
            ..stop = ((Event e) {
                timeControls.pause(e);
                loadButton.disabled = false;
                simulation = null;
                stateHandler = new EmptyMouse();
                circuit.reset();
            });

    ////////////////////////////////////

    selector.onChange.listen((Event e) //Draw table
    {
        const int PREFERRED_COLS = 2;
        int table = int.parse(selector.value);

        Map<String, ComponentFactory> compMap = factoryMapList[table];
        compTable.setInnerHtml(' '); //Clear the old table

        int col = 0;
        void addImage(String key, ComponentFactory cf) {
            if (col == 0) {
                compTable.addRow();
            }
            var cell = compTable.rows.last.addCell();

            cell
                    ..append(cf.image) //Put the factory image and map text in the cell
                    ..appendHtml("<br>")
                    ..appendText(key)
                    ..setAttribute('class', 'cell_border');

            col += (cf.dimensions.x / circuit.cellSize).round(); //Increment the column based on the width of the last image
            col = (col >= PREFERRED_COLS) ? 0 : col; //Clamp the maximum number of columns
        }

        compMap.forEach(addImage);
    });

    StreamSubscription removeSub; //Set the default option of the selector to remove itself on first change and then cancel the listener
    removeSub = selector.onChange.listen((Event e) {
        querySelector('#tempOption').remove();
        removeSub.cancel();
    });

    ////////////////////////////////////

    querySelector('#generateJson').onClick.listen((MouseEvent e) //Generate json string from circuit make it a uri source for a dummy image
    {
    	Map data = circuit.toJson();
    	data['shift'] = [canvas.shift.x, canvas.shift.y];
    	
        String dataUri = window.btoa(JSON.encode(data));
        dummyAnchor..href = 'data:text/plain;base64,' + dataUri
				   ..click();
    });

    ////////////////////////////////////

    InputElement fileInput = querySelector('#loadFile_file');
    loadButton.onClick.listen((MouseEvent e) //Use this button as a front for the file input
    {
        fileInput.click();
    });

    fileInput.onChange.listen((Event e) {
        if (fileInput.files.length > 0) { //If the input has had an upload
            var reader = new FileReader();
            
            reader..onLoad.listen((pe) //File load callback
            {
                window.console.log('File Loaded: "${fileInput.files.last.name}"');
                stateHandler = new EmptyMouse();
                
                try {
                    Map data = JSON.decode(reader.result); //Decode file to JSON map
                    canvas.shift = new Point<int>(data['shift'][0], data['shift'][1]);
                    circuit = new GridCircuit.fromJson(data, factories); //Remove existing components
                } 
                catch (e) {
                    circuit.clear(); //Remove existing components
                    window.alert('Load Aborted: Read error or file corruption');
                }
                
                redraw(); //Make the circuit ir clered space visible
            })
            ..readAsText(fileInput.files.last);            
        }
    });
}
