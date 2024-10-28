class SceneObject {
	visible;
	shapeType;
	shapeIndex;
	surfaceType;
	surfaceIndex;	// normalised normal, pointing "outwards"

	static default = new SceneObject( false, 0, 0, 0, 0 );

	constructor(
		visible,
		shapeType,	// e.g. RECTANGLE
		shapeIndex,	// e.g. the second rectangle in the array of rectangles
		surfaceType,	// e.g. COLOUR
		surfaceIndex	// e.g. the third colour in the array of colours
	) {
		this.visible = visible;
		this.shapeType = shapeType;
		this.shapeIndex = shapeIndex;
		this.surfaceType = surfaceType;
		this.surfaceIndex = surfaceIndex;
	}

	// // the GLSL code to deal with scene objects
	// static getGLSLCode() {
	// 	return `
	// 		struct SceneObject {
	// 			bool visible;
	// 			int shapeType;
	// 			int shapeIndex;
	// 			int surfaceType;
	// 			int surfaceIndex; 
	// 		};
	// 	`;
	// }
}

export { SceneObject };