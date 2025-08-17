#ifndef BACKLACE_SHADOW_CGINC
#define BACKLACE_SHADOW_CGINC

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

#include "./Backlace_Universal.cginc"

VertexOutput  Vertex(VertexData v)
{
    VertexOutput  i;
    i.vertex = v.vertex;
    #if defined(SHADOWS_CUBE)
        i.pos = UnityObjectToClipPos(v.vertex);
        i.lightVec = mul(unity_ObjectToWorld, v.vertex).xyz - _LightPositionRange.xyz;
    #else
        i.pos = UnityClipSpaceShadowCasterPos(v.vertex.xyz, v.normal);
        i.pos = UnityApplyLinearShadowBias(i.pos);
    #endif
    #if defined(_ALPHATEST_ON) || defined(_ALPHABLEND_ON) || defined(_ALPHAPREMULTIPLY_ON) || defined(_ALPHAMODULATE_ON)
        i.uv = v.uv;
        i.uv1 = v.uv1;
        i.uv2 = v.uv2;
        i.uv3 = v.uv3;
    #endif
    return i;
}

float4 Fragment(FragmentData i) : SV_TARGET
{
    FragData = i;
    #if defined(_ALPHATEST_ON) || defined(_ALPHABLEND_ON) || defined(_ALPHAPREMULTIPLY_ON) || defined(_ALPHAMODULATE_ON)
        LoadUVs();
        SampleAlbedo();
        ClipShadowAlpha();
    #endif
    #if defined(SHADOWS_CUBE)
        float depth = length(i.lightVec) + unity_LightShadowBias.x;
        depth *= _LightPositionRange.w;
        return UnityEncodeCubeShadowDepth(depth);
    #else
        return 0;
    #endif
}

#endif // BACKLACE_SHADOW_CGINC