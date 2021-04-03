#version 150

#define NUMCONTROLS 26
#define THRESH 0.5
#define FPRECISION 4000000.0
#define PROJNEAR 0.05
#define PI 3.1415926538

#define CYAN vec4(0.2, 1.0, 1.0, 1.0)
#define MAGENTA vec4(1.0, 0.2, 1.0, 1.0)
#define PURPLE vec4(0.5, 0.2, 0.5, 1.0)
#define DPURPLE vec4(0.25, 0.0, 0.3, 1.0)

int intmod(int i, int base) {
    return i - (i / base * base);
}

vec3 generateBarycentric() {
    if (intmod(gl_VertexID, 4) == 0) {
        return vec3(1.0, 0.0, 0.0);
    }
    else if (intmod(gl_VertexID, 4) == 1) {
        return vec3(0.0, 0.0, 1.0);
    }
    else if (intmod(gl_VertexID, 4) == 2) {
        return vec3(0.0, 1.0, 0.0);
    }
    else {
        return vec3(0.0, 0.0, 1.0);
    }
}

vec4 generateSpectrum() {
    if (intmod(gl_VertexID, 4) == 0) {
        return CYAN;
    }
    else if (intmod(gl_VertexID, 4) == 1) {
        return MAGENTA;
    }
    else if (intmod(gl_VertexID, 4) == 2) {
        return CYAN;
    }
    else {
        return MAGENTA;
    }
}
