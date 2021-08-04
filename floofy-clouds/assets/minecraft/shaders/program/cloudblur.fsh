#version 150

uniform sampler2D DiffuseSampler;
uniform sampler2D DepthSampler;

in vec2 texCoord;
in vec2 oneTexel;

uniform vec2 InSize;
uniform vec2 BlurDir;
uniform float FirstPass;

out vec4 fragColor;

#define BOOST 1.15
#define SCREENEDGE 0.01
#define RADIUSMIN 10.0
#define RADIUSMAX 30.0
#define NEAR 0.1
#define FAR 1536.0
#define ALPHAOVERRIDE 0.95

float LinearizeDepth(float depth) {
    float z = depth * 2.0 - 1.0;
    return (NEAR * FAR) / (FAR + NEAR - z * (FAR - NEAR));    
}


void main() {
    
    vec4 blurred = vec4(0.0);
    float totalStrength = 0.0;
    float totalAlpha = 0.0;
    float totalSamples = 0.0;
    vec4 center = texture(DiffuseSampler, texCoord);
    float depth = clamp(LinearizeDepth(texture(DepthSampler, texCoord).r) / 64.0, 0.0, 1.0);
    float radius = round(depth * RADIUSMIN + (1.0 - depth) * RADIUSMAX);

    if (center.a > 0.0) { // only do cloud processing if current pixel is in the cloud
        blurred = center;
        totalAlpha = center.a;
        totalSamples = 1.0;
        for(float r = 1.0; r <= radius; r += 1.0) {
            vec2 c1 = texCoord + oneTexel * r * BlurDir;
            vec2 c2 = texCoord + oneTexel * -r * BlurDir;
            vec4 sampleValue1 = texture(DiffuseSampler, c1);
            vec4 sampleValue2 = texture(DiffuseSampler, c2);
            sampleValue1.rgb *= BOOST;
            sampleValue2.rgb *= BOOST;

            // deal with edge effect
            if (c1.x > 1.0 + SCREENEDGE|| c1.x < 0.0 - SCREENEDGE|| c1.y > 1.0 + SCREENEDGE|| c1.y < 0.0 - SCREENEDGE) {
                sampleValue1.a = 0.0;
            }
            if (c2.x > 1.0 + SCREENEDGE|| c2.x < 0.0 - SCREENEDGE|| c2.y > 1.0 + SCREENEDGE|| c2.y < 0.0 - SCREENEDGE) {
                sampleValue1.a = 0.0;
            }

            // override default cloud alpha. It is too low for the new blending.
            if (FirstPass == 1.0 && sampleValue1.a > 0.1) {
                sampleValue1.a = ALPHAOVERRIDE;
            }
            if (FirstPass == 1.0 && sampleValue2.a > 0.1) {
                sampleValue2.a = ALPHAOVERRIDE;
            }

            // accumulate average alpha
            totalSamples = totalSamples + 2.0;

            // accumulate smoothed blur
            float strength = 1.0 - abs(r / radius);
            totalStrength = totalStrength + (2.0 * strength);
            if (sampleValue1.a <= 0.0) {
                blurred += vec4(center.rgb, 0.0);
            } else {
                totalAlpha += sampleValue1.a;
                blurred += sampleValue1;
            }
            if (sampleValue2.a <= 0.0) {
                blurred += vec4(center.rgb, 0.0);
            } else {
                totalAlpha += sampleValue2.a;
                blurred += sampleValue2;
            }
        }
    }
    fragColor = vec4(blurred.rgb / (radius * 2.0 + 1.0), clamp((totalAlpha / (radius * 2.0 + 1.0) - 0.5) * 2.0, 0.0, 1.0));
}
