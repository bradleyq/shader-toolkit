#version 150
#moj_import <holo.glsl>

in vec3 Position;

uniform mat4 ModelViewMat;
uniform mat4 ProjMat;
uniform float FogEnd;
uniform float GameTime;

out mat4 ProjInv;
out float isSky;
out float vertexDistance;

#define BOTTOM -32.0
#define SKYSCALE 0.01
#define SKYHEIGHT 16.0
#define SKYRADIUS 512.0
#define FUDGE 0.004

void main() {
    vec3 scaledPos = Position;
    ProjInv = inverse(ProjMat * ModelViewMat);
    isSky = 0.0;
    vertexDistance = length((ModelViewMat * vec4(Position, 1.0)).xyz);

    // sky disk is by default 16.0 units above with radius of 512.0 around the camera at all times.
    if (abs(scaledPos.y  - SKYHEIGHT) < FUDGE && (length(scaledPos.xz) <= FUDGE || abs(length(scaledPos.xz) - SKYRADIUS) < FUDGE)) {
        isSky = 1.0;

        // Make sky into a cone by bringing down edges of the disk.
        if (length(scaledPos.xz) > 1.0) {
            scaledPos.y = BOTTOM;
        }

        // Make it big so it does not interfere with void plane.
        scaledPos.xyz *= SKYSCALE;

        // rotate to z axis
        scaledPos = scaledPos.xzy;
        scaledPos.z *= -1;

        // ignore model view so the cone follows the camera angle.
        gl_Position = removeView(mat4(1.0), ProjMat, GameTime, scaledPos);
    } else {
        gl_Position = removeView(ModelViewMat, ProjMat, GameTime, scaledPos);
    }
}