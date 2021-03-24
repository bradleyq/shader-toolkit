#version 150

#moj_import <fog.glsl>

uniform sampler2D Sampler0;

uniform vec4 ColorModulator;
uniform float FogStart;
uniform float FogEnd;
uniform vec4 FogColor;

in vec4 gl_FragCoord;
in float vertexDistance;
in vec4 vertexColor;
in vec2 texCoord0;
in vec4 normal;

out vec4 fragColor;

void main() {
    vec4 color = texture(Sampler0, texCoord0) * vertexColor * ColorModulator;
    fragColor = linear_fog(color, vertexDistance, FogStart, FogEnd, FogColor);
    if (gl_FragCoord.x <= 1.0 && gl_FragCoord.y <= 1.0) {
        fragColor = vec4(1.0, 0.0, 0.0, 1.0);
    }
}
