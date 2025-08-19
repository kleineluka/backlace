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

// unity includes
#include "UnityCG.cginc"

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
};

sampler3D _DitherMaskLOD;
FragmentData FragData;

#if defined(_ALPHATEST_ON) || defined(_ALPHABLEND_ON) || defined(_ALPHAPREMULTIPLY_ON) || defined(_ALPHAMODULATE_ON)
    float _MainTex_UV;
    float _Cutoff;
    float _DirectLightMode;
    float _EnableSpecular;
    float _SpecularMode;
    float _IndirectFallbackMode;
    float4 Albedo;
    float4 _MainTex_ST;
    float4 _Color;
    UNITY_DECLARE_TEX2D(_MainTex);
    void ClipShadowAlpha()
    {
        #if defined(_ALPHATEST_ON)
            clip(Albedo.a - _Cutoff);
        #else
            #if defined(_ALPHABLEND_ON) || defined(_ALPHAPREMULTIPLY_ON) || defined(_ALPHAMODULATE_ON)
                float dither = tex3D(_DitherMaskLOD, float3(FragData.pos.xy * 0.25, Albedo.a * 0.9375)).a; //Dither16x16Bayer(FragData.pos.xy * 0.25) * Albedo.a;
                clip(dither - 0.01);
            #endif
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
    FragData = i;
    #if defined(_ALPHATEST_ON) || defined(_ALPHABLEND_ON) || defined(_ALPHAPREMULTIPLY_ON) || defined(_ALPHAMODULATE_ON)
        LoadUVs();
        SampleAlbedo();
        ClipShadowAlpha();
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