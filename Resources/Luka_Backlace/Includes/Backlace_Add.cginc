#ifndef BACKLACE_FORWARDADD_CGINC
#define BACKLACE_FORWARDADD_CGINC

// shared properties between base/add passes
FragmentData FragData;
float4 FinalColor;
#if defined(_ALPHAMODULATE_ON)
    sampler3D _DitherMaskLOD;
#endif
float LightAttenuation;
float _DirectLightMode;
float UnmaxedNdotL;
float NdotL;
float NdotV;
float NdotH;
float LdotH;
float _MainTex_UV;
float _Occlusion;
float Occlusion;
float _MSSO_UV;
float _Cutoff;
float _BumpScale;
float _BumpMap_UV;
float Roughness;
float Attenuation;
float RampAttenuation;
float _RampOffset;
float _ShadowIntensity;
float _OcclusionOffsetIntensity;
float _Metallic;
float Metallic;
float _Glossiness;
float Glossiness;
float _Specular;
float Specular;
float SquareRoughness;
float _ReplaceSpecular;
float OneMinusReflectivity;
float _SpecularTintTexture_UV;
float GFS;
float _DFGType;
float _Anisotropy;
float _TangentMap_UV;
float _IndirectFallbackMode;
float _IndirectOverride;
float RoughnessSquared;
float _EnableSpecular;
float _SpecularMode;
float _EnableAddLightLimit;
float _AddLightMin;
float _AddLightMax;
float3 NormalMap;
float3 NormalDir;
float3 LightDir;
float3 ViewDir;
float3 TangentDir;
float3 BitangentDir;
float3 HalfDir;
float3 ReflectDir;
float3 Lightmap;
float3 DynamicLightmap;
float3 IndirectDiffuse;
float3 Diffuse;
float3 VertexDirectDiffuse;
float3 _RampMin;
float3 SpecularColor;
float3 DirectSpecular;
float3 NDF;
float3 EnergyCompensation;
float3 Dfg;
float3 IndirectSpecular;
float3 CustomIndirect;
float4 LightmapDirection;
float4 DynamicLightmapDirection;
float4 SpecLightColor;
float4 LightColor;
float4 Albedo;
float4 _MainTex_ST;
float4 _Color;
float4 _MSSO_ST;
float4 Msso;
float4 _BumpMap_ST;
float4 _RampColor;
float4 _SpecularTintTexture_ST;
float4 _SpecularTint;
float4 _TangentMap_ST;
samplerCUBE _FallbackCubemap;
UNITY_DECLARE_TEX2D(_MainTex);
UNITY_DECLARE_TEX2D(_Ramp);
UNITY_DECLARE_TEX2D_NOSAMPLER(_MSSO);
UNITY_DECLARE_TEX2D_NOSAMPLER(_BumpMap);
UNITY_DECLARE_TEX2D_NOSAMPLER(_SpecularTintTexture);
UNITY_DECLARE_TEX2D_NOSAMPLER(_TangentMap);
Texture2D_float _DFG;
SamplerState sampler_DFG;

// includes
#include "./Backlace_Universal.cginc"
#include "./Backlace_Forward.cginc"
#include "./Backlace_Vertex.cginc"

// ...
float4 Fragment(FragmentData i) : SV_TARGET
{
    FragData = i;
    FinalColor = float4(0, 0, 0, 0);
    LoadUVs();
    SampleAlbedo();
    ClipAlpha();
    SampleNormal();
    SampleMSSO();
    #if defined(_BACKLACE_EMISSION)
        CalculateEmission();
    #endif
    #if defined(_BACKLACE_SPECULAR)
        GetSampleData();
    #endif // _BACKLACE_SPECULAR
    GetDirectionVectors();
    GetLightData();
    GetDotProducts();
    #if defined(_BACKLACE_SPECULAR)
        SetupAlbedoAndSpecColor();
        SetupDFG();
    #endif // _BACKLACE_SPECULAR
    PremultiplyAlpha();
    if (_DirectLightMode == 0)
    {
        GetPBRDiffuse();
    }
    if (_DirectLightMode == 1)
    {
        GetToonDiffuse();
    }
    if (_DirectLightMode == 0)
    {
        GetPBRVertexDiffuse();
    }
    if (_DirectLightMode == 1)
    {
        GetToonVertexDiffuse();
    }
    if (_SpecularMode == 0)
    {
        StandardDirectSpecular();
    }
    if (_SpecularMode == 1)
    {
        AnisotropicDirectSpecular();
    }
    #if defined(_BACKLACE_SPECULAR)
        FinalizeDirectSpecularTerm();
    #endif // _BACKLACE_SPECULAR
    if (_IndirectFallbackMode == 1)
    {
        GetFallbackCubemap();
    }
    #if defined(_BACKLACE_SPECULAR)
        GetIndirectSpecular();
    #endif // _BACKLACE_SPECULAR
    if (_DirectLightMode == 0)
    {
        AddStandardDiffuse();
    }
    if (_DirectLightMode == 1)
    {
        AddToonDiffuse();
    }
    #if defined(_BACKLACE_SPECULAR)
        AddDirectSpecular();
        AddIndirectSpecular();
    #endif // _BACKLACE_SPECULAR
    #if defined(_BACKLACE_EMISSION)
        AddEmission();
    #endif
    AddAlpha();
    return FinalColor;
}

#endif // BACKLACE_FORWARDADD_CGINC