import * as THREE from 'three';
import * as CONST from '../Constants.js';


class RefractingSurface {
	inOutRefractiveIndexRatio;
	colourFactor;

	static glassSurface = new RefractingSurface( 
		1.5,	// BK7(ish)
		CONST.ONE_SURFACE_COLOUR_FACTOR 
	);
	
	constructor(
		inOutRefractiveIndexRatio,
		colourFactor
	) {
		this.inOutRefractiveIndexRatio = inOutRefractiveIndexRatio;
		this.colourFactor = colourFactor;
	}
}

export { RefractingSurface };