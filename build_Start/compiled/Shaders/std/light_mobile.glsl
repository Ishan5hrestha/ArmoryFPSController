#ifndef _LIGHT_MOBILE_GLSL_
#define _LIGHT_MOBILE_GLSL_

#include "compiled.inc"
#include "std/brdf.glsl"
#ifdef _ShadowMap
#include "std/shadows.glsl"
#endif

#ifdef _ShadowMap
	#ifdef _SinglePoint
		#ifdef _Spot
		uniform sampler2DShadow shadowMapSpot[1];
		uniform mat4 LWVPSpot[1];
		#else
		uniform samplerCubeShadow shadowMapPoint[1];
		uniform vec2 lightProj;
		#endif
	#endif
	#ifdef _Clusters
		#ifdef _SingleAtlas
		//!uniform sampler2DShadow shadowMapAtlas;
		#endif
		uniform vec2 lightProj;
		#ifdef _ShadowMapAtlas
		#ifndef _SingleAtlas
		uniform sampler2DShadow shadowMapAtlasPoint;
		#endif
		#else
		uniform samplerCubeShadow shadowMapPoint[4];
		#endif
		#ifdef _Spot
			#ifdef _ShadowMapAtlas
			#ifndef _SingleAtlas
			uniform sampler2DShadow shadowMapAtlasSpot;
			#endif
			#else
			uniform sampler2DShadow shadowMapSpot[maxLightsCluster];
			#endif
			uniform mat4 LWVPSpotArray[maxLightsCluster];
		#endif
	#endif
#endif

vec3 sampleLight(const vec3 p, const vec3 n, const vec3 v, const float dotNV, const vec3 lp, const vec3 lightCol,
	const vec3 albedo, const float rough, const float spec, const vec3 f0
	#ifdef _ShadowMap
		, int index, float bias, bool receiveShadow
	#endif
	#ifdef _Spot
		, bool isSpot, float spotA, float spotB, vec3 spotDir
	#endif
	) {
	vec3 ld = lp - p;
	vec3 l = normalize(ld);
	vec3 h = normalize(v + l);
	float dotNH = dot(n, h);
	float dotVH = dot(v, h);
	float dotNL = dot(n, l);

	vec3 direct = albedo * max(dotNL, 0.0) +
				  specularBRDF(f0, rough, dotNL, dotNH, dotNV, dotVH) * spec;

	direct *= lightCol;
	direct *= attenuate(distance(p, lp));

	#ifdef _Spot
	if (isSpot) {
		float spotEffect = dot(spotDir, l); // lightDir
		// x - cutoff, y - cutoff - exponent
		if (spotEffect < spotA) {
			direct *= smoothstep(spotB, spotA, spotEffect);
		}
		#ifdef _ShadowMap
			if (receiveShadow) {
				#ifdef _SinglePoint
				vec4 lPos = LWVPSpot[0] * vec4(p + n * bias * 10, 1.0);
				direct *= shadowTest(shadowMapSpot[0], lPos.xyz / lPos.w, bias);
				#endif
				#ifdef _Clusters
					vec4 lPos = LWVPSpotArray[index] * vec4(p + n * bias * 10, 1.0);
					#ifdef _ShadowMapAtlas
						direct *= shadowTest(
							#ifndef _SingleAtlas
							shadowMapAtlasSpot
							#else
							shadowMapAtlas
							#endif
							, lPos.xyz / lPos.w, bias
						);
					#else
							 if (index == 0) direct *= shadowTest(shadowMapSpot[0], lPos.xyz / lPos.w, bias);
						else if (index == 1) direct *= shadowTest(shadowMapSpot[1], lPos.xyz / lPos.w, bias);
						else if (index == 2) direct *= shadowTest(shadowMapSpot[2], lPos.xyz / lPos.w, bias);
						else if (index == 3) direct *= shadowTest(shadowMapSpot[3], lPos.xyz / lPos.w, bias);
					#endif
				#endif
			}
		#endif
		return direct;
	}
	#endif

	#ifdef _ShadowMap

		if (receiveShadow) {
			#ifdef _SinglePoint
			#ifndef _Spot
			direct *= PCFCube(shadowMapPoint[0], ld, -l, bias, lightProj, n);
			#endif
			#endif
			#ifdef _Clusters
				#ifdef _ShadowMapAtlas
				direct *= PCFFakeCube(
					#ifndef _SingleAtlas
					shadowMapAtlasPoint
					#else
					shadowMapAtlas
					#endif
					, ld, -l, bias, lightProj, n, index
				);
				#else
					 if (index == 0) direct *= PCFCube(shadowMapPoint[0], ld, -l, bias, lightProj, n);
				else if (index == 1) direct *= PCFCube(shadowMapPoint[1], ld, -l, bias, lightProj, n);
				else if (index == 2) direct *= PCFCube(shadowMapPoint[2], ld, -l, bias, lightProj, n);
				else if (index == 3) direct *= PCFCube(shadowMapPoint[3], ld, -l, bias, lightProj, n);
				#endif
			#endif
		}
	#endif

	return direct;
}

#endif
