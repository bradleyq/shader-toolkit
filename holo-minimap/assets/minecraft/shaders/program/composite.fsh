#version 150

uniform sampler2D DiffuseSampler;
uniform sampler2D MinimapSampler;

in vec2 texCoord;

out vec4 fragColor;

#define HOLOALPHA 0.7

void main() {
    
    // overlay the holo onto the rendered frame
    fragColor = texture( DiffuseSampler, texCoord );
    vec4 mSample = texture( MinimapSampler, texCoord );
    fragColor = vec4(mix(fragColor.rgb, mSample.rgb, mSample.a * HOLOALPHA), 1.0);
}
