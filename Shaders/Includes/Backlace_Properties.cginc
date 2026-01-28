#ifndef BACKLACE_PROPERTIES_CGINC
#define BACKLACE_PROPERTIES_CGINC


// [ ♡ ] ────────────────────── [ ♡ ]
//
//         Global Variables
//
// [ ♡ ] ────────────────────── [ ♡ ]


FragmentData FragData;
float3 NormalMap;
float GFS;
float3 NDF;
float4 Msso;


// [ ♡ ] ────────────────────── [ ♡ ]
//
//          Main Properties
//
// [ ♡ ] ────────────────────── [ ♡ ]


// core settings
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

// texture stitching feature
int _UseTextureStitching;
UNITY_DECLARE_TEX2D_NOSAMPLER(_StitchTex);
float4 _StitchTex_ST;
int _StitchTex_UV;
int _StitchAxis;
float _StitchOffset;

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

// dither mask
#if defined(_BLENDMODE_FADE) || defined(_BACKLACE_DISTANCE_FADE)
    sampler3D _DitherMaskLOD;
#endif // _BLENDMODE_FADE || _BACKLACE_DISTANCE_FADE


// [ ♡ ] ────────────────────── [ ♡ ]
//
//        Lighting Properties
//
// [ ♡ ] ────────────────────── [ ♡ ]


// lighting modes
int _LightingColorMode;
int _LightingDirectionMode;
int _LightingSource;
float4 _ForcedLightDirection;
float _ViewDirectionOffsetX;
float _ViewDirectionOffsetY;
float _GreyscaleLighting;
float _ForceLightColor;
float4 _ForcedLightColor;

// lighting contributions
float _DirectIntensity;
float _IndirectIntensity;
float _VertexIntensity;
float _AdditiveIntensity;
float _BakedDirectIntensity;
float _BakedIndirectIntensity;

// attenuation properties
int _AttenuationMode;
float _AttenuationManual;
float _AttenuationMin;
float _AttenuationMax;
float _AttenuationMultiplier;
float _AttenuationBoost;

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


// [ ♡ ] ────────────────────── [ ♡ ]
//
//          UV Properties
//
// [ ♡ ] ────────────────────── [ ♡ ]


// uv settings
float _MainTex_UV;
float _MSSO_UV;
float _BumpMap_UV;
float _TangentMap_UV;
float _SpecularTintTexture_UV;

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
    UNITY_DECLARE_TEX2D_NOSAMPLER(_UVFlowmapTex);
    float _UVFlowmapStrength;
    float _UVFlowmapSpeed;
    float _UVFlowmapDistortion;
    float _UVFlowmap_UV;
#endif // _BACKLACE_UV_EFFECTS


// [ ♡ ] ────────────────────── [ ♡ ]
//
//         Vertex Properties
//
// [ ♡ ] ────────────────────── [ ♡ ]


// vertex manipulation
float3 _VertexManipulationPosition;
float3 _VertexManipulationScale;


// [ ♡ ] ────────────────────── [ ♡ ]
//
//          Anime Properties
//
// [ ♡ ] ────────────────────── [ ♡ ]


