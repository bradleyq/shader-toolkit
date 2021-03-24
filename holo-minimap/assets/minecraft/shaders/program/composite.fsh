#version 150

uniform sampler2D DiffuseSampler;
uniform sampler2D MinimapSampler;

in vec2 texCoord;

out vec4 fragColor;

void main() {
    fragColor = texture( DiffuseSampler, texCoord );
    vec4 mSample = texture( MinimapSampler, texCoord );
    fragColor = vec4(mix(fragColor.rgb, mSample.rgb, mSample.a * 0.5), 1.0);
}
