#ifndef BACKLACE_UNIVERSAL_CGINC
#define BACKLACE_UNIVERSAL_CGINC

// macros
#define BACKLACE_TRANSFORM_TEX(set, name) (set[name##_UV].xy * name##_ST.xy + name##_ST.zw)

// data structures
struct BacklaceSurfaceData
{
    // resulting colour
    float4 FinalColor;
    // core surface properties
    float4 Albedo;
    float3 NormalDir;
    float3 TangentDir;
    float3 BitangentDir;
    // pbr from msso
    float Metallic;
    float Glossiness;
    float Roughness;
    float SquareRoughness;
    float Specular;
    float OneMinusReflectivity;
    float Occlusion;
    // directional/light vectors
    float3 ViewDir;
    float3 LightDir;
    float3 HalfDir;
    float3 ReflectDir;
    // dot products
    float NdotL;
    float UnmaxedNdotL;
    float NdotV;
    float NdotH;
    float LdotH;
    // calculated light data
    float4 LightColor;
    float4 SpecLightColor;
    float3 IndirectDiffuse;
    float3 Diffuse;
    float3 DirectSpecular;
    float3 IndirectSpecular;
    float3 VertexDirectDiffuse;
    float Attenuation;
    // specular intermediates
    float3 SpecularColor;
    float3 EnergyCompensation;
    float3 Dfg;
    float3 CustomIndirect;
};

// loading uv function
#if defined(UNITY_PASS_FORWARDBASE) || defined(UNITY_PASS_FORWARDADD) || defined(UNITY_PASS_META) || defined(_ALPHATEST_ON) || defined(_ALPHABLEND_ON) || defined(_ALPHAPREMULTIPLY_ON) || defined(_ALPHAMODULATE_ON)
    
    float2 Uvs[4];
    void LoadUVs()
    {
        Uvs[0] = FragData.uv;
        Uvs[1] = FragData.uv1;
        Uvs[2] = FragData.uv2;
        Uvs[3] = FragData.uv3;
    }

    void SampleAlbedo(inout BacklaceSurfaceData Surface)
    {
        Surface.Albedo = UNITY_SAMPLE_TEX2D(_MainTex, BACKLACE_TRANSFORM_TEX(Uvs, _MainTex)) * _Color;
    }

#endif // defined(UNITY_PASS_FORWARDBASE) || defined(UNITY_PASS_FORWARDADD) || defined(UNITY_PASS_META) || defined(_ALPHATEST_ON) || defined(_ALPHABLEND_ON) || defined(_ALPHAPREMULTIPLY_ON) || defined(_ALPHAMODULATE_ON)

// remap float from [oldMin, oldMax] to [newMin, newMax]
inline float remap(float value, float oldMin, float oldMax, float newMin, float newMax)
{
    return (value - oldMin) / (oldMax - oldMin) * (newMax - newMin) + newMin;
}

// remap float2 from [oldMin, oldMax] to [newMin, newMax]
inline float2 remap(float2 value, float2 oldMin, float2 oldMax, float2 newMin, float2 newMax)
{
    return (value - oldMin) / (oldMax - oldMin) * (newMax - newMin) + newMin;
}

// remap float3 from [oldMin, oldMax] to [newMin, newMax]
inline float3 remap(float3 value, float3 oldMin, float3 oldMax, float3 newMin, float3 newMax)
{
    return (value - oldMin) / (oldMax - oldMin) * (newMax - newMin) + newMin;
}

// remap float4 from [oldMin, oldMax] to [newMin, newMax]
inline float4 remap(float4 value, float4 oldMin, float4 oldMax, float4 newMin, float4 newMax)
{
    return (value - oldMin) / (oldMax - oldMin) * (newMax - newMin) + newMin;
}

// to the fifth power without pow
inline half Pow5(half x)
{
    return x * x * x * x * x;
}

// square without pow
float sqr(float x)
{
    return x * x;
}

// here is where we leave out shadow pass
#if defined(UNITY_PASS_FORWARDBASE) || defined(UNITY_PASS_FORWARDADD) || defined(UNITY_PASS_META)

    // sample MSSO texture
    void SampleMSSO(inout BacklaceSurfaceData Surface)
    {
        Msso = UNITY_SAMPLE_TEX2D_SAMPLER(_MSSO, _MainTex, BACKLACE_TRANSFORM_TEX(Uvs, _MSSO));
        Surface.Occlusion = lerp(1, Msso.a, _Occlusion);
    }

    // get the greyscale of a colour
    inline float GetLuma(float3 color)
    {
        return dot(color, float3(0.299, 0.587, 0.114));
    }

    // specular feature
    #if defined(_BACKLACE_SPECULAR)
        // get sample data from MSSO texture
        void GetSampleData(inout BacklaceSurfaceData Surface)
        {
            Surface.Metallic = Msso.r * _Metallic;
            Surface.Glossiness = Msso.g * _Glossiness;
            Surface.Specular = Msso.b * _Specular;
            Surface.Roughness = 1 - Surface.Glossiness;
            Surface.SquareRoughness = max(Surface.Roughness * Surface.Roughness, 0.002);
        }

        // setup albedo and specular color
        void SetupAlbedoAndSpecColor(inout BacklaceSurfaceData Surface)
        {
            float3 specularTint = (UNITY_SAMPLE_TEX2D_SAMPLER(_SpecularTintTexture, _MainTex, BACKLACE_TRANSFORM_TEX(Uvs, _SpecularTintTexture)).rgb * _SpecularTint).rgb;
            float sp = Surface.Specular * 0.08;
            Surface.SpecularColor = lerp(float3(sp, sp, sp), Surface.Albedo.rgb, Surface.Metallic);
            if (_ReplaceSpecular == 1)
            {
                Surface.SpecularColor = specularTint;
            }
            else
            {
                Surface.SpecularColor *= specularTint;
            }
            Surface.OneMinusReflectivity = (1 - sp) - (Surface.Metallic * (1 - sp));
            Surface.Albedo.rgb *= Surface.OneMinusReflectivity;
        }
    #endif // defined(_BACKLACE_SPECULAR)

    // emission feature
    #if defined(_BACKLACE_EMISSION)
        // get strength and colour of emission
        void CalculateEmission(inout BacklaceSurfaceData Surface)
        {
            float3 baseEmission = _EmissionColor.rgb;
            [branch] if (_UseAlbedoAsEmission > 0)
            {
                baseEmission = lerp(baseEmission, Surface.Albedo.rgb, _UseAlbedoAsEmission);
            }
            float3 emissionMap = UNITY_SAMPLE_TEX2D_SAMPLER(_EmissionMap, _MainTex, BACKLACE_TRANSFORM_TEX(Uvs, _EmissionMap)).rgb;
            Emission = baseEmission * emissionMap * _EmissionStrength;
        }
    #endif // _BACKLACE_EMISSION

#endif // UNITY_PASS_FORWARDBASE || UNITY_PASS_FORWARDADD || UNITY_PASS_META

#endif // BACKLACE_UNIVERSAL_CGINC