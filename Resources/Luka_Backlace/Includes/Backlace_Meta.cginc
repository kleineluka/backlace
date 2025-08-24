#ifndef BACKLACE_META_CGINC
#define BACKLACE_META_CGINC

// compiler directives
#pragma vertex Vertex
#pragma fragment Fragment

// unity includes
#include "UnityCG.cginc"
#include "UnityStandardUtils.cginc"
#include "UnityMetaPass.cginc"

// keywords
#include "./Backlace_Keywords.cginc"

// data structures
struct VertexData
{
    float4 vertex : POSITION;
    float3 normal : NORMAL;
    float2 uv : TEXCOORD0;
    float2 uv1 : TEXCOORD1;
    float2 uv2 : TEXCOORD2;
    float2 uv3 : TEXCOORD3;
};

struct FragmentData
{
    float4 pos : SV_POSITION;
    float2 uv : TEXCOORD0;
    float2 uv1 : TEXCOORD1;
    float2 uv2 : TEXCOORD2;
    float2 uv3 : TEXCOORD3;
    float4 vertex : TEXCOORD4;
    float3 worldPos : TEXCOORD5;
    float3 normal : NORMAL;
};

// meta properties
FragmentData FragData;
UNITY_DECLARE_TEX2D(_MainTex);
float4 _MainTex_ST;
float4 _Color;
float _MainTex_UV;

// needed for occlusion in samplemsso
UNITY_DECLARE_TEX2D_NOSAMPLER(_MSSO);
float4 Msso; 
float4 _MSSO_ST;
float _MSSO_UV;
float _Occlusion;

// emission-only features
#if defined(_BACKLACE_EMISSION)
    UNITY_DECLARE_TEX2D_NOSAMPLER(_EmissionMap);
    float4 _EmissionMap_ST;
    float4 _EmissionColor;
    float _EmissionStrength;
    float _UseAlbedoAsEmission;
    float _EmissionMap_UV;
    float3 Emission;
#endif // _BACKLACE_EMISSION

// specular-only features
#if defined(_BACKLACE_SPECULAR)
    UNITY_DECLARE_TEX2D_NOSAMPLER(_SpecularTintTexture);
    float4 _SpecularTintTexture_ST;
    float4 _SpecularTint;
    float _SpecularTintTexture_UV;
    float _Metallic;
    float _Glossiness;
    float _Specular;
    float _ReplaceSpecular;
#endif // _BACKLACE_SPECULAR

// detail-map features
#if defined(_BACKLACE_DETAIL)
    UNITY_DECLARE_TEX2D(_DetailAlbedoMap);
    UNITY_DECLARE_TEX2D(_DetailNormalMap);
    float _DetailMap_UV;
    float _DetailTiling;
    float _DetailNormalStrength;
    float3 NormalMap; // NOTE: dummy variable, detail function needs it but we don't use the result here
#endif // _BACKLACE_DETAIL

// decal1-only features
#if defined(_BACKLACE_DECAL1) || defined(_BACKLACE_DECAL2)
    UNITY_DECLARE_TEX2D(_Decal1Tex);
    float4 _Decal1Tint;
    float2 _Decal1Position;
    float2 _Decal1Scale;
    float _Decal1Rotation;
    float _Decal1_UV;
    float _Decal1TriplanarSharpness;
    int _Decal1BlendMode;
    // not worth for extra compiler time to make these conditional
    float _Decal1IsTriplanar;
    float3 _Decal1TriplanarPosition;
    float _Decal1TriplanarScale;
    float3 _Decal1TriplanarRotation;
#endif // _BACKLACE_DECAL1

// decal2-only features
#if defined(_BACKLACE_DECAL2)
    UNITY_DECLARE_TEX2D(_Decal2Tex);
    float4 _Decal2Tint;
    float2 _Decal2Position;
    float2 _Decal2Scale;
    float _Decal2Rotation;
    float _Decal2_UV;
    float _Decal2TriplanarSharpness;
    int _Decal2BlendMode;
    // not worth for extra compiler time to make these conditional
    float _Decal2IsTriplanar;
    float3 _Decal2TriplanarPosition;
    float _Decal2TriplanarScale;
    float3 _Decal2TriplanarRotation;
#endif // _BACKLACE_DECAL2

// my includes
#include "./Backlace_Universal.cginc"

// meta vertex function
FragmentData Vertex(VertexData v)
{
    FragmentData  i;
    i.vertex = v.vertex;
    i.pos = UnityMetaVertexPosition(v.vertex, v.uv1.xy, v.uv2.xy, unity_LightmapST, unity_DynamicLightmapST);
    i.uv = v.uv;
    i.uv1 = v.uv1;
    i.uv2 = v.uv2;
    i.uv3 = v.uv3;
    i.worldPos = mul(unity_ObjectToWorld, v.vertex);
    i.normal = UnityObjectToWorldNormal(v.normal);
    return i;
}

// meta fragment function
float4 Fragment(FragmentData i) : SV_TARGET
{
    BacklaceSurfaceData Surface = (BacklaceSurfaceData)0;
    Surface.NormalDir = i.normal; // for triplanar decals
    FragData = i;
    UnityMetaInput surfaceData;
    UNITY_INITIALIZE_OUTPUT(UnityMetaInput, surfaceData);
    LoadUVs();
    SampleAlbedo(Surface);
    #if defined(_BACKLACE_DETAIL)
        ApplyDetailMaps(Surface);
    #endif // _BACKLACE_DETAIL
    #if defined(_BACKLACE_DECAL1)
        ApplyDecal1(Surface, FragData, Uvs);
    #endif // _BACKLACE_DECAL1
    #if defined(_BACKLACE_DECAL2)
        ApplyDecal2(Surface, FragData, Uvs);
    #endif // _BACKLACE_DECAL2
    #if defined(_BACKLACE_EMISSION)
        CalculateEmission(Surface);
        surfaceData.Emission = Emission;
    #else // _BACKLACE_EMISSION
        surfaceData.Emission = 0;
    #endif // _BACKLACE_EMISSION
    #if defined(_BACKLACE_SPECULAR)
        SampleMSSO(Surface);
        GetSampleData(Surface);
        SetupAlbedoAndSpecColor(Surface);
    #endif // _BACKLACE_SPECULAR
    surfaceData.Albedo = Surface.Albedo.rgb;
    #if defined(_BACKLACE_SPECULAR)
        surfaceData.Albedo += Surface.SpecularColor * Surface.Roughness * Surface.Roughness * 0.5;
    #endif // _BACKLACE_SPECULAR
    return UnityMetaFragment(surfaceData);
}

#endif // BACKLACE_META_CGINC