precision highp float;

#define PI 3.1415926538

// these constants must take the same values as those defined in Constants.js
#define MAX_SCENE_OBJECTS 16

#define MAX_RECTANGLE_SHAPES 10
#define MAX_SPHERE_SHAPES 4
#define MAX_CYLINDER_MANTLE_SHAPES 4
#define MAX_PLANE_SHAPES 4
#define MAX_SOLID_GEOMETRY_SHAPES 4

#define MAX_CHECKERBOARD_SURFACES 2
#define MAX_COLOUR_SURFACES 10
#define MAX_MIRROR_SURFACES 10
#define MAX_REFRACTING_SURFACES 10
#define MAX_THIN_FOCUSSING_SURFACES 10

#define MAX_INTERSECTING_SHAPES 4

// shapes
#define RECTANGLE_SHAPE 0
#define SPHERE_SHAPE 1
#define CYLINDER_MANTLE_SHAPE 2
#define PLANE_SHAPE 3
#define SOLID_GEOMETRY_SHAPE 10

// surfaces
#define COLOUR_SURFACE 0
#define MIRROR_SURFACE 1
#define THIN_FOCUSSING_SURFACE 2
#define CHECKERBOARD_SURFACE 3
#define REFRACTING_SURFACE 4	// TODO add functions!

// focussing types
#define SPHERICAL_FOCUSSING_TYPE 0
#define CYLINDRICAL_FOCUSSING_TYPE 1
#define TORIC_FOCUSSING_TYPE 2

// refraction types
#define IDEAL_REFRACTION_TYPE 0
#define PHASE_HOLOGRAM_REFRACTION_TYPE 1

// background types
#define TEXTURE_BACKGROUND_TYPE 0
#define COLOUR_BACKGROUND_TYPE 1


const float TOO_FAR = 1e20;
const float TOO_CLOSE = .5e-4;



varying vec3 intersectionPoint;

struct ShapeID {
	int type;
	int index;
};

struct SurfaceID {
	int type;
	int index;
};

//
// scene objects
//

struct SceneObject {
	bool visible;
	ShapeID shapeID;
	SurfaceID surfaceID; 
};
uniform SceneObject sceneObjects[MAX_SCENE_OBJECTS];
uniform int noOfSceneObjects;


//
// shapes
//

struct RectangleShape {
	vec3 corner;
	vec3 span1;
	vec3 span2;
	vec3 nNormal; 
};
uniform RectangleShape rectangleShapes[MAX_RECTANGLE_SHAPES];

struct SphereShape {
	vec3 centre;
	float radius2;	// radius^2
	vec3 nTheta0;	// unit vector in the direction of theta = 0 (north pole)
	vec3 nPhi0;	// unit vector in the direction of phi = 0 (on the equator)
	vec3 nPhi90;	// unit vector in the direction of phi = 90° (on the equator)
};
uniform SphereShape sphereShapes[MAX_SPHERE_SHAPES];

struct CylinderMantleShape {
	vec3 centre;
	float radius;
	float radius2;	// radius^2
	float length;
	vec3 nAxis;	// unit vector in cylinder-axis direction
	vec3 nPhi0;	// unit vector in the direction of phi = 0 (perp. to nAxis)
	vec3 nPhi90;	// unit vector in the direction of phi = 90° (perp. to nAxis)
};
uniform CylinderMantleShape cylinderMantleShapes[MAX_CYLINDER_MANTLE_SHAPES];

struct PlaneShape {
	vec3 pointOnPlane;
	vec3 nNormal;
};
uniform PlaneShape planeShapes[MAX_PLANE_SHAPES];

struct SolidGeometryShape {
	ShapeID shapeIDs[MAX_INTERSECTING_SHAPES];
	bool visible[MAX_INTERSECTING_SHAPES];
	bool insideOut[MAX_INTERSECTING_SHAPES];
	bool clipping[MAX_INTERSECTING_SHAPES];
	int noOfShapes;
};
uniform SolidGeometryShape solidGeometryShapes[MAX_SOLID_GEOMETRY_SHAPES];

//
// surfaces
//

struct CheckerboardSurface {
	float width1;	// width (in surface coordinate 1 of the shape) of checkers in direction 1
	float width2;	// width (in surface coordinate 2 of the shape) of checkers in direction 2
	vec4 colourFactor1;	// multiplies the ray's colour if checkers of type 1 are intersected
	vec4 colourFactor2;	// multiplies the ray's colour if checkers of type 2 are intersected
	bool semitransparent1;	// true if the checkers of type 1 are semi-transparent, false otherwise
	bool semitransparent2;	// true if the checkers of type 2 are semi-transparent, false otherwise
};
uniform CheckerboardSurface checkerboardSurfaces[MAX_CHECKERBOARD_SURFACES];

struct ColourSurface {
	vec4 colourFactor;
	bool semitransparent; 
};
uniform ColourSurface colourSurfaces[MAX_COLOUR_SURFACES];

