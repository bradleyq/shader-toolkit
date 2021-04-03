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
    vec4 color = texture(Sampler0, texCoord0) * vertexColor * ColorModulator;
    color.a *= 1.3;
    //cutout middle of block
    if (min(min(barycentric.x, barycentric.y), barycentric.z) > 0.03) {
        color.rgb = mix(vertexColor.rgb * length(color.rgb), color.rgb, 0.1);
        color.a *= 0.5;
    }
    fragColor = linear_fog(color, vertexDistance, FogStart, FogEnd, FogColor);
}
