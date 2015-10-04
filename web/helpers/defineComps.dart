part of main;

void defineComps() {
    ImageElement genCompImage(ComponentFactory cf) => new ImageElement(src: 'images/${cf.type}.png')
			..setAttribute('draggable', 'false')
        	..onClick.listen((MouseEvent e) => stateHandler.selectComponent(cf));

    void drawBasicComponent(Component c, CanvasRenderingContext2D context) //A basic draw method for CopyComponents with static images
    {
        context.drawImage(c.image, c.position.x, c.position.y);
    }

    Map<String, ComponentFactory> createOption(String pageName) {
        factoryMapList.add(new Map<String, ComponentFactory>()); //Create and add the map
        selector.appendHtml('<option value="${factoryMapList.length - 1}"> ${pageName} </option>'); //Create and appand the select option
        return factoryMapList.last; //Return the new map
    }

    Map<String, ComponentFactory> map;

    map = createOption('Utility');
    //////////////////////////////////////

    map['Source'] = new ComponentFactory();
    map['Source']
            ..type = 'source'
            ..addOutput('Q', 66, 37)
            ..image = genCompImage(map['Source'])
            ..propagationDelay = 0
            ..drawFunc = ((Component c, dynamic context) {
                //Draw a colorful circle c.inside the output
                if (simulationActive) {
                    context
                            ..beginPath()
                            ..arc(c.position.x + 35, c.position.y + 38, 23, 0, 2 * PI)
                            ..closePath()

                            ..fillStyle = SimCanvasElement.getColor(c.storage['state'], 0.5)
                            ..fill();
                }

                drawBasicComponent(c, context); //Draw the component image
            })
            ..logicFunc = ((Component c) {
                return {
                    'Q': (c.storage['state'] == null) ? Tri.BOTH : c.storage['state']
                };
            });

    map['Splitter'] = new ComponentFactory();
    map['Splitter']
            ..type = 'splitter'
            ..addInput('A', 38, 38)
            ..addOutput('Q0', 20, 38)
            ..addOutput('Q1', 38, 20)
            ..addOutput('Q2', 55, 38)
            ..addOutput('Q3', 38, 55)
            ..image = genCompImage(map['Splitter'])
            ..propagationDelay = 0
            ..drawFunc = drawBasicComponent
            ..logicFunc = ((Component c) {
                return {
                    'Q0': c.ins['A'],
                    'Q1': c.ins['A'],
                    'Q2': c.ins['A'],
                    'Q3': c.ins['A']
                };
            });

    map['Not'] = new ComponentFactory();
    map['Not']
            ..type = 'not'
            ..addInput('A', 9, 37)
            ..addOutput('Q', 68, 38)
            ..image = genCompImage(map['Not'])
            ..drawFunc = drawBasicComponent
            ..logicFunc = ((Component c) {
                return {
                    'Q': -c.ins['A']
                };
            });

    map['Buffer'] = new ComponentFactory();
    map['Buffer']
            ..type = 'buffer'
            ..addInput('A', 8, 37)
            ..addOutput('Q', 68, 38)
            ..image = genCompImage(map['Buffer'])
            ..drawFunc = drawBasicComponent
            ..logicFunc = ((Component c) {
                return {
                    'Q': c.ins['A']
                };
            });

    map['Output'] = new ComponentFactory();
    map['Output']
            ..type = 'output'
            ..addInput('A', 9, 37)
            ..image = genCompImage(map['Output'])
            ..drawFunc = ((Component c, dynamic context) {
                //Draw a colorful circle inside the output
                if (simulationActive) {
                    context
                            ..beginPath()
                            ..arc(c.position.x + 39, c.position.y + 38, 23, 0, 2 * PI)
                            ..closePath()

                            ..fillStyle = SimCanvasElement.getColor(c.ins['A'].asTri, 0.5)
                            ..fill();
                }

                drawBasicComponent(c, context); //Draw the component image
            })
            ..logicFunc = ((Component c) {
                return null; //Lamps have no possible dependants
            });

    map['Clock'] = new ComponentFactory();
    map['Clock']
            ..type = 'clock'
            ..addOutput('Q', 38, 8)
            ..selfDependent = true
            ..image = genCompImage(map['Clock'])
            ..propagationDelay = 5
            ..drawFunc = drawBasicComponent
            ..logicFunc = ((Component c) {
                return {
                    'Q': (c.outs['Q'].asTri == Tri.BOTH) ? Tri.TRUE : -c.outs['Q']
                };
            });



    map = createOption('2-Input Gates');
    //////////////////////////////////////////////////

    map['And'] = new ComponentFactory();
    map['And']
            ..type = 'and2'
            ..addInput('A', 8, 24)
            ..addInput('B', 8, 52)
            ..addOutput('Q', 67, 38)
            ..image = genCompImage(map['And'])
            ..drawFunc = drawBasicComponent
            ..logicFunc = ((Component c) {
                return {
                    'Q': c.ins['A'] & c.ins['B']
                };
            });

    map['Nand'] = new ComponentFactory();
    map['Nand']
            ..type = 'nand2'
            ..addInput('A', 8, 24)
            ..addInput('B', 8, 52)
            ..addOutput('Q', 67, 38)
            ..image = genCompImage(map['Nand'])
            ..drawFunc = drawBasicComponent
            ..logicFunc = ((Component c) {
                return {
                    'Q': -(c.ins['A'] & c.ins['B'])
                };
            });

    map['Or'] = new ComponentFactory();
    map['Or']
            ..type = 'or2'
            ..addInput('A', 8, 24)
            ..addInput('B', 8, 52)
            ..addOutput('Q', 67, 38)
            ..image = genCompImage(map['Or'])
            ..drawFunc = drawBasicComponent
            ..logicFunc = ((Component c) {
                return {
                    'Q': c.ins['A'] | c.ins['B']
                };
            });

    map['Nor'] = new ComponentFactory();
    map['Nor']
            ..type = 'nor2'
            ..addInput('A', 8, 24)
            ..addInput('B', 8, 52)
            ..addOutput('Q', 67, 38)
            ..image = genCompImage(map['Nor'])
            ..drawFunc = drawBasicComponent
            ..logicFunc = ((Component c) {
                return {
                    'Q': -(c.ins['A'] | c.ins['B'])
                };
            });

    map['Xor'] = new ComponentFactory();
    map['Xor']
            ..type = 'xor2'
            ..addInput('A', 8, 24)
            ..addInput('B', 8, 52)
            ..addOutput('Q', 67, 38)
            ..image = genCompImage(map['Xor'])
            ..drawFunc = drawBasicComponent
            ..logicFunc = ((Component c) {
                return {
                    'Q': c.ins['A'] ^ c.ins['B']
                };
            });



    map = createOption('3-Input Gates');
    /////////////////////////////////////////

    map['And'] = new ComponentFactory();
    map['And']
            ..type = 'and3'
            ..addInput('A', 8, 21)
            ..addInput('B', 8, 37)
            ..addInput('C', 8, 53)
            ..addOutput('Q', 67, 38)
            ..image = genCompImage(map['And'])
            ..drawFunc = drawBasicComponent
            ..logicFunc = ((Component c) {
                return {
                    'Q': c.ins['A'] & c.ins['B'] & c.ins['C']
                };
            });

    map['Nand'] = new ComponentFactory();
    map['Nand']
            ..type = 'nand3'
            ..addInput('A', 8, 21)
            ..addInput('B', 8, 37)
            ..addInput('C', 8, 53)
            ..addOutput('Q', 67, 38)
            ..image = genCompImage(map['Nand'])
            ..drawFunc = drawBasicComponent
            ..logicFunc = ((Component c) {
                return {
                    'Q': -(c.ins['A'] & c.ins['B'] & c.ins['C'])
                };
            });

    map['Or'] = new ComponentFactory();
    map['Or']
            ..type = 'or3'
            ..addInput('A', 8, 21)
            ..addInput('B', 8, 37)
            ..addInput('C', 8, 53)
            ..addOutput('Q', 67, 38)
            ..image = genCompImage(map['Or'])
            ..drawFunc = drawBasicComponent
            ..logicFunc = ((Component c) {
                return {
                    'Q': c.ins['A'] | c.ins['B'] | c.ins['C']
                };
            });

    map['Nor'] = new ComponentFactory();
    map['Nor']
            ..type = 'nor3'
            ..addInput('A', 8, 21)
            ..addInput('B', 8, 37)
            ..addInput('C', 8, 53)
            ..addOutput('Q', 67, 38)
            ..image = genCompImage(map['Nor'])
            ..drawFunc = drawBasicComponent
            ..logicFunc = ((Component c) {
                return {
                    'Q': -(c.ins['A'] | c.ins['B'] | c.ins['C'])
                };
            });

    map['Xor'] = new ComponentFactory();
    map['Xor']
            ..type = 'xor3'
            ..addInput('A', 8, 21)
            ..addInput('B', 8, 37)
            ..addInput('C', 8, 53)
            ..addOutput('Q', 67, 38)
            ..image = genCompImage(map['Xor'])
            ..drawFunc = drawBasicComponent
            ..logicFunc = ((Component c) {
                return {
                    'Q': c.ins['A'] ^ c.ins['B'] ^ c.ins['C']
                };
            });



    map = createOption('Flip-Flops');
    ////////////////////////////////////////////////

    Function flipFlopBase(Function f) { //Accpets a function to create a function
	    var RSTable = [[Tri.BOTH, Tri.BOTH, Tri.FALSE], //Row -> R: 0
	        		   [Tri.BOTH, Tri.BOTH, Tri.BOTH], //Col -> S: 0
	       			   [Tri.TRUE, Tri.BOTH, null]];
	    
	    Map<String, Tristate> result(Component c) {
	    	Tri q = RSTable[c.ins['R'].asTri.asInt][c.ins['S'].asTri.asInt];
            if(q == null) { //Set and Reset are high
                if (c.ins['CLK'].asTri == Tri.TRUE && c.storage['clockPast'] == Tri.FALSE) {//Is rising edge
                    q = f(c);
                }
            }

            c.storage['clockPast'] = c.ins['CLK'].asTri; //Record the clock state without exception
            return (q == null) ? null : {
                'Q' :  q,
                '-Q': -q
            };
	    }
	    return result;
    }

    map['Toggle'] = new ComponentFactory(); //Define a rising-edge toggle flip-flop
    map['Toggle']
            ..type = 'toggle'
            ..addInput('S', 75, 10)
            ..addInput('T', 35, 60)
            ..addInput('CLK', 35, 90)
            ..addInput('R', 75, 140)
            ..addOutput('Q', 115, 60)
            ..addOutput('-Q', 115, 90)
            ..image = genCompImage(map['Toggle'])
            ..drawFunc = drawBasicComponent
            ..logicFunc = flipFlopBase((Component c) => (c.ins['T'].asTri == Tri.TRUE) ? -c.outs['Q'] : null); //Toggle logic
    

    map['D'] = new ComponentFactory(); //Define a rising-edge toggle flip-flop
    map['D']
            ..type = 'd'
            ..addInput('S', 75, 10)
            ..addInput('D', 35, 60)
            ..addInput('CLK', 35, 90)
            ..addInput('R', 75, 140)
            ..addOutput('Q', 115, 60)
            ..addOutput('-Q', 115, 90)
            ..image = genCompImage(map['D'])
            ..drawFunc = drawBasicComponent
            ..logicFunc = flipFlopBase((Component c) => c.ins['D'].asTri);
             

    map['JK'] = new ComponentFactory(); //Define a rising-edge toggle flip-flop
    map['JK']
            ..type = 'jk'
            ..addInput('S', 75, 10)
            ..addInput('J', 35, 53)
            ..addInput('CLK', 35, 76)
            ..addInput('K', 35, 99)
            ..addInput('R', 75, 140)
            ..addOutput('Q', 115, 60)
            ..addOutput('-Q', 115, 90)
            ..image = genCompImage(map['JK'])
            ..drawFunc = drawBasicComponent
            ..logicFunc = flipFlopBase((Component c) {//JK Logic definition
			        var temp = [[null,	   Tri.BOTH, Tri.FALSE], //Row -> J: 0
					            [Tri.BOTH, Tri.BOTH, Tri.BOTH], //Col -> K: 0
					            [Tri.TRUE, Tri.BOTH, -c.outs['Q']]];
			
			        return temp[c.ins['J'].asTri.asInt][c.ins['K'].asTri.asInt]; //Access the appropriate member
    			});

}