struct MirrorSurface {
	vec4 colourFactor;
};
uniform MirrorSurface mirrorSurfaces[MAX_MIRROR_SURFACES];

struct RefractingSurface {
	float inOutRefractiveIndexRatio;
	vec4 colourFactor;
};
uniform RefractingSurface refractingSurfaces[MAX_REFRACTING_SURFACES];

struct ThinFocussingSurface {
	vec3 principalPoint;
	float opticalPower;
	int focussingType;
	vec3 nOpticalPowerDirection;
	bool reflective;
	int refractionType;
	vec4 colourFactor;
};
uniform ThinFocussingSurface thinFocussingSurfaces[MAX_THIN_FOCUSSING_SURFACES];

uniform int maxTraceLevel;

// background
uniform int backgroundType;
uniform sampler2D backgroundTexture;
uniform vec4 backgroundColour;

// the camera's wide aperture
uniform float focusDistance;
uniform int noOfRays;
uniform vec3 apertureXHat;
uniform vec3 apertureYHat;
uniform vec3 viewDirection;
uniform float apertureRadius;
uniform float randomNumbersX[100];
uniform float randomNumbersY[100];


//
// findIntersectionWith<...> functions
//

bool findIntersectionWithRectangleShape(
	vec3 s, // ray start point, origin 
	vec3 nD, // normalised ray direction 
	int rectangleIndex,
	out vec3 intersectionPosition,
	out float intersectionDistance
) {
	// if the ray is parallel to the rectangle; there is no intersection 
	float d = dot(nD, rectangleShapes[rectangleIndex].nNormal);
	if (d == 0.) {
		return false;
	}
	
	// calculate delta to check for intersections 
	float delta = dot(rectangleShapes[rectangleIndex].corner - s, rectangleShapes[rectangleIndex].nNormal) / d;
	if (delta<0.) {
		// intersection with rectangle is in backward direction
		return false;
	}

	// calculate the intersection position
	intersectionPosition = s + delta*nD;

	// does the intersection position lie within the rectangle 
	// (or elsewhere on the plane of the rectangle)?
	vec3 v = intersectionPosition - rectangleShapes[rectangleIndex].corner;

	float x1 = dot(v, rectangleShapes[rectangleIndex].span1);
	if( (x1 < 0.) || (x1 > dot(rectangleShapes[rectangleIndex].span1, rectangleShapes[rectangleIndex].span1)) ) { return false; }
	float x2 = dot(v, rectangleShapes[rectangleIndex].span2);
	if(x2 < 0. || x2 > dot(rectangleShapes[rectangleIndex].span2, rectangleShapes[rectangleIndex].span2)) { return false; }

	// the intersection position lies within the rectangle
	intersectionDistance = delta;	// if nD is not normalised: delta*length(nD);
	return true;
}

// find the smallest positive solution for delta of the equation
//  a delta^2 + b delta + c = 0,
// or
//  delta^2 + (b/a) delta + (c/a) = 0
bool calculateDelta(
	float bOverA,
	float cOverA,
	out float delta
) {
	// calculate the discriminant
	float discriminant = bOverA*bOverA - 4.*cOverA;

	if(discriminant < 0.) {
		// the discriminant is negative -- all solutions are imaginary, so there is no intersection
		return false;
	}

	// there is at least one intersection, but is at least one in the forward direction?

	// calculate the square root of the discriminant
	float sqrtDiscriminant = sqrt(discriminant);

	// try the "-" solution first, as this will be closer, provided it is positive (i.e. in the forward direction)
	delta = (-bOverA - sqrtDiscriminant)/2.;
	if(delta < 0.) {
		// the delta for the "-" solution is negative, so that is a "backwards" solution; try the "+" solution
		delta = (-bOverA + sqrtDiscriminant)/2.;

		if(delta < 0.)
			// the "+" solution is also in the backwards direction
			return false;
	}
	return true;
}

bool findIntersectionWithSphereShape(
	vec3 s, 	// ray start point
	vec3 nD, 	// ray direction
	int sphereIndex,
	out vec3 intersectionPosition,
	out float intersectionDistance
) {
	// for maths see geometry.pdf
	vec3 v = s - sphereShapes[sphereIndex].centre;
	// float a = dot(nD, nD);
	float b = 2.*dot(nD, v);
	float c = dot(v, v) - sphereShapes[sphereIndex].radius2;

	float delta;
	if(calculateDelta(
		b,	// if nD is not normalised: b/a,	// bOverA
		c,	// if nD is not normalised: c/a,	// cOverA
		delta
	)) {
		// there is an intersection in the forward direction, at
		intersectionPosition = s + delta*nD;
		intersectionDistance = delta;	// if nD is not normalised: delta*length(nD);
		return true;
	}
	return false;
}

