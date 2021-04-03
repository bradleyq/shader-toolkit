#version 150

#moj_import <fog.glsl>

uniform sampler2D Sampler0;

uniform vec4 ColorModulator;
uniform float FogStart;
uniform float FogEnd;
uniform vec4 FogColor;

in float vertexDistance;
in vec4 vertexColor;
in vec2 texCoord0;
in vec4 normal;
in vec3 barycentric;

out vec4 fragColor;

void main() {
    if (min(min(barycentric.x, barycentric.y), barycentric.z) > 0.05) {
        discard;
    }
    vec4 color = vertexColor;
    fragColor = linear_fog(color, vertexDistance, FogStart, FogEnd, FogColor);
}
