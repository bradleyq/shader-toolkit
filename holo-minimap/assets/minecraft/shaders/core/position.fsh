#version 150

#moj_import <fog.glsl>

uniform vec4 ColorModulator;
uniform float FogStart;
uniform float FogEnd;
uniform vec4 FogColor;
uniform vec2 ScreenSize;

in mat4 ProjInv;
in float isSky;
in float vertexDistance;

out vec4 fragColor;

#define GRIDOFFSET 0.078
#define GRIDDENSITY 10.0

void main() {
    
    // custom fog calculation if sky because sky disc is no longer above the head
    if (isSky > 0.5) {
        // get player space view vector
        vec4 screenPos = gl_FragCoord;
        screenPos.xy = (screenPos.xy / ScreenSize - vec2(0.5)) * 2.0;
        screenPos.zw = vec2(1.0);
        vec3 view = normalize((ProjInv * screenPos).xyz);
        float ndusq = clamp(dot(view, vec3(0.0, 1.0, 0.0)), 0.0, 1.0);
        ndusq = ndusq * ndusq;

        fragColor = linear_fog(ColorModulator, pow(1.0 - ndusq, 8.0), 0.0, 1.0, FogColor);
    } 
    // default shading for void plane and stars
    else {
        fragColor = linear_fog(ColorModulator, vertexDistance, FogStart, FogEnd, FogColor);
    }

    // draw control pixel in corner. Only in no holo mode can this actually be drawn
    if (gl_FragCoord.x <= 1.0 && gl_FragCoord.y <= 1.0) {
        fragColor = vec4(1.0, 0.0, 0.0, 1.0);
    }
}
