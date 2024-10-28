import * as THREE from 'three';

class ColourSurface {
	colourFactor;	// multiplies the ray's colour
	semitransparent;

	static white = new ColourSurface( new THREE.Vector4(1, 1, 1, 1), false );
	static black = new ColourSurface( new THREE.Vector4(0, 0, 0, 1), false );
	static red = new ColourSurface( new THREE.Vector4(1, 0, 0, 1), false );
	static green = new ColourSurface( new THREE.Vector4(0, 1, 0, 1), false );
	static blue = new ColourSurface( new THREE.Vector4(0, 0, 1, 1), false );

	constructor(
		colourFactor,
		semitransparent
	) {
		this.colourFactor = colourFactor;
		this.semitransparent = semitransparent;
	}
}

export { ColourSurface };