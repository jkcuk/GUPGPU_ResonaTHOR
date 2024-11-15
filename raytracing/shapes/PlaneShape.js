import * as THREE from 'three';
import { Util } from '../Util.js';

class PlaneShape {
	pointOnPlane;
	nNormal;	// normalised normal, pointing "outwards"

	static zPlaneShape = new PlaneShape( 
		new THREE.Vector3(0, 0, 0),	// pointOnPlane
		new THREE.Vector3(0, 0, 1)	// normal
	);
	
	constructor(
		pointOnPlane,
		normal	// normal, pointing "outwards"; needs to be perpendicular to span1 and span2
	) {
		this.pointOnPlane = pointOnPlane;
		this.nNormal = normal.normalize();
	}
}

export { PlaneShape };