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
float4 _MainTex_TexelSize;
UNITY_DECLARE_TEX2D_NOSAMPLER(_BumpMap);
float4 _BumpMap_ST;
float4 _Color;
float _Cutoff;
float _BumpScale;
int _UseBump;
int _BumpFromAlbedo;
float _BumpFromAlbedoOffset;
int _IndirectFallbackMode;
int _IndirectOverride;
int _FlipBackfaceNormals;

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
int _SpecularStandardKind;
int _SpecularSpecialKind;
int _SpecularEnergyMode;
float _SpecularEnergy;
float _SpecularEnergyMin;
float _SpecularEnergyMax;

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

// anime feature
#if defined(BACKLACE_TOON)
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
    float _OcclusionOffsetIntensity;
    #if defined(_ANIMEMODE_RAMP)
        UNITY_DECLARE_TEX2D(_Ramp);
        float _Ramp_UV;
        float4 _RampColor;
        float _RampOffset;
        float _ShadowIntensity;
        float3 _RampMin;
        int _RampNormalIntensity;
        float _RampIndex;
        float _RampTotal;
    #elif defined(_ANIMEMODE_HALFTONE) // _ANIMEMODE_*
        float4 _AnimeShadowColor;
        float _AnimeShadowThreshold;
        float4 _AnimeHalftoneColor;
        float _AnimeHalftoneThreshold;
        float _AnimeShadowSoftness;
        float _AnimeOcclusionToShadow;
    #elif defined(_ANIMEMODE_HIFI) // _ANIMEMODE_*
        float _Hifi1Threshold;
        float _Hifi1Feather;
        float4 _Hifi1Color;
        float _Hifi2Threshold;
        float _Hifi2Feather;
        float4 _Hifi2Color;
        float4 _HifiBorderColor;
        float _HifiBorderWidth;
    #elif defined(_ANIMEMODE_SKIN) // _ANIMEMODE_*
        UNITY_DECLARE_TEX2D(_SkinLUT);
        float4 _SkinShadowColor;
        float _SkinScattering;
    #elif defined(_ANIMEMODE_WRAPPED) // _ANIMEMODE_*
        float _WrapFactor;
        float _WrapNormalization;
        float4 _WrapColorHigh;
        float4 _WrapColorLow;
    #endif // _ANIMEMODE_*
#endif // BACKLACE_TOON

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
#if defined(BACKLACE_SPECULAR)
    // specific specular modes
    #if defined(_SPECULARMODE_TOON) // _SPECULARMODE_*
        UNITY_DECLARE_TEX2D(_HighlightRamp);
        float4 _HighlightRampColor;
        float _HighlightIntensity;
        float _HighlightRampOffset;
        float _HighlightHardness;
    #elif defined(_SPECULARMODE_HAIR) // _SPECULARMODE_*
        // hair
        UNITY_DECLARE_TEX2D(_HairFlowMap);
        float _HairFlowMap_UV;
        float _PrimarySpecularShift;
        float _SecondarySpecularShift;
        float4 _SecondarySpecularColor;
        float _SpecularExponent;
        float _SpecularJitter;
    #elif defined(_SPECULARMODE_CLOTH) // _SPECULARMODE_*
        // cloth
        float4 _SheenColor;
        float _SheenIntensity;
        float _SheenRoughness;
    #endif // _SPECULARMODE_*
    // vertex specular feature
    #if defined(_BACKLACE_VERTEX_SPECULAR) // VERTEX SPECULAR
        float3 VertexLightDir;
    #endif // _BACKLACE_VERTEX_SPECULAR
#endif // BACKLACE_SPECULAR

// decal1 feature
#if defined(_BACKLACE_DECALS)
    // shared
    int _DecalStage;
    // decal1
    int _Decal1Enable;
    UNITY_DECLARE_TEX2D(_Decal1Tex);
    float4 _Decal1Tint;
    float2 _Decal1Position;
    float2 _Decal1Scale;
    float _Decal1Rotation;
    float _Decal1_UV;
    float _Decal1TriplanarSharpness;
    int _Decal1BlendMode;
    int _Decal1Space;
    float _Decal1Behavior;
    float3 _Decal1TriplanarPosition;
    float _Decal1TriplanarScale;
    float3 _Decal1TriplanarRotation;
    float _Decal1Repeat;
    float2 _Decal1Scroll;
    float _Decal1HueShift;
    float _Decal1AutoCycleHue;
    float _Decal1CycleSpeed;
    // decal 2
    int _Decal2Enable;
    UNITY_DECLARE_TEX2D_NOSAMPLER(_Decal2Tex); // share sampler with decal1
    float4 _Decal2Tint;
    float2 _Decal2Position;
    float2 _Decal2Scale;
    float _Decal2Rotation;
    float _Decal2_UV;
    float _Decal2TriplanarSharpness;
    int _Decal2BlendMode;
    int _Decal2Space;
    float _Decal2Behavior;
    float3 _Decal2TriplanarPosition;
    float _Decal2TriplanarScale;
    float3 _Decal2TriplanarRotation;
    float _Decal2Repeat;
    float2 _Decal2Scroll;
    float _Decal2HueShift;
    float _Decal2AutoCycleHue;
    float _Decal2CycleSpeed;
#endif // _BACKLACE_DECALS

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
    UNITY_DECLARE_TEX2D_NOSAMPLER(_UVFlowmapTex);
    float _UVFlowmapStrength;
    float _UVFlowmapSpeed;
    float _UVFlowmapDistortion;
    float _UVFlowmap_UV;
#endif // _BACKLACE_UV_EFFECTS

// shadow map feature
#if defined(_BACKLACE_SHADOW_MAP)
    UNITY_DECLARE_TEX2D_NOSAMPLER(_ShadowMap);
    float _ShadowMap_UV;
    float _ShadowMapIntensity;
#endif // _BACKLACE_SHADOW_MAP

// texture stitching feature
int _UseTextureStitching;
UNITY_DECLARE_TEX2D_NOSAMPLER(_StitchTex);
float4 _StitchTex_ST;
int _StitchTex_UV;
int _StitchAxis;
float _StitchOffset;

#endif // BACKLACE_PROPERTIES_CGINC

