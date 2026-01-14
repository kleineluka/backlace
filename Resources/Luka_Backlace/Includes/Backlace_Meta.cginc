#ifndef BACKLACE_META_CGINC
#define BACKLACE_META_CGINC

// compiler directives
#pragma vertex Vertex
#pragma fragment Fragment
#pragma multi_compile_instancing

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

// uv manipulation
float _UV_Offset_X;
float _UV_Offset_Y;
float _UV_Scale_X;
float _UV_Scale_Y;
float _UV_Rotation;
float _UV_Scroll_X_Speed;
float _UV_Scroll_Y_Speed;

// uv effects
#if defined(_BACKLACE_UV_EFFECTS)
    // triplanar
    float _UVTriplanarMapping;
    float3 _UVTriplanarPosition;
    float _UVTriplanarScale;
    float3 _UVTriplanarRotation;
    float _UVTriplanarSharpness;
    // screenspace
    float _UVScreenspaceMapping;
    float _UVScreenspaceTiling;
    // flipbook
    float _UVFlipbook;
    float _UVFlipbookRows;
    float _UVFlipbookColumns;
    float _UVFlipbookFrames;
    float _UVFlipbookFPS;
    float _UVFlipbookScrub;
    // flowmap
    float _UVFlowmap;
    UNITY_DECLARE_TEX2D(_UVFlowmapTex);
    float _UVFlowmapStrength;
    float _UVFlowmapSpeed;
    float _UVFlowmapDistortion;
    float _UVFlowmap_UV;
#endif // _BACKLACE_UV_EFFECTS

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
    int _SpecularStanardKind;
    int _SpecularSpecialKind;
#endif // _BACKLACE_SPECULAR

//decal1/2-only features
float _DecalStage;

// decal1-only feature
#if defined(_BACKLACE_DECAL1)
    UNITY_DECLARE_TEX2D(_Decal1Tex);
    float4 _Decal1Tint;
    float2 _Decal1Position;
    float2 _Decal1Scale;
    float _Decal1Rotation;
    float _Decal1_UV;
    float _Decal1TriplanarSharpness;
    int _Decal1BlendMode;
    float  _Decal1IsTriplanar;
    float3 _Decal1TriplanarPosition;
    float _Decal1TriplanarScale;
    float3 _Decal1TriplanarRotation;
    float _Decal1Repeat;
    float2 _Decal1Scroll;
    float _Decal1HueShift;
    float _Decal1AutoCycleHue;
    float _Decal1CycleSpeed;
#endif // _BACKLACE_DECAL1

// decal2-only feature
#if defined(_BACKLACE_DECAL2)
    UNITY_DECLARE_TEX2D(_Decal2Tex);
    float4 _Decal2Tint;
    float2 _Decal2Position;
    float2 _Decal2Scale;
    float _Decal2Rotation;
    float _Decal2_UV;
    float _Decal2TriplanarSharpness;
    int _Decal2BlendMode;
    float _Decal2IsTriplanar;
    float3 _Decal2TriplanarPosition;
    float _Decal2TriplanarScale;
    float3 _Decal2TriplanarRotation;
    float _Decal2Repeat;
    float2 _Decal2Scroll;
    float _Decal2HueShift;
    float _Decal2AutoCycleHue;
    float _Decal2CycleSpeed;
#endif // _BACKLACE_DECAL2

// texture stitching feature
int _UseTextureStitching;
UNITY_DECLARE_TEX2D(_StitchTex);
float4 _StitchTex_ST;
int _StitchTex_UV;
int _StitchAxis;
float _StitchOffset;

// my includes
#include "./Backlace_Universal.cginc"

// detail-map features
#if defined(_BACKLACE_DETAIL)
UNITY_DECLARE_TEX2D(_DetailAlbedoMap);
UNITY_DECLARE_TEX2D(_DetailNormalMap);
float _DetailMap_UV;
float _DetailTiling;
float _DetailNormalStrength;
float3 NormalMap; // NOTE: dummy variable, detail function needs it but we don't use the result here
void ApplyDetailMaps(inout BacklaceSurfaceData Surface)
{
    float2 detailUV = Uvs[_DetailMap_UV] * _DetailTiling;
    float4 detailAlbedo = UNITY_SAMPLE_TEX2D(_DetailAlbedoMap, detailUV);
    Surface.Albedo.rgb *= detailAlbedo.rgb * 2 * detailAlbedo.a;
    float3 detailNormalTS = UnpackScaleNormal(UNITY_SAMPLE_TEX2D(_DetailNormalMap, detailUV), _DetailNormalStrength);
    float3 baseNormalTS = NormalMap;
    NormalMap = normalize(float3(baseNormalTS.xy + detailNormalTS.xy, baseNormalTS.z * detailNormalTS.z));
}
#endif // _BACKLACE_DETAIL

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
    Uvs[0] = ManipulateUVs(FragData.uv, _UV_Rotation, _UV_Scale_X, _UV_Scale_Y, _UV_Offset_X, _UV_Offset_Y, _UV_Scroll_X_Speed, _UV_Scroll_Y_Speed);
    #if defined(_BACKLACE_UV_EFFECTS)
        ApplyUVEffects(Uvs[0], Surface);
    #endif // _BACKLACE_UV_EFFECTS
    SampleAlbedo(Surface, i.vertex.xyz);
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