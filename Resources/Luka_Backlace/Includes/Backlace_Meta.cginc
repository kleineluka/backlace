#ifndef BACKLACE_META_CGINC
#define BACKLACE_META_CGINC

FragmentData FragData;
float3 Albedo;
float3 Emission;
float3 SpecularColor;
float Roughness;
float _MainTex_UV;
float _Occlusion;
float Occlusion;
float _MSSO_UV;
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
float _DirectLightMode;
float _EnableSpecular;
float _SpecularMode;
float _IndirectFallbackMode;
float4 _MainTex_ST;
float4 _Color;
float4 _MSSO_ST;
float4 Msso;
float4 _SpecularTintTexture_ST;
float4 _SpecularTint;
UNITY_DECLARE_TEX2D(_MainTex);
UNITY_DECLARE_TEX2D_NOSAMPLER(_MSSO);
UNITY_DECLARE_TEX2D_NOSAMPLER(_SpecularTintTexture);

#include "./Backlace_Universal.cginc"

FragmentData  Vertex(VertexData v)
{
    FragmentData  i;
    i.vertex = v.vertex;
    i.pos = UnityMetaVertexPosition(v.vertex, v.uv1.xy, v.uv2.xy, unity_LightmapST, unity_DynamicLightmapST);
    i.uv = v.uv;
    i.uv1 = v.uv1;
    i.uv2 = v.uv2;
    i.uv3 = v.uv3;
    return i;
}

float4 Fragment(FragmentData i) : SV_TARGET
{
    FragData = i;
    UnityMetaInput surfaceData;
    UNITY_INITIALIZE_OUTPUT(UnityMetaInput, surfaceData);
    Albedo = 0;
    SpecularColor = 0;
    Roughness = 1;
    LoadUVs();
    SampleAlbedo();
    SampleMSSO();
    #if defined(_BACKLACE_EMISSION)
        CalculateEmission();
    #endif
    #if defined(_BACKLACE_SPECULAR)
        GetSampleData();
        SetupAlbedoAndSpecColor();
    #endif // _BACKLACE_SPECULAR
    #if defined(_BACKLACE_EMISSION)
        surfaceData.Emission = Emission;
    #else
        surfaceData.Emission = 0;
    #endif
    surfaceData.Albedo = Albedo + SpecularColor * Roughness * Roughness;
    surfaceData.SpecularColor = SpecularColor;
    return UnityMetaFragment(surfaceData);
}

#endif // BACKLACE_META_CGINC