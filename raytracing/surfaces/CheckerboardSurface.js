import * as THREE from 'three';
import { Util } from '../Util.js';

class CheckerboardSurface {
	width1;	// width (in surface coordinate 1 of the shape) of checkers in direction 1
	width2;	// width (in surface coordinate 2 of the shape) of checkers in direction 2
	colourFactor1;	// multiplies the ray's colour if checkers of type 1 are intersected
	colourFactor2;	// multiplies the ray's colour if checkers of type 2 are intersected
	semitransparent1;	// true if the checkers of type 1 are semi-transparent, false otherwise
	semitransparent2;	// true if the checkers of type 1 are semi-transparent, false otherwise

	static blackWhiteCheckers = new CheckerboardSurface( 
		1, 1, // widths
		Util.white, Util.black,	// colour factors
		false, false	// semitransparencies
	 );

	 static blackWhiteCheckersSemitransparent = new CheckerboardSurface( 
		1, 1, // widths
		Util.white, Util.black,	// colour factors
		true, true	// semitransparencies
	 );

	 static grayCheckersSemitransparent = new CheckerboardSurface( 
		1, 1, // widths
		Util.gray20, Util.gray80,	// colour factors
		true, true	// semitransparencies
	 );

	constructor(
		width1,
		width2,
		colourFactor1,
		colourFactor2,
		semitransparent1,
		semitransparent2
	) {
		this.width1 = width1;
		this.width2 = width2;
		this.colourFactor1 = colourFactor1;
		this.colourFactor2 = colourFactor2;
		this.semitransparent1 = semitransparent1;
		this.semitransparent2 = semitransparent2;
	}
}

export { CheckerboardSurface };