#if defined(BACKLACE_TOON)
    // manual normals
    int _ToggleManualNormals;
    int _ManualNormalPreview;
    float4 _ManualNormalOffset;
    float4 _ManualNormalScale;
    float4 _ManualApplication;
    float _ManualNormalSharpness;
    // ambient gradient
    float _ToggleAmbientGradient;
    float4 _AmbientUp;
    float4 _AmbientDown;
    float _AmbientIntensity;
    float _AmbientSkyThreshold;
    float _AmbientGroundThreshold;
    //sdf shadow
    float _ToggleSDFShadow;
    UNITY_DECLARE_TEX2D(_SDFShadowTexture);
    float _SDFShadowThreshold;
    float _SDFShadowSoftness;
    float3 _SDFLocalForward;
    float3 _SDFLocalRight;
    // stockings
    int _ToggleStockings;
    UNITY_DECLARE_TEX2D(_StockingsMap);
    float _StockingsPower;
    float _StockingsDarkWidth;
    float _StockingsLightedWidth;
    float _StockingsLightedIntensity;
    float _StockingsRoughness;
    float4 _StockingsColor;
    float4 _StockingsColorDark;
    // eye parallax
    int _ToggleEyeParallax;
    UNITY_DECLARE_TEX2D_NOSAMPLER(_EyeParallaxIrisTex);
    UNITY_DECLARE_TEX2D_NOSAMPLER(_EyeParallaxEyeMaskTex);
    float _EyeParallaxStrength;
    float _EyeParallaxClamp;
    int _ToggleEyeParallaxBreathing;
    float _EyeParallaxBreathStrength;
    float _EyeParallaxBreathSpeed;
    // translucent hair
    int _ToggleHairTransparency;
    float4 _HairHeadForward;
    float4 _HairHeadUp;
    float4 _HairHeadRight;
    float _HairBlendAlpha;
    float _HairTransparencyStrength;
    // expression map
    int _ToggleExpressionMap;
    UNITY_DECLARE_TEX2D_NOSAMPLER(_ExpressionMap);
    float4 _ExCheekColor;
    float _ExCheekIntensity;
    float4 _ExShyColor;
    float _ExShyIntensity;
    float4 _ExShadowColor;
    float _ExShadowIntensity;
    // face map
    int _ToggleFaceMap;
    float4 _FaceHeadForward;
    UNITY_DECLARE_TEX2D_NOSAMPLER(_FaceMap);
    int _ToggleNoseLine;
    float _NoseLinePower;
    float4 _NoseLineColor;
    int _ToggleEyeShadow;
    float4 _ExEyeColor;
    float _EyeShadowIntensity;
    int _ToggleLipOutline;
    float4 _LipOutlineColor;
    float _LipOutlineIntensity;
    #if defined(_ANIMEMODE_RAMP)
        UNITY_DECLARE_TEX2D(_Ramp);
        float _Ramp_UV;
        float4 _RampColor;
        float _RampOffset;
        float _RampShadows;
        float3 _RampMin;
        int _RampNormalIntensity;
        float _RampIndex;
        float _RampTotal;
        float _RampOcclusionOffset;
    #elif defined(_ANIMEMODE_CEL) // _ANIMEMODE_*
        float _CelThreshold;
        float _CelFeather;
        float _CelCastShadowFeather;
        float _CelCastShadowPower;
        float4 _CelShadowTint;
    #elif defined(_ANIMEMODE_NPR) // _ANIMEMODE_*
        // npr
        float _NPRDiffMin;
        float _NPRDiffMax;
        float4 _NPRLitColor;
        float4 _NPRShadowColor;
        // shared specular
        UNITY_DECLARE_TEX2D_NOSAMPLER(_NPRSpecularMask);
        // forward specular
        float _NPRForwardSpecular;
        float _NPRForwardSpecularRange;
        float _NPRForwardSpecularMultiplier;
        float4 _NPRForwardSpecularColor;
        // blinn phong specular
        int _NPRBlinn;
        float _NPRBlinnPower;
        float _NPRBlinnMin;
        float _NPRBlinnMax;
        float4 _NPRBlinnColor;
        float _NPRBlinnMultiplier;
        // fake sss
        int _NPRSSS;
        float _NPRSSSExp;
        float _NPRSSSRef;
        float _NPRSSSMin;
        float _NPRSSSMax;
        float _NPRSSSShadows;
        float4 _NPRSSSColor;
        // rim lighting
        int _NPRRim;
        float _NPRRimExp;
        float _NPRRimMin;
        float _NPRRimMax;
        float4 _NPRRimColor;
    #elif defined(_ANIMEMODE_TRIBAND) // _ANIMEMODE_*
        float _TriBandSmoothness;
        float _TriBandThreshold;
        float _TriBandShallowWidth;
        float4 _TriBandShadowColor;
        float4 _TriBandShallowColor;
        float4 _TriBandLitColor;
        float4 _TriBandPostShadowTint;
        float4 _TriBandPostShallowTint;
        float4 _TriBandPostLitTint;
        float _TriBandAttenuatedShadows;
    #elif defined(_ANIMEMODE_PACKED) // _ANIMEMODE_*
        int _PackedMapStyle;
        UNITY_DECLARE_TEX2D_NOSAMPLER(_PackedMapOne);
        UNITY_DECLARE_TEX2D_NOSAMPLER(_PackedMapTwo);
        UNITY_DECLARE_TEX2D_NOSAMPLER(_PackedMapThree);
        float4 _PackedLitColor;
        float4 _PackedShadowColor;
        float _PackedShadowSmoothness;
        float4 _PackedRimColor;
        float _PackedRimThreshold;
        float _PackedRimPower;
        int _PackedMapMetals;
        float _PackedAmbient;
        int _PackedRimLight;
        // uma musume
        float _PackedUmaSpecularBoost;
        float4 _PackedUmaMetalDark;
        float4 _PackedUmaMetalLight;
        // arc system works (guilty gear strive style)
        float _PackedGGSpecularSize;
        float _PackedGGSpecularIntensity;
        float4 _PackedGGSpecularTint;
        float _PackedGGShadow1Push;
        float _PackedGGShadow1Smoothness;
        float _PackedGGShadow2Push;
        float _PackedGGShadow2Smoothness;
        float4 _PackedGGShadow1Tint;
        float4 _PackedGGShadow2Tint;
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


// [ ♡ ] ────────────────────── [ ♡ ]
//
//         Specular Properties
//
// [ ♡ ] ────────────────────── [ ♡ ]


#if defined(BACKLACE_SPECULAR)
    // used in specular calculations
    float _Occlusion;
    float _Metallic;
    float _Glossiness;
    float _Specular;
    float _SpecularIntensity;
    float _ReplaceSpecular;
    float _Anisotropy;
    UNITY_DECLARE_TEX2D_NOSAMPLER(_MSSO);
    float4 _MSSO_ST;
    samplerCUBE _FallbackCubemap;
    UNITY_DECLARE_TEX2D_NOSAMPLER(_SpecularTintTexture);
    UNITY_DECLARE_TEX2D_NOSAMPLER(_TangentMap);
    float4 _SpecularTintTexture_ST;
    float4 _SpecularTint;
    float4 _TangentMap_ST;
    int _SpecularEnergyMode;
    float _SpecularEnergy;
    float _SpecularEnergyMin;
    float _SpecularEnergyMax;
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


// [ ♡ ] ────────────────────── [ ♡ ]
//
//         Misc Properties
//
// [ ♡ ] ────────────────────── [ ♡ ]


// sticker properties
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

// shadow map properties
#if defined(_BACKLACE_SHADOW_MAP)
    UNITY_DECLARE_TEX2D_NOSAMPLER(_ShadowMap);
    float _ShadowMap_UV;
    float _ShadowMapIntensity;
#endif // _BACKLACE_SHADOW_MAP


#endif // BACKLACE_PROPERTIES_CGINC