bool isWithinFiniteBitOfCylinderMantleShape(
	vec3 position,
	int cylinderMantleIndex
) {
	float a = dot( position - cylinderMantleShapes[cylinderMantleIndex].centre, cylinderMantleShapes[cylinderMantleIndex].nAxis );
	return ( abs(a) <= 0.5*cylinderMantleShapes[cylinderMantleIndex].length );
}

bool findIntersectionWithCylinderMantleShape(
	vec3 s, 	// ray start point
	vec3 nD, 	// normalised ray direction
	int cylinderMantleIndex,
	out vec3 intersectionPosition,
	out float intersectionDistance
) {
	// first a quick check if the ray intersects the (infinitely long) cylinder mantle
	// see https://en.wikipedia.org/wiki/Skew_lines#Distance

	vec3 n = normalize(cross(cylinderMantleShapes[cylinderMantleIndex].nAxis, nD));	// a normalised vector perpendicular to both line and cylinder direction
	float distance = dot(s-cylinderMantleShapes[cylinderMantleIndex].centre, n);

	if(distance > cylinderMantleShapes[cylinderMantleIndex].radius) return false;

	// there is an intersection with the *infinite* cylinder mantle; calculate delta such that intersection position = s + delta * d

	// for maths see J's lab book 19/10/24
	vec3 v = cross( cylinderMantleShapes[cylinderMantleIndex].nAxis, s-cylinderMantleShapes[cylinderMantleIndex].centre );
	vec3 w = cross( cylinderMantleShapes[cylinderMantleIndex].nAxis, nD );
	// coefficients of quadratic equation a delta^2 + b delta + c = 0
	float a = dot(w, w);
	float b = 2.*dot(v, w);
	float c = dot(v, v) - cylinderMantleShapes[cylinderMantleIndex].radius2;
	float bOverA = b/a;
	float cOverA = c/a;

	// calculate the discriminant
	float discriminant = bOverA*bOverA - 4.*cOverA;

	if(discriminant < 0.) {
		// the discriminant is negative -- all solutions are imaginary, so there is no intersection
		return false;
	}

	// there is at least one intersection, but is at least one in the forward direction?

	// calculate the square root of the discriminant
	float sqrtDiscriminant = sqrt(discriminant);

	// try the "-" solution first, as this will be closer, provided it is positive (i.e. in the forward direction)
	float delta = (-bOverA - sqrtDiscriminant)/2.;
	intersectionPosition = s + delta*nD;
	if( (delta < 0.) || !isWithinFiniteBitOfCylinderMantleShape( intersectionPosition, cylinderMantleIndex ) ) {
		// the "-" solution lies in the "backwards" direction or doesn't lie on the finite bit of the cylinder mantle; try the "+" solution
		delta = (-bOverA + sqrtDiscriminant)/2.;

		intersectionPosition = s + delta*nD;
		if( (delta < 0.) || !isWithinFiniteBitOfCylinderMantleShape( intersectionPosition, cylinderMantleIndex ) )
			// the "-" solution lies in the "backwards" direction or doesn't lie on the finite bit of the cylinder mantle
			return false;
	}
	
	intersectionDistance = delta;	// if light-ray direction is not normalised: delta*length(nD);
	return true;
}

bool findIntersectionWithPlaneShape(
	vec3 s, // ray start point, origin 
	vec3 nD, // normalised ray direction 
	int planeIndex,
	out vec3 intersectionPosition,
	out float intersectionDistance
) {
	// if the ray is parallel to the plane there is no intersection 
	float d = dot(nD, planeShapes[planeIndex].nNormal);
	if (d == 0.) {
		return false;
	}
	
	// calculate delta to check for intersections 
	float delta = dot(planeShapes[planeIndex].pointOnPlane - s, planeShapes[planeIndex].nNormal) / d;
	if (delta<0.) {
		// intersection with rectangle is in backward direction
		return false;
	}

	// calculate the intersection position
	intersectionPosition = s + delta*nD;
	intersectionDistance = delta;	// if nD is not normalised: delta*length(nD);
	return true;
}

