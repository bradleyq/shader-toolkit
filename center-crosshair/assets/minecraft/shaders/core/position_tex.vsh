#version 150

in vec3 Position;
in vec2 UV0;

uniform sampler2D Sampler0;
uniform mat4 ModelViewMat;
uniform mat4 ProjMat;
uniform vec2 ScreenSize;

out vec2 texCoord0;
out vec3 vertexColor;

#define CROSSHAIRSIZE 0.05      // target crosshair size as multiple of Y height
#define CROSSHAIRSIZEMIN 80.0   // minimum crosshair size on screen in pix (entire sprite, not just visible portion)
#define FUDGE 0.999             // for UV to prevent stitching effect. no touchy!
#define SPRITESIZE 1.0 / 16.0   // size of crosshair on icons.png. no touchy!
#define MINTEXSIZE 1024.0       // minimum size of crosshair+ui texture

void main() {
    vec4 pos = ProjMat * ModelViewMat * vec4(Position, 1.0);
    vec2 dim = textureSize(Sampler0, 0);
    float ratio = ScreenSize.y / ScreenSize.x;
    texCoord0 = UV0;
    vertexColor = vec3(1.0);
    

    if (dim.x >= MINTEXSIZE && dim.y >= MINTEXSIZE && abs(pos.x) <= 0.1 * ratio && abs(pos.y) <= 0.1 && Position.z == 0.0 && UV0.x < SPRITESIZE && UV0.y < SPRITESIZE) {
        if (pos.x < 0.0) {
            pos.x = -max(CROSSHAIRSIZE * ratio, CROSSHAIRSIZEMIN / ScreenSize.x);
            texCoord0.x = SPRITESIZE * (1.0 - FUDGE);
        } else {
            texCoord0.x = SPRITESIZE * FUDGE;
            pos.x = max(CROSSHAIRSIZE * ratio, CROSSHAIRSIZEMIN / ScreenSize.x);
        }
        if (pos.y < 0.0) {
            texCoord0.y = SPRITESIZE * (1.0 - FUDGE);
            pos.y = -max(CROSSHAIRSIZE, CROSSHAIRSIZEMIN / ScreenSize.y);
        } else {
            texCoord0.y = SPRITESIZE * FUDGE;
            pos.y = max(CROSSHAIRSIZE, CROSSHAIRSIZEMIN / ScreenSize.y);
        }
        
        if (int(ScreenSize.x) % 2 == 1) { // handle odd width case
            pos.x -= 1.0 / ScreenSize.x;
        }
        if (int(ScreenSize.y) % 2 == 1) { // handle odd height case
            pos.y -= 1.0 / ScreenSize.y;
        }
    }
    gl_Position = pos;
}
