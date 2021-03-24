#version 150

#moj_import <fog.glsl>

uniform vec4 ColorModulator;
uniform float FogStart;
uniform float FogEnd;
uniform vec4 FogColor;
uniform vec2 ScreenSize;

in vec4 gl_FragCoord;
in mat3 ProjInv;

out vec4 fragColor;

#define GRIDOFFSET 0.078
#define GRIDDENSITY 10.0

void main() {
    vec4 screenPos = gl_FragCoord;
    screenPos.xy = (screenPos.xy / ScreenSize - vec2(0.5)) * 2.0;
    screenPos.zw = vec2(1.0);
    vec3 view = normalize(ProjInv * screenPos.xyz);
    float ndusq = clamp(dot(view, vec3(0.0, 1.0, 0.0)), 0.0, 1.0);
    float vdn = dot(view, vec3(0.0, 1.0, 0.0));
    float vdt = dot(view, vec3(1.0, 0.0, 0.0));
    float vdb = dot(view, vec3(0.0, 0.0, 1.0));
    ndusq = ndusq * ndusq;

    fragColor = linear_fog(ColorModulator, pow(1.0 - ndusq, 8.0), 0.0, 1.0, FogColor);
    if (fract(vdn * GRIDDENSITY + GRIDOFFSET) < 0.01 
     || fract(vdt * GRIDDENSITY + GRIDOFFSET) < 0.01
     || fract(vdb * GRIDDENSITY + GRIDOFFSET) < 0.01) {
        fragColor = vec4(1.0, 0.0, 0.0, 1.0);
    }
}