/* A simple shape is any shape other than a SolidGeometryShape */
bool findIntersectionWithSimpleShape(
	in vec3 s, // ray start point, origin 
	in vec3 nD, // normalized ray direction 
	in ShapeID originShapeID,
	in ShapeID shapeID,
	out vec3 intersectionPosition,
	out float intersectionDistance
) {
	if(shapeID.type == RECTANGLE_SHAPE) {
		// check if the ray originated on the same rectangle
		if( originShapeID == shapeID ) {
			// it did, but only a single intersection is possible, so no intersection
			return false;
		}

		return findIntersectionWithRectangleShape(
			s, // ray start point, origin 
			nD, // normalised ray direction 
			shapeID.index,	// rectangle shape index
			intersectionPosition,
			intersectionDistance
		);
	} else if(shapeID.type == SPHERE_SHAPE ) {
		// check if the ray originated on the same sphere
		if( originShapeID == shapeID ) {
			// it did; avoid finding the same intersection again by advancing the ray a tiny bit before checking
			s += TOO_CLOSE*nD;
		}

		return findIntersectionWithSphereShape(
			s, // ray start point, origin 
			nD, // normalised ray direction 
			shapeID.index,
			intersectionPosition,
			intersectionDistance
		);
	} else if(shapeID.type == CYLINDER_MANTLE_SHAPE ) {
		// check if the ray originated on the same cylinder
		if( originShapeID == shapeID ) {
			// it did; avoid finding the same intersection again by advancing the ray a tiny bit before checking
			s += TOO_CLOSE*nD;
		}

		return findIntersectionWithCylinderMantleShape(
			s, // ray start point, origin 
			nD, // normalised ray direction 
			shapeID.index,
			intersectionPosition,
			intersectionDistance
		);
	} else if(shapeID.type == PLANE_SHAPE ) {
		// check if the ray originated on the same plane
		if( originShapeID == shapeID ) {
			// it did, but only a single intersection is possible, so no intersection
			return false;
		}

		return findIntersectionWithPlaneShape(
			s, // ray start point, origin 
			nD, // normalised ray direction 
			shapeID.index,	// plane shape index
			intersectionPosition,
			intersectionDistance
		);
	}
	return false;
}

bool isInsideShape(
	vec3 position,
	ShapeID shapeID
);

bool isInsideAllClippingShapes(
	vec3 position, 
	int solidGeometryIndex, 
	ShapeID intersectedShapeID
) {
	// go through all the clipping shapes (apart from the intersected one) and check
	// if the intersection position is inside them
	for(int i = 0; i < solidGeometryShapes[solidGeometryIndex].noOfShapes; i++) {
		if( 
			(solidGeometryShapes[solidGeometryIndex].shapeIDs[i] != intersectedShapeID) && 
			solidGeometryShapes[solidGeometryIndex].clipping[i] 
		) {
			// the shape is not the intersected one and it is clipping
			if(
				!(
					solidGeometryShapes[solidGeometryIndex].insideOut[i] ^^
					isInsideShape(
						position,
						solidGeometryShapes[solidGeometryIndex].shapeIDs[i]
					)
				)
			) {
				return false;
			}
		}
	}
	return true;
}

bool findIntersectionWithSolidGeometryShape(
	vec3 s, 	// ray start point
	vec3 nD, 	// normalised ray direction
	in ShapeID originShapeID,
	int solidGeometryIndex,
	out ShapeID intersectedSimpleShapeID,	// to identify the specific shape within the solid-geometry shape
	out vec3 intersectionPosition,
	out float intersectionDistance
) {
	intersectionDistance = TOO_FAR;

	vec3 currentIntersectionPosition;
	float currentIntersectionDistance;
	bool tryAgain;

	// go through all the visible shapes
	for(int i = 0; i < solidGeometryShapes[solidGeometryIndex].noOfShapes; i++) {
		// is the current shape visible?
		if( solidGeometryShapes[solidGeometryIndex].visible[i] ) {
			// yes, it's visible; check if there is an intersection
			vec3 sCurrent = s;
			ShapeID lastIntersectedShapeID = originShapeID;
			int remainingSteps = 4;	// a safety measure, which is hopefully not reqired
			do {
				tryAgain = false;
				if( findIntersectionWithSimpleShape(
					sCurrent,
					nD,
					lastIntersectedShapeID,
					solidGeometryShapes[solidGeometryIndex].shapeIDs[i],
					currentIntersectionPosition,
					currentIntersectionDistance
				) ) {
					currentIntersectionDistance += distance(s, sCurrent);
					if( currentIntersectionDistance < intersectionDistance ) {
						if( isInsideAllClippingShapes(
							currentIntersectionPosition, 
							solidGeometryIndex, 
							solidGeometryShapes[solidGeometryIndex].shapeIDs[i]
						) ) {
							intersectedSimpleShapeID = solidGeometryShapes[solidGeometryIndex].shapeIDs[i];
							intersectionPosition = currentIntersectionPosition;
							intersectionDistance = currentIntersectionDistance;
						} else {
							// we need to check for further intersections with the same shape;
							// advance the ray a little bit so that we don't get stuck in the loop
							sCurrent = currentIntersectionPosition + TOO_CLOSE*nD;
							lastIntersectedShapeID = solidGeometryShapes[solidGeometryIndex].shapeIDs[i];
							tryAgain = true;
						}
					}
				}
			} while( tryAgain && (remainingSteps-- > 0) );
		}
	}
	return ( intersectionDistance < TOO_FAR );
}

