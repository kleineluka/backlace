#ifndef BACKLACE_PROPERTIES_CGINC
#define BACKLACE_PROPERTIES_CGINC

FragmentData FragData;
float _LightingColorMode;
float _LightingDirectionMode;
float4 _ForcedLightDirection;
float _ViewDirectionOffsetX;
float _ViewDirectionOffsetY;
float LightAttenuation;
float _MainTex_UV;
float _Occlusion;
float _MSSO_UV;
float _Cutoff;
float _BumpScale;
float _BumpMap_UV;
float RampAttenuation;
float _Metallic;
float _Glossiness;
float _Specular;
float _ReplaceSpecular;
float _SpecularTintTexture_UV;
float GFS;
float _DFGType;
float _Anisotropy;
float _TangentMap_UV;
float _IndirectFallbackMode;
float _IndirectOverride;
float RoughnessSquared;
float _EnableSpecular;
float _GreyscaleLighting;
float _ForceLightColor;
float4 _ForcedLightColor;
float3 NormalMap;
float3 Lightmap;
float3 DynamicLightmap;
float3 NDF;
float4 LightmapDirection;
float4 DynamicLightmapDirection;
float4 _MainTex_ST;
float4 _Color;
float4 _MSSO_ST;
float4 Msso;
float4 _BumpMap_ST;
float4 _SpecularTintTexture_ST;
float4 _SpecularTint;
float4 _TangentMap_ST;
samplerCUBE _FallbackCubemap;
UNITY_DECLARE_TEX2D(_MainTex);
UNITY_DECLARE_TEX2D_NOSAMPLER(_MSSO);
UNITY_DECLARE_TEX2D_NOSAMPLER(_BumpMap);
UNITY_DECLARE_TEX2D_NOSAMPLER(_SpecularTintTexture);
UNITY_DECLARE_TEX2D_NOSAMPLER(_TangentMap);
Texture2D_float _DFG;
SamplerState sampler_DFG;

// uv manipulation
float _UV_Offset_X;
float _UV_Offset_Y;
float _UV_Scale_X;
float _UV_Scale_Y;
float _UV_Rotation;
float _UV_Scroll_X_Speed;
float _UV_Scroll_Y_Speed;

// dither feature
#if defined(_ALPHAMODULATE_ON) || defined(_BACKLACE_DISTANCE_FADE)
    sampler3D _DitherMaskLOD;
#endif // _ALPHAMODULATE_ON || _BACKLACE_DISTANCE_FADE

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
    #if defined(_TOONMODE_RAMP)
        UNITY_DECLARE_TEX2D(_Ramp);
        float _Ramp_UV;
        float4 _RampColor;
        float _RampOffset;
        float _ShadowIntensity;
        float _OcclusionOffsetIntensity;
        float3 _RampMin;
    #elif defined(_TOONMODE_ANIME)
        float4 _AnimeShadowColor;
        float _AnimeShadowThreshold;
        float4 _AnimeHalftoneColor;
        float _AnimeHalftoneThreshold;
        float _AnimeShadowSoftness;
        float _AnimeOcclusionToShadow;
    #endif // _TOONMODE_RAMP || _TOONMODE_ANIME
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

// rim feature
#if defined(_BACKLACE_RIMLIGHT)
    float3 Rimlight;
    float4 _RimColor;
    float _RimWidth;
    float _RimIntensity;
    float _RimLightBased;
#endif // _BACKLACE_RIMLIGHT

// clear coat feature
#if defined(_BACKLACE_CLEARCOAT)
    UNITY_DECLARE_TEX2D(_ClearcoatMap);
    float4 _ClearcoatMap_ST;
    float _ClearcoatStrength;
    float _ClearcoatRoughness;
    float _ClearcoatReflectionStrength;
    float _ClearcoatMap_UV;
    float4 _ClearcoatColor;
#endif // _BACKLACE_CLEARCOAT

