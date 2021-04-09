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
    vec4 color = texture(Sampler0, texCoord0) * ColorModulator;
    vec4 mutableVertexColor = vertexColor;
    if (min(min(barycentric.x, barycentric.y), barycentric.z) > 0.03) {
        mutableVertexColor = PURPLE;
        color = mutableVertexColor * length(color) / 2.0;
    } else {
        color = mutableVertexColor;
    }
    fragColor = linear_fog(color, vertexDistance, FogStart, FogEnd, FogColor);
}
