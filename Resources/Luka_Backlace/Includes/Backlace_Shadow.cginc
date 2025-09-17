#ifndef BACKLACE_SHADOW_CGINC
#define BACKLACE_SHADOW_CGINC

// compiler directives
#pragma target 5.0
#pragma multi_compile_shadowcaster
#pragma skip_variants FOG_LINEAR FOG_EXP FOG_EXP2
#pragma vertex Vertex
#pragma fragment Fragment

// keywords
#pragma multi_compile _BLENDMODE_CUTOUT _BLENDMODE_FADE _BLENDMODE_TRANSPARENT _BLENDMODE_PREMULTIPLY
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
    #if defined(_BLENDMODE_CUTOUT) || defined(_BLENDMODE_TRANSPARENT) || defined(_BLENDMODE_PREMULTIPLY) || defined(_BLENDMODE_FADE)
        float2 uv : TEXCOORD0;
        float2 uv1 : TEXCOORD1;
        float2 uv2 : TEXCOORD2;
        float2 uv3 : TEXCOORD3;
    #endif // defined(_BLENDMODE_CUTOUT) || defined(_BLENDMODE_TRANSPARENT) || defined(_BLENDMODE_PREMULTIPLY) || defined(_BLENDMODE_FADE)
    #if defined(SHADOWS_CUBE)
        float3 lightVec : TEXCOORD4;
    #endif // SHADOWS_CUBE
    float4 vertex : TEXCOORD5;
    float3 worldPos : TEXCOORD6;
    float3 normal : NORMAL;
};

struct FragmentData
{
    #if defined(_BLENDMODE_TRANSPARENT) || defined(_BLENDMODE_PREMULTIPLY) || defined(_BLENDMODE_FADE)
        UNITY_VPOS_TYPE pos : VPOS;
    #else
        float4 pos : SV_POSITION;
    #endif
    #if defined(_BLENDMODE_CUTOUT) || defined(_BLENDMODE_TRANSPARENT) || defined(_BLENDMODE_PREMULTIPLY) || defined(_BLENDMODE_FADE)
        float2 uv : TEXCOORD0;
        float2 uv1 : TEXCOORD1;
        float2 uv2 : TEXCOORD2;
        float2 uv3 : TEXCOORD3;
    #endif // defined(_BLENDMODE_CUTOUT) || defined(_BLENDMODE_TRANSPARENT) || defined(_BLENDMODE_PREMULTIPLY) || defined(_BLENDMODE_FADE)
    #if defined(SHADOWS_CUBE)
        float3 lightVec : TEXCOORD4;
    #endif // SHADOWS_CUBE
    float4 vertex : TEXCOORD5;
    float3 worldPos : TEXCOORD6;
    float3 normal : NORMAL;
};

// main properties
sampler3D _DitherMaskLOD;
FragmentData FragData;
UNITY_DECLARE_TEX2D(_MainTex);
float4 _MainTex_ST;
float4 _Color;
float _Cutoff;
float _MainTex_UV;
int _DecalStage;

// uv manipulation
float _UV_Offset_X;
float _UV_Offset_Y;
float _UV_Scale_X;
float _UV_Scale_Y;
float _UV_Rotation;
float _UV_Scroll_X_Speed;
float _UV_Scroll_Y_Speed;

// vertex manipulation
float3 _VertexManipulationPosition;
float3 _VertexManipulationScale;

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

// my includes
#include "./Backlace_Universal.cginc"
#include "./Backlace_Effects.cginc"

#if defined(_BLENDMODE_CUTOUT) || defined(_BLENDMODE_TRANSPARENT) || defined(_BLENDMODE_PREMULTIPLY) || defined(_BLENDMODE_FADE)
    float _DirectLightMode;
    float _EnableSpecular;  
    float _IndirectFallbackMode;
    void ClipShadowAlpha(inout BacklaceSurfaceData Surface)
    {
        #if defined(_BLENDMODE_CUTOUT)
            clip(Surface.Albedo.a - _Cutoff);
        #else // _BLENDMODE_CUTOUT
            #if defined(_BLENDMODE_TRANSPARENT) || defined(_BLENDMODE_PREMULTIPLY) || defined(_BLENDMODE_FADE)
                float dither = tex3D(_DitherMaskLOD, float3(FragData.pos.xy * 0.25, Surface.Albedo.a * 0.9375)).a; //Dither16x16Bayer(FragData.pos.xy * 0.25) * Albedo.a;
                clip(dither - 0.01);
            #endif // _BLENDMODE_TRANSPARENT || _BLENDMODE_PREMULTIPLY || _BLENDMODE_FADE
        #endif
    }
#endif // defined(_BLENDMODE_CUTOUT) || defined(_BLENDMODE_TRANSPARENT) || defined(_BLENDMODE_PREMULTIPLY) || defined(_BLENDMODE_FADE)