// specular feature
#if defined(_BACKLACE_SPECULAR)
    // specific specular modes
    #if defined(_SPECULARMODE_TOON) // TOON SPECULAR
        UNITY_DECLARE_TEX2D(_HighlightRamp);
        float4 _HighlightRampColor;
        float _HighlightIntensity;
        float _HighlightRampOffset;
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

// matcap feature
#if defined(_BACKLACE_MATCAP)
    UNITY_DECLARE_TEX2D(_MatcapTex);
    UNITY_DECLARE_TEX2D(_MatcapMask);
    float4 _MatcapTex_ST;
    float _MatcapIntensity;
    float3 _MatcapTint;
    float _MatcapSmoothnessEnabled;
    float _MatcapSmoothness;
    float _MatcapMask_UV;
    int _MatcapBlendMode;
#endif // _BACKLACE_MATCAP

// cubemap feature
#if defined(_BACKLACE_CUBEMAP)
    samplerCUBE _CubemapTex;
    float4 _CubemapTint;
    float _CubemapIntensity;
    int _CubemapBlendMode;
#endif // _BACKLACE_CUBEMAP

// parallax feature
#if defined(_BACKLACE_PARALLAX)
    UNITY_DECLARE_TEX2D(_ParallaxMap);
    float _ParallaxMap_UV;
    float _ParallaxStrength;
    float _ParallaxMode;
    float _ParallaxSteps;
    #if defined(_BACKLACE_PARALLAX_SHADOWS)
        float ParallaxShadow;
        float _ParallaxShadowSteps;
        float _ParallaxShadowStrength;
    #endif // _BACKLACE_PARALLAX_SHADOWS
#endif // _BACKLACE_PARALLAX

// subsurface scattering feature
#if defined(_BACKLACE_SSS)
    UNITY_DECLARE_TEX2D(_ThicknessMap);
    float _ThicknessMap_UV;
    float4 _SSSColor;
    float _SSSStrength;
    float _SSSDistortion;
    float _SSSSpread;
    float _SSSBaseColorMix;
#endif // _BACKLACE_SSS

// detail feature
#if defined(_BACKLACE_DETAIL)
    UNITY_DECLARE_TEX2D(_DetailAlbedoMap);
    UNITY_DECLARE_TEX2D(_DetailNormalMap);
    float _DetailMap_UV;
    float _DetailTiling;
    float _DetailNormalStrength;
#endif // _BACKLACE_DETAIL

// decal1 feature
#if defined(_BACKLACE_DECAL1) || defined(_BACKLACE_DECAL2)
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
#endif // _BACKLACE_DECAL2

// post-processing feature
#if defined(_BACKLACE_POST_PROCESSING)
    UNITY_DECLARE_TEX2D(_ColorGradingLUT);
    float4 _RGBColor;
    float _RGBBlendMode;
    float _HSVMode;
    float _HSVHue;
    float _HSVSaturation;
    float _HSVValue;
    float _ToggleHueShift;
    float _HueShift;
    float _ToggleAutoCycle;
    float _AutoCycleSpeed;
    float _ColorGradingIntensity;   
    float _BlackAndWhite;
    float _Brightness;
#endif // _BACKLACE_POST_PROCESSING

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

// dissolve feature
#if defined(_BACKLACE_DISSOLVE)
    float _DissolveProgress;
    UNITY_DECLARE_TEX2D(_DissolveNoiseTex);
    float _DissolveNoiseScale;
    float4 _DissolveEdgeColor;
    int _DissolveType;
    float _DissolveEdgeWidth;
    float4 _DissolveDirection;
    int _DissolveDirectionSpace;
    float _DissolveDirectionBounds;
    float _DissolveVoxelDensity;
    float _DissolveEdgeSharpness;
    float _DissolveEdgeMode;
#endif // _BACKLACE_DISSOLVE

#endif // BACKLACE_PROPERTIES_CGINC

