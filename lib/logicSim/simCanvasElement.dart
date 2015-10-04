part of logicSim;

//View-space: the pixel coordinates of the canvas according the the browser
//Component-space: the pixel coordinates of the Components and Canvas

class SimCanvasElement extends CanvasElement {
	//Statics
	static String getColor(dynamic key, num alpha) {
		alpha = (alpha < 0) ? 0 : alpha;
		alpha = (alpha > 1) ? 1 : alpha;

		return _colorMap[key] + '${alpha})';
	}

	static void addColor(dynamic key, int r, int g, int b) {
		_colorMap[key] = 'rgba($r, $g, $b, ';
	}
	
	static Map<dynamic, String> _colorMap = {
		null: 'rgba(255, 255, 0, ',
		'BLACK': 'rgba(0, 0, 0, ',
		'RED': 'rgba(255, 0, 0, ',
		'LIGHT_GREY': 'rgba(200, 200, 200, ',
		'DARK_GREY': 'rgba(100, 100, 100, ',
		Tri.TRUE: 'rgba(255, 0, 0, ',
		Tri.FALSE: 'rgba(0, 0, 0, ',
		Tri.BOTH: 'rgba(255, 255, 0, '
	};
	
	static final String TAG = 'x-sim_canvas';
	static final String SUPER_TAG = 'canvas';
	static bool _registered = false;
	
	//Data
	Point<int> shift = new Point<int>(0, 0);
	Point<int> _mouse = new Point<int>(0, 0); //Mouse posiiton in view space

	//Consructor
	SimCanvasElement.created() : super.created() { }
	
	factory SimCanvasElement([Point<int> shift, CanvasElement replacing]) {
		if(!_registered) {
			document.registerElement(TAG, SimCanvasElement, extendsTag:SUPER_TAG);
			_registered = true;
		}

		SimCanvasElement ret = new Element.tag(SUPER_TAG, TAG);
		if(shift != null) { ret.shift = shift; }
		if(replacing != null) { replacing.attributes.forEach((String k, String v) => ret.attributes[k] = v); } //Copy attributes of replacing Canvas
		return ret;
	}
	
	//Methods
	Rectangle<int> get view => new Rectangle<int>(shift.x, shift.y, parent.borderEdge.width, parent.borderEdge.height);

	Point<int> get compMouse => _mouse + shift; //Mouse position in component space
			   set viewMouse(Point<int> p) => _mouse = p;

	CanvasRenderingContext2D get context2D {
		_reset();
		_transform();
		super.context2D.beginPath(); //Disconnect all new paths from other function calls
		return super.context2D;
	}

	void _transform() => super.context2D.translate(-shift.x, -shift.y); //Work in component space
	void _reset() {
		super.context2D
			..setTransform(1, 0, 0, 1, 0, 0)
			..globalAlpha = 1;
	}

	void clear() {
		_reset();
		super.context2D.clearRect(0, 0, width, height);
	}

	void drawGrid(int dim) {
		_reset();

		int gridCols = (width ~/ dim) + 1;
		int gridRows = (height ~/ dim) + 1;

		super.context2D
				..lineWidth = 1
				..strokeStyle = getColor('LIGHT_GREY', 1)
				..beginPath();

		for (int i = 0; i <= gridCols; i++) { //Draw the vertical lines
			super.context2D
					..moveTo((i * dim) - (shift.x % dim), 0)
					..lineTo((i * dim) - (shift.x % dim), height);
		}

		for (int i = 0; i <= gridRows; i++) { //Draw the vertical lines
			super.context2D
					..moveTo(0, (i * dim) - (shift.y % dim))
					..lineTo(width, (i * dim) - (shift.y % dim));
		}

		super.context2D.stroke();
	}

	void drawCrosshair() {
		_reset();

		super.context2D
			..lineWidth = 1
			..strokeStyle = getColor('DARK_GREY', 1)

			..beginPath()
			..moveTo(_mouse.x, 0)
			..lineTo(_mouse.x, height)
			..moveTo(0, _mouse.y)
			..lineTo(width, _mouse.y)

			..stroke();
	}

	void drawWires(Iterable<Wire> wires, [bool enableColour = false]) {
		super.context2D.lineWidth = 3;
		_reset();
		_transform();

		for (Wire w in wires) {
			List<Point<int>> path = w.path;

			super.context2D
					..beginPath()
					..moveTo(path.first.x, path.first.y)
					..strokeStyle = getColor(enableColour ? w.asTri : 'BLACK', 1);
			
			for (int i = 1; i < path.length; i++) {
				super.context2D.lineTo(path[i].x, path[i].y);
			}

			super.context2D.stroke();
		}
	}

	void drawComponents(Iterable<Component> comps) {
		_reset();
		_transform();

		for (Component c in comps) {
			super.context2D.beginPath();
			c.draw(super.context2D);
		}
	}

	void drawNodes(Iterable<InternalNode> nodes) //Define a function to circle a p
	{
		_reset();
		_transform();

		super.context2D
			..beginPath()
			..lineWidth = 1
			..strokeStyle = getColor('BLACK', 0.3);

		for (InternalNode n in nodes) {
			super.context2D
				..moveTo(n.position.x + NODE_RADIUS, n.position.y) //Move to the start of the circle
				..arc(n.position.x, n.position.y, NODE_RADIUS, 0, 2 * PI); //Arc the circle
		}

		super.context2D.stroke();
	}
}
