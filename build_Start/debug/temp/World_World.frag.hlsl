Texture2D<float4> nishitaLUT : register(t0);
SamplerState _nishitaLUT_sampler : register(s0);
uniform float2 nishitaDensity;
uniform float3 sunDir;
uniform float envmapStrength;

static float3 normal;
static float4 fragColor;

struct SPIRV_Cross_Input
{
    float3 normal : TEXCOORD0;
};

struct SPIRV_Cross_Output
{
    float4 fragColor : SV_Target0;
};

float2 nishita_rsi(float3 r0, float3 rd, float sr)
{
    float a = dot(rd, rd);
    float b = 2.0f * dot(rd, r0);
    float c = dot(r0, r0) - (sr * sr);
    float d = (b * b) - ((4.0f * a) * c);
    float2 _104;
    if (d < 0.0f)
    {
        _104 = float2(100000.0f, -100000.0f);
    }
    else
    {
        _104 = float2(((-b) - sqrt(d)) / (2.0f * a), ((-b) + sqrt(d)) / (2.0f * a));
    }
    return _104;
}

float3 nishita_lookupLUT(float height, float sunTheta)
{
    float2 coords = float2(sqrt(height * 1.5576324585708789527416229248047e-07f), 0.5f + ((0.5f * sign(sunTheta - 1.57079601287841796875f)) * sqrt(abs((sunTheta * 0.63661992549896240234375f) - 1.0f))));
    return nishitaLUT.SampleLevel(_nishitaLUT_sampler, coords, 0.0f).xyz;
}

float random(float2 coords)
{
    return frac(sin(dot(coords, float2(12.98980045318603515625f, 78.233001708984375f))) * 43758.546875f);
}

float3 nishita_atmosphere(float3 r, float3 r0, float3 pSun, float rPlanet)
{
    float2 p = nishita_rsi(r0, r, 6420000.0f);
    if (p.x > p.y)
    {
        return 0.0f.xxx;
    }
    p.y = min(p.y, nishita_rsi(r0, r, rPlanet).x);
    float iStepSize = (p.y - p.x) / 16.0f;
    float iTime = 0.0f;
    float3 totalRlh = 0.0f.xxx;
    float3 totalMie = 0.0f.xxx;
    float iOdRlh = 0.0f;
    float iOdMie = 0.0f;
    float mu = dot(r, pSun);
    float mumu = mu * mu;
    float pRlh = 0.0596831142902374267578125f * (1.0f + mumu);
    float pMie = (0.119366228580474853515625f * (0.422399997711181640625f * (mumu + 1.0f))) / (pow(1.577600002288818359375f - ((2.0f * mu) * 0.7599999904632568359375f), 1.5f) * 2.577600002288818359375f);
    for (int i = 0; i < 16; i++)
    {
        float3 iPos = r0 + (r * (iTime + (iStepSize * 0.5f)));
        float iHeight = length(iPos) - rPlanet;
        float odStepRlh = (exp((-iHeight) / 8000.0f) * nishitaDensity.x) * iStepSize;
        float odStepMie = (exp((-iHeight) / 1200.0f) * nishitaDensity.y) * iStepSize;
        iOdRlh += odStepRlh;
        iOdMie += odStepMie;
        float sunTheta = acos(dot(normalize(iPos), normalize(pSun)));
        float3 jODepth = nishita_lookupLUT(iHeight, sunTheta);
        float2 param = r.xy;
        jODepth += lerp(-1000.0f, 1000.0f, random(param)).xxx;
        float3 attn = exp(-(((1.9999999494757503271102905273438e-05f * (iOdMie + jODepth.y)).xxx + (float3(5.5000000429572537541389465332031e-06f, 1.2999999853491317480802536010742e-05f, 2.2399999579647555947303771972656e-05f) * (iOdRlh + jODepth.x))) + (float3(1.5905184227449353784322738647461e-06f, 9.6707037755550118163228034973145e-07f, 7.3095684172130859224125742912292e-08f) * jODepth.z)));
        totalRlh += (attn * odStepRlh);
        totalMie += (attn * odStepMie);
        iTime += iStepSize;
    }
    return (((float3(5.5000000429572537541389465332031e-06f, 1.2999999853491317480802536010742e-05f, 2.2399999579647555947303771972656e-05f) * pRlh) * totalRlh) + (totalMie * (pMie * 1.9999999494757503271102905273438e-05f))) * 22.0f;
}

float3 sun_disk(float3 n, float3 light_dir, float disk_size, float intensity)
{
    float dist = distance(n, light_dir) / disk_size;
    float invDist = 1.0f - dist;
    float mu = sqrt(invDist * invDist);
    float3 limb_darkening = 1.0f.xxx - (1.0f.xxx - pow(mu.xxx, float3(0.397000014781951904296875f, 0.5030000209808349609375f, 0.652000010013580322265625f)));
    return 1.0f.xxx + (limb_darkening * (((1.0f - step(1.0f, dist)) * 22.0f) * intensity));
}

void frag_main()
{
    float3 n = normalize(normal);
    float3 SkyTexture_Color_res = nishita_atmosphere(n, float3(0.0f, 0.0f, 6360000.0f), sunDir, 6360000.0f) * sun_disk(n, sunDir, 0.0047560040839016437530517578125f, 1.0f);
    fragColor = float4(SkyTexture_Color_res.x, SkyTexture_Color_res.y, SkyTexture_Color_res.z, fragColor.w);
    fragColor.w = 0.0f;
}

SPIRV_Cross_Output main(SPIRV_Cross_Input stage_input)
{
    normal = stage_input.normal;
    frag_main();
    SPIRV_Cross_Output stage_output;
    stage_output.fragColor = fragColor;
    return stage_output;
}
