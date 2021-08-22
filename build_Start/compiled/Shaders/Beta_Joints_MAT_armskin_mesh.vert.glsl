#version 450
#include "compiled.inc"
#include "std/skinning.glsl"
in vec4 pos;
in vec2 nor;
in vec4 bone;
in vec4 weight;
out vec3 wnormal;
uniform mat3 N;
uniform float posUnpack;
uniform mat4 WVP;
void main() {
	vec4 spos = vec4(pos.xyz, 1.0);
	vec4 skinA;
	vec4 skinB;
	getSkinningDualQuat(ivec4(bone * 32767), weight, skinA, skinB);
	spos.xyz *= posUnpack;
	spos.xyz += 2.0 * cross(skinA.xyz, cross(skinA.xyz, spos.xyz) + skinA.w * spos.xyz); // Rotate
	spos.xyz += 2.0 * (skinA.w * skinB.xyz - skinB.w * skinA.xyz + cross(skinA.xyz, skinB.xyz)); // Translate
	spos.xyz /= posUnpack;
	wnormal = normalize(N * (vec3(nor.xy, pos.w) + 2.0 * cross(skinA.xyz, cross(skinA.xyz, vec3(nor.xy, pos.w)) + skinA.w * vec3(nor.xy, pos.w))));
	gl_Position = WVP * spos;
}
