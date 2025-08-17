#ifndef BACKLACE_UNIVERSAL_CGINC
#define BACKLACE_UNIVERSAL_CGINC

// macros
#define BACKLACE_TRANSFORM_TEX(set, name) (set[name##_UV].xy * name##_ST.xy + name##_ST.zw)

// loading uv functions
// todo: rework this, seems incredibly inefficient ?
#if defined(UNITY_PASS_FORWARDBASE) || defined(UNITY_PASS_FORWARDADD) || defined(UNITY_PASS_META) || defined(_ALPHATEST_ON) || defined(_ALPHABLEND_ON) || defined(_ALPHAPREMULTIPLY_ON) || defined(_ALPHAMODULATE_ON)
    
    float2 Uvs[1];
    inline void LoadUV0()
    {
        Uvs[0] = FragData.uv;
    }

    void LoadUVList()
    {
        LoadUV0();
    }

    void LoadUVs()
    {
        LoadUVList();
    }

    // sample texture shortcuct
    // too: make colour passed to it instead of using _Color
    void SampleAlbedo()
    {
        Albedo = UNITY_SAMPLE_TEX2D(_MainTex, BACKLACE_TRANSFORM_TEX(Uvs, _MainTex)) * _Color;
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

// here is where we leave out shadow pass
#if defined(UNITY_PASS_FORWARDBASE) || defined(UNITY_PASS_FORWARDADD) || defined(UNITY_PASS_META)

    // sample MSSO texture
    void SampleMSSO()
    {
        Msso = UNITY_SAMPLE_TEX2D_SAMPLER(_MSSO, _MainTex, BACKLACE_TRANSFORM_TEX(Uvs, _MSSO));
        Occlusion = lerp(1, Msso.a, _Occlusion);
    }

    // get sample data from MSSO texture
    void GetSampleData()
    {
        Metallic = Msso.r * _Metallic;
        Glossiness = Msso.g * _Glossiness;
        Specular = Msso.b * _Specular;
        Roughness = 1 - Glossiness;
        SquareRoughness = max(Roughness * Roughness, 0.002);
    }

    // setup albedo and specular color
    void SetupAlbedoAndSpecColor()
    {
        float3 specularTint = (UNITY_SAMPLE_TEX2D_SAMPLER(_SpecularTintTexture, _MainTex, BACKLACE_TRANSFORM_TEX(Uvs, _SpecularTintTexture)).rgb * _SpecularTint).rgb;
        float sp = Specular * 0.08;
        SpecularColor = lerp(float3(sp, sp, sp), Albedo.rgb, Metallic);
        if (_ReplaceSpecular == 1)
        {
            SpecularColor = specularTint;
        }
        else
        {
            SpecularColor *= specularTint;
        }
        OneMinusReflectivity = (1 - sp) - (Metallic * (1 - sp));
        Albedo.rgb *= OneMinusReflectivity;
    }

#endif // UNITY_PASS_FORWARDBASE || UNITY_PASS_FORWARDADD || UNITY_PASS_META

#endif // BACKLACE_UNIVERSAL_CGINC