// shadow vertex function
VertexOutput  Vertex(VertexData v)
{
    VertexOutput  i;
    // vertex effects from forward passes
    v.vertex.xyz *= _VertexManipulationScale;
    v.vertex.xyz += _VertexManipulationPosition;
    #if defined(_BACKLACE_VERTEX_DISTORTION)
        DistortVertex(v.vertex);
    #endif // _BACKLACE_VERTEX_DISTORTION
    i.vertex = v.vertex;
    i.normal = UnityObjectToWorldNormal(v.normal);
    i.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
    #if defined(_BACKLACE_PARALLAX)
        float3 parallaxWorldPos = i.worldPos;
        float3 worldNormal = UnityObjectToWorldNormal(v.normal);
        float3 worldTangent = UnityObjectToWorldDir(v.tangentDir.xyz);
        float3 worldBitangent = cross(worldNormal, worldTangent) * v.tangentDir.w * unity_WorldTransformParams.w;
        float3 lightDir = UnityWorldSpaceLightDir(parallaxWorldPos);
        float3 viewDirForParallax = -lightDir; 
        float3x3 worldToTangent = float3x3(worldTangent, worldBitangent, worldNormal);
        float3 viewDirTS = mul(worldToTangent, viewDirForParallax);
        float2 parallaxUVs = v.uv;
        float height = UNITY_SAMPLE_TEX2D_LOD(_ParallaxMap, parallaxUVs, 0).r;
        float2 offset = viewDirTS.xy * (height * _ParallaxStrength);
        parallaxWorldPos += offset.x * worldTangent + offset.y * worldBitangent;
        v.vertex.xyz = mul(unity_WorldToObject, float4(parallaxWorldPos, 1)).xyz;
    #endif // _BACKLACE_PARALLAX
    // flat model shadow casting
    #if defined(_BACKLACE_FLAT_MODEL)
        float4 finalClipPos;
        float3 finalWorldPos;
        float3 finalWorldNormal;
        FlattenModel(v, finalClipPos, finalWorldPos, finalWorldNormal);
        i.pos = UnityClipSpaceShadowCasterPos(mul(unity_WorldToObject, float4(finalWorldPos, 1.0)).xyz, finalWorldNormal);
    #else // _BACKLACE_FLAT_MODEL
        // original shadow caster position calculation
        #if defined(SHADOWS_CUBE)
            i.pos = UnityObjectToClipPos(v.vertex);
            i.lightVec = mul(unity_ObjectToWorld, v.vertex).xyz - _LightPositionRange.xyz;
        #else
            i.pos = UnityClipSpaceShadowCasterPos(v.vertex.xyz, v.normal);
        #endif
    #endif
    i.pos = UnityApplyLinearShadowBias(i.pos);
    #if defined(_BLENDMODE_CUTOUT) || defined(_BLENDMODE_TRANSPARENT) || defined(_BLENDMODE_PREMULTIPLY) || defined(_BLENDMODE_FADE)
        i.uv = v.uv;
        i.uv1 = v.uv1;
        i.uv2 = v.uv2;
        i.uv3 = v.uv3;
    #endif // defined(_BLENDMODE_CUTOUT) || defined(_BLENDMODE_TRANSPARENT) || defined(_BLENDMODE_PREMULTIPLY) || defined(_BLENDMODE_FADE)
    return i;
}

// shadow fragment function
float4 Fragment(FragmentData i) : SV_TARGET
{
    BacklaceSurfaceData Surface = (BacklaceSurfaceData)0;
    FragData = i;
    #if defined(_BLENDMODE_CUTOUT) || defined(_BLENDMODE_TRANSPARENT) || defined(_BLENDMODE_PREMULTIPLY) || defined(_BLENDMODE_FADE)
        LoadUVs();
        Uvs[0] = ManipulateUVs(FragData.uv, _UV_Rotation, _UV_Scale_X, _UV_Scale_Y, _UV_Offset_X, _UV_Offset_Y, _UV_Scroll_X_Speed, _UV_Scroll_Y_Speed);
        #if defined(_BACKLACE_UV_EFFECTS)
            ApplyUVEffects(Uvs[0], Surface);
        #endif // _BACKLACE_UV_EFFECTS
        SampleAlbedo(Surface);
        #if defined(_BACKLACE_DECAL1)
            ApplyDecal1(Surface, FragData, Uvs);
        #endif // _BACKLACE_DECAL1
        #if defined(_BACKLACE_DECAL2)
            ApplyDecal2(Surface, FragData, Uvs);
        #endif // _BACKLACE_DECAL2
        ClipShadowAlpha(Surface);
    #endif // defined(_BLENDMODE_CUTOUT) || defined(_BLENDMODE_TRANSPARENT) || defined(_BLENDMODE_PREMULTIPLY) || defined(_BLENDMODE_FADE)
    #if defined(_BACKLACE_DISSOLVE)
        float dissolveMapValue = GetDissolveMapValue(i.worldPos, i.vertex.xyz, i.normal);
        clip(_DissolveProgress - dissolveMapValue); // dont need edge glow, just clip
    #endif
    #if defined(SHADOWS_CUBE)
        float depth = length(i.lightVec) + unity_LightShadowBias.x;
        depth *= _LightPositionRange.w;
        return UnityEncodeCubeShadowDepth(depth);
    #else // SHADOWS_CUBE
        return 0;
    #endif // SHADOWS_CUBE
}

#endif // BACKLACE_SHADOW_CGINC