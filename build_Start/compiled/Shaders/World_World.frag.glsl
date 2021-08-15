#version 450
#include "compiled.inc"
#include "std/sky.glsl"
in vec3 normal;
out vec4 fragColor;
uniform vec3 sunDir;
uniform float envmapStrength;
void main() {
	vec3 n = normalize(normal);
	vec3 SkyTexture_Color_res = nishita_atmosphere(n, vec3(0, 0, 6360000.0), sunDir, 6360000.0)* sun_disk(n, sunDir, 0.004756004314708402, 1.0);
	fragColor.rgb = SkyTexture_Color_res;
	fragColor.a = 0.0;
}
