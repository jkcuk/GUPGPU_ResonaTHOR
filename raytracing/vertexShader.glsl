precision highp float;

varying vec3 intersectionPoint;

void main()	{
	// projectionMatrix, modelViewMatrix, position -> passed in from Three.js
	intersectionPoint = (modelMatrix * vec4(position, 1.0)).xyz;	// position.xyz;
	
	gl_Position = projectionMatrix
		* modelViewMatrix
		* vec4(position, 1.0);
}