precision mediump float;       	// Set the default precision to medium. We don't need as high of a 
								// precision in the fragment shader.
uniform vec3 u_LightPos;       	// The position of the light in eye space.
uniform sampler2D u_Texture;    // The input texture.
  
varying vec3 v_Position;		// Interpolated position for this fragment.
varying vec3 v_Normal;         	// Interpolated normal for this fragment.
varying vec2 v_TexCoordinate;   // Interpolated texture coordinate per fragment.


varying vec3 vTangentViewPos;
varying vec3 vTangentFragPos;




vec2 ParallaxMapping(vec2 texCoords, vec3 viewDir);

// Parallax Occlusion Mapping
vec2 ParallaxMapping(vec2 texCoords, vec3 viewDir)
{
    // number of depth layers
    const float minLayers = 16.0;
    const float maxLayers = 64.0;
    float numLayers = mix(maxLayers, minLayers, abs(dot(vec3(0.0, 0.0, 1.0), viewDir)));
    // calculate the size of each layer
    float layerDepth = 1.0 / numLayers;
    // depth of current layer
    float currentLayerDepth = 0.0;
    // the amount to shift the texture coordinates per layer (from vector P)
    vec2 P = viewDir.xy / viewDir.z * 0.151;
    vec2 deltaTexCoords = P / numLayers;

    // get initial values
    vec2  currentTexCoords     = texCoords;
    float currentDepthMapValue = 1.0-texture2D(u_Texture, currentTexCoords).r;

    int layerCount = 0;
    while(currentLayerDepth < currentDepthMapValue)
    {
        ++layerCount;

        // shift texture coordinates along direction of P
        currentTexCoords = texCoords - P * float(layerCount)/ numLayers;

        // get depthmap value at current texture coordinates
        currentDepthMapValue = 1.0-texture2D(u_Texture, currentTexCoords).r;
        // get depth of next layer
        currentLayerDepth = float(layerCount)/ numLayers;
    }


    // -- parallax occlusion mapping interpolation from here on
    // get texture coordinates before collision
    vec2 prevTexCoords = texCoords - P * float(layerCount - 1)/ numLayers;

    // get depth after and before collision for linear interpolation
    float afterDepth  = currentDepthMapValue - currentLayerDepth;
    float beforeDepth = 1.0-texture2D(u_Texture, prevTexCoords).r - currentLayerDepth + layerDepth;

    // interpolation of texture coordinates
    float weight = afterDepth / (afterDepth - beforeDepth);
    vec2 finalTexCoords = prevTexCoords * weight + currentTexCoords * (1.0 - weight);

    return finalTexCoords;
}





// The entry point for our fragment shader.
void main()
{
    // Offset texture coordinates with Parallax Mapping
    vec3 viewDir = normalize(vTangentViewPos - vTangentFragPos);
    vec2 texCoords = v_TexCoordinate;

        texCoords = ParallaxMapping(v_TexCoordinate,  viewDir);

    // discards a fragment when sampling outside default texture region (fixes border artifacts)
    if(texCoords.x > 1.0 || texCoords.y > 1.0 || texCoords.x < 0.0 || texCoords.y < 0.0)
       discard;





	// Will be used for attenuation.
    float distance = length(u_LightPos - v_Position);

	// Get a lighting direction vector from the light to the vertex.
    vec3 lightVector = normalize(u_LightPos - v_Position);

	// Calculate the dot product of the light vector and vertex normal. If the normal and light vector are
	// pointing in the same direction then it will get max illumination.
    float diffuse = max(dot(v_Normal, lightVector), 0.0);

	// Add attenuation.
    diffuse = diffuse * (1.0 / (1.0 + (0.25 * distance)));

    // Add ambient lighting
    diffuse = diffuse + 0.7;

	// Multiply the color by the diffuse illumination level and texture value to get final output color.
	vec4 textureColor = texture2D(u_Texture, texCoords);
    gl_FragColor = (diffuse * textureColor );
}