bool findIntersectionWithShape(
	in vec3 s, // ray start point, origin 
	in vec3 nD, // normalized ray direction 
	in ShapeID originShapeID,
	in ShapeID shapeID,
	out ShapeID intersectedSimpleShapeID,
	out vec3 intersectionPosition,
	out float intersectionDistance
) {
	if( shapeID.type == SOLID_GEOMETRY_SHAPE ) {
		return findIntersectionWithSolidGeometryShape(
			s, // ray start point, origin 
			nD, // normalised ray direction 
			originShapeID,
			shapeID.index,
			intersectedSimpleShapeID,	// to identify the specific shape within the solid-geometry shape
			intersectionPosition,
			intersectionDistance
		);
	} else {
		intersectedSimpleShapeID = shapeID;
		return findIntersectionWithSimpleShape(
			s,
			nD,
			originShapeID,
			shapeID,
			intersectionPosition,
			intersectionDistance
		);
	}
}

// find the (closest) intersection in the ray's forward direction with any of the
// objects that make up the scene
// s: ray start point (will not be altered)
// d: ray direction
// intersectionPosition: initial value ignored; becomes the position of the intersection
// intersectionDistance: initial value ignored; becomes the distance to the closest intersection point
// objectSetIndex: 0/1/2 if the intersection is with the x/y/z planes, 3 if it is with coloured spheres
// objectIndex: initial value ignored; becomes the index of the object within the object set being intersected
// returns true if an intersection has been found
bool findIntersectionWithScene(
	in vec3 s, // ray start point, origin 
	in vec3 nD, // normalized ray direction 
	in ShapeID originShapeID,
	out int closestIntersectedSceneObjectIndex,
	out ShapeID closestIntersectedSimpleShapeID,	// in case the scene object is of type SOLID_GEOMETRY_TYPE
	out vec3 closestIntersectionPosition,
	out float closestIntersectionDistance
) {
	closestIntersectionDistance = TOO_FAR;	// this means there is no intersection, so far

	// create space for info on the current intersection
	ShapeID intersectedSimpleShapeID;
	vec3 intersectionPosition;
	float intersectionDistance;

	// go through all the scene objects
	for(int sceneObjectIndex = 0; sceneObjectIndex < noOfSceneObjects; sceneObjectIndex++) {
		// check for intersections only if the scene object is visible
		if(sceneObjects[sceneObjectIndex].visible) {
			// the scene object is visible
			if( 
				findIntersectionWithShape(
					s, // ray start point, origin 
					nD, // ray direction 
					originShapeID,	// originShapeID
					sceneObjects[sceneObjectIndex].shapeID,	// shapeID
					intersectedSimpleShapeID,
					intersectionPosition,
					intersectionDistance
				)
			) {
				// the ray intersects the shape

				// is this the new closest intersection?
				if( intersectionDistance < closestIntersectionDistance ) {
					// this is the new closest intersection
					// take note of the parameters that describe it
					closestIntersectedSceneObjectIndex = sceneObjectIndex;
					closestIntersectedSimpleShapeID = intersectedSimpleShapeID;
					closestIntersectionDistance = intersectionDistance;
					closestIntersectionPosition = intersectionPosition;
				}
			}
		}
	}
	return (closestIntersectionDistance < TOO_FAR);
}

//
// isInside<shape> functions
//

// the outside of a rectangle is interpreted here as the side of the rectangle plane
// to which the vector nNormal points (i.e. nNormal is a (normalised) *outwards-facing* normal)
bool isInsideRectangleShape(
	vec3 position,
	int rectangleShapeIndex
) {
	// nNormal is, by definition, facing outwards
	return ( dot( position - rectangleShapes[ rectangleShapeIndex ].corner, rectangleShapes[ rectangleShapeIndex ].nNormal ) <= 0. );
}

bool isInsideSphereShape(
	vec3 position,
	int sphereShapeIndex
) {
	vec3 r = position - sphereShapes[sphereShapeIndex].centre;
	return ( dot(r, r) <= sphereShapes[sphereShapeIndex].radius2);
}

// the inside of a cylinder mantle (no end caps) is interpreted here as 
// the inside of the cylinder formed by the cylinder mantle with end caps
bool isInsideCylinderMantleShape(
	vec3 position,
	int cylinderMantleShapeIndex
) {
	vec3 v = cross( position - cylinderMantleShapes[cylinderMantleShapeIndex].centre, cylinderMantleShapes[cylinderMantleShapeIndex].nAxis );
	if( dot(v, v) <= cylinderMantleShapes[cylinderMantleShapeIndex].radius2 ) {
		// position is inside the infinitely extended cylinder mantle

		// check if it lies within the (actually finite) cylinder mantle
		float a = dot( 
			position - cylinderMantleShapes[cylinderMantleShapeIndex].centre, 
			cylinderMantleShapes[cylinderMantleShapeIndex].nAxis 
		) / ( 0.5*cylinderMantleShapes[cylinderMantleShapeIndex].length );
		return ( (-1.0 <= a) && (a <= 1.0) );
	}
	return false;
}

