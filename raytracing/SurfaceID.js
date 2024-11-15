/**
 * A class that allows each surface to be identified.
 * type: an integer that identifies the type of the surface
 * index: an integer that's the index of the surface in the relevant array in RaytracingScene
 * 
 * Example: type = COLOUR_SURFACE, index = 1 means that the surface is a colour surface whose
 * parameters can be found in raytracingScene.colourSurfaces[1].
 */
class SurfaceID {
	type;	// one of CONST.COLOUR_SURFACE, ...
	index;	// index of the surface in the relevant array in raytracingScene, e.g. raytracingScene.colourSurfaces

	static none = new SurfaceID(-1, -1);

	constructor(
		type,
		index
	) {
		this.type = type;
		this.index = index;
	}
}

export { SurfaceID };