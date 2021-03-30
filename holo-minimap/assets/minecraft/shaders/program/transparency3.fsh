#version 150

uniform sampler2D DiffuseSampler;
uniform sampler2D DiffuseDepthSampler;
uniform sampler2D TranslucentSampler;
uniform sampler2D TranslucentDepthSampler;
uniform sampler2D PastFrameSampler;

in vec2 texCoord;

out vec4 fragColor;

#define near 0.00004882812 
#define far 1.0

#define HOLOCLIP 0.004
#define HOLOCOLOR vec4(0.1, 1.6, 1.3, 1.0)

float LinearizeDepth(float depth) 
{
    return (2.0 * near * far) / (far + near - depth * (far - near));    
}

void main() {
    fragColor = texture(PastFrameSampler, texCoord);
    vec4 hmm = texture(DiffuseSampler, vec2(0.0001, 0.0001));

    // if no control pixel detected, copy new frame onto 'minimap' output, otherwise keep last frame
    if (!(hmm.r > 0.99 && hmm.a > 0.99 && hmm.g < 0.01 && hmm.b < 0.01)) {
        fragColor = vec4(0.0);
        float tdep = LinearizeDepth(texture(TranslucentDepthSampler, texCoord).r);
        float dep = LinearizeDepth(texture(DiffuseDepthSampler, texCoord).r);

        // clip past a certain distance
        if (dep < HOLOCLIP || tdep < HOLOCLIP) {
            fragColor = texture( DiffuseSampler, texCoord );
            if (tdep < dep) {
                vec4 mSample = texture( TranslucentSampler, texCoord );
                fragColor = vec4(mix(fragColor.rgb, mSample.rgb, mSample.a), 1.0);
            }
        }
        fragColor = mix(fragColor, vec4(length(fragColor))/ 2.0, 0.5) * HOLOCOLOR;
    }
}
