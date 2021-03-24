#version 150
#moj_import <holo.glsl>

in vec3 Position;

uniform mat4 ModelViewMat;
uniform mat4 ProjMat;
uniform float GameTime;

out mat3 ProjInv;

void main() {
    vec3 scaledPos = Position;

    if (length(ProjMat * ModelViewMat * vec4(scaledPos, 1.0)) > 24.0) {
        scaledPos.y = -512.0;
        scaledPos.xz /= 8.0;
    }

    gl_Position = removeView(ModelViewMat, ProjMat, GameTime, scaledPos);
    ProjInv = inverse(mat3(ProjMat * ModelViewMat));
}
