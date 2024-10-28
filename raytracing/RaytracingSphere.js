import * as THREE from 'three';

class RaytracingSphere extends THREE.Mesh {
	constructor( radius, uniforms, vertexShaderCode, fragmentShaderCode ) {
		super(
			new THREE.TetrahedronGeometry( radius, 0 ), 
			new THREE.ShaderMaterial({
				side: THREE.DoubleSide,
				// wireframe: true,
				uniforms: uniforms,
				vertexShader: vertexShaderCode,
				fragmentShader: fragmentShaderCode,
			})
		);
	}

	get uniforms() {
		return this.material.uniforms;
	}
}

export { RaytracingSphere };