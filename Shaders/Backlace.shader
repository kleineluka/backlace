Shader "luka/indev/backlace"
{

    Properties
    {
        // RENDERING SETTINGS
        // [Space(35)]
        // [Header(Rendering Settings)]
        // [Space(10)]
        //[Enum(Opaque, 0, Cutout, 1, Fade, 2, Transparent, 3, TransClipping, 4, Additive, 6, Multiplicative, 7)] _BlendMode ("Rendering Mode", Float) = 0 // removed 5=soft additive, 8=2x multiplicative
        [Enum(Opaque, 0, Cutout, 1, Fade, 2, OpaqueFade, 3, Transparent, 4, Premultiply, 5, Additive, 6, Soft Additive, 7, Multiplicative, 8, 2Multiplicative, 9)] _BlendMode ("Rendering Mode", Float) = 0
        // base blend
        [Toggle] _OverrideBaseBlend ("Override Base Blend", Float) = 0
        [Enum(UnityEngine.Rendering.BlendMode)] _SrcBlend ("Src Blend", Float) = 1
        [Enum(UnityEngine.Rendering.BlendMode)] _DstBlend ("Dst Blend", Float) = 0
        [Enum(UnityEngine.Rendering.BlendOp)] _BlendOp ("Blend Operation", Float) = 0
        // additive blend
        [Toggle] _OverrideAddBlend ("Override Additive Blend", Float) = 0
        [Enum(UnityEngine.Rendering.BlendMode)] _AddSrcBlend ("Additive Src Blend", Float) = 1
        [Enum(UnityEngine.Rendering.BlendMode)] _AddDstBlend ("Additive Dst Blend", Float) = 1
        [Enum(UnityEngine.Rendering.BlendOp)] _AddBlendOp ("Additive Blend Operation", Float) = 0
        // zwrite
        [Toggle] _OverrideZWrite ("Override ZWrite", Float) = 0
        [Enum(Off, 0, On, 1)] _ZWrite ("ZWrite", Float) = 1
        // render queue
        [Toggle] _OverrideRenderQueue ("Override Render Queue", Float) = 0
        // culling
        [Enum(UnityEngine.Rendering.CullMode)] _Cull ("Cull Mode", Int) = 2
        // ztest 
        [Enum(UnityEngine.Rendering.CompareFunction)] _ZTest ("ZTest", Int) = 3
        // stencil
        [IntRange] _StencilRef ("Stencil Reference", Range(0, 255)) = 0
        [Enum(UnityEngine.Rendering.CompareFunction)] _StencilComp ("Stencil Comparison", Int) = 8 // Always
        [Enum(UnityEngine.Rendering.StencilOp)] _StencilPass ("Stencil Pass Op", Int) = 0 // Keep
        [Enum(UnityEngine.Rendering.StencilOp)] _StencilFail ("Stencil Fail Op", Int) = 0 // Keep
        [Enum(UnityEngine.Rendering.StencilOp)] _StencilZFail ("Stencil ZFail Op", Int) = 0 // Keep
        // outline stencil
        [IntRange] _OutlineStencilRef ("Outline Stencil Reference", Range(0, 255)) = 0
        [Enum(UnityEngine.Rendering.CompareFunction)] _OutlineStencilComp ("Outline Stencil Comparison", Int) = 8 // Always
        [Enum(UnityEngine.Rendering.StencilOp)] _OutlineStencilPass ("Outline Stencil Pass Op", Int) = 0 // Keep
        [Enum(UnityEngine.Rendering.StencilOp)] _OutlineStencilFail ("Outline Stencil Fail Op", Int) = 0 // Keep
        [Enum(UnityEngine.Rendering.StencilOp)] _OutlineStencilZFail ("Outline Stencil ZFail Op", Int) = 0 // Keep
        // vrchat fallback
        [Enum(Toon, 0, Double Sided, 1, Unlit, 2, Particle, 3, Matcap, 4, Sprite, 5, Hidden, 6)] _VRCFallback ("VRChat Fallback", Int) = 0
        // flip backface normals
        [Enum(Disabled, 0, Enabled, 1)] _ToggleFlipNormals ("Flip Backface Normals", Int) = 0

        // MAIN MAPS AND ALPHA
        // [Space(35)]
        // [Header(Main Maps and Alpha)]
        // [Space(10)]
        _MainTex ("Main texture", 2D) = "white" { }
        _Color ("Albedo color", Color) = (1, 1, 1, 1)
        _Cutoff ("Alpha Cutoff", Range(0, 1)) = 0.5
        _BumpMap ("Normal map", 2D) = "bump" { }
        _BumpScale ("Normal map scale", Float) = 1
        _Alpha ("Alpha", Range(0, 1)) = 1.0
        [Enum(Early, 0, Late, 1)] _DecalStage ("Decal Stage", Int) = 1

        // UV MANIPULATION
        // [Space(35)]
        // [Header(UV Manipulation)]
        // [Space(10)]
        _UV_Offset_X ("UV Offset X", Float) = 0
        _UV_Offset_Y ("UV Offset Y", Float) = 0
        _UV_Scale_X ("UV Scale X", Float) = 1
        _UV_Scale_Y ("UV Scale Y", Float) = 1
        _UV_Rotation ("UV Rotation", Range(0, 360)) = 0
        _UV_Scroll_X_Speed ("UV Scroll X Speed", Float) = 0
        _UV_Scroll_Y_Speed ("UV Scroll Y Speed", Float) = 0

        // UV EFFECTS
        // [Space(35)]
        // [Header(UV Effects)]
        // [Space(10)]
        [Toggle(_BACKLACE_UV_EFFECTS)] _ToggleUVEffects ("Enable UV Effects", Float) = 0.0
        // triplanar
        [Enum(Disabled, 0, Enabled, 1)] _UVTriplanarMapping ("Enable Triplanar Mapping", Float) = 0.0
        _UVTriplanarPosition ("World Position (XYZ)", Vector) = (0, 0, 0, 0)
        _UVTriplanarScale ("World Scale", Float) = 1.0
        _UVTriplanarRotation ("World Rotation (XYZ)", Vector) = (0, 0, 0, 0)
        _UVTriplanarSharpness ("Triplanar Blend Sharpness", Range(1, 10)) = 2.0
        // screenspace
        [Enum(Disabled, 0, Enabled, 1)] _UVScreenspaceMapping ("Enable Screenspace Mapping", Float) = 0.0
        _UVScreenspaceTiling ("Screenspace Tiling", Float) = 1.0
        // flipbook
        [Enum(Disabled, 0, Enabled, 1)] _UVFlipbook ("Enable Flipbook Animation", Float) = 0.0
        _UVFlipbookRows ("Flipbook Rows", Int) = 1
        _UVFlipbookColumns ("Flipbook Columns", Int) = 1
        _UVFlipbookFrames ("Total Frames", Int) = 1
        _UVFlipbookFPS ("Flipbook FPS", Float) = 30.0
        _UVFlipbookScrub ("Manual Scrub", Float) = 0.0
        // flowmap
        [Enum(Disabled, 0, Enabled, 1)] _UVFlowmap ("Enable Flowmap", Float) = 0.0
        _UVFlowmapTex ("Flowmap Texture (RG)", 2D) = "gray" { }
        _UVFlowmapStrength ("Flowmap Strength", Range(0, 1)) = 0.5
        _UVFlowmapSpeed ("Flowmap Speed", Float) = 1.0
        _UVFlowmapDistortion ("Flowmap Distortion", Range(0, 1)) = 0.5

        // VERTEX MANIPULATION
        // [Space(35)]
        // [Header(Vertex Manipulation)]
        // [Space(10)]
        _VertexManipulationPosition ("World Position (XYZ)", Vector) = (0, 0, 0, 0)
        _VertexManipulationScale ("World Scale (XYZ)", Vector) = (1, 1, 1, 0)

        // EMISSION
        // [Space(35)]
        // [Header(Emission)]
        // [Space(10)]
        [Toggle(_BACKLACE_EMISSION)] _ToggleEmission ("Enable Emission", Float) = 0.0
        [HDR] _EmissionColor ("Emission Color", Color) = (0, 0, 0, 1)
        _EmissionMap ("Emission Map (Mask)", 2D) = "black" { }
        [IntRange] _UseAlbedoAsEmission ("Use Albedo for Emission", Range(0, 1)) = 0.0
        _EmissionStrength ("Emission Strength", Float) = 1.0

        // LIGHT LIMITING
        // [Space(35)]
        // [Header(Light Limiting)]
        // [Space(10)]
        [Enum(Disabled, 0, Enabled, 1)] _EnableBaseLightLimit ("Enable Base Pass Limit", Range(0, 1)) = 0.0
        _BaseLightMin ("Base Light Min", Float) = 0.0
        _BaseLightMax ("Base Light Max", Float) = 2.0
        [Enum(Disabled, 0, Enabled, 1)] _EnableAddLightLimit ("Enable Add Pass Limit", Range(0, 1)) = 0.0
        _AddLightMin ("Add Light Min", Float) = 0.0
        _AddLightMax ("Add Light Max", Float) = 2.0
        _GreyscaleLighting ("Greyscale Lighting", Range(0, 1)) = 0.0
        _ForceLightColor ("Force Light Color", Range(0, 1)) = 0.0
        _ForcedLightColor ("Forced Light Color", Color) = (1, 1, 1, 1)

        // LIGHTING MODELS
        // [Space(35)]
        // [Header(Lighting Model)]
        // [Space(10)]
        [Enum(Backlace, 0, PoiCustom, 1, OpenLit, 2, Standard, 3, Mochie, 4)] _LightingColorMode ("Light Color Mode", Int) = 0
        [Enum(Backlace, 0, Forced World Direction, 1, View Direction, 2)] _LightingDirectionMode ("Light Direction Mode", Int) = 0
        _ForcedLightDirection ("Forced Light Direction", Vector) = (0.0, 1.0, 0.0, 0.0)
        _ViewDirectionOffsetX ("View Direction Offset X", Float) = 0.0
        _ViewDirectionOffsetY ("View Direction Offset Y", Float) = 0.0
        _DirectIntensity ("RT Direct Intensity", Float) = 1.0
        _IndirectIntensity ("RT Indirect Intensity", Float) = 1.0
        _VertexIntensity ("RT Vertex Intensity", Float) = 1.0
        _AdditiveIntensity ("RT Additive Intensity", Float) = 1.0
        _BakedDirectIntensity ("Baked Direct Intensity", Float) = 1.0
        _BakedIndirectIntensity ("Baked Indirect Intensity", Float) = 1.0

        // TOON LIGHTING
        // [Space(35)]
        // [Header(Toon Lighting)]
        // [Space(10)]
        [Toggle(_BACKLACE_TOON)] _ToggleAnimeLighting ("Enable Anime Lighting", Float) = 0.0
        [KeywordEnum(Ramp, Procedural)] _AnimeMode ("Anime Mode", Int) = 0
        // ramp
        _Ramp ("Toon Ramp", 2D) = "white" { }
        _RampColor ("Ramp Color", Color) = (1, 1, 1, 1)
        _RampOffset ("Ramp Offset", Range(-1, 1)) = 0
        _ShadowIntensity ("Shadow intensity", Range(0, 1)) = 0.6
        _OcclusionOffsetIntensity ("Occlusion Offset Intensity", Range(0, 1)) = 0
        _RampMin ("Ramp Min", Color) = (0.003921569, 0.003921569, 0.003921569, 0.003921569)
        // anime
        [HDR] _AnimeShadowColor ("Core Shadow Color", Color) = (0.5, 0.5, 1, 1) // <-- RENAME THIS
        _AnimeShadowThreshold ("Core Shadow Threshold", Range(0, 1)) = 0.3 // <-- RENAME and adjust default
        [HDR] _AnimeHalftoneColor ("Halftone Color", Color) = (0.8, 0.8, 1, 1) // <-- ADD THIS
        _AnimeHalftoneThreshold ("Halftone Threshold", Range(0, 1)) = 0.6 // <-- ADD THIS
        _AnimeShadowSoftness ("Shadow Softness", Range(0.001, 1)) = 0.02
        // ambient gradient
        [Enum(Disabled, 0, Enabled, 1)] _ToggleAmbientGradient ("Enable Ambient Gradient", Float) = 0.0
        _AnimeOcclusionToShadow ("Occlusion To Shadow", Range(0, 1)) = 0.5
        _AmbientUp ("Sky Ambient", Color) = (0.8, 0.8, 1, 1)
        _AmbientSkyThreshold ("Sky Threshold", Range(0, 1)) = 0.5
        _AmbientDown ("Ground Ambient", Color) = (1, 0.9, 0.8, 1)
        _AmbientGroundThreshold ("Ground Threshold", Range(0, 1)) = 0.5 
        _AmbientIntensity ("Gradient Intensity", Range(0, 1)) = 0.25
        // tinting
        [Enum(Disabled, 0, Raw Light, 1, Tuned Light, 2, Ramp Based, 3)] _TintMaskSource ("Tint Mask Source", Int) = 0
        [HDR] _LitTint ("Lit Area Tint", Color) = (1, 1, 1, 0.75)
        _LitThreshold ("Lit Coverage", Range(0, 1)) = 0.6
        [HDR] _ShadowTint ("Shadow Area Tint", Color) = (1, 1, 1, 0.75)
        _ShadowThreshold ("Shadow Coverage", Range(0, 1)) = 0.4

        // SPECULAR
        // [Space(35)]
        // [Header(Specular)]
        // [Space(10)]
        [Toggle(_BACKLACE_SPECULAR)] _ToggleSpecular ("Enable Specular", Float) = 0.0
        [Toggle(_BACKLACE_VERTEX_SPECULAR)] _ToggleVertexSpecular ("Enable Vertex Specular", Float) = 0.0
        [KeywordEnum(Standard, Anisotropic, Toon, Hair, Cloth)] _SpecularMode ("Specular Mode", Float) = 0
        _MSSO ("MSSO", 2D) = "white" { }
        _Metallic ("Metallic", Range(0, 1)) = 0
        _Glossiness ("Glossiness", Range(0, 1)) = 0
        _Occlusion ("Occlusion", Range(0, 1)) = 1
        [PowerSlider(2.0)] _SpecularIntensity ("Specular Intensity", Range(0.01, 25)) = 1.0
        _Specular ("Specular", Range(0, 1)) = 0.5
        _SpecularTintTexture ("Specular Tint Texture", 2D) = "white" { }
        _SpecularTint ("Specular Tint", Color) = (1, 1, 1, 1)
        _TangentMap ("Tangent Map", 2D) = "white" { }
        _Anisotropy ("Ansotropy", Range(-1, 1)) = 0
        [Enum(Disabled, 0, Enabled, 1)] _ReplaceSpecular ("Replace Specular", Range(0, 1)) = 0
        // toon highlights
        _HighlightRamp ("Highlight Ramp", 2D) = "white" { }
        _HighlightRampColor ("Highlight Color", Color) = (1, 1, 1, 1)
        _HighlightIntensity ("Highlight Intensity", Float) = 1.0
        _HighlightRampOffset ("Highlight Ramp Offset", Range(-1, 1)) = 0.0
        _HighlightHardness ("Highlight Hardness", Range(0.01, 10)) = 0.1
        // hair specular
        [NoScaleOffset] _HairFlowMap ("Hair Flow/Tangent Map (RG)", 2D) = "gray" { }
        _PrimarySpecularShift ("Primary Specular Shift", Range(-1, 1)) = 0
        _SecondarySpecularShift ("Secondary Specular Shift", Range(-1, 1)) = 0.1
        [HDR] _SecondarySpecularColor ("Secondary Specular Color", Color) = (1, 1, 1, 1)
        _SpecularExponent ("Specular Exponent", Range(1, 256)) = 64
        // cloth specular
        _SheenColor ("Sheen Color", Color) = (1, 1, 1, 1)
        _SheenIntensity ("Sheen Intensity", Float) = 0.5
        _SheenRoughness ("Sheen Roughness", Float) = 0.5

        // RIM LIGHTING
        // [Space(35)]
        // [Header(Rim Lighting)]
        // [Space(10)]
        [Toggle(_BACKLACE_RIMLIGHT)] _ToggleRimlight ("Enable Rim Lighting", Float) = 0.0
        [HDR] _RimColor ("Rim Color", Color) = (1, 1, 1, 1)
        _RimWidth ("Rim Width", Range(20, 0.1)) = 2.5
        _RimIntensity ("Rim Intensity", Float) = 1.0
        [Enum(Disabled, 0, Enabled, 1)] _RimLightBased ("Light-Based Rim", Range(0, 1)) = 0.0

        // CLEARCOAT
        // [Space(35)]
        // [Header(Clear Coat)]
        // [Space(10)]
        [Toggle(_BACKLACE_CLEARCOAT)] _ToggleClearcoat ("Enable Clear Coat", Float) = 0.0
        _ClearcoatStrength ("Strength", Range(0, 1)) = 1.0
        _ClearcoatReflectionStrength ("Reflection Strength", Range(0, 2)) = 1.0
        [NoScaleOffset] _ClearcoatMap ("Mask (R=Strength, G=Roughness)", 2D) = "white" { }
        _ClearcoatRoughness ("Roughness", Range(0, 1)) = 0.1
        _ClearcoatColor ("Color", Color) = (1, 1, 1, 1)

        // MATCAP
        // [Space(35)]
        // [Header(Matcap)]
        // [Space(10)]
        [Toggle(_BACKLACE_MATCAP)] _ToggleMatcap ("Enable Matcap", Float) = 0.0
        [NoScaleOffset] _MatcapTex ("Matcap Texture", 2D) = "white" { }
        [HDR] _MatcapTint ("Matcap Tint", Color) = (1, 1, 1, 1)
        _MatcapIntensity ("Matcap Intensity", Range(0, 2)) = 1.0
        [Enum(Additive, 0, Multiply, 1, Replace, 2)] _MatcapBlendMode ("Blend Mode", Int) = 0
        [NoScaleOffset] _MatcapMask ("Matcap Mask (R)", 2D) = "white" { }
        [Enum(Disabled, 0, Enabled, 1)] _MatcapSmoothnessEnabled ("Enable Smoothness", Float) = 0.0
        _MatcapSmoothness ("Smoothness", Range(0, 1)) = 0.0

        // DECAL 1
        // [Space(35)]
        // [Header(Decal 1)]
        // [Space(10)]
        [Toggle(_BACKLACE_DECAL1)] _Decal1Enable ("Enable Decal 1", Float) = 0.0
        [NoScaleOffset] _Decal1Tex ("Decal Texture (A=Mask)", 2D) = "white" { }
        _Decal1Tint ("Tint", Color) = (1, 1, 1, 1)
        [Enum(Additive, 0, Multiply, 1, Alpha Blend, 2)] _Decal1BlendMode ("Blend Mode", Int) = 2
        [Enum(Disabled, 0, Enabled, 1)]  _Decal1IsTriplanar ("Use Triplanar Mapping", Float) = 0.0
        _Decal1Position ("UV Position (XY)", Vector) = (0.5, 0.5, 0, 0)
        _Decal1Scale ("UV Scale (XY)", Vector) = (0.25, 0.25, 0, 0)
        _Decal1Rotation ("UV Rotation", Range(0, 360)) = 0
        _Decal1TriplanarPosition ("World Position (XYZ)", Vector) = (0, 0, 0, 0)
        _Decal1TriplanarScale ("World Scale", Float) = 1.0
        _Decal1TriplanarRotation ("World Rotation (XYZ)", Vector) = (0, 0, 0, 0)
        _Decal1TriplanarSharpness ("Triplanar Blend Sharpness", Range(1, 10)) = 2.0
        [Enum(Disabled, 0, Enabled, 1)] _Decal1Repeat ("Repeat Pattern", Float) = 0.0
        _Decal1Scroll ("Scroll Speed (XY)", Vector) = (0, 0, 0, 0)
        _Decal1HueShift ("Hue Shift", Range(0, 2)) = 0.0
        [Enum(Disabled, 0, Enabled, 1)] _Decal1AutoCycleHue ("Auto Cycle Hue", Float) = 0.0
        _Decal1CycleSpeed ("Cycle Speed", Float) = 0.1

        // DECAL 2
        // [Space(35)]
        // [Header(Decal 2)]
        // [Space(10)]
        [Toggle(_BACKLACE_DECAL2)] _Decal2Enable ("Enable Decal 2", Float) = 0.0
        [NoScaleOffset] _Decal2Tex ("Decal Texture (A=Mask)", 2D) = "white" { }
        _Decal2Tint ("Tint", Color) = (1, 1, 1, 1)
        [Enum(Additive, 0, Multiply, 1, Alpha Blend, 2)] _Decal2BlendMode ("Blend Mode", Int) = 2
        [Enum(Disabled, 0, Enabled, 1)] _Decal2IsTriplanar ("Use Triplanar Mapping", Float) = 0.0
        _Decal2Position ("UV Position (XY)", Vector) = (0.5, 0.5, 0, 0)
        _Decal2Scale ("UV Scale (XY)", Vector) = (0.25, 0.25, 0, 0)
        _Decal2Rotation ("UV Rotation", Range(0, 360)) = 0
        _Decal2TriplanarPosition ("World Position (XYZ)", Vector) = (0, 0, 0, 0)
        _Decal2TriplanarScale ("World Scale", Float) = 1.0
        _Decal2TriplanarRotation ("World Rotation (XYZ)", Vector) = (0, 0, 0, 0)
        _Decal2TriplanarSharpness ("Triplanar Blend Sharpness", Range(1, 10)) = 2.0
        [Enum(Disabled, 0, Enabled, 1)] _Decal2Repeat ("Repeat Pattern", Float) = 0.0
        _Decal2Scroll ("Scroll Speed (XY)", Vector) = (0, 0, 0, 0)
        _Decal2HueShift ("Hue Shift", Range(0, 2)) = 0.0
        [Enum(Disabled, 0, Enabled, 1)] _Decal2AutoCycleHue ("Auto Cycle Hue", Float) = 0.0
        _Decal2CycleSpeed ("Cycle Speed", Float) = 0.1

        // POST-PROCESSING
        // [Space(35)]
        // [Header(Post Processing)]
        // [Space(10)]
        [Toggle(_BACKLACE_POST_PROCESSING)] _TogglePostProcessing ("Enable Post Processing", Float) = 0.0
        [HDR] _RGBColor ("RGB Tint", Color) = (1, 1, 1, 1)
        _RGBBlendMode ("RGB Multiply/Replace", Range(0, 1)) = 0.0
        [Enum(Disabled, 0, Additive, 1, Multiply, 2)] _HSVMode ("HSV Mode", Float) = 0.0
        _HSVHue ("Hue", Float) = 0.0
        _HSVSaturation ("Saturation", Float) = 1.0
        _HSVValue ("Value (Brightness)", Float) = 1.0
        [Enum(Disabled, 0, Enabled, 1)] _ToggleHueShift ("Enable Hue Shift", Range(0, 1)) = 0.0
        _HueShift ("Hue Shift", Range(-1, 1)) = 0.0
        [Enum(Disabled, 0, Enabled, 1)] _ToggleAutoCycle ("Enable Auto Cycle Hue", Float) = 0.0
        _AutoCycleSpeed ("Auto Cycle Speed", Float) = 0.1
        [NoScaleOffset] _ColorGradingLUT ("Color Grading LUT", 2D) = "white" { }
        _ColorGradingIntensity ("Grading Intensity", Range(0, 1)) = 0.0
        _BlackAndWhite ("Black and White", Range(0, 1)) = 0.0
        _Brightness ("Brightness", Range(0, 2)) = 1.0

        // CUBEMAP
        // [Space(35)]
        // [Header(Cubemap)]
        // [Space(10)]
        [Toggle(_BACKLACE_CUBEMAP)] _ToggleCubemap ("Enable Cubemap", Float) = 0.0
        [NoScaleOffset] _CubemapTex ("Cubemap", Cube) = "" { }
        [HDR] _CubemapTint ("Cubemap Tint", Color) = (1, 1, 1, 1)
        _CubemapIntensity ("Cubemap Intensity", Range(0, 2)) = 1.0
        [Enum(Additive, 0, Multiply, 1, Replace, 2)] _CubemapBlendMode ("Blend Mode", Int) = 0

        // PARALLAX MAPPING
        // [Space(35)]
        // [Header(Parallax Mapping)]
        // [Space(10)]
        [Toggle(_BACKLACE_PARALLAX)] _ToggleParallax ("Enable Parallax Mapping", Float) = 0.0
        [Enum(Fast, 0, Fancy, 1)] _ParallaxMode ("Parallax Mode", Int) = 0
        [NoScaleOffset] _ParallaxMap ("Height Map (R)", 2D) = "black" { }
        _ParallaxStrength ("Parallax Strength", Range(0, 0.1)) = 0.02
        _ParallaxSteps ("High Quality Steps", Range(4, 64)) = 16
        [Toggle(_BACKLACE_PARALLAX_SHADOWS)] _ToggleParallaxShadows ("Enable Self-Shadowing", Float) = 0.0
        _ParallaxShadowSteps ("Shadow Quality Steps", Range(2, 16)) = 8
        _ParallaxShadowStrength ("Shadow Strength", Range(0, 1)) = 0.75

        // SUBSURFACE SCATTERING
        // [Space(35)]
        // [Header(Subsurface Scattering)]
        // [Space(10)]
        [Toggle(_BACKLACE_SSS)] _ToggleSSS ("Enable Subsurface Scattering", Float) = 0.0
        _SSSColor ("SSS Color", Color) = (1, 0.8, 0.7, 1) 
        _SSSStrength ("SSS Strength", Range(0, 5)) = 1.0
        _SSSPower ("SSS Power", Range(0.1, 10)) = 2.0
        _SSSDistortion ("SSS Distortion", Range(0, 1)) = 0.5
        [NoScaleOffset] _SSSThicknessMap ("SSS Thickness Map (R)", 2D) = "white" { }
        _SSSThickness ("SSS Thickness Attenuation", Range(0, 2)) = 1.0

        // SHADOW MAP
        // [Space(35)]
        // [Header(Shadow Map)]
        // [Space(10)]
        [Toggle(_BACKLACE_SHADOW_MAP)] _ToggleShadowMap ("Enable Shadow Map", Float) = 0.0
        [NoScaleOffset] _ShadowMap ("Shadow Map (R=Mask)", 2D) = "white" { }
        _ShadowMapIntensity ("Intensity", Range(0, 1)) = 1.0

        // DETAIL MAPPING
        // [Space(35)]
        // [Header(Detail Mapping)]
        // [Space(10)]
        [Toggle(_BACKLACE_DETAIL)] _ToggleDetail ("Enable Detail Maps", Float) = 0.0
        [NoScaleOffset] _DetailAlbedoMap ("Detail Albedo (A=Strength)", 2D) = "gray" { }
        [NoScaleOffset] _DetailNormalMap ("Detail Normal Map", 2D) = "bump" { }
        _DetailTiling ("Detail Tiling", Float) = 16
        _DetailNormalStrength ("Detail Normal Strength", Range(0, 2)) = 1.0

        // DISSOLVE EFFECT
        // [Space(35)]
        // [Header(Dissolve Effect)]
        // [Space(10)]
        [Toggle(_BACKLACE_DISSOLVE)] _ToggleDissolve ("Enable Dissolve", Float) = 0.0
        _DissolveProgress ("Dissolve Progress", Range(0, 2.0)) = 0.0
        [Enum(Noise, 0, Directional, 1, Voxel, 2)] _DissolveType ("Dissolve Type", Int) = 0
        // edge glow
        [HDR] _DissolveEdgeColor ("Edge Color", Color) = (1, 0.5, 0, 1)
        _DissolveEdgeWidth ("Edge Width", Range(0.001, 0.25)) = 0.05
        [Enum(Glow, 0, Smooth Fade, 1)] _DissolveEdgeMode ("Edge Mode", Float) = 0
        _DissolveEdgeSharpness ("Edge Sharpness", Range(0.0, 1.0)) = 0.0
        // noise
        [NoScaleOffset] _DissolveNoiseTex ("Noise Texture (R)", 2D) = "gray" { }
        _DissolveNoiseScale ("Noise Scale", Float) = 5.0
        // directional
        _DissolveDirection ("Wipe Direction (XYZ)", Vector) = (0, 1, 0, 0)
        [Enum(Local Space, 0, World Space, 1)] _DissolveDirectionSpace ("Wipe Space", Int) = 0
        _DissolveDirectionBounds ("Wipe Bounds Size", Float) = 1.0
        // voxel
        _DissolveVoxelDensity ("Voxel Density", Float) = 20.0

        // PATHING
        // [Space(35)]
        // [Header(Pathing)]
        // [Space(10)]
        [Toggle(_BACKLACE_PATHING)] _TogglePathing ("Enable Pathing", Float) = 0.0
        [Enum(Albedo UV, 0, Triplanar, 1)] _PathingMappingMode ("Mapping Mode", Int) = 0
        [NoScaleOffset] _PathingMap ("Path Map (R)", 2D) = "black" { }
        _PathingScale ("Path Scale", Float) = 1.0
        [Enum(Additive, 0, Multiply, 1, Alpha Blend, 2)] _PathingBlendMode ("Blend Mode", Int) = 0
        [Enum(Colour, 0, Texture, 1, Gradient, 2)] _PathingColorMode ("Color Mode", Int) = 0
        _PathingTexture ("Path Texture", 2D) = "white" { }
        [HDR] _PathingColor ("Path Color", Color) = (0, 1, 1, 1)
        [HDR] _PathingColor2 ("Secondary Color", Color) = (1, 0, 0, 1)
        _PathingEmission ("Emission Strength", Float) = 2.0
        [Enum(Fill, 0, Path, 1, Loop, 2)] _PathingType ("Path Type", Int) = 1
        _PathingSpeed ("Speed", Float) = 0.5
        _PathingWidth ("Path Width", Range(0.001, 0.5)) = 0.1
        _PathingSoftness ("Softness", Range(0.001, 1.0)) = 0.5
        _PathingOffset ("Time Offset", Range(0, 1)) = 0.0

        // SCREEN SPACE RIM LIGHTING
        // [Space(35)]
        // [Header(Depth Rim Lighting)]
        // [Space(10)]
        [Toggle(_BACKLACE_DEPTH_RIMLIGHT)] _ToggleDepthRim ("Enable Depth Rim Lighting", Float) = 0.0
        [HDR] _DepthRimColor ("Color", Color) = (0.5, 0.75, 1, 1)
        _DepthRimWidth ("Width", Range(0, 0.5)) = 0.1
        _DepthRimThreshold ("Threshold", Range(0.01, 1)) = 0.1
        _DepthRimSharpness ("Sharpness", Range(0.01, 1)) = 0.1
        [Enum(Additive, 0, Replace, 1, Multiply, 2)] _DepthRimBlendMode ("Blend Mode", Int) = 0

        // AUDIOLINK
        // [Space(35)]
        // [Header(AudioLink)]
        // [Space(10)]
        [Toggle(_BACKLACE_AUDIOLINK)] _ToggleAudioLink ("Enable AudioLink", Float) = 0.0
        _AudioLinkFallback ("Fallback Level", Range(0, 1)) = 1.0
        [Enum(Disabled, 0, Bass, 1, Low Mids, 2, High Mids, 3, Treble, 4, Overall, 5)] _AudioLinkEmissionBand ("Emission Band", Float) = 0
        _AudioLinkEmissionStrength ("  Strength", Range(0, 10)) = 1.0
        _AudioLinkEmissionRange ("  Min/Max", Vector) = (0, 1, 0, 0)
        [Enum(Disabled, 0, Bass, 1, Low Mids, 2, High Mids, 3, Treble, 4, Overall, 5)] _AudioLinkRimBand ("Rim Light Band", Float) = 0
        _AudioLinkRimStrength ("  Strength", Range(0, 10)) = 1.0
        _AudioLinkRimRange ("  Min/Max", Vector) = (0, 1, 0, 0)
        [Enum(Disabled, 0, Bass, 1, Low Mids, 2, High Mids, 3, Treble, 4, Overall, 5)] _AudioLinkHueShiftBand ("Hue Shift Band", Float) = 0
        _AudioLinkHueShiftStrength ("  Strength", Range(0, 1)) = 0.2
        _AudioLinkHueShiftRange ("  Min/Max", Vector) = (0, 1, 0, 0)
        [Enum(Disabled, 0, Bass, 1, Low Mids, 2, High Mids, 3, Treble, 4, Overall, 5)] _AudioLinkDecalHueBand ("Decal Hue Band", Float) = 0
        _AudioLinkDecalHueStrength ("  Strength", Range(0, 10)) = 2.0
        _AudioLinkDecalHueRange ("  Min/Max", Vector) = (0, 1, 0, 0)
        [Enum(Disabled, 0, Bass, 1, Low Mids, 2, High Mids, 3, Treble, 4, Overall, 5)] _AudioLinkDecalEmissionBand ("Decal Emission Band", Float) = 0
        _AudioLinkDecalEmissionStrength ("  Strength", Range(0, 10)) = 2.0
        _AudioLinkDecalEmissionRange ("  Min/Max", Vector) = (0, 1, 0, 0)
        [Enum(Disabled, 0, Bass, 1, Low Mids, 2, High Mids, 3, Treble, 4, Overall, 5)] _AudioLinkDecalOpacityBand ("Decal Opacity Band", Float) = 0
        _AudioLinkDecalOpacityStrength ("  Strength", Range(0, 10)) = 2.0
        _AudioLinkDecalOpacityRange ("  Min/Max", Vector) = (0, 1, 0, 0)
        [Enum(Disabled, 0, Bass, 1, Low Mids, 2, High Mids, 3, Treble, 4, Overall, 5)] _AudioLinkVertexBand ("Vertex Grow/Shrink Band", Float) = 0
        _AudioLinkVertexStrength ("  Strength", Range(-0.2, 0.2)) = 0.05
        _AudioLinkVertexRange ("  Min/Max", Vector) = (0, 1, 0, 0)
        [Enum(Disabled, 0, Bass, 1, Low Mids, 2, High Mids, 3, Treble, 4, Overall, 5)] _AudioLinkOutlineBand ("Outline Band", Float) = 0
        _AudioLinkOutlineStrength ("  Strength", Range(0, 0.1)) = 0.01
        _AudioLinkOutlineRange ("  Min/Max", Vector) = (0, 1, 0, 0)
        [Enum(Disabled, 0, Bass, 1, Low Mids, 2, High Mids, 3, Treble, 4, Overall, 5)] _AudioLinkMatcapBand ("Matcap Band", Float) = 0
        _AudioLinkMatcapStrength ("  Strength", Range(0, 5)) = 1.0
        _AudioLinkMatcapRange ("  Min/Max", Vector) = (0, 1, 0, 0)
        [Enum(Disabled, 0, Bass, 1, Low Mids, 2, High Mids, 3, Treble, 4, Overall, 5)] _AudioLinkPathingBand ("Pathing Band", Float) = 0
        _AudioLinkPathingStrength ("  Strength", Range(0, 0.5)) = 0.1
        _AudioLinkPathingRange ("  Min/Max", Vector) = (0, 1, 0, 0)
        [Enum(Disabled, 0, Bass, 1, Low Mids, 2, High Mids, 3, Treble, 4, Overall, 5)] _AudioLinkGlitterBand ("Glitter Band", Float) = 0
        _AudioLinkGlitterStrength ("  Strength", Range(0, 1)) = 1.0
        _AudioLinkGlitterRange ("  Min/Max", Vector) = (0, 1, 0, 0)
        [Enum(Disabled, 0, Bass, 1, Low Mids, 2, High Mids, 3, Treble, 4, Overall, 5)] _AudioLinkIridescenceBand ("Iridescence Band", Float) = 0
        _AudioLinkIridescenceStrength ("  Strength", Range(0, 5)) = 1.0
        _AudioLinkIridescenceRange ("  Min/Max", Vector) = (0, 1, 0, 0)

        // LTCGI
        // [Space(35)]
        // [Header(LTCGI)]
        // [Space(10)]
        [Toggle(_BACKLACE_LTCGI)] _ToggleLTCGI ("Enable LTCGI", Float) = 0.0

        // GLITTER
        // [Space(35)]
        // [Header(Glitter)]
        // [Space(10)]
        [Toggle(_BACKLACE_GLITTER)] _ToggleGlitter ("Enable Glitter", Float) = 0.0
        [Enum(Procedural, 0, Texture, 1)] _GlitterMode ("Mode", Range(0, 1)) = 0.0
        [NoScaleOffset] _GlitterNoiseTex ("Noise Texture (R)", 2D) = "gray" { }
        [NoScaleOffset] _GlitterMask ("Mask (R)", 2D) = "white" { }
        _GlitterTint ("Tint", Color) = (1, 1, 1, 1)
        _GlitterFrequency ("Density", Float) = 50.0
        _GlitterThreshold ("Density Threshold", Range(0.01, 1.0)) = 0.5
        _GlitterSize ("Size", Range(0.01, 0.5)) = 0.1
        _GlitterFlickerSpeed ("Flicker Speed", Range(0, 5)) = 1.0
        _GlitterBrightness ("Brightness", Range(0, 10)) = 2.0
        _GlitterContrast ("Contrast", Range(1, 256)) = 128.0
        _ToggleGlitterRainbow ("Enable Rainbow", Range(0, 1)) = 0.0
        _GlitterRainbowSpeed ("Rainbow Speed", Range(0, 5)) = 0.1

        // DISTANCE FADING
        // [Space(35)]
        // [Header(Distance Fading)]
        // [Space(10)]
        [Toggle(_BACKLACE_DISTANCE_FADE)] _ToggleDistanceFade ("Enable Distance Fading", Float) = 0.0
        [Enum(World Position, 0, Object Center, 1)] _DistanceFadeReference ("Fade Reference Point", Range(0, 1)) = 0
        [Enum(Disabled, 0, Enabled, 1)] _ToggleNearFade ("Enable Near Fade", Float) = 0.0
        [Enum(Transparent, 0, Dither, 1)] _NearFadeMode ("Near Fade Mode", Float) = 0.0
        _NearFadeDitherScale ("Near Fade Dither Scale", Range(100, 0.1)) = 10
        _NearFadeStart ("Near Fade Start", Float) = 0.5
        _NearFadeEnd ("Near Fade End", Float) = 0.0
        [Enum(Disabled, 0, Enabled, 1)] _ToggleFarFade ("Enable Far Fade", Float) = 0.0
        _FarFadeStart ("Far Fade Start", Float) = 20.0
        _FarFadeEnd ("Far Fade End", Float) = 50.0

        // IRIDESCENCE
        // [Space(35)]
        // [Header(Iridescence)]
        // [Space(10)]
        [Toggle(_BACKLACE_IRIDESCENCE)] _ToggleIridescence ("Enable Iridescence", Float) = 0.0
        [KeywordEnum(Texture, Procedural)] _IridescenceMode ("Mode", Int) = 0
        [NoScaleOffset] _IridescenceMask ("Mask (R)", 2D) = "white" { }
        [HDR] _IridescenceTint ("Tint", Color) = (1, 1, 1, 1)
        _IridescenceIntensity ("Intensity", Range(0, 5)) = 1.0
        [Enum(Additive, 0, Screen, 1, Alpha Blend, 2)] _IridescenceBlendMode ("Blend Mode", Int) = 0
        _IridescenceParallax ("View Parallax", Range(0, 1)) = 0.5
        [NoScaleOffset] _IridescenceRamp ("Color Ramp", 2D) = "white" { }
        _IridescencePower ("Power", Range(0.1, 10)) = 1.0
        _IridescenceFrequency ("Rainbow Frequency", Range(0.1, 20)) = 5.0

        // SHADOW TEXTURE
        // [Space(35)]
        // [Header(Shadow Texture)]
        // [Space(10)]
        [Toggle(_BACKLACE_SHADOW_TEXTURE)] _ToggleShadowTexture ("Enable Shadow Texture", Float) = 0.0
        [Enum(UV Albedo, 0, Screen Pattern, 1, Triplanar Pattern, 2)] _ShadowTextureMappingMode ("Shadow Mode", Int) = 0
        _ShadowTextureIntensity ("Shadow Intensity", Range(0, 1)) = 1.0
        [NoScaleOffset] _ShadowTex ("Shadow Texture / Pattern", 2D) = "white" { }
        _ShadowPatternColor ("Pattern Tint", Color) = (0, 0, 0, 1)
        _ShadowPatternScale ("Pattern Scale / Tiling", Float) = 5.0
        _ShadowPatternTriplanarSharpness ("Triplanar Blend Sharpness", Range(1, 10)) = 2.0
        _ShadowPatternTransparency ("Pattern Transparency", Range(0, 1)) = 1

        // FLAT MODEL
        // [Space(35)]
        // [Header(Flat Model)]
        // [Space(10)]
        [Toggle(_BACKLACE_FLAT_MODEL)] _ToggleFlatModel ("Enable Flat Model", Float) = 0.0
        [Enum(Disabled, 0, Enabled, 1)] _FlatModeAutoflip ("Auto-Flip", Float) = 0.0
        _FlatModel ("Flat Model Strength", Range(0, 1)) = 0.0
        _FlatModelDepthCorrection ("Depth Correction", Range(-0.2, 0.2)) = -0.1
        _FlatModelFacing ("Facing Direction", Range(-1, 1)) = 0.0
        [Enum(Disabled, 1, Enabled, 0)] _FlatModelLockAxis ("Follow Camera", Range(0, 1)) = 1.0

        // WORLD AFFECT
        // [Space(35)]
        // [Header(World Aligned Effect)]
        // [Space(10)]
        [Toggle(_BACKLACE_WORLD_EFFECT)] _ToggleWorldEffect ("Enable World Effect", Float) = 0.0
        [Enum(Alpha Blend, 0, Additive, 1, Multiply, 2)] _WorldEffectBlendMode ("Blend Mode", Int) = 0
        [NoScaleOffset] _WorldEffectTex ("Effect Texture (A=Mask)", 2D) = "white" { }
        [HDR] _WorldEffectColor ("Effect Color", Color) = (1, 1, 1, 1)
        _WorldEffectDirection ("Effect Direction (XYZ)", Vector) = (0, 1, 0, 0)
        _WorldEffectScale ("Effect Scale", Float) = 1.0
        _WorldEffectBlendSharpness ("Directional Blend Sharpness", Range(0.1, 20)) = 4.0
        _WorldEffectIntensity ("Effect Intensity", Range(0, 2)) = 1.0
        _WorldEffectPosition ("World Position (XYZ)", Vector) = (0, 0, 0, 0)
        _WorldEffectRotation ("World Rotation (XYZ)", Vector) = (0, 0, 0, 0)

        // VRCHAT MIRROR DETECTION
        // [Space(35)]
        // [Header(VRChat Mirror Detection)]
        // [Space(10)]
        [Toggle(_BACKLACE_VRCHAT_MIRROR)] _ToggleMirrorDetection ("Enable VRChat Mirror Detection", Float) = 0.0
        [Enum(Texture, 0, Hide, 1, Only Show, 2)] _MirrorDetectionMode ("Mirror Mode", Int) = 0
        _MirrorDetectionTexture ("Mirror Detection Texture", 2D) = "white" { }

        // TOUCH REACTIVE
        // [Space(35)]
        // [Header(Touch Reactive)]
        // [Space(10)]
        [Toggle(_BACKLACE_TOUCH_REACTIVE)] _ToggleTouchReactive ("Enable Touch Reactive", Float) = 0.0
        [HDR] _TouchColor ("Touch Color", Color) = (1, 0, 1, 1)
        _TouchRadius ("Touch Radius", Range(0, .5)) = 0.1
        _TouchHardness ("Touch Hardness", Range(0.01, 10)) = 2.0
        [Enum(Additive, 0, Replace, 1, Multiply, 2, Rainbow, 3)] _TouchMode ("Touch Mode", Float) = 0.0
        _TouchRainbowSpeed ("Touch Rainbow Speed", Float) = 0.1
        _TouchRainbowSpread ("Touch Rainbow Spread", Float) = 1.0

        // REFREACTION
        // [Space(35)]
        // [Header(Refraction)]
        // [Space(10)]
        [Toggle(_BACKLACE_REFRACTION)] _ToggleRefraction ("Enable Refraction Effect", Float) = 0.0
        [NoScaleOffset] _RefractionMask ("Mask (R=Strength)", 2D) = "white" { }
        _RefractionTint ("Refraction Tint", Color) = (0.8, 0.9, 1.0, 0.5)
        _RefractionIOR ("Refraction Strength", Range(0.0, 1.0)) = 0.1
        _RefractionFresnel ("Fresnel Power", Range(0.1, 20)) = 5.0
        _RefractionOpacity ("Refraction Opacity", Range(0, 1)) = 0.5
        _RefractionSeeThrough ("See Through Strength", Range(0, 1)) = 0
        [Enum(Reverse Fresnel, 0, Fresnel, 1, Soft Fresnel, 2, Manual, 3)] _RefractionMode ("Refraction Mode", Float) = 0.0
        _RefractionMixStrength ("Mix Strength", Float) = 0
        _RefractionBlendMode ("Refraction Additive<->Replace", Range(0, 1)) = 0
        // caustics
        [NoScaleOffset] _CausticsTex ("Internal Caustics Texture", 2D) = "gray" { }
        _CausticsColor ("Caustics Color", Color) = (1, 1, 1, 1)
        _CausticsTiling ("Caustics Tiling", Float) = 2.0
        _CausticsSpeed ("Caustics Animation Speed", Range(0, 3)) = 0.2
        _CausticsIntensity ("Caustics Intensity", Range(0, 5)) = 1.5
        // uv distortion
        [NoScaleOffset] _DistortionNoiseTex ("Distortion Noise (RG)", 2D) = "gray" { }
        _DistortionNoiseTiling ("Distortion Noise Tiling", Float) = 5.0
        _DistortionNoiseStrength ("Distortion Noise Strength", Range(0, 1.0)) = 0.2
        // colour distortion
        [Enum(Disabled, 0, Chromatic Aberration, 1, Blur, 2)] _RefractionDistortionMode ("Blur Mode", Int) = 1
        _RefractionCAStrength ("Chromatic Aberration Strength", Range(0, 5)) = 2
        _RefractionBlurStrength ("Blur Strength", Range(0, 0.5)) = 0.05
        [Enum(Disabled, 0, Enabled, 1)] _RefractionCAUseFresnel ("Use Fresnel for CA", Int) = 0.0 
        _RefractionCAEdgeFade ("CA Fresnel Power", Range(0.1, 10)) = 2.0 

        // VERTEX DISTORTION
        // [Space(35)]
        // [Header(Vertex Distortion)]
        // [Space(10)]
        [Toggle(_BACKLACE_VERTEX_DISTORTION)] _ToggleVertexDistortion ("Enable Vertex Distortion", Float) = 0.0
        [Enum(Wave, 0, Jumble, 1)] _VertexDistortionMode ("Distortion Mode", Int) = 0
        _VertexDistortionStrength ("Distortion Strength", Vector) = (0.1, 0.1, 0.1, 0)
        _VertexDistortionSpeed ("Distortion Speed", Vector) = (1, 1, 1, 0)
        _VertexDistortionFrequency ("Distortion Frequency", Vector) = (1, 1, 1, 0)

        // FAKE SCREEN SPACE REFLECTIONS
        // [Space(35)]
        // [Header(Fake Screen Space Reflections)]
        // [Space(10)]
        [Toggle(_BACKLACE_SSR)] _ToggleSSR ("Enable Screen Space Reflections", Float) = 0.0
        [Enum(Planar, 0, Raymarched, 1)] _SSRMode ("Reflection Mode", Int) = 0
        [NoScaleOffset] _SSRMask ("Mask (R)", 2D) = "white" { }
        [HDR] _SSRTint ("Reflection Tint", Color) = (1, 1, 1, 1)
        _SSRIntensity ("Intensity", Range(0, 2)) = 1.0
        [Enum(Additive, 0, Alpha Blend, 1, Multiply, 2, Screen, 3)] _SSRBlendMode ("Blend Mode", Int) = 0
        _SSRFresnelPower ("Fresnel Power", Range(0.1, 20)) = 5.0
        _SSRFresnelScale ("Fresnel Scale", Range(0, 2)) = 1.0
        _SSRFresnelBias ("Fresnel Bias", Range(0, 1)) = 0.0
        _SSRCoverage ("Coverage", Range(0, 1)) = 0.0
        // planar settings
        _SSRParallax ("Parallax Strength", Range(0, 1)) = 0.1
        [NoScaleOffset] _SSRDistortionMap ("Distortion Map (RG)", 2D) = "gray" { }
        _SSRDistortionStrength ("Distortion Strength", Range(0, 0.25)) = 0.01
        _SSRWorldDistortion ("World Distortion Strength", Range(0, 1)) = 0.0
        _SSRBlur ("Blur Strength", Range(0, 10)) = 1.0
        // raymarched settings
        [IntRange] _SSRMaxSteps ("Max Steps", Range(1, 50)) = 25
        _SSRStepSize ("Step Size", Float) = 0.05
        _SSREdgeFade ("Edge Fade", Range(0.01, 1)) = 0.1
        [Enum(Disabled, 0, Enabled, 1)] _SSRCamFade ("Enable Camera Distance Fade", Int) = 0.0
        _SSRCamFadeStart ("SSR Camera Fade Start", Float) = 20.0
        _SSRCamFadeEnd ("SSR Camera Fade End", Float) = 50.0
        _SSRFlipUV ("Flip Reflection UV", Range(0, 1)) = 0 // more stylised if on, less accurate
        [Enum(Disabled, 0, Enabled, 1)] _SSRAdaptiveStep ("Enable Adaptive Step Size", Int) = 1
        _SSRThickness ("Culling Thickness", Float) = 0.01
        [Enum(Stretch, 0, Fade, 1, Cutoff, 2, Mirror, 3)] _SSROutOfViewMode ("Out Of View Mode", Int) = 0

        // DITHER
        // [Space(35)]
        // [Header(Dither)]
        // [Space(10)]
        [Toggle(_BACKLACE_DITHER)] _ToggleDither ("Enable Dither", Float) = 0.0
        [Enum(Screen, 0, World, 1, UV, 2)] _DitherSpace ("Dither Space", Int) = 0
        _DitherAmount ("Dither Amount", Range(0, 1)) = 0
        _DitherScale ("Dither Scale", Range(100, 0.1)) = 10

        // LOW PRECISION
        // [Space(35)]
        // [Header(Low Precision)]
        // [Space(10)]
        [Toggle(_BACKLACE_PS1)] _TogglePS1 ("Enable Low Precision (PS1)", Float) = 0.0
        [Enum(Disabled, 0, World Space, 1, Screen Space, 2)] _PS1Rounding ("Rounding Style", Int) = 0.0
        _PS1RoundingPrecision ("Rounding Precision", Float) = 64
        [Enum(Disabled, 0, Enabled, 1)] _PS1Affine ("Enable Affine Texture Mapping", Int) = 0.0
        [Enum(Disabled, 0, Enabled, 1)] _PS1Compression ("Enable Color Compression", Int) = 0.0
        _PS1CompressionPrecision ("Color Compression Precision", Float) = 32

        // OUTLINE
        // [Space(70)]
        // [Header(Outline)]
        // [Space(10)]
        _OutlineColor ("Outline Color", Color) = (0, 0, 0, 1)
        _OutlineWidth ("Outline Width", Range(0, 0.1)) = 0.005
        [Enum(Disabled, 0, Enabled, 1)] _OutlineVertexColorMask ("Use Vertex Color (R) Mask", Float) = 0.0
        [Enum(Disabled, 0, Enabled, 1)] _OutlineDistanceFade ("Enable Distance Fade", Float) = 0.0
        _OutlineFadeStart ("Fade Start Distance", Float) = 10.0
        _OutlineFadeEnd ("Fade End Distance", Float) = 15.0
        [Enum(Disabled, 0, Enabled, 1)] _OutlineHueShift ("Enable Hue Shift", Float) = 0.0 
        _OutlineHueShiftSpeed ("Hue Shift Speed", Float) = 0.2
        _OutlineOpacity ("Outline Opacity", Range(0, 1)) = 1.0

        // INDIRECT LIGHTING
        // [Space(35)]
        // [Header(Indirect Lighting)]
        // [Space(10)]
        [Enum(Disabled, 0, Enabled, 1)] _IndirectOverride ("Indirect Override", Float) = 0.0
        [Enum(Disabled, 0, Cubemap, 1)] _IndirectFallbackMode ("Indirect Fallback Mode", Float) = 0.0
        _FallbackCubemap ("Fallback Cubemap", Cube) = "" { }

        // UV SETTINGS
        // [Space(35)]
        // [Header(UV Settings)]
        // [Space(10)]
        [Enum(Zero, 0, One, 1, Two, 2, Three, 3)] _MainTex_UV ("Main texture UV set", Int) = 0
        [Enum(Zero, 0, One, 1, Two, 2, Three, 3)] _BumpMap_UV ("Bump map UV set", Int) = 0
        [Enum(Zero, 0, One, 1, Two, 2, Three, 3)] _MSSO_UV ("MSSO UV set", Int) = 0
        [Enum(Zero, 0, One, 1, Two, 2, Three, 3)] _SpecularTintTexture_UV ("Specular Tint UV Set", Int) = 0
        [Enum(Zero, 0, One, 1, Two, 2, Three, 3)] _TangentMap_UV ("Tangent Map UV", Int) = 0
        [Enum(Zero, 0, One, 1, Two, 2, Three, 3)] _EmissionMap_UV ("Emission Map UV Set", Int) = 0
        [Enum(Zero, 0, One, 1, Two, 2, Three, 3)] _ClearcoatMap_UV ("Clear Coat Map UV Set", Int) = 0
        [Enum(Zero, 0, One, 1, Two, 2, Three, 3)] _MatcapMask_UV ("Clear Coat Map UV Set", Int) = 0
        [Enum(Zero, 0, One, 1, Two, 2, Three, 3)] _ParallaxMap_UV ("Height Map UV Set", Int) = 0
        [Enum(Zero, 0, One, 1, Two, 2, Three, 3)] _ThicknessMap_UV ("Thickness Map UV Set", Int) = 0
        [Enum(Zero, 0, One, 1, Two, 2, Three, 3)] _DetailMap_UV ("Detail Map UV Set", Int) = 0
        [Enum(Zero, 0, One, 1, Two, 2, Three, 3)] _Decal1_UV ("Deca; 1 UV Set", Int) = 0
        [Enum(Zero, 0, One, 1, Two, 2, Three, 3)] _Decal2_UV ("Decal 2 UV Set", Int) = 0
        [Enum(Zero, 0, One, 1, Two, 2, Three, 3)] _Glitter_UV ("Glitter UV Set", Int) = 0.0
        [Enum(Zero, 0, One, 1, Two, 2, Three, 3)] _IridescenceMask_UV ("Iridescence Mask UV Set", Int) = 0.0
        [Enum(Zero, 0, One, 1, Two, 2, Three, 3)] _GlitterMask_UV ("Glitter Mask UV Set", Int) = 0.0
        [Enum(Zero, 0, One, 1, Two, 2, Three, 3)] _HairFlowMap_UV ("Hair Flow Map UV Set", Int) = 0.0
        [Enum(Zero, 0, One, 1, Two, 2, Three, 3)] _ShadowTex_UV ("Shadow Texture UV Set", Int) = 0
        [Enum(Zero, 0, One, 1, Two, 2, Three, 3)] _Flowmap_UV ("Flowmap UV Set", Int) = 0.0
        [Enum(Zero, 0, One, 1, Two, 2, Three, 3)] _MirrorDetectionTexture_UV ("Mirror Detection Texture UV Set", Int) = 0
        [Enum(Zero, 0, One, 1, Two, 2, Three, 3)] _RefractionMask_UV ("Refraction Mask UV Set", Int) = 0
        [Enum(Zero, 0, One, 1, Two, 2, Three, 3)] _PathingMap_UV ("Pathing Map UV Set", Int) = 0
        [Enum(Zero, 0, One, 1, Two, 2, Three, 3)] _ShadowMap_UV ("Shadow Map UV Set", Int) = 0
        [Enum(Zero, 0, One, 1, Two, 2, Three, 3)] _PathingTexture_UV ("Pathing Texture UV Set", Int) = 0
        [Enum(Zero, 0, One, 1, Two, 2, Three, 3)] _Dither_UV ("Dither UV Set", Int) = 0
    }
    SubShader
    {

        // Rendering Settings
        // Tags { "RenderType" = "TransparentCutout" "Queue" = "AlphaTest" } or Transparent
        Tags { "RenderType" = "Transparent" "Queue" = "Transparent" "VRCFallback"="Toon" "Backlace"="1.0.0" }
        Blend [_SrcBlend] [_DstBlend]
        ZWrite [_ZWrite]
        Cull [_Cull]
        Stencil { Ref [_StencilRef] Comp [_StencilComp] Pass [_StencilPass] Fail [_StencilFail] ZFail [_StencilZFail] }
        GrabPass { Tags { "LightMode" = "ForwardBase" } "_BacklaceGP" } // todo: make this work with forwardadd as well..

        // Outline Pass
        Pass
        {
            Name "Outline"
            Tags { "LightMode" = "Always" }
            Cull Front
            ZWrite Off
            Blend SrcAlpha OneMinusSrcAlpha
            Stencil { Ref [_OutlineStencilRef] Comp [_OutlineStencilComp] Pass [_OutlineStencilPass] Fail [_OutlineStencilFail] ZFail [_OutlineStencilZFail] }
            CGPROGRAM
            #ifndef UNITY_PASS_OUTLINE
                #define UNITY_PASS_OUTLINE
            #endif // UNITY_PASS_OUTLINE
            #include "../Resources/Luka_Backlace/Includes/Backlace_Outline.cginc"
            ENDCG
        }

        // Forward Base Pass
        Pass
        {  
            Name "ForwardBase"
            ZTest [_ZTest]
            Tags { "LightMode" = "ForwardBase" }
            CGPROGRAM
            #ifndef UNITY_PASS_FORWARDBASE
                #define UNITY_PASS_FORWARDBASE
            #endif // UNITY_PASS_FORWARDBASE
            #ifndef BACKLACE_GRABPASS
                #define BACKLACE_GRABPASS
            #endif // BACKLACE_GRABPASS
            #include "../Resources/Luka_Backlace/Includes/Backlace_Forward.cginc"
            ENDCG
        }
          
        // Forward Add Pass
        Pass
        {
            Name "ForwardAdd"
            Tags { "LightMode" = "ForwardAdd" }
            Blend [_SrcBlend] One // make it, well, additive
            Fog { Color(0, 0, 0, 0) } // additive should have black fog
            ZWrite Off // don't write to depth for additive
            CGPROGRAM
            #ifndef UNITY_PASS_FORWARDADD
                #define UNITY_PASS_FORWARDADD
            #endif // UNITY_PASS_FORWARDADD
            #ifndef BACKLACE_GRABPASS
                #define BACKLACE_GRABPASS
            #endif // BACKLACE_GRABPASS
            #include "../Resources/Luka_Backlace/Includes/Backlace_Forward.cginc"
            ENDCG
        }

        // Shadow Pass
        Pass
        {
            Name "ShadowCaster"
            Tags { "LightMode" = "ShadowCaster" }
            ZWrite On 
            ZTest [_ZTest]
            CGPROGRAM
            #ifndef UNITY_PASS_SHADOWCASTER
                #define UNITY_PASS_SHADOWCASTER
            #endif // UNITY_PASS_SHADOWCASTER
            #include "../Resources/Luka_Backlace/Includes/Backlace_Shadow.cginc"
            ENDCG
        }
        
        // Meta Pass
        Pass
        {
            Name "Meta"
            Tags { "LightMode" = "Meta" }
            Cull Off
            CGPROGRAM
            #ifndef UNITY_PASS_META
                #define UNITY_PASS_META
            #endif // UNITY_PASS_META
            #include "../Resources/Luka_Backlace/Includes/Backlace_Meta.cginc"
            ENDCG
        }

    }
    CustomEditor "Luka.Backlace.Interface"
}