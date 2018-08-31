uniform mat4 u_MVPMatrix;		// A constant representing the combined model/view/projection matrix.      		       
uniform mat4 u_MVMatrix;		// A constant representing the combined model/view matrix.       		
		  			
attribute vec4 a_Position;		// Per-vertex position information we will pass in.
attribute vec3 a_Normal;		// Per-vertex normal information we will pass in.
attribute vec2 a_TexCoordinate; // Per-vertex texture coordinate information we will pass in.

varying vec3 v_Position;		// This will be passed into the fragment shader.
varying vec3 v_Normal;			// This will be passed into the fragment shader.
varying vec2 v_TexCoordinate;   // This will be passed into the fragment shader.


uniform mat4 u_MMatrix;
uniform vec3 viewPos;
varying vec3 vFragPos;
varying vec3 vTangentViewPos;
varying vec3 vTangentFragPos;


// The entry point for our vertex shader.
void main()
{
	// Transform the vertex into eye space.
	v_Position = vec3(u_MVMatrix * a_Position);

	// Pass through the texture coordinate.
	v_TexCoordinate = a_TexCoordinate;

	// Transform the normal's orientation into eye space.
    v_Normal = vec3(u_MVMatrix * vec4(a_Normal, 0.0));

	// gl_Position is a special variable used to store the final position.
	// Multiply the vertex by the matrix to get the final point in normalized screen coordinates.
	gl_Position = u_MVPMatrix * a_Position;





    vFragPos = vec3(u_MMatrix * a_Position);

    vec3 world_tangent;
    vec3 binormal;

    vec3 Normal = normalize(a_Normal*2.0-1.0);

    vec3 c1 = cross(vec3(0.0, 0.0, 1.0), Normal);
    vec3 c2 = cross(vec3(0.0, 1.0, 0.0), Normal);

    if ( length(c1) > length(c2) ) { world_tangent = c1;  } else { world_tangent = c2;}



    world_tangent = normalize(world_tangent);
    binormal = normalize(cross(world_tangent, a_Normal));

    vec3 T = normalize(mat3(u_MMatrix) * world_tangent);
    vec3 B = normalize(mat3(u_MMatrix) * binormal);
    vec3 N = normalize(mat3(u_MMatrix) * a_Normal);
    mat3 TBN = mat3(T, B, N);

    vTangentViewPos  = viewPos*TBN;
    vTangentFragPos  = vFragPos*TBN;
}