// the outside of a plane is interpreted here as the side of the plane
// to which the vector nNormal points (i.e. nNormal is a (normalised) *outwards-facing* normal)
bool isInsidePlaneShape(
	vec3 position,
	int planeShapeIndex
) {
	// nNormal is, by definition, facing outwards
	return ( dot( position - planeShapes[ planeShapeIndex ].pointOnPlane, planeShapes[ planeShapeIndex ].nNormal ) <= 0. );
}


/* this should never be called as isInside<...>Shape functions are intended for use in
solid-geometry functions, and an isInsideSolidGeometryShape function call would result
from adding a shape of type SOLID_GEOMETRY_SHAPE to a SolidGeometryShape, which is not
allowed as it would result in a recursive function call.
See https://www.khronos.org/opengl/wiki/Core_Language_(GLSL)#Recursion
*/ 
bool isInsideSolidGeometryShape(
	vec3 position,
	int solidGeometryIndex
) {
	// not intended to ever be called
	return false;
}

bool isInsideShape(
	vec3 position,
	ShapeID shapeID
) {
	if(shapeID.type == RECTANGLE_SHAPE) {
		return isInsideRectangleShape(
			position,
			shapeID.index
		);
	} else if(shapeID.type == SPHERE_SHAPE ) {
		return isInsideSphereShape(
			position,
			shapeID.index
		);
	} else if(shapeID.type == CYLINDER_MANTLE_SHAPE ) {
		return isInsideCylinderMantleShape(
			position,
			shapeID.index
		);
	} else if(shapeID.type == PLANE_SHAPE ) {
		return isInsidePlaneShape(
			position,
			shapeID.index
		);
	} else if(shapeID.type == SOLID_GEOMETRY_SHAPE) {
		return isInsideSolidGeometryShape(
			position,
			shapeID.index
		);
	}
}

bool isInsideSceneObject(
	vec3 position,
	int sceneObjectIndex
) {
	return isInsideShape(
		position,
		sceneObjects[sceneObjectIndex].shapeID
	);
}

//
// getNormal2<...> functions
//

vec3 getNormal2RectangleShape(
	vec3 position,
	int rectangleShapeIndex
) {
	return rectangleShapes[rectangleShapeIndex].nNormal;
}

vec3 getNormal2SphereShape(
	vec3 position,
	int sphereShapeIndex
) {
	return normalize(position - sphereShapes[sphereShapeIndex].centre);
}

vec3 getNormal2CylinderMantleShape(
	vec3 position,
	int cylinderMantleShapeIndex
) {
	vec3 v = position - cylinderMantleShapes[cylinderMantleShapeIndex].centre;
	return normalize( v - dot(v, cylinderMantleShapes[cylinderMantleShapeIndex].nAxis)*cylinderMantleShapes[cylinderMantleShapeIndex].nAxis );
}

vec3 getNormal2PlaneShape(
	vec3 position,
	int planeShapeIndex
) {
	return planeShapes[planeShapeIndex].nNormal;
}

// returns the normalised normal at the position
vec3 getNormal2Shape(
	vec3 position,
	ShapeID shapeID
) {
	if( shapeID.type == RECTANGLE_SHAPE ) return getNormal2RectangleShape(position, shapeID.index);
	else if( shapeID.type == SPHERE_SHAPE ) return getNormal2SphereShape(position, shapeID.index);
	else if( shapeID.type == CYLINDER_MANTLE_SHAPE ) return getNormal2CylinderMantleShape(position, shapeID.index);
	else if( shapeID.type == PLANE_SHAPE ) return getNormal2PlaneShape(position, shapeID.index);
	return vec3(0, 1, 0);
}

//
// getSurfaceCoordinatesOn<...> functions
//

// returns (u, v), where position = corner + u*normalize(span1) + v*normalize(span2)
vec2 getSurfaceCoordinatesOnRectangleShape(
	vec3 position,
	int rectangleShapeIndex
) {
	vec3 v = position - rectangleShapes[rectangleShapeIndex].corner;
	return vec2(
		dot(v, normalize(rectangleShapes[rectangleShapeIndex].span1)),
		dot(v, normalize(rectangleShapes[rectangleShapeIndex].span2))
	);
}

vec2 getSurfaceCoordinatesOnSphereShape(
	vec3 position,
	int sphereShapeIndex
) {
	vec3 v = normalize(position - sphereShapes[sphereShapeIndex].centre);

	return vec2(
		acos(dot(v, sphereShapes[sphereShapeIndex].nTheta0)),	// theta
		atan(dot(v, sphereShapes[sphereShapeIndex].nPhi90), dot(v, sphereShapes[sphereShapeIndex].nPhi0))	// phi
	);
}

vec2 getSurfaceCoordinatesOnCylinderMantleShape(
	vec3 position,
	int cylinderMantleShapeIndex
) {
	vec3 v = position - cylinderMantleShapes[cylinderMantleShapeIndex].centre;

	return vec2(
		acos(dot(v, cylinderMantleShapes[cylinderMantleShapeIndex].nAxis)),	// theta
		atan(dot(v, cylinderMantleShapes[cylinderMantleShapeIndex].nPhi90), dot(v, cylinderMantleShapes[cylinderMantleShapeIndex].nPhi0))	// phi
	);
}

