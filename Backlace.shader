Shader "luka/indev/backlace"
{

    Properties
    {
        // RENDERING SETTINGS
        [Space(35)]
        [Header(Rendering Settings)]
        [Space(10)]
        _SrcBlend ("Src Blend", Float) = 1.0
        _DstBlend ("Dst Blend", Float) = 0.0
        _ZWrite ("ZWrite", Float) = 1.0
        [Enum(UnityEngine.Rendering.CullMode)] _Cull ("Cull Mode", Int) = 2
        _Mode ("Blend mode", Int) = 0
        [IntRange] _StencilID ("Stencil ID (0-255)", Range(0, 255)) = 0
        [Enum(UnityEngine.Rendering.CompareFunction)] _StencilComp ("Stencil Comparison", Int) = 0
        [Enum(UnityEngine.Rendering.StencilOp)] _StencilOp ("Stencil Operation", Int) = 0

        // MAIN MAPS AND ALPHA
        [Space(35)]
        [Header(Main Maps and Alpha)]
        [Space(10)]
        _MainTex ("Main texture", 2D) = "white" { }
        _Color ("Albedo color", Color) = (1, 1, 1, 1)
        _Cutoff ("Alpha Cutoff", Range(0, 1)) = 0.5
        _BumpMap ("Normal map", 2D) = "bump" { }
        _BumpScale ("Normal map scale", Float) = 1

        // UV MANIPULATION
        [Space(35)]
        [Header(UV Manipulation)]
        [Space(10)]
        _UV_Offset_X ("UV Offset X", Float) = 0
        _UV_Offset_Y ("UV Offset Y", Float) = 0
        _UV_Scale_X ("UV Scale X", Float) = 1
        _UV_Scale_Y ("UV Scale Y", Float) = 1
        _UV_Rotation ("UV Rotation", Range(0, 360)) = 0

        // UV EFFECTS

        // VERTEX MANIPULATION

        // VERTEX EFFECTS

        // EMISSION
        [Space(35)]
        [Header(Emission)]
        [Space(10)]
        [Toggle(_BACKLACE_EMISSION)] _ToggleEmission ("Enable Emission", Float) = 0.0
        [HDR] _EmissionColor ("Emission Color", Color) = (0, 0, 0, 1)
        _EmissionMap ("Emission Map (Mask)", 2D) = "black" { }
        [IntRange] _UseAlbedoAsEmission ("Use Albedo for Emission", Range(0, 1)) = 0.0
        _EmissionStrength ("Emission Strength", Float) = 1.0

        // LIGHT LIMITING
        [Space(35)]
        [Header(Light Limiting)]
        [Space(10)]
        [IntRange] _EnableBaseLightLimit ("Enable Base Pass Limit", Range(0, 1)) = 0.0
        _BaseLightMin ("Base Light Min", Float) = 0.0
        _BaseLightMax ("Base Light Max", Float) = 2.0
        [IntRange] _EnableAddLightLimit ("Enable Add Pass Limit", Range(0, 1)) = 0.0
        _AddLightMin ("Add Light Min", Float) = 0.0
        _AddLightMax ("Add Light Max", Float) = 2.0
        _GreyscaleLighting ("Greyscale Lighting", Range(0, 1)) = 0.0
        _ForceLightColor ("Force Light Color", Range(0, 1)) = 0.0
        _ForcedLightColor ("Forced Light Color", Color) = (1, 1, 1, 1)

        // LIGHTING MODELS
        [Space(35)]
        [Header(Lighting Model)]
        [Space(10)]
        [Enum(Backlace, 0, PoiCustom, 1, OpenLit, 2, Standard, 3, Mochie, 4)] _LightingColorMode ("Light Color Mode", Int) = 0
        [Enum(Backlace, 0, Forced World Direction, 1, View Direction, 2)] _LightingDirectionMode ("Light Direction Mode", Int) = 0
        _ForcedLightDirection ("Forced Light Direction", Vector) = (0.0, 1.0, 0.0, 0.0)
        _ViewDirectionOffsetX ("View Direction Offset X", Float) = 0.0
        _ViewDirectionOffsetY ("View Direction Offset Y", Float) = 0.0

        // TOON LIGHTING
        [Space(35)]
        [Header(Toon Lighting)]
        [Space(10)]
        [Toggle(_BACKLACE_TOON)] _ToggleToonLighting ("Enable Toon Lighting", Float) = 0.0
        [KeywordEnum(Ramp, Anime)] _ToonMode ("Toon Mode", Int) = 0
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
        [Enum(Disabled, 0, Enabled, 1)] _ToggleAnimeAmbientGradient ("Enable Ambient Gradient", Float) = 0.0
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
        [Space(35)]
        [Header(Specular)]
        [Space(10)]
        [Toggle(_BACKLACE_SPECULAR)] _ToggleSpecular ("Enable Specular", Float) = 0.0
        [Toggle(_BACKLACE_VERTEX_SPECULAR)] _ToggleVertexSpecular ("Enable Vertex Specular", Float) = 0.0
        [KeywordEnum(Standard, Anisotropic, Toon, Hair, Cloth)] _SpecularMode ("Specular Mode", Float) = 0
        _MSSO ("MSSO", 2D) = "white" { }
        _Metallic ("Metallic", Range(0, 1)) = 0
        _Glossiness ("Glossiness", Range(0, 1)) = 0
        _Occlusion ("Occlusion", Range(0, 1)) = 1
        _Specular ("Specular", Range(0, 1)) = 0.5
        _SpecularTintTexture ("Specular Tint Texture", 2D) = "white" { }
        _SpecularTint ("Specular Tint", Color) = (1, 1, 1, 1)
        _TangentMap ("Tangent Map", 2D) = "white" { }
        _Anisotropy ("Ansotropy", Range(-1, 1)) = 0
        _ReplaceSpecular ("Replace Specular", Float) = 0
        // toon highlights
        _HighlightRamp ("Highlight Ramp", 2D) = "white" { }
        _HighlightRampColor ("Highlight Color", Color) = (1, 1, 1, 1)
        _HighlightIntensity ("Highlight Intensity", Float) = 1.0
        _HighlightRampOffset ("Highlight Ramp Offset", Range(-1, 1)) = 0.0
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
        [Space(35)]
        [Header(Rim Lighting)]
        [Space(10)]
        [Toggle(_BACKLACE_RIMLIGHT)] _ToggleRimlight ("Enable Rim Lighting", Float) = 0.0
        [HDR] _RimColor ("Rim Color", Color) = (1, 1, 1, 1)
        _RimWidth ("Rim Width", Range(20, 0.1)) = 2.5
        _RimIntensity ("Rim Intensity", Float) = 1.0
        [IntRange] _RimLightBased ("Light-Based Rim", Range(0, 1)) = 0.0

        // CLEARCOAT
        [Space(35)]
        [Header(Clear Coat)]
        [Space(10)]
        [Toggle(_BACKLACE_CLEARCOAT)] _ToggleClearcoat ("Enable Clear Coat", Float) = 0.0
        _ClearcoatStrength ("Strength", Range(0, 1)) = 1.0
        _ClearcoatReflectionStrength ("Reflection Strength", Range(0, 2)) = 1.0
        [NoScaleOffset] _ClearcoatMap ("Mask (R=Strength, G=Roughness)", 2D) = "white" { }
        _ClearcoatRoughness ("Roughness", Range(0, 1)) = 0.1
        _ClearcoatColor ("Color", Color) = (1, 1, 1, 1)

        // MATCAP
        [Space(35)]
        [Header(Matcap)]
        [Space(10)]
        [Toggle(_BACKLACE_MATCAP)] _ToggleMatcap ("Enable Matcap", Float) = 0.0
        [NoScaleOffset] _MatcapTex ("Matcap Texture", 2D) = "white" { }
        [HDR] _MatcapTint ("Matcap Tint", Color) = (1, 1, 1, 1)
        _MatcapIntensity ("Matcap Intensity", Range(0, 2)) = 1.0
        [Enum(Additive, 0, Multiply, 1, Replace, 2)] _MatcapBlendMode ("Blend Mode", Int) = 0
        [NoScaleOffset] _MatcapMask ("Matcap Mask (R)", 2D) = "white" { }
        [Enum(OFF, 0, ON, 1)] _MatcapSmoothnessEnabled ("Enable Smoothness", Float) = 0.0
        _MatcapSmoothness ("Smoothness", Range(0, 1)) = 0.0

        // CUBEMAP
        [Space(35)]
        [Header(Cubemap)]
        [Space(10)]
        [Toggle(_BACKLACE_CUBEMAP)] _ToggleCubemap ("Enable Cubemap", Float) = 0.0
        [NoScaleOffset] _CubemapTex ("Cubemap", Cube) = "" { }
        [HDR] _CubemapTint ("Cubemap Tint", Color) = (1, 1, 1, 1)
        _CubemapIntensity ("Cubemap Intensity", Range(0, 2)) = 1.0
        [Enum(Additive, 0, Multiply, 1, Replace, 2)] _CubemapBlendMode ("Blend Mode", Int) = 0

        // PARALLAX MAPPING
        [Space(35)]
        [Header(Parallax Mapping)]
        [Space(10)]
        [Toggle(_BACKLACE_PARALLAX)] _ToggleParallax ("Enable Parallax Mapping", Float) = 0.0
        [Enum(Fast, 0, Fancy, 1)] _ParallaxMode ("Parallax Mode", Int) = 0
        [NoScaleOffset] _ParallaxMap ("Height Map (R)", 2D) = "black" { }
        _ParallaxStrength ("Parallax Strength", Range(0, 0.1)) = 0.02
        _ParallaxSteps ("High Quality Steps", Range(4, 64)) = 16
        [Toggle(_BACKLACE_PARALLAX_SHADOWS)] _ToggleParallaxShadows ("Enable Self-Shadowing", Float) = 0.0
        _ParallaxShadowSteps ("Shadow Quality Steps", Range(2, 16)) = 8
        _ParallaxShadowStrength ("Shadow Strength", Range(0, 1)) = 0.75 

        // SUBSURFACE SCATTERING
        [Space(35)]
        [Header(Subsurface Scattering)]
        [Space(10)]
        [Toggle(_BACKLACE_SSS)] _ToggleSSS ("Enable Subsurface Scattering", Float) = 0.0
        [NoScaleOffset] _ThicknessMap ("Thickness Map (R)", 2D) = "white" { }
        [HDR] _SSSColor ("Scattering Tint", Color) = (1, 1, 1, 1)
        _SSSStrength ("Strength", Range(0, 2)) = 1.0
        _SSSDistortion ("Distortion", Range(0, 1)) = 0.5
        _SSSSpread ("Spread", Range(16, 0.01)) = 2.0
        _SSSBaseColorMix ("Mix With Albedo", Range(0, 1)) = 0.0

        // DETAIL MAPPING
        [Space(35)]
        [Header(Detail Mapping)]
        [Space(10)]
        [Toggle(_BACKLACE_DETAIL)] _ToggleDetail ("Enable Detail Maps", Float) = 0.0
        [NoScaleOffset] _DetailAlbedoMap ("Detail Albedo (A=Strength)", 2D) = "gray" { }
        [NoScaleOffset] _DetailNormalMap ("Detail Normal Map", 2D) = "bump" { }
        _DetailTiling ("Detail Tiling", Float) = 16
        _DetailNormalStrength ("Detail Normal Strength", Range(0, 2)) = 1.0

        // DECAL 1
        [Space(35)]
        [Header(Decal 1)]
        [Space(10)]
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

        // DECAL 2
        [Space(35)]
        [Header(Decal 2)]
        [Space(10)]
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

        // POST-PROCESSING
        [Space(35)]
        [Header(Post Processing)]
        [Space(10)]
        [Toggle(_BACKLACE_POST_PROCESSING)] _TogglePostProcessing ("Enable Post Processing", Float) = 0.0
        [HDR] _RGBColor ("RGB Tint", Color) = (1, 1, 1, 1)
        _RGBBlendMode ("RGB Multiply/Replace", Range(0, 1)) = 0.0
        [Enum(Additive, 0, Multiply, 1)] _HSVMode ("HSV Mode", Float) = 0.0
        _HSVHue ("Hue", Range(-1, 1)) = 0.0
        _HSVSaturation ("Saturation", Float) = 1.0
        _HSVValue ("Value (Brightness)", Float) = 1.0
        [Enum(Disabled, 0, Enabled, 1)] _ToggleHueShift ("Enable Hue Shift", Range(0, 1)) = 0.0
        _HueShift ("Hue Shift", Range(-1, 1)) = 0.0
        [Enum(Disabled, 0, Enabled, 1)] _ToggleAutoCycle ("Enable Auto Cycle Hue", Float) = 0.0
        _AutoCycleSpeed ("Auto Cycle Speed", Float) = 0.1
        [NoScaleOffset] _ColorGradingLUT ("Color Grading LUT", 2D) = "white" { }
        _ColorGradingIntensity ("Grading Intensity", Range(0, 1)) = 1.0
        _BlackAndWhite ("Black and White", Range(0, 1)) = 0.0
        _Brightness ("Brightness", Range(0, 2)) = 1.0

        // GLITTER
        [Space(35)]
        [Header(Glitter)]
        [Space(10)]
        [Toggle(_BACKLACE_GLITTER)] _ToggleGlitter ("Enable Glitter", Float) = 0.0
        [Enum(Procedural, 0, Texture, 1)] _GlitterMode ("Mode", Range(0, 1)) = 0.0
        [NoScaleOffset] _GlitterNoiseTex ("Noise Texture (R)", 2D) = "gray" { }
        [NoScaleOffset] _GlitterMask ("Mask (R)", 2D) = "white" { }
        _GlitterTint ("Tint", Color) = (1, 1, 1, 1)
        _GlitterFrequency ("Density", Float) = 50.0
        _GlitterThreshold ("Density Threshold", Range(0.01, 1.0)) = 0.5
        _GlitterSize ("Size", Range(0.01, 0.5)) = 0.1
        _GlitterFlickerSpeed ("Flicker Speed", Float) = 1.0
        _GlitterBrightness ("Brightness", Float) = 2.0
        _GlitterContrast ("Contrast", Range(1, 256)) = 128.0
        _ToggleGlitterRainbow ("Enable Rainbow", Range(0, 1)) = 0.0
        _GlitterRainbowSpeed ("Rainbow Speed", Float) = 0.1

        // DISTANCE FADING
        [Space(35)]
        [Header(Distance Fading)]
        [Space(10)]
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
        [Space(35)]
        [Header(Iridescence)]
        [Space(10)]
        [Toggle(_BACKLACE_IRIDESCENCE)] _ToggleIridescence ("Enable Iridescence", Float) = 0.0
        [KeywordEnum(Texture, Procedural)] _IridescenceMode ("Mode", Int) = 0
        [NoScaleOffset] _IridescenceMask ("Mask (R)", 2D) = "white" { }
        [HDR] _IridescenceTint ("Tint", Color) = (1, 1, 1, 1)
        _IridescenceIntensity ("Intensity", Range(0, 5)) = 1.0
        [Enum(Additive, 0, Screen, 1, Alpha Blend, 2)] _IridescenceBlendMode ("Blend Mode", Int) = 0
        _IridescenceParallax ("View Parallax", Range(0, 1)) = 0.5
        [NoScaleOffset] _IridescenceRamp ("Color Ramp", 2D) = "white" { }
        _IridescencePower ("Ramp Power", Range(0.1, 10)) = 1.0
        _IridescenceFrequency ("Rainbow Frequency", Range(0.1, 20)) = 5.0

        // INDIRECT LIGHTING
        [Space(35)]
        [Header(Indirect Lighting)]
        [Space(10)]
        _IndirectFallbackMode ("Indirect Fallback Mode", Float) = 0.0
        _IndirectOverride ("Indirect Override", Float) = 0.0
        _FallbackCubemap ("Fallback Cubemap", Cube) = "" { }

        // GEOMETRY EFFECTS
        [Space(35)]
        [Header(Geometry Effects)]
        [Space(10)]
        [Toggle(_BACKLACE_GEOMETRY_EFFECTS)] _ToggleGeometryEffects ("Enable Geometry Effects", Float) = 0.0

        // UV SETTINGS
        [Space(35)]
        [Header(UV Settings)]
        [Space(10)]
        _UVCount ("UV Count", Float) = 0.0
        _UV1Index ("UV1 Index", Float) = 0.0
        _MainTex_UV ("Main texture UV set", Float) = 0
        _BumpMap_UV ("Bump map UV set", Float) = 0
        _MSSO_UV ("MSSO UV set", Float) = 0
        _SpecularTintTexture_UV ("Specular Tint UV Set", Float) = 0
        _TangentMap_UV ("Tangent Map UV", Float) = 0
        _EmissionMap_UV ("Emission Map UV Set", Float) = 0
        _ClearcoatMap_UV ("Clear Coat Map UV Set", Float) = 0
        _MatcapMask_UV ("Clear Coat Map UV Set", Float) = 0
        _ParallaxMap_UV ("Height Map UV Set", Float) = 0
        _ThicknessMap_UV ("Thickness Map UV Set", Float) = 0
        _DetailMap_UV ("Detail Map UV Set", Float) = 0
        _Decal1_UV ("Deca; 1 UV Set", Float) = 0
        _Decal2_UV ("Decal 2 UV Set", Float) = 0
        _Glitter_UV ("Glitter UV Set", Float) = 0.0
        _IridescenceMask_UV ("Iridescence Mask UV Set", Float) = 0.0
        _GlitterMask_UV ("Glitter Mask UV Set", Float) = 0.0
        _HairFlowMap_UV ("Hair Flow Map UV Set", Float) = 0.0
        _FuzzMap_UV ("Fuzz Map UV Set", Float) = 0.0
        _ThreadMap_UV ("Thread Map UV Set", Float) = 0.0

        // DO NOT CHANGE
        [Space(35)]
        [Header(Do Not Change)]
        [Space(10)]
        [NonModifiableTextureData][NoScaleOffset] _DFG ("DFG Lut", 2D) = "black" { }
        [NonModifiableTextureData][NoScaleOffset] _DFGType ("Lighing Type", Float) = 0
        _StencilSection ("Stencil Section Display", Int) = 0
    }

    SubShader
    {

        // Rendering Settings
        // Tags { "RenderType"="Transparent" "Queue"="Transparent" }
        Tags { "RenderType" = "TransparentCutout" "Queue" = "AlphaTest" }
        Blend [_SrcBlend] [_DstBlend]
        ZWrite [_ZWrite]
        Cull [_Cull]
        Stencil
        {
            Ref [_StencilID]
            Comp [_StencilComp]
            Pass [_StencilOp]
        }

        // Forward Base Pass
        Pass
        {  
            Tags { "LightMode" = "ForwardBase" }
            CGPROGRAM
            #ifndef UNITY_PASS_FORWARDBASE
                #define UNITY_PASS_FORWARDBASE
            #endif // UNITY_PASS_FORWARDBASE
            #include "Resources/Luka_Backlace/Includes/Backlace_Forward.cginc"
            ENDCG
        }
          
        // Forward Add Pass
        Pass
        {
            Tags { "LightMode" = "ForwardAdd" }
            Blend [_SrcBlend] One // make it, well, *additive
            Fog { Color(0, 0, 0, 0) } // additive should have black fog
            ZWrite Off
            CGPROGRAM
            #ifndef UNITY_PASS_FORWARDADD
                #define UNITY_PASS_FORWARDADD
            #endif // UNITY_PASS_FORWARDADD
            #include "Resources/Luka_Backlace/Includes/Backlace_Forward.cginc"
            ENDCG
        }

        // Shadow Pass
        Pass
        {
            Tags { "LightMode" = "ShadowCaster" }
            ZWrite On 
            ZTest LEqual
            CGPROGRAM
            #ifndef UNITY_PASS_SHADOWCASTER
                #define UNITY_PASS_SHADOWCASTER
            #endif // UNITY_PASS_SHADOWCASTER
            #include "Resources/Luka_Backlace/Includes/Backlace_Shadow.cginc"
            ENDCG
        }
        
        // Meta Pass
        Pass
        {
            Tags { "LightMode" = "Meta" }
            Cull Off
            CGPROGRAM
            #ifndef UNITY_PASS_META
                #define UNITY_PASS_META
            #endif // UNITY_PASS_META
            #include "Resources/Luka_Backlace/Includes/Backlace_Meta.cginc"
            ENDCG
        }

    }

}