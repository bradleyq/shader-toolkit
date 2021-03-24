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

void main() {
    vec4 screenPos = gl_FragCoord;
    screenPos.xy = (screenPos.xy / ScreenSize - vec2(0.5)) * 2.0;
    screenPos.zw = vec2(1.0);
    vec3 view = normalize(ProjInv * screenPos.xyz);
    float ndusq = clamp(dot(view, vec3(0.0, 1.0, 0.0)), 0.0, 1.0);
    ndusq = ndusq * ndusq;

    fragColor = linear_fog(ColorModulator, pow(1.0 - ndusq, 8.0), 0.0, 1.0, FogColor);
    if (gl_FragCoord.x <= 1.0 && gl_FragCoord.y <= 1.0) {
        fragColor = vec4(1.0, 0.0, 0.0, 1.0);
    }
}
