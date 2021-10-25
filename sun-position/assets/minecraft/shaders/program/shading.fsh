#version 150

uniform sampler2D DiffuseSampler;
uniform sampler2D DiffuseDepthSampler;
uniform vec2 OutSize;

in vec2 texCoord;
in vec2 oneTexel;
in vec3 sunDir;
in mat4 ProjInv;
in float near;
in float far;

out vec4 fragColor;

// moj_import doesn't work in post-process shaders ;_; Felix pls fix
#define NUMCONTROLS 26
#define THRESH 0.5
#define FPRECISION 4000000.0
#define PROJNEAR 0.05
#define FUDGE 32.0

int inControl(vec2 screenCoord, float screenWidth) {
    if (screenCoord.y < 1.0) {
        float index = floor(screenWidth / 2.0) + THRESH / 2.0;
        index = (screenCoord.x - index) / 2.0;
        if (fract(index) < THRESH && index < NUMCONTROLS && index >= 0) {
            return int(index);
        }
    }
    return -1;
}

vec4 getNotControl(sampler2D inSampler, vec2 coords, bool inctrl) {
    if (inctrl) {
        return (texture(inSampler, coords - vec2(oneTexel.x, 0.0)) + texture(inSampler, coords + vec2(oneTexel.x, 0.0)) + texture(inSampler, coords + vec2(0.0, oneTexel.y))) / 3.0;
    } else {
        return texture(inSampler, coords);
    }
}

// tweak lighting color here
#define NOON vec3(1.3)
#define NOONA vec3(0.7, 0.75, 0.9)
#define EVENING vec3(1.4, 1.1, 0.7)
#define EVENINGA vec3(0.7, 0.8, 1.2)
#define NIGHT vec3(1.0)
#define NIGHTA vec3(1.0)

float LinearizeDepth(float depth) 
{
    return (2.0 * near * far) / (far + near - depth * (far - near));    
}

float luma(vec3 color){
	return dot(color,vec3(0.299, 0.587, 0.114));
}

vec4 backProject(vec4 vec) {
    vec4 tmp = ProjInv * vec;
    return tmp / tmp.w;
}

void main() {
    bool inctrl = inControl(texCoord * OutSize, OutSize.x) > -1;

    fragColor = getNotControl(DiffuseSampler, texCoord, inctrl);
    float depth = getNotControl(DiffuseDepthSampler, texCoord, inctrl).r;

    // only do lighting if not sky and sunDir exists
    if (LinearizeDepth(depth) < far - FUDGE && length(sunDir) > 0.99) {

        // first calculate approximate surface normal using depth map
        float depth2 = getNotControl(DiffuseDepthSampler, texCoord + vec2(0.0, oneTexel.y), inctrl).r;
        float depth3 = getNotControl(DiffuseDepthSampler, texCoord + vec2(oneTexel.x, 0.0), inctrl).r;
        float depth4 = getNotControl(DiffuseDepthSampler, texCoord - vec2(0.0, oneTexel.y), inctrl).r;
        float depth5 = getNotControl(DiffuseDepthSampler, texCoord - vec2(oneTexel.x, 0.0), inctrl).r;

        vec2 scaledCoord = 2.0 * (texCoord - vec2(0.5));

        vec3 fragpos = backProject(vec4(scaledCoord, depth, 1.0)).xyz;
        vec3 p2 = backProject(vec4(scaledCoord + 2.0 * vec2(0.0, oneTexel.y), depth2, 1.0)).xyz;
        p2 = p2 - fragpos;
        vec3 p3 = backProject(vec4(scaledCoord + 2.0 * vec2(oneTexel.x, 0.0), depth3, 1.0)).xyz;
        p3 = p3 - fragpos;
        vec3 p4 = backProject(vec4(scaledCoord - 2.0 * vec2(0.0, oneTexel.y), depth4, 1.0)).xyz;
        p4 = p4 - fragpos;
        vec3 p5 = backProject(vec4(scaledCoord - 2.0 * vec2(oneTexel.x, 0.0), depth5, 1.0)).xyz;
        p5 = p5 - fragpos;
        vec3 normal = normalize(cross(p2, p3)) 
                    + normalize(cross(-p4, p3)) 
                    + normalize(cross(p2, -p5)) 
                    + normalize(cross(-p4, -p5));
        normal = normal == vec3(0.0) ? vec3(0.0, 1.0, 0.0) : normalize(-normal);

        // use cos between sunDir to determine light and ambient colors
        float sdu = dot(vec3(0.0, 1.0, 0.0), sunDir);
        vec3 direct;
        vec3 ambient;
        if (sdu > 0.0) {
            direct = mix(EVENING, NOON, sdu);
            ambient = mix(EVENINGA, NOONA, sdu);
        } else {
            direct = mix(EVENING, NIGHT, pow(-sdu, 0.25));
            ambient = mix(EVENINGA, NIGHTA, pow(-sdu, 0.25));
        }

        // apply lighting color. not quite standard diffuse light equation since the blocks are already "pre-lit"
        fragColor.rgb *= mix(ambient, direct, clamp(dot(normal, sunDir), 0.0, 1.0));

        // desaturate bright pixels for more realistic feel
        fragColor.rgb = mix(fragColor.rgb, vec3(length(fragColor.rgb)/sqrt(3.0)), luma(fragColor.rgb) * 0.5);
    }
}
