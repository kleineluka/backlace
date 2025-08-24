#ifndef BACKLACE_SHADOW_CGINC
#define BACKLACE_SHADOW_CGINC

// compiler directives
#pragma target 5.0
#pragma multi_compile_shadowcaster
#pragma skip_variants FOG_LINEAR FOG_EXP FOG_EXP2
#pragma vertex Vertex
#pragma fragment Fragment

// keywords
#pragma shader_feature_local _ _ALPHATEST_ON _ALPHAMODULATE_ON _ALPHABLEND_ON _ALPHAPREMULTIPLY_ON
#pragma shader_feature_local _ _BACKLACE_PARALLAX
#pragma shader_feature_local _ _BACKLACE_DECAL1
#pragma shader_feature_local _ _BACKLACE_DECAL2

// unity includes
#include "UnityCG.cginc"

// data structures
struct VertexData
{
    float4 vertex : POSITION;
    float3 normal : NORMAL;
    float4 tangentDir : TANGENT;
    float2 uv : TEXCOORD0;
    float2 uv1 : TEXCOORD1;
    float2 uv2 : TEXCOORD2;
    float2 uv3 : TEXCOORD3;
};

struct VertexOutput
{
    float4 pos : SV_POSITION;
    #if defined(_ALPHATEST_ON) || defined(_ALPHABLEND_ON) || defined(_ALPHAPREMULTIPLY_ON) || defined(_ALPHAMODULATE_ON)
        float2 uv : TEXCOORD0;
        float2 uv1 : TEXCOORD1;
        float2 uv2 : TEXCOORD2;
        float2 uv3 : TEXCOORD3;
    #endif // defined(_ALPHATEST_ON) || defined(_ALPHABLEND_ON) || defined(_ALPHAPREMULTIPLY_ON) || defined(_ALPHAMODULATE_ON)
    #if defined(SHADOWS_CUBE)
        float3 lightVec : TEXCOORD4;
    #endif // SHADOWS_CUBE
    float4 vertex : TEXCOORD5;
    float3 worldPos : TEXCOORD6;
    float3 normal : NORMAL;
};

struct FragmentData
{
    #if defined(_ALPHABLEND_ON) || defined(_ALPHAPREMULTIPLY_ON) || defined(_ALPHAMODULATE_ON)
        UNITY_VPOS_TYPE pos : VPOS;
    #else
        float4 pos : SV_POSITION;
    #endif
    #if defined(_ALPHATEST_ON) || defined(_ALPHABLEND_ON) || defined(_ALPHAPREMULTIPLY_ON) || defined(_ALPHAMODULATE_ON)
        float2 uv : TEXCOORD0;
        float2 uv1 : TEXCOORD1;
        float2 uv2 : TEXCOORD2;
        float2 uv3 : TEXCOORD3;
    #endif // defined(_ALPHATEST_ON) || defined(_ALPHABLEND_ON) || defined(_ALPHAPREMULTIPLY_ON) || defined(_ALPHAMODULATE_ON)
    #if defined(SHADOWS_CUBE)
        float3 lightVec : TEXCOORD4;
    #endif // SHADOWS_CUBE
    float4 vertex : TEXCOORD5;
    float3 worldPos : TEXCOORD6;
    float3 normal : NORMAL;
};

sampler3D _DitherMaskLOD;
FragmentData FragData;
UNITY_DECLARE_TEX2D(_MainTex);
float4 _MainTex_ST;
float4 _Color;
float _Cutoff;
float _MainTex_UV;

// parallax-only features
#if defined(_BACKLACE_PARALLAX)
    UNITY_DECLARE_TEX2D(_ParallaxMap);
    float _ParallaxMap_UV;
    float _ParallaxStrength;
#endif // _BACKLACE_PARALLAX

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

#if defined(_ALPHATEST_ON) || defined(_ALPHABLEND_ON) || defined(_ALPHAPREMULTIPLY_ON) || defined(_ALPHAMODULATE_ON)
    float _DirectLightMode;
    float _EnableSpecular;  
    float _IndirectFallbackMode;
    UNITY_DECLARE_TEX2D(_MainTex);
    void ClipShadowAlpha(inout BacklaceSurfaceData Surface)
    {
        #if defined(_ALPHATEST_ON)
            clip(Surface.Albedo.a - _Cutoff);
        #else // _ALPHATEST_ON
            #if defined(_ALPHABLEND_ON) || defined(_ALPHAPREMULTIPLY_ON) || defined(_ALPHAMODULATE_ON)
                float dither = tex3D(_DitherMaskLOD, float3(FragData.pos.xy * 0.25, Surface.Albedo.a * 0.9375)).a; //Dither16x16Bayer(FragData.pos.xy * 0.25) * Albedo.a;
                clip(dither - 0.01);
            #endif // _ALPHABLEND_ON || _ALPHAPREMULTIPLY_ON || _ALPHAMODULATE_ON
        #endif
    }
