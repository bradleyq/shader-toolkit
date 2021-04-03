#version 150

#define CYAN vec4(0.2, 1.0, 1.0, 1.0)
#define MAGENTA vec4(1.0, 0.2, 1.0, 1.0)
#define PURPLE vec4(0.5, 0.2, 0.5, 1.0)
#define DPURPLE vec4(0.25, 0.0, 0.3, 1.0)

vec4 linear_fog(vec4 inColor, float vertexDistance, float fogStart, float fogEnd, vec4 fogColor) {
    if (fogStart > 1.0) { // just to look nicer
        fogStart /= 10.0;
    }
    if (vertexDistance <= fogStart) {
        return inColor;
    }

    float fogValue = vertexDistance < fogEnd ? smoothstep(fogStart, fogEnd, vertexDistance) : 1.0;

    // modified fog color to purple
    return vec4(mix(inColor.rgb, PURPLE.rgb * length(fogColor.rgb) / sqrt(3.0), fogValue * fogColor.a), inColor.a);
}

float linear_fog_fade(float vertexDistance, float fogStart, float fogEnd) {
    if (vertexDistance <= fogStart) {
        return 1.0;
    } else if (vertexDistance >= fogEnd) {
        return 0.0;
    }

    return smoothstep(fogEnd, fogStart, vertexDistance);
}
