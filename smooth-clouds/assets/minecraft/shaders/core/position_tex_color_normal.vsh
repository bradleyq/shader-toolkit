#version 150

#moj_import <fog.glsl>

in vec3 Position;
in vec2 UV0;
in vec4 Color;
in vec3 Normal;

uniform mat4 ModelViewMat;
uniform mat4 ProjMat;
uniform mat3 IViewRotMat;
uniform int FogShape;

out vec2 texCoord0;
out float vertexDistance;
out vec4 vertexColor;
out vec3 normal;
out float yval;

float slide(float val , float start, float end) {
    return clamp((val - start) / (end - start), 0.0, 1.0);
}

void main() {
    gl_Position = ProjMat * ModelViewMat * vec4(Position, 1.0);

    texCoord0 = UV0;
    vertexDistance = fog_distance(ModelViewMat, Position, FogShape);

    // try the flatten the cloud shading as much as possible
    vec4 col = Color;
    float yc = mix(127.0, 174.0, slide(col.b, 178.0 / 255.0, 110.0 / 255.0));
    float xc = mix(153.0, 225.0, slide(col.b, 229.0 / 255.0, 142.0 / 255.0));
    float zc = mix(204.0, 200.0, slide(col.b, 203.0 / 255.0, 126.0 / 255.0));

    if (dot(Normal, vec3(0.0, -1.0, 0.0)) > 0.999) {
        col.rgb *= 255.0 / yc;
    }
    else if (dot(Normal, vec3(0.0, 1.0, 0.0)) > 0.999) {
        col.rgb *= 255.0 / 255.0;
    }
    else if (abs(dot(Normal, vec3(1.0, 0.0, 0.0))) > 0.999) {
        col.rgb *= 255.0 / xc;
    }
    else if (abs(dot(Normal, vec3(0.0, 0.0, 1.0))) > 0.999) {
        col.rgb *= 255.0 / zc;
    }
    col = min(col, 1.0);

    vertexColor = col;
    normal = Normal;

    yval = 0.0;

    int faceVert = gl_VertexID % 4;
    if (((faceVert == 1 || faceVert == 2) && abs(dot(normal, vec3(1.0, 0.0, 0.0))) > 0.99)
      ||((faceVert == 0 || faceVert == 1) && abs(dot(normal, vec3(0.0, 0.0, 1.0))) > 0.99)){
        yval = 1.0;
    }

    if (dot(normal, vec3(0.0, 1.0, 0.0)) > 0.99) {
        yval = 1.0;
    }
}
