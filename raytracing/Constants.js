import * as THREE from 'three';

// THESE CONSTANTS MUST TAKE THE SAME VALUES AS THE CONSTANTS IN fragmentShader.glsl
export const MAX_SCENE_OBJECTS = 10;	// max number of scene objects
export const MAX_RECTANGLE_SHAPES = 10;
export const MAX_SPHERE_SHAPES = 10;
export const MAX_CYLINDER_MANTLE_SHAPES = 10;
export const MAX_COLOUR_SURFACES = 10;
export const MAX_MIRROR_SURFACES = 10;
export const MAX_THIN_FOCUSSING_SURFACES = 10;
export const MAX_CHECKERBOARD_SURFACES = 2;	// must be the same as MAX_CHECKERBOARD_SURFACES in fragmentShader.glsl

// the shapeTypes of the supported shapes
export const RECTANGLE_SHAPE = 0;	// must be the same as RECTANGLE_SHAPE in fragmentShader.glsl
export const SPHERE_SHAPE = 1;	// must be the same as SPHERE_SHAPE in fragmentShader.glsl
export const CYLINDER_MANTLE_SHAPE = 2;	// must be the same as CYLINDER_MANTLE_SHAPE in fragmentShader.glsl
// export const DISC = 3;	//
// TODO: add triangle etc.

// the surfaceTypes of the supported surfaces
export const COLOUR_SURFACE = 0;	// must be the same as COLOUR_SURFACE in fragmentShader.glsl
export const MIRROR_SURFACE = 1;	// must be the same as MIRROR_SURFACE in fragmentShader.glsl
export const THIN_FOCUSSING_SURFACE = 2;	// must be the same as THIN_FOCUSSING_SURFACE in fragmentShader.glsl
export const CHECKERBOARD_SURFACE = 3;	// must be the same as CHECKERBOARD_SURFACE in fragmentShader.glsl

// refraction types
export const IDEAL_REFRACTION_TYPE = 0;
export const PHASE_HOLOGRAM_REFRACTION_TYPE = 1;

// focussing types
export const SPHERICAL_FOCUSSING_TYPE = 0;
export const CYLINDRICAL_FOCUSSING_TYPE = 1;
export const TORIC_FOCUSSING_TYPE = 2;

// default transmission coefficients...
export const ONE_SURFACE_TRANSMISSION_COEFFICIENT = 0.96;	// approx. transmission coefficient of a typical air-glass interface
export const TWO_SURFACE_TRANSMISSION_COEFFICIENT = 0.9216;	// approx. transmission coefficient of two typical air-glass interfaces

// ... and colour factors
export const ONE_SURFACE_COLOUR_FACTOR = new THREE.Vector4(
	ONE_SURFACE_TRANSMISSION_COEFFICIENT,
	ONE_SURFACE_TRANSMISSION_COEFFICIENT,
	ONE_SURFACE_TRANSMISSION_COEFFICIENT,
	1
);export const TWO_SURFACE_COLOUR_FACTOR = new THREE.Vector4(
	TWO_SURFACE_TRANSMISSION_COEFFICIENT,
	TWO_SURFACE_TRANSMISSION_COEFFICIENT,
	TWO_SURFACE_TRANSMISSION_COEFFICIENT,
	1
);