static float3 wnormal;
static float3 mposition;
static float4 fragColor[2];

struct SPIRV_Cross_Input
{
    float3 mposition : TEXCOORD0;
    float3 wnormal : TEXCOORD1;
};

struct SPIRV_Cross_Output
{
    float4 fragColor[2] : SV_Target0;
};

float mod(float x, float y)
{
    return x - y * floor(x / y);
}

float2 mod(float2 x, float2 y)
{
    return x - y * floor(x / y);
}

float3 mod(float3 x, float3 y)
{
    return x - y * floor(x / y);
}

float4 mod(float4 x, float4 y)
{
    return x - y * floor(x / y);
}

float3 tex_checker(float3 co, float3 col1, float3 col2, float scale)
{
    float3 p = (co + 9.9999897429370321333408355712891e-07f.xxx) * scale;
    float xi = abs(floor(p.x));
    float yi = abs(floor(p.y));
    float zi = abs(floor(p.z));
    bool check = (mod(xi, 2.0f) == mod(yi, 2.0f)) == (mod(zi, 2.0f) != 0.0f);
    bool3 _104 = check.xxx;
    return float3(_104.x ? col1.x : col2.x, _104.y ? col1.y : col2.y, _104.z ? col1.z : col2.z);
}

float2 octahedronWrap(float2 v)
{
    return (1.0f.xx - abs(v.yx)) * float2((v.x >= 0.0f) ? 1.0f : (-1.0f), (v.y >= 0.0f) ? 1.0f : (-1.0f));
}

float packFloatInt16(float f, uint i)
{
    return (0.06248569488525390625f * f) + (0.06250095367431640625f * float(i));
}

float packFloat2(float f1, float f2)
{
    return floor(f1 * 255.0f) + min(f2, 0.9900000095367431640625f);
}

void frag_main()
{
    float3 n = normalize(wnormal);
    float3 TextureCoordinate_Object_res = mposition;
    float3 CheckerTexture_Color_res = tex_checker(TextureCoordinate_Object_res, 0.800000011920928955078125f.xxx, 0.4000000059604644775390625f.xxx, 1.0f);
    float3 basecol = CheckerTexture_Color_res;
    float roughness = 0.100000001490116119384765625f;
    float metallic = 0.0f;
    float occlusion = 1.0f;
    float specular = 1.0f;
    n /= ((abs(n.x) + abs(n.y)) + abs(n.z)).xxx;
    float2 _148;
    if (n.z >= 0.0f)
    {
        _148 = n.xy;
    }
    else
    {
        _148 = octahedronWrap(n.xy);
    }
    n = float3(_148.x, _148.y, n.z);
    fragColor[0] = float4(n.xy, roughness, packFloatInt16(metallic, 0u));
    fragColor[1] = float4(basecol, packFloat2(occlusion, specular));
}

SPIRV_Cross_Output main(SPIRV_Cross_Input stage_input)
{
    wnormal = stage_input.wnormal;
    mposition = stage_input.mposition;
    frag_main();
    SPIRV_Cross_Output stage_output;
    stage_output.fragColor = fragColor;
    return stage_output;
}
