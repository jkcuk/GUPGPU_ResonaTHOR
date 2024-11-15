import * as THREE from 'three';
import { Util } from '../Util.js';

class RectangleShape {
	corner;
	span1;
	span2;
	nNormal;	// normalised normal, pointing "outwards"

	static zRectangleShape = new RectangleShape( 
		new THREE.Vector3(-0.5, -0.5, 0),	// corner
		new THREE.Vector3(1, 0, 0),	// span1
		new THREE.Vector3(0, 1, 0),	// span2
		new THREE.Vector3(0, 0, 1)	// normal
	);
	
	constructor(
		corner,
		span1,	// span vector 1
		span2,	// span vector 2, needs to be perpendicular to span1
		normal	// normal, pointing "outwards"; needs to be perpendicular to span1 and span2
	) {
		this.corner = corner;
		this.span1 = span1;
		this.span2 = Util.getPartPerpendicularTo1( span2, span1 );
		this.nNormal = Util.getPartPerpendicularTo2( normal, this.span1, this.span2 ).normalize();
	}

	static getRectangleShape(
		corner,
		span1,	// span vector 1
		span2	// span vector 2, needs to be perpendicular to span1
	) {
		return new RectangleShape(
			corner,
			span1,
			span2,
			span1.clone().cross(span2)
		);
	}
}

export { RectangleShape };