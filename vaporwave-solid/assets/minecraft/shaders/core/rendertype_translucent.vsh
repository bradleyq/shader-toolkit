#version 150

#moj_import <light.glsl>
#moj_import <utils.glsl>

in vec3 Position;
in vec4 Color;
in vec2 UV0;
in ivec2 UV2;
in vec3 Normal;

uniform sampler2D Sampler2;

uniform mat4 ModelViewMat;
uniform mat4 ProjMat;
uniform vec3 ChunkOffset;
uniform float GameTime;

out float vertexDistance;
out vec4 vertexColor;
out vec2 texCoord0;
out vec4 normal;
out vec3 barycentric;

void main() {
    barycentric = generateBarycentric();
    vec3 transformedPos = Position;
    vertexColor = MAGENTA;
    
    //water waves and color pulse
    if (abs(mod(Position.y * 16, 16) - 14.2) < 0.05) {
        transformedPos.y += sin(mod(Position.x * PI / 8.0 + GameTime * 1500, 2 * PI)) / 16.0;
        vertexColor.rgb += (sin(mod(Position.z * PI / 4.0 + GameTime * 1000, 2 * PI)) + 1.0) * vec3(0.1);
    }

    gl_Position = ProjMat * ModelViewMat * vec4(transformedPos + ChunkOffset, 1.0);

    vertexDistance = length((ModelViewMat * vec4(transformedPos + ChunkOffset, 1.0)).xyz);
    vertexColor.rgb *= length(Color) / 1.5;
    texCoord0 = UV0;
    normal = ProjMat * ModelViewMat * vec4(Normal, 0.0);
}