#endif // defined(_ALPHATEST_ON) || defined(_ALPHABLEND_ON) || defined(_ALPHAPREMULTIPLY_ON) || defined(_ALPHAMODULATE_ON)

// my includes
#include "./Backlace_Universal.cginc"

// shadow vertex function
VertexOutput  Vertex(VertexData v)
{
    VertexOutput  i;
    i.vertex = v.vertex;
    float3 worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
    i.normal = UnityObjectToWorldNormal(v.normal);
    i.worldPos = worldPos;
    #if defined(_BACKLACE_PARALLAX)
        float3 worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
        float3 worldNormal = UnityObjectToWorldNormal(v.normal);
        float3 worldTangent = UnityObjectToWorldDir(v.tangentDir.xyz);
        float3 worldBitangent = cross(worldNormal, worldTangent) * v.tangentDir.w * unity_WorldTransformParams.w;
        float3 lightDir = UnityWorldSpaceLightDir(worldPos);
        float3 viewDirForParallax = -lightDir; 
        float3x3 worldToTangent = float3x3(worldTangent, worldBitangent, worldNormal);
        float3 viewDirTS = mul(worldToTangent, viewDirForParallax);
        float2 parallaxUVs = v.uv;
        float height = UNITY_SAMPLE_TEX2D_LOD(_ParallaxMap, parallaxUVs, 0).r;
        float2 offset = viewDirTS.xy * (height * _ParallaxStrength);
        worldPos += offset.x * worldTangent + offset.y * worldBitangent;
        v.vertex.xyz = mul(unity_WorldToObject, float4(worldPos, 1)).xyz;
    #endif // _BACKLACE_PARALLAX
    #if defined(SHADOWS_CUBE)
        i.pos = UnityObjectToClipPos(v.vertex);
        i.lightVec = mul(unity_ObjectToWorld, v.vertex).xyz - _LightPositionRange.xyz;
    #else // SHADOWS_CUBE
        i.pos = UnityClipSpaceShadowCasterPos(v.vertex.xyz, v.normal);
        i.pos = UnityApplyLinearShadowBias(i.pos);
    #endif // SHADOWS_CUBE
    #if defined(_ALPHATEST_ON) || defined(_ALPHABLEND_ON) || defined(_ALPHAPREMULTIPLY_ON) || defined(_ALPHAMODULATE_ON)
        i.uv = v.uv;
        i.uv1 = v.uv1;
        i.uv2 = v.uv2;
        i.uv3 = v.uv3;
    #endif // defined(_ALPHATEST_ON) || defined(_ALPHABLEND_ON) || defined(_ALPHAPREMULTIPLY_ON) || defined(_ALPHAMODULATE_ON)
    return i;
}

// shadow fragment function
float4 Fragment(FragmentData i) : SV_TARGET
{
    BacklaceSurfaceData Surface = (BacklaceSurfaceData)0;
    FragData = i;
    #if defined(_ALPHATEST_ON) || defined(_ALPHABLEND_ON) || defined(_ALPHAPREMULTIPLY_ON) || defined(_ALPHAMODULATE_ON)
        LoadUVs();
        SampleAlbedo(Surface);
        #if defined(_BACKLACE_DECAL1)
            ApplyDecal1(Surface, FragData, Uvs);
        #endif // _BACKLACE_DECAL1
        #if defined(_BACKLACE_DECAL2)
            ApplyDecal2(Surface, FragData, Uvs);
        #endif // _BACKLACE_DECAL2
        ClipShadowAlpha(Surface);
    #endif // defined(_ALPHATEST_ON) || defined(_ALPHABLEND_ON) || defined(_ALPHAPREMULTIPLY_ON) || defined(_ALPHAMODULATE_ON)
    #if defined(SHADOWS_CUBE)
        float depth = length(i.lightVec) + unity_LightShadowBias.x;
        depth *= _LightPositionRange.w;
        return UnityEncodeCubeShadowDepth(depth);
    #else // SHADOWS_CUBE
        return 0;
    #endif // SHADOWS_CUBE
}

#endif // BACKLACE_SHADOW_CGINC