// returns the surface coordinates at the position
vec2 getSurfaceCoordinatesOnShape(
	vec3 position,
	ShapeID shapeID
) {
	if( shapeID.type == RECTANGLE_SHAPE ) return getSurfaceCoordinatesOnRectangleShape(position, shapeID.index);
	else if( shapeID.type == SPHERE_SHAPE ) return getSurfaceCoordinatesOnSphereShape(position, shapeID.index);
	else if( shapeID.type == CYLINDER_MANTLE_SHAPE ) return getSurfaceCoordinatesOnCylinderMantleShape(position, shapeID.index);
	return vec2(0, 0);
}

//
// interactWith<...> functions
//

bool interactWithThinFocussingSurface(
 	inout vec3 s,	// intersection position; out value becomes new ray start point
	inout vec3 nD,	// normalised ray direction 
	inout vec4 c,	// colour/brightness
	vec3 nN,	// normalised (outwards-facing) normal
	int thinFocussingSurfaceIndex
) {
	vec3 pi = s - thinFocussingSurfaces[thinFocussingSurfaceIndex].principalPoint;

	// is it a non-spherical focussing surface?
	if( thinFocussingSurfaces[thinFocussingSurfaceIndex].focussingType == CYLINDRICAL_FOCUSSING_TYPE ) {
		pi = dot(pi, thinFocussingSurfaces[thinFocussingSurfaceIndex].nOpticalPowerDirection)*thinFocussingSurfaces[thinFocussingSurfaceIndex].nOpticalPowerDirection;
	} else if( thinFocussingSurfaces[thinFocussingSurfaceIndex].focussingType == TORIC_FOCUSSING_TYPE ) {
		// TODO
	}

	float reflectionFactor = (thinFocussingSurfaces[thinFocussingSurfaceIndex].reflective)?-1.0:1.0;

	if(thinFocussingSurfaces[thinFocussingSurfaceIndex].refractionType == IDEAL_REFRACTION_TYPE) {
		// ideal thin lens/mirror

		// "normalise" the direction such that the magnitude of the "nD component" is 1
		vec3 d1 = nD/abs(dot(nD, nN));

		// calculate the "nN component" of d1, which is of magnitude 1 but the sign can be either + or -
		float d1N = dot(d1, nN);

		vec3 d1T = d1 - nN*d1N;	// the transverse (perpendicular to nN) part of d1

		// the 3D deflected direction comprises the transverse components and a n component of magnitude 1
		// and the same sign as d1N = dot(d, nHat)
		nD = normalize(d1T - pi*thinFocussingSurfaces[thinFocussingSurfaceIndex].opticalPower + nN*reflectionFactor*d1N);	// replace d1N with sign(d1N) if d1 is differently normalised
	} else if(thinFocussingSurfaces[thinFocussingSurfaceIndex].refractionType == PHASE_HOLOGRAM_REFRACTION_TYPE) {
		// phase hologram
		// nD is already normalised as required
		float nDN = dot(nD, nN);	// the nN component of nD
		
		// the transverse (perpendicular to nN) part of the outgoing light-ray direction
		vec3 dT = nD - nN*nDN - pi*thinFocussingSurfaces[thinFocussingSurfaceIndex].opticalPower;

		// from the transverse direction, construct a 3D vector by setting the n component such that the length
		// of the vector is 1
		nD = normalize(dT + nN*reflectionFactor*sign(nDN)*sqrt(1.0 - dot(dT, dT)));
	}

	c *= thinFocussingSurfaces[thinFocussingSurfaceIndex].colourFactor;
	return true;	// keep raytracing
}

