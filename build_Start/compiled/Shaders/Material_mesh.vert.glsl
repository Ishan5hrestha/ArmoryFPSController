#version 450
in vec4 pos;
in vec2 nor;
out vec3 wnormal;
out vec3 mposition;
uniform mat3 N;
uniform mat4 WVP;
uniform float posUnpack;
void main() {
	vec4 spos = vec4(pos.xyz, 1.0);
	wnormal = normalize(N * vec3(nor.xy, pos.w));
	mposition = spos.xyz * posUnpack;
	gl_Position = WVP * spos;
}
