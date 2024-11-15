import * as THREE from 'three';
import * as CONST from '../Constants.js';
import { Util } from '../Util.js';
import { ShapeID } from '../ShapeID.js';

/** Intersection of shapes.  
 * The shapes must not be of type SOLID_GEOMETRY_SHAPE, as this would result in recursive function
 * calls in the shader (which is forbidden in GLSL).
 * The surface of the SolidGeometryShape is formed by points on the surfaces of visible shapes
 * that lie inside all clipping shapes (noting that some are inside out)
*/
class SolidGeometryShape {
	shapeIDs = new Array(CONST.MAX_INTERSECTING_SHAPES).fill(ShapeID.none); 
	visible = new Array(CONST.MAX_INTERSECTING_SHAPES).fill(false);
	insideOut = new Array(CONST.MAX_INTERSECTING_SHAPES).fill(false);
	clipping = new Array(CONST.MAX_INTERSECTING_SHAPES).fill(false);
	// solidGeometryRoles = new Array(CONST.MAX_INTERSECTING_SHAPES).fill(0);
	noOfShapes = 0;

	// add a shape returns its array index
	addShape( shapeID, visible, insideOut, clipping ) {
		if(this.noOfShapes >= CONST.MAX_INTERSECTING_SHAPES) {
			throw new Error( "Number of shapes ("+this.noOfShapes+") exceeds CONST.MAX_INTERSECTING_SHAPES ("+CONST.MAX_INTERSECTING_SHAPES+").");
		}
	
		if( shapeID.Type == CONST.SOLID_GEOMETRY_SHAPE ) {
			// see https://www.khronos.org/opengl/wiki/Core_Language_(GLSL)#Recursion
			throw new Error( "Cannot add shape of type CONST.SOLID_GEOMETRY_SHAPE to SolidGeometryShape, as this would result in recursion." );
		}

		// add the new shape
		this.shapeIDs[this.noOfShapes] = shapeID;
		this.visible[this.noOfShapes] = visible;
		this.insideOut[this.noOfShapes] = insideOut;
		this.clipping[this.noOfShapes] = clipping;
			
		// return its array index
		return this.noOfShapes++;
	}
}

export { SolidGeometryShape };