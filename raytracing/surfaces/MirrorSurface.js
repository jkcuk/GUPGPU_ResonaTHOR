import * as THREE from 'three';

class MirrorSurface {
	colourFactor;

	static perfectMirrorSurface = new MirrorSurface( new THREE.Vector4(1, 1, 1, 1) );
	
	constructor(
		colourFactor
	) {
		this.colourFactor = colourFactor;
	}
}

export { MirrorSurface };