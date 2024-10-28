import * as THREE from 'three';

class Util {
    static get xHat() { return new THREE.Vector3(1, 0, 0); }   // making this a getter means each xHat is re-created, so mutable functions can be called
    static get yHat() { return new THREE.Vector3(0, 1, 0); }
    static get zHat() { return new THREE.Vector3(0, 0, 1); }

    static white = new THREE.Vector4(1, 1, 1, 1);
	static black = new THREE.Vector4(0, 0, 0, 1);
	static red = new THREE.Vector4(1, 0, 0, 1);
	static green = new THREE.Vector4(0, 1, 0, 1);
	static blue = new THREE.Vector4(0, 0, 1, 1);
    static gray20 = new THREE.Vector4(0.2, 0.2, 0.2, 1);
    static gray40 = new THREE.Vector4(0.4, 0.4, 0.4, 1);
    static gray60 = new THREE.Vector4(0.6, 0.6, 0.6, 1);
    static gray80 = new THREE.Vector4(0.8, 0.8, 0.8, 1);

    static coefficient2colourFactor(coefficient) {
        return new THREE.Vector4(coefficient, coefficient, coefficient, 1.);
    }

    /** returns the part of v that's perpendicular to w */
    static getPartPerpendicularTo1(v, w) {
        // console.log("Util.getPartPerpendicularTo(", v, ", ", w, ")");
        return v.clone().sub(v.clone().projectOnVector(w));
    }

    /** returns the part of v that's perpendicular to w1 and w2 */
    static getPartPerpendicularTo2(v, w1, w2) {
        // console.log("Util.getPartPerpendicularTo(", v, ", ", w1, ", ", w2, ")");
        return v.clone().projectOnVector( w1.clone().cross(w2) ).normalize();
    }
}

export { Util }