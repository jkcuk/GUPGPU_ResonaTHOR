import * as THREE from 'three';
import { Util } from '../Util.js';

class CylinderMantleShape {
	centre;
	radius;
	radius2;	// radius^2
	length;
	nAxis;	// unit vector in cylinder-axis direction
	nPhi0;	// unit vector in the direction of phi = 0 (perp. to nAxis)
	nPhi90;	// unit vector in the direction of phi = 90° (perp. to nAxis)

	static xCylinderMantleShape = new CylinderMantleShape( 
		new THREE.Vector3(0, 0, 0),	// centre
		1,	// radius
		1,	// length
		new THREE.Vector3(1, 0, 0),	// axis
		new THREE.Vector3(0, 1, 0),	// phi0
		new THREE.Vector3(0, 0, 1)	// phi90
	);

	static getCylinderMantleShape(
		centre,
		radius,
		length,
		axis
	) {
		let phi0 = Util.getANormalTo(axis);
		return new CylinderMantleShape(
			centre,
			radius,
			length,
			axis,
			phi0,
			Util.crossProduct(axis, phi0)
		);
	}
	
	constructor(
		centre,
		radius,
		length,
		axis,
		phi0,
		phi90
	) {
		this.centre = centre;
		this.radius = radius;
		this.radius2 = radius*radius;
		this.length = length;
		this.nAxis = axis.normalize();
		this.nPhi0 = Util.getPartPerpendicularTo1( phi0, this.nAxis ).normalize();
		this.nPhi90 = Util.getPartPerpendicularTo2( phi90, this.nAxis, this.nPhi0 ).normalize();
	}
}

export { CylinderMantleShape };