// returns true if no further raytracing is required
bool interactWithSurface(
	inout vec3 s,	// intersection position; out value becomes new ray start point
	inout vec3 nD,	// normalised ray direction 
	inout vec4 c,	// colour/brightness
	SurfaceID surfaceID,
	ShapeID shapeID
	// int sceneObjectIndex
) {
	if( surfaceID.type == COLOUR_SURFACE ) {
		c *= colourSurfaces[ surfaceID.index ].colourFactor;	// multiply colour by the colour multiplier
		return colourSurfaces[ surfaceID.index ].semitransparent;	// keep raytracing if semitransparent, otherwise not
	} 
	else if( surfaceID.type == MIRROR_SURFACE ) {
		c *= mirrorSurfaces[ surfaceID.index ].colourFactor;	// multiply colour by the colour multiplier
		vec3 n = normalize(getNormal2Shape( s, shapeID ));
		nD -= 2.0*dot(nD, n)*n; // should already be normalized; alternative: reflect( normalize(d), vec3(1,0,1));
		return true;	// keep raytracing
	}
	else if( surfaceID.type == THIN_FOCUSSING_SURFACE ) {
		return interactWithThinFocussingSurface(
			s,	// intersection position; out value becomes new ray start point
			nD,	// normalised ray direction 
			c,	// colour/brightness
			normalize(getNormal2Shape( s, shapeID )),	// normalised (outwards-facing) normal
			surfaceID.index
		);
	}
	else if( surfaceID.type == CHECKERBOARD_SURFACE ) {
		CheckerboardSurface cs = checkerboardSurfaces[surfaceID.index];
		vec2 uv = getSurfaceCoordinatesOnShape(
			s,	// position
			shapeID
		) / vec2(cs.width1, cs.width2);
		// if( (2.*floor( mod( uv.x, 2. )) - 1.) * (2.*floor( mod( uv.y, 2. )) - 1.) == -1. ) {
		uv = 2.*floor( mod( getSurfaceCoordinatesOnShape(
			s,	// position
			shapeID
		) / vec2(cs.width1, cs.width2) , 2.)) - 1.;
		if( uv.x * uv.y == -1. ) {
		// if(mod(uv.x, 2.) < 1.) {
			c *= cs.colourFactor1;
			return cs.semitransparent1;
		} else {
			c *= cs.colourFactor2;
			return cs.semitransparent2;
		}
	}
	
	// all surface types should be dealt with by now
	// if this code is reached, then that isn't the case
	c *= vec4(1, .4, 0, 1);	// return orange
	return false;
}

//
// other functions
//

vec4 getColorOfBackground(
	vec3 nD	// normalized light-ray direction
) {
	if( backgroundType == TEXTURE_BACKGROUND_TYPE ) {
		// float l = length(nD);
		float phi = atan(nD.z, nD.x) + PI;
		float theta = acos(nD.y);	// if light-ray direction is not normalised then nD.y/l
		return texture(backgroundTexture, vec2(mod(phi/(2.*PI), 1.0), 1.-theta/PI));
	} else if ( backgroundType == COLOUR_BACKGROUND_TYPE ) {
		return backgroundColour;
	}
}

void main() {
	// first calculate the focusPosition, i.e. the point this pixel is focussed on
	vec3 pv = intersectionPoint - cameraPosition;	// the "pixel view direction", i.e. a vector from the centre of the camera aperture to the point on the object the shader is currently "shading"
	vec3 focusPosition = cameraPosition + focusDistance/abs(dot(pv, viewDirection))*pv;	// see Johannes's lab book 30/4/24 p.174

	// trace <noOfRays> rays
	gl_FragColor = vec4(0, 0, 0, 0);
	vec4 color;
	for(int i=0; i<noOfRays; i++) {
		// the current ray start position, a random point on the camera's circular aperture
		vec3 s = cameraPosition + apertureRadius*randomNumbersX[i]*apertureXHat + apertureRadius*randomNumbersY[i]*apertureYHat;

		// first calculate the current light-ray direction:
		// the ray first passes through focusPosition and then p,
		// so the "backwards" ray direction from the camera to the intersection point is
		vec3 nD = normalize( focusPosition - s );

		// current colour/brightness; will be multiplied by each surface's colour/brightness factor
		vec4 c = vec4(1.0, 1.0, 1.0, 1.0);

		ShapeID intersectedSimpleShapeID;
		vec3 intersectionPosition;
		float intersectionDistance;
		int intersectedSceneObjectIndex;
		ShapeID originShapeID = ShapeID(-1, -1);
		int tl = maxTraceLevel;	// max trace level
		bool continueRaytracing = true;
		while(
			continueRaytracing &&
			(tl-- >= 0) &&
			findIntersectionWithScene(
				s, // ray start point, origin 
				nD, // ray direction 
				originShapeID,	// originShapeID
				intersectedSceneObjectIndex,	// closestIntersectedSceneObjectIndex
				intersectedSimpleShapeID,	// in case the scene object is of type SOLID_GEOMETRY_TYPE
				intersectionPosition,	// closestIntersectionPosition
				intersectionDistance	// closestIntersectionDistance
			) 
		) {
			s = intersectionPosition;
			continueRaytracing = interactWithSurface(
				s,	// ray start point, origin 
				nD,	// ray direction 
				c,	// brightness multiplier
				sceneObjects[intersectedSceneObjectIndex].surfaceID,
				intersectedSimpleShapeID
			);
			originShapeID = intersectedSimpleShapeID;
			// TODO pass origin simple shape info to findIntersectionWithScene?
		}

		if( tl >= 0 ) {
			if( continueRaytracing ) c *= getColorOfBackground(nD);
		} else {
			c = vec4(0., 0., 0., 1.);
		}

		// finally, multiply by the brightness factor and add to gl_FragColor
		gl_FragColor += c;
	}
		
	gl_FragColor /= float(noOfRays);
}