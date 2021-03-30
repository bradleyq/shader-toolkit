#version 150

#define OFFSET vec3(0.75, -0.25, -0.5)
#define BIGPRIME 781633
#define PERIOD 10
#define SCALE 300
#define OUTOFWORLD 1000

// check if current frame is a holo render
bool inHolo(float GameTime) {
    return mod(GameTime * BIGPRIME, PERIOD) < 1.0;
}

// output scaled position if holo frame
vec4 scaleView(mat4 ModelViewMat, mat4 ProjMat, float GameTime, vec3 Position) {
    if (inHolo(GameTime)) {
        Position /= SCALE;
    }
    vec4 scaledPos4 = ModelViewMat * vec4(Position, 1.0);
    if (mod(GameTime * BIGPRIME, PERIOD) < 1.0) {
        scaledPos4.xyz += OFFSET;
    }
    scaledPos4 = ProjMat * scaledPos4;
    return scaledPos4;
}

// remove target from render view if holo
vec4 removeView(mat4 ModelViewMat, mat4 ProjMat, float GameTime, vec3 Position) {
    vec4 scaledPos4 = ProjMat * ModelViewMat * vec4(Position, 1.0);
    if (inHolo(GameTime)) {
        scaledPos4 /= scaledPos4.w;
        scaledPos4.y += OUTOFWORLD;
    }
    return scaledPos4;
}
