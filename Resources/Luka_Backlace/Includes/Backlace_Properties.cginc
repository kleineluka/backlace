#ifndef BACKLACE_PROPERTIES_CGINC
#define BACKLACE_PROPERTIES_CGINC

// global variables
FragmentData FragData;
float3 NormalMap;
float3 Lightmap;
float GFS;
float3 NDF;
float3 DynamicLightmap;
float4 LightmapDirection;
float4 DynamicLightmapDirection;
float4 Msso;
float RoughnessSquared;
float RampAttenuation;
float LightAttenuation;

// main settings
float _Alpha;
UNITY_DECLARE_TEX2D(_MainTex);
float4 _MainTex_ST;
UNITY_DECLARE_TEX2D_NOSAMPLER(_BumpMap);
float4 _BumpMap_ST;
float4 _Color;
float _Cutoff;
float _BumpScale;
int _IndirectFallbackMode;
int _IndirectOverride;
int _FlipBackfaceNormals;
int _DecalStage;

// specular settings
float _Occlusion;
float _Metallic;
float _Glossiness;
float _Specular;
float _SpecularIntensity;
float _ReplaceSpecular;
float _Anisotropy;
float _EnableSpecular;
samplerCUBE _FallbackCubemap;
UNITY_DECLARE_TEX2D_NOSAMPLER(_MSSO);
UNITY_DECLARE_TEX2D_NOSAMPLER(_SpecularTintTexture);
UNITY_DECLARE_TEX2D_NOSAMPLER(_TangentMap);
float4 _MSSO_ST;
float4 _SpecularTintTexture_ST;
float4 _SpecularTint;
float4 _TangentMap_ST;

// lighting settings
float _LightingColorMode;
float _LightingDirectionMode;
float4 _ForcedLightDirection;
float _ViewDirectionOffsetX;
float _ViewDirectionOffsetY;
float _GreyscaleLighting;
float _ForceLightColor;
float4 _ForcedLightColor;

// uv settings
float _MainTex_UV;
float _MSSO_UV;
float _BumpMap_UV;
float _TangentMap_UV;
float _SpecularTintTexture_UV;

// lighting contributions
float _DirectIntensity;
float _IndirectIntensity;
float _VertexIntensity;
float _AdditiveIntensity;
float _BakedDirectIntensity;
float _BakedIndirectIntensity;

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

// dither feature
#if defined(_BLENDMODE_FADE) || defined(_BACKLACE_DISTANCE_FADE)
    sampler3D _DitherMaskLOD;
#endif // _BLENDMODE_FADE || _BACKLACE_DISTANCE_FADE

// min/max light (base)
#if defined(UNITY_PASS_FORWARDBASE)
    float _EnableBaseLightLimit;
    float _BaseLightMin;
    float _BaseLightMax;
#endif // UNITY_PASS_FORWARDBASE

// min/max light (add)
#if defined(UNITY_PASS_FORWARDADD)
    float _EnableAddLightLimit;
    float _AddLightMin;
    float _AddLightMax;
#endif // UNITY_PASS_FORWARDADD

// toon feature
#if defined(_BACKLACE_TOON)
    float _TintMaskSource;
    float4 _LitTint;
    float4 _ShadowTint;
    float _ShadowThreshold;
    float _LitThreshold;
    float _ToggleAmbientGradient;
    float4 _AmbientUp;
    float4 _AmbientDown;
    float _AmbientIntensity;
    float _AmbientSkyThreshold;
    float _AmbientGroundThreshold;
    float _ToggleSDFShadow;
    UNITY_DECLARE_TEX2D(_SDFShadowTexture);
    float _SDFShadowThreshold;
    float _SDFShadowSoftness;
    #if defined(_ANIMEMODE_RAMP)
        UNITY_DECLARE_TEX2D(_Ramp);
        float _Ramp_UV;
        float4 _RampColor;
        float _RampOffset;
        float _ShadowIntensity;
        float _OcclusionOffsetIntensity;
        float3 _RampMin;
        int _RampNormalIntensity;
    #elif defined(_ANIMEMODE_PROCEDURAL)
        float4 _AnimeShadowColor;
        float _AnimeShadowThreshold;
        float4 _AnimeHalftoneColor;
        float _AnimeHalftoneThreshold;
        float _AnimeShadowSoftness;
        float _AnimeOcclusionToShadow;
    #endif // _ANIMEMODE_RAMP || _ANIMEMODE_PROCEDURAL
#endif // _BACKLACE_TOON

// emission feature
#if defined(_BACKLACE_EMISSION)
    float3 Emission;
    float4 _EmissionColor;
    float4 _EmissionMap_ST;
    float _UseAlbedoAsEmission;
    float _EmissionStrength;
    float _EmissionMap_UV;
    UNITY_DECLARE_TEX2D_NOSAMPLER(_EmissionMap);
#endif // _BACKLACE_EMISSION

// specular feature
#if defined(_BACKLACE_SPECULAR)
    // specific specular modes
    #if defined(_SPECULARMODE_TOON) // TOON SPECULAR
        UNITY_DECLARE_TEX2D(_HighlightRamp);
        float4 _HighlightRampColor;
        float _HighlightIntensity;
        float _HighlightRampOffset;
        float _HighlightHardness;
    #elif defined(_SPECULARMODE_HAIR) // HAIR SPECULAR
        UNITY_DECLARE_TEX2D(_HairFlowMap);
        float _HairFlowMap_UV;
        float _PrimarySpecularShift;
        float _SecondarySpecularShift;
        float4 _SecondarySpecularColor;
        float _SpecularExponent;
    #elif defined(_SPECULARMODE_CLOTH) // CLOTH SPECULAR
        float4 _SheenColor;
        float _SheenIntensity;
        float _SheenRoughness;
    #endif // _SPECULARMODE_TOON || _SPECULARMODE_HAIR || _SPECULARMODE_CLOTH
    // vertex specular feature
    #if defined(_BACKLACE_VERTEX_SPECULAR) // VERTEX SPECULAR
        float3 VertexLightDir;
    #endif // _BACKLACE_VERTEX_SPECULAR
#endif // _BACKLACE_SPECULAR

// decal1 feature
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

// decal2 feature
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

// shadow map feature
#if defined(_BACKLACE_SHADOW_MAP)
    UNITY_DECLARE_TEX2D(_ShadowMap);
    float _ShadowMap_UV;
    float _ShadowMapIntensity;
#endif // _BACKLACE_SHADOW_MAP

// texture stitching feature
#if defined(_BACKLACE_STITCH)
    UNITY_DECLARE_TEX2D(_StitchTex);
    float4 _StitchTex_ST;
    int _StitchTex_UV;
    int _StitchAxis;
    float _StitchOffset;
#endif // _BACKLACE_STITCH

#endif // BACKLACE_PROPERTIES_CGINC

