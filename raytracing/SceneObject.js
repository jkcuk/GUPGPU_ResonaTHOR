import { ShapeID } from './ShapeID.js';
import { SurfaceID } from './SurfaceID.js';

class SceneObject {
	visible;
	shapeID;
	surfaceID;

	static none = new SceneObject( true, ShapeID.none, SurfaceID.none );

	constructor(
		visible,
		shapeID,
		surfaceID
	) {
		this.visible = visible;
		this.shapeID = shapeID;
		this.surfaceID = surfaceID;
	}
}

export { SceneObject };