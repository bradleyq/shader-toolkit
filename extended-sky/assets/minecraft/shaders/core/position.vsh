#version 150

in vec3 Position;

uniform mat4 ModelViewMat;
uniform mat4 ProjMat;
uniform float GameTime;

out mat3 ProjInv;

#define BOTTOM -512
#define SCALE 0.125

void main() {
    vec3 scaledPos = Position;

    // sky disk is by default 16.0 units above the camera at all times. 24.0 to be safe.
    if (length(ProjMat * ModelViewMat * vec4(scaledPos, 1.0)) > 24.0) {
        scaledPos.y = BOTTOM;
        scaledPos.xz *= SCALE;
    }

    gl_Position = ProjMat * ModelViewMat * vec4(scaledPos, 1.0);
    ProjInv = inverse(mat3(ProjMat * ModelViewMat));
}
