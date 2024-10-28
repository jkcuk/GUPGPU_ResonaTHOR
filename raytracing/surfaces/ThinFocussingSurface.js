import * as THREE from 'three';
import * as CONST from '../Constants.js';

class ThinFocussingSurface {
	principalPoint;
	opticalPower;	// optical power
	focussingType;	// one of SPHERICAL_FOCUSSING_TYPE, CYLINDRICAL_FOCUSSING_TYPE, TORIC_FOCUSSING_TYPE
	nOpticalPowerDirection;	// normalised vector in optical-power direction
	reflective;	// true = mirror
	refractionType;	// one of IDEAL_REFRACTION_TYPE, PHASE_HOLOGRAM_REFRACTION_TYPE
	colourFactor;

	static idealThinLensSurface = new ThinFocussingSurface( 
		new THREE.Vector3(0, 0, 0),	// principalPoint
		1,	// opticalPower
		CONST.SPHERICAL_FOCUSSING_TYPE,	// focussing type
		new THREE.Vector3(1, 0, 0),	// optical-power direction
		false,	// reflective
		CONST.IDEAL_REFRACTION_TYPE,	// refraction type
		CONST.TWO_SURFACE_COLOUR_FACTOR
	);
	
	constructor(
		principalPoint,
		opticalPower,
		focussingType,
		opticalPowerDirection,
		reflective,
		refractionType,
		colourFactor
	) {
		this.principalPoint = principalPoint;
		this.opticalPower = opticalPower;
		this.focussingType = focussingType;
		this.nOpticalPowerDirection = opticalPowerDirection.normalize();
		this.reflective = reflective;
		this.refractionType = refractionType;
		this.colourFactor = colourFactor;
	}
}

export { ThinFocussingSurface };