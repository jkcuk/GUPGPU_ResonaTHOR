/**
 * A class that allows each shape to be identified.
 * type: an integer that identifies the type of the shape
 * index: an integer that's the index of the shape in the relevant array in RaytracingScene
 * 
 * Example: type = RECTANGLE_SHAPE, index = 1 means that the shape is a rectangle whose
 * parameters can be found in raytracingScene.rectangleShapes[1].
 */
class ShapeID {
	type;	// one of CONST.RECTANGLE_SHAPE, ...
	index;	// index of the shape in the relevant array in raytracingScene, e.g. raytracingScene.rectangleShapes

	static none = new ShapeID(-1, -1);

	constructor(
		type,
		index
	) {
		this.type = type;
		this.index = index;
	}
}

export { ShapeID };