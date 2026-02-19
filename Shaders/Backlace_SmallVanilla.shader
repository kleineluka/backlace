Shader "luka/backlace/small/vanilla"
{

    Properties
    {
        // RENDERING SETTINGS
        // [Space(35)]
        // [Header(Rendering Settings)]
        // [Space(10)]
        _BlendMode ("Rendering Mode", Int) = 0
        [Toggle] _OverrideBaseBlend ("Override Base Blend", Float) = 0
        [Enum(UnityEngine.Rendering.BlendMode)] _SrcBlend ("Src Blend", Float) = 1
        [Enum(UnityEngine.Rendering.BlendMode)] _DstBlend ("Dst Blend", Float) = 0
        [Enum(UnityEngine.Rendering.BlendOp)] _BlendOp ("Blend Operation", Float) = 0
        [Toggle] _OverrideAddBlend ("Override Additive Blend", Float) = 0
        [Enum(UnityEngine.Rendering.BlendMode)] _AddSrcBlend ("Additive Src Blend", Float) = 1
        [Enum(UnityEngine.Rendering.BlendMode)] _AddDstBlend ("Additive Dst Blend", Float) = 1
        [Enum(UnityEngine.Rendering.BlendOp)] _AddBlendOp ("Additive Blend Operation", Float) = 0
        [Toggle] _OverrideZWrite ("Override ZWrite", Float) = 0
        [Enum(Off, 0, On, 1)] _ZWrite ("ZWrite", Float) = 1
        [Toggle] _OverrideRenderQueue ("Override Render Queue", Float) = 0
        [Enum(UnityEngine.Rendering.CullMode)] _Cull ("Cull Mode", Int) = 2
        [Enum(UnityEngine.Rendering.CompareFunction)] _ZTest ("ZTest", Int) = 4
        [IntRange] _StencilRef ("Stencil Reference", Range(0, 255)) = 0
        [Enum(UnityEngine.Rendering.CompareFunction)] _StencilComp ("Stencil Comparison", Int) = 8 // Always
        [Enum(UnityEngine.Rendering.StencilOp)] _StencilPass ("Stencil Pass Op", Int) = 0 // Keep
        [Enum(UnityEngine.Rendering.StencilOp)] _StencilFail ("Stencil Fail Op", Int) = 0 // Keep
        [Enum(UnityEngine.Rendering.StencilOp)] _StencilZFail ("Stencil ZFail Op", Int) = 0 // Keep
        [Enum(Toon, 0, Double Sided, 1, Unlit, 2, Particle, 3, Matcap, 4, Sprite, 5, Hidden, 6)] _VRCFallback ("VRChat Fallback", Int) = 0
        [Enum(Disabled, 0, Enabled, 1)] _ToggleFlipNormals ("Flip Backface Normals", Int) = 0

        // MAIN MAPS AND ALPHA
        // [Space(35)]
        // [Header(Main Maps and Alpha)]
        // [Space(10)]
        _MainTex ("Main texture", 2D) = "white" { }
        _Color ("Albedo color", Color) = (1, 1, 1, 1)
        _Cutoff ("Alpha Cutoff", Range(0, 1)) = 0.5
        [Enum(Disabled, 0, Enabled, 1)] _UseBump ("Enable Normal Map", Int) = 0
        _BumpMap ("Normal map", 2D) = "bump" { }
        _BumpScale ("Normal map scale", Float) = 1
        [Enum(Disabled, 0, Enabled, 1)] _BumpFromAlbedo ("Derive Normals", Int) = 0
        _BumpFromAlbedoOffset ("Derived Offset", Float) = 1
        _Alpha ("Alpha", Range(0, 1)) = 1.0

        // TEXTURE STITCHING
        // [Space(35)]
        // [Header(Texture Stitching)]
        // [Space(10)]
        [Enum(Disabled, 0, Enabled, 1)] _UseTextureStitching ("Enable Texture Stitching", Int) = 0
        [NoScaleOffset] _StitchTex ("Stitch Texture (RGB)", 2D) = "white" { }
        [Enum(X Axis, 0, Y Axis, 1, Z Axis, 2)] _StitchAxis ("Stitch Axis", Int) = 0
        _StitchOffset ("Stitch Seam Offset", Float) = 0

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
        _UVTriplanarSharpness ("Triplanar Blend Sharpness", Range(0.01, 10)) = 2.0
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
        [Enum(Disabled, 0, LUT, 1, ACES, 2, GT, 3, Lit Colour Wheel, 4)] _ColorGradingMode ("Colour Grading Mode", Int) = 0
        [NoScaleOffset] _ColorGradingLUT ("Colour Grading LUT", 2D) = "white" { }
        _ColorGradingIntensity ("Grading Intensity", Range(0, 1)) = 0.0
        _GTShadows ("Black Tightness", Range(1, 2)) = 1.33
        _GTHighlights ("Highlight Roll-off", Range(0.1, 1)) = 1.0
        _LCWLift ("LCW Lift", Color) = (0, 0, 0, 0)
        _LCWGamma ("LCW Gamma", Color) = (1, 1, 1, 1)
        _LCWGain ("LCW Gain", Color) = (1, 1, 1, 1)
        _BlackAndWhite ("Black and White", Range(0, 1)) = 0.0
        _Brightness ("Brightness", Range(0, 2)) = 1.0

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
        [Enum(Zero, 0, One, 1, Two, 2, Three, 3)] _Decal1_UV ("Decal 1 UV Set", Int) = 0
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
        [Enum(Zero, 0, One, 1, Two, 2, Three, 3)] _StitchTex_UV ("Stitch Texture UV Set", Int) = 0
        [Enum(Zero, 0, One, 1, Two, 2, Three, 3)] _SDFShadowTexture_UV ("SDF Shadow UV Set", Int) = 0
        [Enum(Zero, 0, One, 1, Two, 2, Three, 3)] _StockingsMap_UV ("Stockings Map UV Set", Int) = 0
        [Enum(Zero, 0, One, 1, Two, 2, Three, 3)] _EyeParallaxIrisTex_UV ("Eye Parallax Iris UV Set", Int) = 0
        [Enum(Zero, 0, One, 1, Two, 2, Three, 3)] _EyeParallaxEyeMaskTex_UV ("Eye Parallax Mask UV Set", Int) = 0
        [Enum(Zero, 0, One, 1, Two, 2, Three, 3)] _HairMaskTex_UV ("Hair Mask UV Set", Int) = 0
        [Enum(Zero, 0, One, 1, Two, 2, Three, 3)] _ExpressionMap_UV ("Expression Map UV Set", Int) = 0
        [Enum(Zero, 0, One, 1, Two, 2, Three, 3)] _FaceMap_UV ("Face Map UV Set", Int) = 0
        [Enum(Zero, 0, One, 1, Two, 2, Three, 3)] _NPRSpecularMask_UV ("NPR Specular Mask UV Set", Int) = 0
        [Enum(Zero, 0, One, 1, Two, 2, Three, 3)] _PackedMapOne_UV ("Packed Map One UV Set", Int) = 0
        [Enum(Zero, 0, One, 1, Two, 2, Three, 3)] _PackedMapTwo_UV ("Packed Map Two UV Set", Int) = 0
        [Enum(Zero, 0, One, 1, Two, 2, Three, 3)] _PackedMapThree_UV ("Packed Map Three UV Set", Int) = 0
        [Enum(Zero, 0, One, 1, Two, 2, Three, 3)] _SkinLUT_UV ("Skin LUT UV Set", Int) = 0

        // LIGHTING MODELS
        // [Space(35)]
        // [Header(Lighting Model)]
        // [Space(10)]
        [Enum(Backlace, 0, PoiCustom, 1, OpenLit, 2, Standard, 3, Mochie, 4)] _LightingColorMode ("Light Color Mode", Int) = 0
        [Enum(Backlace, 0, Forced World Direction, 1, View Direction, 2, Object Relative, 3, Ambient Priority, 4)] _LightingDirectionMode ("Light Direction Mode", Int) = 0
        [Enum(Backlace, 0, Unity, 1)] _LightingSource ("Lighting Source", Int) = 0
        [Enum(Mix, 0, Stack, 1)] _IndirectAlbedo ("Indirect Albedo", Int) = 1
        [Enum(Natural, 0, Stylised, 1)] _DirectDiffuse ("Direct Diffuse", Int) = 1
        [Enum(Natural, 0, Stylised, 1)] _IndirectDiffuse ("Indirect Diffuse", Int) = 0
        [Enum(Disabled, 0, Enabled, 1)] _DirectionalAmbience ("Directional Ambience", Int) = 1
        [Enum(Disabled, 0, Enabled, 1)] _IndirectAdditive ("Indirect Additive", Int) = 0
        _ForcedLightDirection ("Forced Light Direction", Vector) = (0.0, 1.0, 0.0, 0.0)
        _ViewDirectionOffsetX ("View Direction Offset X", Float) = 0.0
        _ViewDirectionOffsetY ("View Direction Offset Y", Float) = 0.0
        _DirectIntensity ("RT Direct Intensity", Float) = 1.0
        _IndirectIntensity ("RT Indirect Intensity", Float) = 1.0
        _VertexIntensity ("RT Vertex Intensity", Float) = 1.0
        _AdditiveIntensity ("RT Additive Intensity", Float) = 1.0
        _BakedDirectIntensity ("Baked Direct Intensity", Float) = 1.0
        _BakedIndirectIntensity ("Baked Indirect Intensity", Float) = 1.0
        [Enum(Disabled, 0, Enabled, 1)] _IndirectOverride ("Indirect Override", Float) = 0.0
        [Enum(Disabled, 0, Cubemap, 1)] _IndirectFallbackMode ("Indirect Fallback Mode", Float) = 0.0
        _FallbackCubemap ("Fallback Cubemap", Cube) = "" { }

        // EMISSION
        // [Space(35)]
        // [Header(Emission)]
        // [Space(10)]
        [Toggle(_BACKLACE_EMISSION)] _ToggleEmission ("Enable Emission", Float) = 0.0
        [HDR] _EmissionColor ("Emission Color", Color) = (0, 0, 0, 1)
        _EmissionMap ("Emission Map (Mask)", 2D) = "black" { }
        [IntRange] _UseAlbedoAsEmission ("Use Albedo for Emission", Range(0, 1)) = 0.0
        _EmissionStrength ("Emission Strength", Float) = 1.0

        // ATTENUATION
        // [Space(35)]
        // [Header(Light Attenuation)]
        // [Space(10)]
        _AttenuationOverride ("Override Attenuation", Range(0, 1)) = 0
        _AttenuationManual ("Manual Attenuation", Float) = 1.0
        _AttenuationMin ("Attenuation Min", Float) = -100
        _AttenuationMax ("Attenuation Max", Float) = 100
        _AttenuationMultiplier ("Attenuation Multiplier", Float) = 1.0
        _AttenuationBoost ("Attenuation Boost", Float) = 0.0
        [Enum(Disabled, 0, Enabled, 1)] _AttenuationShaded ("Shaded Attenuation", Int) = 0

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

        // SHADING
        // [Space(35)]
        // [Header(Shading)]
        // [Space(10)]
        [KeywordEnum(PBR, Ramp, Cel, NPR, Packed, TriBand, Skin, Wrapped)] _AnimeMode ("Anime Mode", Int) = 1
        // ramp
        [Enum(Texture, 0, Procedural, 1)] _RampMode ("Ramp Mode", Int) = 0
        _Ramp ("Ramp Map", 2D) = "white" { }
        _RampColor ("Ramp Color", Color) = (1, 1, 1, 1)
        _RampOffset ("Ramp Offset", Range(-1, 1)) = 0
        _RampShadows ("Ramp Shadow intensity", Range(0, 1)) = 0.6
        _RampOcclusionOffset ("Ramp Occlusion Offset Intensity", Range(0, 1)) = 0
        _RampMin ("Ramp Min", Color) = (0.003921569, 0.003921569, 0.003921569, 0.003921569)
        _RampProceduralShift ("Ramp Shift", Range(-1, 1)) = 0
        _RampProceduralToony ("Ramp Toony Factor", Range(0, 1)) = 0.9
        [Enum(Disabled, 0, Enabled, 1)] _RampNormalIntensity ("Ramp Normals to Intensity", Float) = 0
        [IntRange] _RampIndex ("Ramp Index", Range(0, 9)) = 0
        [IntRange] _RampTotal ("Ramp Total", Range(1, 10)) = 1
        // cel
        [Enum(Default, 0, Harsh, 1, Smooth, 2)] _CelMode ("Cel Shading Mode", Int) = 0
        _CelThreshold ("Cel Threshold", Range(-1, 1)) = 0
        _CelFeather ("Cel Feather", Range(0.001, 1)) = 0.05
        _CelCastShadowFeather ("Cast Shadow Feather", Range(0.001, 1)) = 0.1
        _CelCastShadowPower ("Cast Shadow Power", Range(0, 1)) = 1.0
        [HDR] _CelShadowTint ("Cel Shadow Tint", Color) = (0.7, 0.7, 0.8, 1)
        [HDR] _CelLitTint ("Cel Lit Tint", Color) = (1.0, 1.0, 1.0, 1)
        _CelSmoothGradientPower ("Cel Gradient Power", Range(0.1, 4)) = 1.0
        _CelSmoothOcclusionStrength ("Cel Occlusion Strength", Range(0, 1)) = 0.5
        // npr
        _NPRDiffMin ("NPR Diffuse SmoothStep Min", Range(0, 2)) = 0.0
        _NPRDiffMax ("NPR Diffuse SmoothStep Max", Range(0, 2)) = 1.0
        _NPRLitColor ("NPR Lit Color", Color) = (1, 1, 1, 1)
        _NPRShadowColor ("NPR Shadow Color", Color) = (0.3, 0.3, 0.3, 1)
        // npr - shared specular
        _NPRSpecularMask ("NPR Specular Mask", 2D) = "white" { }
        // npr - forward specular
        [Enum(Disabled, 0, Enabled, 1)] _NPRForwardSpecular ("Enable NPR Forward Specular", Int) = 1
        _NPRForwardSpecularRange ("NPR Forward Specular Range", Range(0, 1)) = 0.5
        _NPRForwardSpecularMultiplier ("NPR Forward Specular Multiplier", Float) = 5.0
        _NPRForwardSpecularColor ("NPR Forward Specular Color", Color) = (1, 1, 1, 1)
        // npr - bling phong specular
        [Enum(Disabled, 0, Enabled, 1)] _NPRBlinn ("Enable NPR Phong Specular", Int) = 1
        _NPRBlinnPower ("NPR Phong Specular Power", Float) = 10
        _NPRBlinnMin ("NPR Phong Specular Min", Range(0, 2)) = 0.0
        _NPRBlinnMax ("NPR Phong Specular Max", Range(0, 2)) = 1.0
        _NPRBlinnColor ("NPR Phong Specular Color", Color) = (1, 1, 1, 1)
        _NPRBlinnMultiplier ("NPR Phong Specular Multiplier", Float) = 5.0
        // npr - fake sss
        [Enum(Disabled, 0, Enabled, 1)] _NPRSSS ("Enable NPR SSS", Int) = 1
        _NPRSSSExp ("NPR SSS Exponent", Float) = 5.0
        _NPRSSSRef ("NPR SSS Reflectance", Range(0, 0.5)) = 0.04
        _NPRSSSMin ("NPR SSS Min", Range(0, 1)) = 0.0
        _NPRSSSMax ("NPR SSS Max", Range(0, 1)) = 1.0
        _NPRSSSShadows ("NPR SSS Shadow Strength", Range(0, 1)) = 0.5
        _NPRSSSColor ("NPR SSS Color", Color) = (1, 0.8, 0.7, 1)
        // npr - rim lighting
        [Enum(Disabled, 0, Enabled, 1)] _NPRRim ("Enable NPR Rim Lighting", Int) = 1
        _NPRRimExp ("NPR Rim Power", Float) = 10
        _NPRRimMin ("NPR Rim Min", Range(0, 2)) = 0.0
        _NPRRimMax ("NPR Rim Max", Range(0, 2)) = 1.0
        _NPRRimColor ("NPR Rim Color", Color) = (1, 1, 1, 1)
        // packed map
        [Enum(Genshin, 0, UmaMusume, 1, GuiltyGear, 2)] _PackedMapStyle ("Packed Map Style", Int) = 0
        _PackedMapOne ("Packed Map One", 2D) = "white" { }
        _PackedMapTwo ("Packed Map Two", 2D) = "white" { }
        _PackedMapThree ("Packed Map Three", 2D) = "white" { }
        _PackedLitColor ("Packed Lit Color", Color) = (1.0, 1.0, 1.0, 1)
        _PackedShadowColor ("Packed Shadow Color", Color) = (0.7, 0.7, 0.8, 1)
        _PackedShadowSmoothness ("Packed Shadow Smoothness", Range(0.001, 0.5)) = 0.05
        [Enum(Disabled, 0, Enabled, 1)] _PackedRimLight ("Enable Rimlight", Int) = 1
        _PackedRimColor ("Packed Rim Color", Color) = (1, 1, 1, 1)
        _PackedRimThreshold ("Packed Rim Threshold", Range(-1, 1)) = 0.5
        _PackedRimPower ("Packed Rim Power", Range(0, 5)) = 1
        [Enum(Disabled, 0, Enabled, 1)] _PackedMapMetals ("Enable Metals", Int) = 0
        _PackedAmbient ("Ambient Lights", Range(0, 1)) = 0.5
        // packed map - umamusume specific
        _PackedUmaSpecularBoost ("UmaMusume Specular Boost", Range(0, 100)) = 20
        _PackedUmaMetalDark ("UmaMusume Metal Dark Colour", Color) = (0.2, 0.2, 0.2, 1)
        _PackedUmaMetalLight ("UmaMusume Metal Light Colour", Color) = (1.0, 1.0, 1.0, 1)
        // packed map - guilty gear specific
        _PackedGGSpecularSize ("GG Specular Size", Range(0, 1)) = 0.2
        _PackedGGSpecularIntensity ("GG Specular Intensity", Float) = 1.0
        _PackedGGSpecularTint ("GG Specular Tint", Color) = (1, 1, 1, 1)
        _PackedGGShadow1Push ("GG Shadow 1 Push", Range(-1, 1)) = 0.5
        _PackedGGShadow1Smoothness ("GG Shadow 1 Smoothness", Range(0, 1)) = 0.0
        _PackedGGShadow2Push ("GG Shadow 2 Push", Range(-1, 1)) = -1.0
        _PackedGGShadow2Smoothness ("GG Shadow 2 Smoothness", Range(0, 1)) = 0.0
        _PackedGGShadow1Tint ("GG Shadow 1 Tint", Color) = (1, 1, 1, 1)
        _PackedGGShadow2Tint ("GG Shadow 2 Tint", Color) = (1, 1, 1, 1)
        // tri band
        _TriBandSmoothness ("TriBand Shadow Smoothness", Range(0.001, 0.5)) = 0.05
        _TriBandThreshold ("TriBand Shadow Threshold", Range(-1, 1)) = 0.0
        _TriBandShallowWidth ("TriBand Shallow Band Width", Range(0, 1)) = 0.25
        [HDR] _TriBandShadowColor ("TriBand Shadow Color", Color) = (0.6, 0.6, 0.6, 1)
        [HDR] _TriBandShallowColor ("TriBand Shallow (Transition) Color", Color) = (0.8, 0.8, 0.8, 1)
        [HDR] _TriBandLitColor ("TriBand Lit Color", Color) = (1.0, 1.0, 1.0, 1)
        _TriBandPostShadowTint ("TriBand Post Shadow Tint", Color) = (0.85, 0.78, 0.77, 1)
        _TriBandPostShallowTint ("TriBand Post Shallow Tint", Color) = (0.95, 0.96, 0.90, 1)
        _TriBandPostLitTint ("TriBand Post Lit/Front Tint", Color) = (1.0, 0.95, 0.93, 1)
        _TriBandAttenuatedShadows ("TriBand Attenuated Shadows", Range(0, 1)) = 0.0
        _TriBandIndirectShallow ("TriBand Indirect to Shallow Only", Range(0, 1)) = 0.0
        // skin
        _SkinLUT ("Skin LUT (RGB)", 2D) = "white" { }
        _SkinShadowColor ("Skin Shadow Color", Color) = (0.75, 0.65, 0.65, 1)
        _SkinScattering ("Skin Scattering", Range(0, 1)) = 0.5
        // wrapped
        _WrapFactor ("Wrap Factor", Range(0, 3)) = 0.5
        _WrapNormalization ("Wrap Normalization", Range(0, 2)) = 0.5
        _WrapColorHigh ("Wrap High Color", Color) = (1, 1, 1, 1)
        _WrapColorLow ("Wrap Low Color", Color) = (0, 0, 0, 1)

        // ANIME EXTRAS
        // [Space(35)]
        // [Header(Anime Extras)]
        // [Space(10)]
        // ambient gradient
        [Toggle(_BACKLACE_ANIME_EXTRAS)] _ToggleAnimeExtras ("Enable Anime Extras", Int) = 0
        [Enum(Disabled, 0, Enabled, 1)] _ToggleAmbientGradient ("Enable Ambient Gradient", Float) = 0.0
        _AnimeOcclusionToShadow ("Occlusion To Shadow", Range(0, 1)) = 0.5
        _AmbientUp ("Sky Ambient", Color) = (0.8, 0.8, 1, 1)
        _AmbientSkyThreshold ("Sky Threshold", Range(0, 1)) = 0.5
        _AmbientDown ("Ground Ambient", Color) = (1, 0.9, 0.8, 1)
        _AmbientGroundThreshold ("Ground Threshold", Range(0, 1)) = 0.5
        _AmbientIntensity ("Gradient Intensity", Range(0, 1)) = 0.25
        // manual normals
        [Enum(Disabled, 0, Enabled, 1)] _ToggleManualNormals ("Enable Manual Normals", Int) = 0.0
        [Enum(Disabled, 0, Preview X, 1, Preview Y, 2, Preview Z, 3, Preview XYZ, 4)] _ManualNormalPreview ("Manual Normal Preview", Int) = 0
        _ManualNormalOffset ("Manual Normal Offset", Vector) = (0, 0, 0, 0)
        _ManualNormalScale ("Manual Normal Scale", Vector) = (1, 1, 1, 0)
        _ManualApplication ("Manual Normal Application", Vector) = (1, 1, 1, 0)
        _ManualNormalSharpness ("Manual Normal Sharpness", Range(0.1, 5)) = 1.0
        // sdf shadow
        [Enum(Disabled, 0, Enabled, 1)] _ToggleSDFShadow ("Enable SDF Shadow", Float) = 0.0
        _SDFLocalForward ("Local Forward (e.g. 0,0,1)", Vector) = (0, 0, 1, 0)
        _SDFLocalRight ("Local Right (e.g. 1,0,0)", Vector) = (1, 0, 0, 0)
        _SDFShadowTexture ("SDF Shadow Texture", 2D) = "white" { }
        _SDFShadowThreshold ("SDF Shadow Threshold", Range(0, 1)) = 0.5
        _SDFShadowSoftness ("SDF Shadow Softness", Range(0.001, 1)) = 0.05
        // stocking feature
        [Enum(Disabled, 0, Enabled, 1)] _ToggleStockings ("Enable Stockings", Int) = 0
        _StockingsMap ("Stockings Map (R:Mask G:Light B:Rough)", 2D) = "white" { }
        _StockingsPower ("Stockings Power", Range(0.04, 1)) = 0.7
        _StockingsDarkWidth ("Stockings Dark Width", Range(0, 2)) = 0.5
        _StockingsLightedWidth ("Stockings Light Width", Range(0, 10)) = 1
        _StockingsLightedIntensity ("Stockings Light Intensity", Range(0, 1)) = 0.25
        _StockingsRoughness ("Stockings Roughness", Range(0, 1)) = 1
        _StockingsColor ("Stockings Colour", Color) = (1, 1, 1, 1)
        _StockingsColorDark ("Stockings Dark Colour", Color) = (0.5, 0.5, 0.5, 1)
        // parallax eye
        [Enum(Disabled, 0, Enabled, 1)] _ToggleEyeParallax ("Enable Eye Parallax", Int) = 0
        [NoScaleOffset] _EyeParallaxIrisTex ("Iris Texture", 2D) = "white" { }
        [NoScaleOffset] _EyeParallaxEyeMaskTex ("Eye Mask Texture (R=Mask)", 2D) = "white" { }
        _EyeParallaxStrength ("Eye Parallax Strength", Float) = 0.02
        _EyeParallaxClamp ("Eye Parallax Clamp", Float) = 0.1
        [Enum(Disabled, 0, Enabled, 1)] _ToggleEyeParallaxBreathing ("Enable Eye Parallax Breathing", Int) = 0
        _EyeParallaxBreathStrength ("Breathing Eye Parallax Strength", Range(0, 1)) = 0.01
        _EyeParallaxBreathSpeed ("Breathing Eye Parallax Speed", Float) = 1.0
        // translucent hair
        [Enum(Disabled, 0, Enabled, 1)] _ToggleHairTransparency ("Enable Hair Transparency", Int) = 0
        _HairHeadForward ("Head Forward Direction", Vector) = (0, 0, 1, 0)
        _HairHeadUp ("Head Up Direction", Vector) = (0, 1, 0, 0)
        _HairHeadRight ("Head Right Direction", Vector) = (1, 0, 0, 0)
        [PowerSlider(2.0)] _HairBlendAlpha ("Minimum Alpha", Range(0, 1)) = 0.5
        _HairTransparencyStrength ("Transparency Strength", Range(0, 1)) = 1.0
        // translucent hair - hair masking
        [Enum(Disabled, 0, SDF Volume, 1, Distance, 2, Texture Mask, 3)] _HairHeadMaskMode ("Head Mask Mode", Int) = 0
        [Enum(Disabled, 0, Enabled, 1)] _HairSDFPreview ("Enable SDF Preview", Int) = 0
        _HairHeadCenter ("Head Center Position (Local)", Vector) = (0, 0, 0, 0)
        _HairSDFScale ("SDF Head Scale (XYZ)", Vector) = (0.15, 0.2, 0.12, 0)
        _HairSDFSoftness ("SDF Softness", Float) = 0.05
        _HairSDFBlend ("SDF Blend", Range(0, 1)) = 0.8
        _HairDistanceFalloffStart ("Distance Falloff Start", Float) = 0.05
        _HairDistanceFalloffEnd ("Distance Falloff End", Float) = 0.15
        _HairDistanceFalloffStrength ("Distance Falloff Strength", Range(0, 1)) = 1
        [NoScaleOffset] _HairMaskTex ("Hair Mask Texture (R = Allow Transparency)", 2D) = "white" { }
        _HairMaskStrength ("Hair Mask Strength", Range(0, 1)) = 1
        [Enum(Disabled, 0, Enabled, 1)] _HairExtremeAngleGuard ("Guard Extreme Up/Down Angles", Int) = 0
        _HairAngleFadeStart ("Angle Guard Start (Degrees)", Float) = 55
        _HairAngleFadeEnd ("Angle Guard End (Degrees)", Float) = 75
        _HairAngleGuardStrength ("Angle Guard Strength", Range(0, 1)) = 1
        // expression map
        [Enum(Disabled, 0, Enabled, 1)] _ToggleExpressionMap ("Enable Expression Map", Int) = 0
        _ExpressionMap ("Expression Map (RGBA)", 2D) = "white" { }
        _ExCheekColor ("Cheek Color", Color) = (1, 0.6, 0.6, 1)
        _ExCheekIntensity ("Cheek Intensity", Range(0, 1)) = 1.0
        _ExShyColor ("Shy Color", Color) = (1, 0.6, 0.6, 1)
        _ExShyIntensity ("Shy Intensity", Range(0, 1)) = 1.0
        _ExShadowColor ("Shadow Tint Color", Color) = (0.9, 0.85, 1, 1)
        _ExShadowIntensity ("Shadow Tint Intensity", Range(0, 1)) = 1.0
        // face map
        [Enum(Disabled, 0, Enabled, 1)] _ToggleFaceMap ("Enable Face Map", Int) = 0
        _FaceHeadForward ("Face Head Forward (Local)", Vector) = (0, 0, 1, 0)
        _FaceMap ("Face Map (RGBA)", 2D) = "white" { }
        [Enum(Disabled, 0, Enabled, 1)] _ToggleNoseLine ("Enable Nose Line", Int) = 0
        _NoseLinePower ("Nose Line Power", Float) = 2.0
        _NoseLineColor ("Nose Line Color", Color) = (0.25, 0.25, 0.25, 1)
        [Enum(Disabled, 0, Enabled, 1)] _ToggleEyeShadow ("Enable Eye Shadow", Int) = 0
        _ExEyeColor ("Eye Shadow Color", Color) = (0.9, 0.6, 0.6, 1)
        _EyeShadowIntensity ("Eye Shadow Intensity", Range(0, 1)) = 1.0
        [Enum(Disabled, 0, Enabled, 1)] _ToggleLipOutline ("Enable Lip Outline", Int) = 0
        _LipOutlineColor ("Lip Outline Color", Color) = (0.6, 0.1, 0.1, 1)
        _LipOutlineIntensity ("Lip Outline Intensity", Range(0, 1)) = 1.0
        // anime gradient
        [Enum(Disabled, 0, Enabled, 1)] _ToggleAnimeGradient ("Enable Anime Gradient", Int) = 0
        [Enum(Replace, 0, Multiply, 1)] _AnimeGradientMode ("Gradient Mode", Int) = 0
        _AnimeGradientDirection ("Gradient Direction", Vector) = (0, 1, 0, 0)
        _AnimeGradientColourA ("Gradient Color A", Color) = (1, 1, 1, 1)
        _AnimeGradientColourB ("Gradient Color B", Color) = (0, 0, 0, 1)
        _AnimeGradientOffset ("Gradient Offset", Range(-1, 1)) = 0.0
        _AnimeGradientMultiplier ("Gradient Multiplier", Float) = 1.0
        // toon highlights
        [Enum(Disabled, 0, Enabled, 1)] _ToggleSpecularToon ("Enable Specular Toon Highlights", Int) = 0
        _SpecularToonShininess ("Specular Shininess", Range(1, 128)) = 32
        _SpecularToonRoughness ("Specular Roughness", Range(0, 0.5)) = 0.1
        _SpecularToonSharpness ("Specular Sharpness", Range(0, 1)) = 1.0
        _SpecularToonIntensity ("Specular Intensity", Float) = 1.0
        _SpecularToonThreshold ("Specular Threshold", Float) = 1.0
        [HDR] _SpecularToonColor ("Specular Color", Color) = (1, 1, 1, 1)
        [Enum(Disabled, 0, Enabled, 1)] _SpecularToonUseLighting ("Use Lighting", Int) = 0
        // angel rings
        [Enum(Disabled, 0, View Aligned, 1, UV Flow, 2)] _AngelRingMode ("Angel Ring Mode", Int) = 0
        _AngelRingSharpness ("Ring Sharpness", Range(1, 100)) = 20
        _AngelRingThreshold ("Ring Threshold", Range(0, 1)) = 0.5
        _AngelRingSoftness ("Ring Softness", Range(0, 0.5)) = 0.05
        _AngelRing1Position ("Primary Ring Position", Range(0, 1)) = 0.5
        _AngelRing1Width ("Primary Ring Width", Range(0.01, 0.5)) = 0.15
        _AngelRing1Color ("Primary Ring Colour", Color) = (1, 1, 1, 1)
        [Enum(Disabled, 0, Enabled, 1)] _UseSecondaryRing ("Enable Secondary Ring", Int) = 1
        _AngelRing2Position ("Secondary Ring Position", Range(0, 1)) = 0.7
        _AngelRing2Width ("Secondary Ring Width", Range(0.01, 0.5)) = 0.2
        [HDR] _AngelRing2Color ("Secondary Ring Colour", Color) = (0.8, 0.9, 1, 0.6)
        [Enum(Disabled, 0, Enabled, 1)] _UseTertiaryRing ("Enable Tertiary Ring", Int) = 0
        _AngelRing3Position ("Tertiary Ring Position", Range(0, 1)) = 0.3
        _AngelRing3Width ("Tertiary Ring Width", Range(0.01, 0.5)) = 0.1
        [HDR] _AngelRing3Color ("Tertiary Ring Colour", Color) = (1, 0.8, 0.8, 0.5)
        _AngelRingHeightDirection ("Height Direction", Vector) = (0, 1, 0, 0)
        _AngelRingHeightScale ("Height Scale", Float) = 1.0
        _AngelRingHeightOffset ("Height Offset", Float) = 0.0
        [Enum(Add, 0, Screen, 1, Multiply, 2)] _AngelRingBlendMode ("Composite Blend Mode", Int) = 0
        _AngelRingManualOffset ("Manual Offset", Float) = 0
        _AngelRingManualScale ("Manual Scale", Float) = 0
        [Enum(Disabled, 0, Uniform, 1, Random, 2)] _AngelRingBreakup ("Ring Breakup", Int) = 0
        _AngelRingBreakupDensity ("Breakup Density", Float) = 1.0
        _AngelRingBreakupWidthMin ("Breakup Width Min", Float) = 0.1
        _AngelRingBreakupWidthMax ("Breakup Width Max", Float) = 0.3
        _AngelRingBreakupSoftness ("Breakup Softness", Float) = 0.1
        _AngelRingBreakupHeight ("Breakup Height", Float) = 0
        [Enum(Disabled, 0, Enabled, 1)] _AngelRingUseLighting ("Use Lighting", Int) = 0

        // SPECULAR
        // [Space(35)]
        // [Header(Specular)]
        // [Space(10)]
        [Toggle(_BACKLACE_SPECULAR)] _ToggleSpecular ("Enable Specular", Int) = 0
        [Enum(Disabled, 0, Enabled, 1)] _ToggleVertexSpecular ("Enable Vertex Specular", Int) = 0
        [Enum(Standard, 0, Anisotropic, 1)] _SpecularMode ("Specular Mode", Int) = 0
        [Enum(Disabled, 0, Turquin, 1, Safe, 2, Manual, 3)] _SpecularEnergyMode ("Specular Energy Mode", Int) = 0
        _SpecularEnergyMin ("Specular Energy Min", Float) = 0.0
        _SpecularEnergyMax ("Specular Energy Max", Float) = 3.0
        _SpecularEnergy ("Specular Energy", Float) = 1.0
        _MSSO ("MSSO", 2D) = "white" { }
        _Metallic ("Metallic", Range(0, 1)) = 0
        _Glossiness ("Glossiness", Range(0, 1)) = 0
        _Occlusion ("Occlusion", Range(0, 1)) = 1
        [PowerSlider(2.0)] _SpecularIntensity ("Specular Intensity", Range(0.01, 25)) = 1.0
        _Specular ("Specular", Range(0, 1)) = 0.5
        _SpecularTintTexture ("Specular Tint Texture", 2D) = "white" { }
        _SpecularTint ("Specular Tint", Color) = (1, 1, 1, 1)
        _TangentMap ("Tangent Map", 2D) = "white" { }
        _Anisotropy ("Anisotropy", Range(-1, 1)) = 0
        [Enum(Disabled, 0, Enabled, 1)] _ReplaceSpecular ("Replace Specular", Range(0, 1)) = 0

        // RIM LIGHTING
        [KeywordEnum(Disabled, Fresnel, Depth, Normal)] _RimMode ("Rim Light Mode", Int) = 0
        // fresnel
        [HDR] _RimColor ("Rim Color", Color) = (1, 1, 1, 1)
        _RimWidth ("Rim Width", Range(20, 0.1)) = 2.5
        _RimIntensity ("Rim Intensity", Float) = 1.0
        [Enum(Disabled, 0, Enabled, 1)] _RimLightBased ("Light-Based Rim", Range(0, 1)) = 0.0
        // depth
        [HDR] _DepthRimColor ("Color", Color) = (0.5, 0.75, 1, 1)
        _DepthRimWidth ("Width", Range(0, 0.5)) = 0.1
        _DepthRimThreshold ("Threshold", Range(0.01, 1)) = 0.1
        _DepthRimSharpness ("Sharpness", Range(0.01, 1)) = 0.1
        [Enum(Additive, 0, Replace, 1, Multiply, 2)] _DepthRimBlendMode ("Blend Mode", Int) = 0
        // normal
        [HDR] _OffsetRimColor ("Color", Color) = (1, 1, 1, 1)
        _OffsetRimWidth ("Width", Range(0, 0.2)) = 0.02
        _OffsetRimHardness ("Hardness", Range(0.01, 1)) = 0.5
        [Enum(Disabled, 0, Enabled, 1)] _OffsetRimLightBased ("Light-Based", Float) = 1.0
        [Enum(Additive, 0, Replace, 1, Multiply, 2)] _OffsetRimBlendMode ("Blend Mode", Int) = 0

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
        [Enum(Fast UV, 0, Fancy UV, 1, Layered, 2, Interior, 3)] _ParallaxMode ("Parallax Mode", Int) = 0
        [NoScaleOffset] _ParallaxMap ("Height Map (R)", 2D) = "black" { }
        _ParallaxStrength ("Parallax Strength", Float) = 0.02 // initially (0, 0.35)
        _ParallaxSteps ("High Quality Steps", Range(4, 64)) = 16
        [Enum(Additive, 0, Multiply, 1, Alpha Blend, 2, Replace, 3)] _ParallaxBlend ("Parallax Blend Mode", Int) = 0
        // interior settings
        [NoScaleOffset] _InteriorCubemap ("Interior Cubemap", Cube) = "" { }
        _InteriorColor ("Interior Color", Color) = (1, 1, 1, 1)
        _InteriorTiling ("Interior Tiling", Float) = 1.0
        // layered settings
        [NoScaleOffset] _ParallaxLayer1 ("Parallax Layer 1", 2D) = "white" { }
        [NoScaleOffset] _ParallaxLayer2 ("Parallax Layer 2", 2D) = "white" { }
        [NoScaleOffset] _ParallaxLayer3 ("Parallax Layer 3", 2D) = "white" { }
        _ParallaxLayerDepth1 ("Parallax Layer Depth 1", Float) = 0.05
        _ParallaxLayerDepth2 ("Parallax Layer Depth 2", Float) = 0.1
        _ParallaxLayerDepth3 ("Parallax Layer Depth 3", Float) = 0.2
        [Enum(Top to Bottom, 0, Bottom to Top, 1, Additive, 2, Average, 3)] _ParallaxStack ("Layer Stack Mode", Int) = 0
        _ParallaxBlendWeight ("Layer Blend Weight", Range(0, 2)) = 1.0
        [Enum(Disabled, 0, Enabled, 1)] _ParallaxTile ("Tile Layers", Int) = 1

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

        // DETAIL MAPPING
        // [Space(35)]
        // [Header(Detail Mapping)]
        // [Space(10)]
        [Toggle(_BACKLACE_DETAIL)] _ToggleDetail ("Enable Detail Maps", Float) = 0.0
        [NoScaleOffset] _DetailAlbedoMap ("Detail Albedo (A=Strength)", 2D) = "gray" { }
        [NoScaleOffset] _DetailNormalMap ("Detail Normal Map", 2D) = "bump" { }
        _DetailTiling ("Detail Tiling", Float) = 16
        _DetailNormalStrength ("Detail Normal Strength", Range(0, 2)) = 1.0

        // SHADOW MAP
        // [Space(35)]
        // [Header(Shadow Map)]
        // [Space(10)]
        [Toggle(_BACKLACE_SHADOW_MAP)] _ToggleShadowMap ("Enable Shadow Map", Float) = 0.0
        [NoScaleOffset] _ShadowMap ("Shadow Map (R=Mask)", 2D) = "white" { }
        _ShadowMapIntensity ("Intensity", Range(0, 1)) = 1.0

        // DECAL SHARED
        // [Space(35)]
        // [Header(Decal Shared Settings)]
        // [Space(10)]
        [Toggle(_BACKLACE_DECALS)] _ToggleDecals ("Enable Decals", Int) = 0
        [Enum(Lit, 0, Unlit, 1)] _DecalStage ("Decal Stage", Int) = 1

        // DECAL 1
        // [Space(35)]
        // [Header(Decal 1)]
        // [Space(10)]
        [Enum(Disabled, 0, Enabled, 1)] _Decal1Enable ("Enable Decal 1", Int) = 0
        [NoScaleOffset] _Decal1Tex ("Decal Texture (A=Mask)", 2D) = "white" { }
        _Decal1Tint ("Tint", Color) = (1, 1, 1, 1)
        [Enum(Additive, 0, Multiply, 1, Alpha Blend, 2)] _Decal1BlendMode ("Blend Mode", Int) = 2
        [Enum(UV, 0, Triplanar, 1, Screen, 2)] _Decal1Space ("Mapping Space", Int) = 0
        [Enum(Decal, 1, Overlay, 0)] _Decal1Behavior ("Decal Behavior", Int) = 1
        _Decal1Position ("UV Position (XY)", Vector) = (0.5, 0.5, 0, 0)
        _Decal1Scale ("UV Scale (XY)", Vector) = (0.25, 0.25, 0, 0)
        _Decal1Rotation ("UV Rotation", Range(0, 360)) = 0
        _Decal1TriplanarPosition ("World Position (XYZ)", Vector) = (0, 0, 0, 0)
        _Decal1TriplanarScale ("World Scale", Float) = 1.0
        _Decal1TriplanarRotation ("World Rotation (XYZ)", Vector) = (0, 0, 0, 0)
        _Decal1TriplanarSharpness ("Triplanar Blend Sharpness", Range(0.01, 10)) = 2.0
        [Enum(Cull Outside, 0, Tile, 1, Default Behaviour, 2)] _Decal1Repeat ("Repeat Pattern", Float) = 0.0
        _Decal1Scroll ("Scroll Speed (XY)", Vector) = (0, 0, 0, 0)
        _Decal1HueShift ("Hue Shift", Range(0, 2)) = 0.0
        [Enum(Disabled, 0, Enabled, 1)] _Decal1AutoCycleHue ("Auto Cycle Hue", Float) = 0.0
        _Decal1CycleSpeed ("Cycle Speed", Float) = 0.1
        [Enum(Disabled, 0, Enabled, 1)] _Decal1Spritesheet ("Enable Spritesheet Animation", Float) = 0.0
        _Decal1SheetCols ("Spritesheet Columns", Int) = 1
        _Decal1SheetRows ("Spritesheet Rows", Int) = 1
        _Decal1SheetFPS ("Spritesheet FPS", Float) = 10.0
        _Decal1SheetSlider ("Spritesheet Frame Slider", Range(0, 1)) = 0.0
        [Enum(Disabled, 0, Distortion, 1, Glitch, 2)] _Decal1SpecialEffect ("Special Effect", Int) = 0
        _Decal1DistortionControls ("Distortion Controls", Vector) = (0, 0, 0, 0)
        _Decal1DistortionSpeed ("Distortion Speed", Float) = 0
        _Decal1GlitchControls ("Glitch Controls", Vector) = (0, 0, 0, 0)

        // DECAL 2
        // [Space(35)]
        // [Header(Decal 2)]
        // [Space(10)]
        [Enum(Disabled, 0, Enabled, 1)] _Decal2Enable ("Enable Decal 2", Int) = 0
        [NoScaleOffset] _Decal2Tex ("Decal Texture (A=Mask)", 2D) = "white" { }
        _Decal2Tint ("Tint", Color) = (1, 1, 1, 1)
        [Enum(Additive, 0, Multiply, 1, Alpha Blend, 2)] _Decal2BlendMode ("Blend Mode", Int) = 2
        [Enum(UV, 0, Triplanar, 1, Screen, 2)] _Decal2Space ("Mapping Space", Int) = 0
        [Enum(Decal, 1, Overlay, 0)] _Decal2Behavior ("Decal Behavior", Int) = 1
        _Decal2Position ("UV Position (XY)", Vector) = (0.5, 0.5, 0, 0)
        _Decal2Scale ("UV Scale (XY)", Vector) = (0.25, 0.25, 0, 0)
        _Decal2Rotation ("UV Rotation", Range(0, 360)) = 0
        _Decal2TriplanarPosition ("World Position (XYZ)", Vector) = (0, 0, 0, 0)
        _Decal2TriplanarScale ("World Scale", Float) = 1.0
        _Decal2TriplanarRotation ("World Rotation (XYZ)", Vector) = (0, 0, 0, 0)
        _Decal2TriplanarSharpness ("Triplanar Blend Sharpness", Range(0.01, 10)) = 2.0
        [Enum(Cull Outside, 0, Tile, 1, Default Behaviour, 2)] _Decal2Repeat ("Repeat Pattern", Float) = 0.0
        _Decal2Scroll ("Scroll Speed (XY)", Vector) = (0, 0, 0, 0)
        _Decal2HueShift ("Hue Shift", Range(0, 2)) = 0.0
        [Enum(Disabled, 0, Enabled, 1)] _Decal2AutoCycleHue ("Auto Cycle Hue", Float) = 0.0
        _Decal2CycleSpeed ("Cycle Speed", Float) = 0.1
        [Enum(Disabled, 0, Enabled, 1)] _Decal2Spritesheet ("Enable Spritesheet Animation", Float) = 0.0
        _Decal2SheetCols ("Spritesheet Columns", Int) = 1
        _Decal2SheetRows ("Spritesheet Rows", Int) = 1
        _Decal2SheetFPS ("Spritesheet FPS", Float) = 10.0
        _Decal2SheetSlider ("Spritesheet Frame Slider", Range(0, 1)) = 0.0
        [Enum(Disabled, 0, Distortion, 1, Glitch, 2)] _Decal2SpecialEffect ("Special Effect", Int) = 0
        _Decal2DistortionControls ("Distortion Controls", Vector) = (0, 0, 0, 0)
        _Decal2DistortionSpeed ("Distortion Speed", Float) = 0
        _Decal2GlitchControls ("Glitch Controls", Vector) = (0, 0, 0, 0)

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
        [Enum(UV, 0, Triplanar, 1)] _PathingMappingMode ("Mapping Mode", Int) = 0
        [NoScaleOffset] _PathingMap ("Path Map (R)", 2D) = "black" { }
        _PathingScale ("Path Scale", Float) = 1.0
        [Enum(Additive, 0, Multiply, 1, Alpha Blend, 2)] _PathingBlendMode ("Blend Mode", Int) = 0
        [Enum(Colour, 0, Texture, 1, Gradient, 2)] _PathingColorMode ("Color Mode", Int) = 0
        _PathingTexture ("Path Texture", 2D) = "white" { }
        [HDR] _PathingColor ("Path Color", Color) = (0, 1, 1, 1)
        [HDR] _PathingColor2 ("Secondary Color", Color) = (1, 0, 0, 1)
        _PathingEmission ("Emission Strength", Float) = 2.0
        [Enum(Fill, 0, Path, 1, Loop, 2, PingPong, 3, Trail, 4, Converge, 5)] _PathingType ("Path Type", Int) = 1
        _PathingSpeed ("Speed", Float) = 0.5
        _PathingWidth ("Path Width", Range(0.001, 0.5)) = 0.1
        _PathingSoftness ("Softness", Range(0.001, 1.0)) = 0.5
        _PathingOffset ("Time Offset", Range(0, 1)) = 0.0
        _PathingStart ("Path Start", Range(0, 1)) = 0.0
        _PathingEnd ("Path End", Range(0, 1)) = 1.0

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
        [Enum(Texture, 0, Procedural, 1)] _IridescenceMode ("Mode", Int) = 0
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
        [Enum(Additive, 0, Multiply, 1, Alpha Blend, 2)] _ShadowTextureBlendMode ("Blend Mode", Int) = 1
        _ShadowTextureIntensity ("Shadow Intensity", Range(0, 1)) = 1.0
        [NoScaleOffset] _ShadowTex ("Shadow Texture / Pattern", 2D) = "white" { }
        _ShadowPatternColor ("Pattern Tint", Color) = (0, 0, 0, 1)
        _ShadowPatternScale ("Pattern Scale / Tiling", Float) = 5.0
        _ShadowPatternTriplanarSharpness ("Triplanar Blend Sharpness", Range(0.01, 10)) = 2.0
        _ShadowPatternTransparency ("Pattern Transparency", Range(0, 1)) = 1
        [Enum(Disabled, 0, Enabled, 1)] _ShadowPatternLightBased ("Light-Based Texturing", Int) = 1
        [Enum(Disabled, 0, Indirect, 1, Full, 2)] _ShadowPatternLit ("Shadow Recieves Light", Int) = 1

        // FLAT MODEL
        // [Space(35)]
        // [Header(Flat Model)]
        // [Space(10)]
        [Enum(Disabled, 0, Enabled, 1)] _ToggleFlatModel ("Enable Flat Model", Float) = 0.0
        [Enum(Disabled, 0, Enabled, 1)] _FlatModeAutoflip ("Auto-Flip", Float) = 0.0
        _FlatModel ("Flat Model Strength", Range(0, 1)) = 0.0
        _FlatModelDepthCorrection ("Depth Correction", Range(-0.2, 0.2)) = -0.1
        _FlatModelFacing ("Facing Direction", Range(-1, 1)) = 0.0
        [Enum(Disabled, 1, Enabled, 0)] _FlatModelLockAxis ("Follow Camera", Range(0, 1)) = 1.0

        // WORLD ALIGNED
        // [Space(35)]
        // [Header(World Aligned Effect)]
        // [Space(10)]
        [Toggle(_BACKLACE_WORLD_EFFECT)] _ToggleWorldEffect ("Enable World Effect", Float) = 0.0
        [Enum(Alpha Blend, 0, Additive, 1, Multiply, 2)] _WorldEffectBlendMode ("Blend Mode", Int) = 0
        [NoScaleOffset] _WorldEffectTex ("Effect Texture (A=Mask)", 2D) = "white" { }
        [NoScaleOffset] _WorldEffectMask ("Effect Mask (R)", 2D) = "white" { }
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

        // DITHER
        // [Space(35)]
        // [Header(Dither)]
        // [Space(10)]
        [Enum(Disabled, 0, Enabled, 1)] _ToggleDither ("Enable Dither", Float) = 0.0
        [Enum(Screen, 0, World, 1, UV, 2)] _DitherSpace ("Dither Space", Int) = 0
        _DitherAmount ("Dither Amount", Range(0, 1)) = 0
        _DitherScale ("Dither Scale", Range(100, 0.1)) = 10

        // LOW PRECISION
        // [Space(35)]
        // [Header(Low Precision)]
        // [Space(10)]
        [Enum(Disabled, 0, Enabled, 1)] _TogglePS1 ("Enable Low Precision (PS1)", Float) = 0.0
        [Enum(Disabled, 0, World Space, 1, Screen Space, 2)] _PS1Rounding ("Rounding Style", Int) = 0.0
        _PS1RoundingPrecision ("Rounding Precision", Float) = 64
        [Enum(Disabled, 0, Enabled, 1)] _PS1Compression ("Enable Color Compression", Int) = 0.0
        _PS1CompressionPrecision ("Color Compression Precision", Float) = 32

        // VERTEX DISTORTION
        // [Space(35)]
        // [Header(Vertex Distortion)]
        // [Space(10)]
        [Toggle(_BACKLACE_VERTEX_DISTORTION)] _ToggleVertexDistortion ("Enable Vertex Distortion", Float) = 0.0
        [Enum(Distortion, 0, Glitch, 1)] _VertexEffectType ("Effect Type", Int) = 0
        [Enum(Wave, 0, Jumble, 1, Wind, 2, Breathing, 3)] _VertexDistortionMode ("Distortion Mode", Int) = 0
        [Enum(Slice, 0, Blocky, 1, Wave, 2, Jitter, 3)] _VertexGlitchMode ("Glitch Mode", Int) = 0
        [Enum(Disabled, 0, Red, 1, Green, 2, Blue, 3, All, 4)] _VertexDistortionColorMask ("Color Channel Mask", Int) = 0
        // shared (glitch, wave and jumble)
        _VertexDistortionStrength ("Distortion Strength", Vector) = (0.1, 0.1, 0.1, 0)
        _VertexDistortionSpeed ("Distortion Speed", Vector) = (1, 1, 1, 0)
        _VertexDistortionFrequency ("Distortion Frequency", Vector) = (1, 1, 1, 0)
        // wind
        _WindStrength ("Wind Strength", Range(0, 1)) = 0.1
        _WindSpeed ("Wind Speed", Range(0, 5)) = 1.0
        _WindScale ("Wind Noise Scale", Float) = 1.0
        _WindDirection ("Wind Direction (XYZ)", Vector) = (1, 0, 0, 0)
        [NoScaleOffset] _WindNoiseTex ("Wind Noise Texture (R)", 2D) = "gray" { }
        // breathing
        _BreathingStrength ("Breathing Strength", Range(0, 0.1)) = 0.01
        _BreathingSpeed ("Breathing Speed", Range(0, 5)) = 1.0
        // glitch settings
        _GlitchFrequency ("Glitch Frequency", Float) = 1.0

        // REFREACTION
        // [Space(35)]
        // [Header(Refraction)]
        // [Space(10)]
        [Toggle(_BACKLACE_REFRACTION)] _ToggleRefraction ("Enable Refraction Effect", Float) = 0.0
        [Enum(Grabpass, 0, Texture, 1)] _RefractionSourceMode ("Refraction Source", Int) = 0
        _RefractionTexture ("Refraction Texture", 2D) = "white" { }
        [NoScaleOffset] _RefractionMask ("Mask (R=Strength)", 2D) = "white" { }
        _RefractionTint ("Refraction Tint", Color) = (0.8, 0.9, 1.0, 0.5)
        _RefractionIOR ("Refraction Strength", Range(0.0, 1.0)) = 0.1
        _RefractionFresnel ("Fresnel Power", Range(0.1, 20)) = 5.0
        _RefractionOpacity ("Refraction Opacity", Range(0, 1)) = 0.5
        _RefractionSeeThrough ("See Through Strength", Range(0, 1)) = 0
        [Enum(Reverse Fresnel, 0, Fresnel, 1, Soft Fresnel, 2, Manual, 3)] _RefractionMode ("Refraction Mode", Float) = 0.0
        _RefractionMixStrength ("Mix Strength", Float) = 0
        _RefractionBlendMode ("Refraction Additive<->Replace", Range(0, 1)) = 0
        _RefractionGrabpassTint ("Grabpass Tint", Color) = (1, 1, 1, 1)
        [Enum(Disabled, 0, Enabled, 1)] _RefractionZoomToggle ("Enable Zoom", Float) = 0.0
        _RefractionZoom ("Zoom Strength", Range(0, 1)) = 0.0
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

        // FAKE SCREEN SPACE REFLECTIONS
        // [Space(35)]
        // [Header(Fake Screen Space Reflections)]
        // [Space(10)]
        [Toggle(_BACKLACE_SSR)] _ToggleSSR ("Enable Screen Space Reflections", Float) = 0.0
        [Enum(Grabpass, 0, Texture, 1)] _SSRSourceMode ("Reflection Source", Int) = 0
        _SSRTexture ("Reflection Texture", 2D) = "white" { }
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
        [IntRange] _SSRMaxSteps ("Max Steps", Range(1, 35)) = 20
        _SSRStepSize ("Step Size", Float) = 0.05
        _SSREdgeFade ("Edge Fade", Range(0.01, 1)) = 0.1
        [Enum(Disabled, 0, Enabled, 1)] _SSRCamFade ("Enable Camera Distance Fade", Int) = 0.0
        _SSRCamFadeStart ("SSR Camera Fade Start", Float) = 20.0
        _SSRCamFadeEnd ("SSR Camera Fade End", Float) = 50.0
        _SSRFlipUV ("Flip Reflection UV", Range(0, 1)) = 0 // more stylised if on, less accurate
        [Enum(Disabled, 0, Enabled, 1)] _SSRAdaptiveStep ("Enable Adaptive Step Size", Int) = 1
        _SSRThickness ("Culling Thickness", Float) = 0.01
        [Enum(Stretch, 0, Fade, 1, Cutoff, 2, Mirror, 3)] _SSROutOfViewMode ("Out Of View Mode", Int) = 0

        // LIQUID LAYER
        // [Space(35)]
        // [Header(Liquid Layer)]
        // [Space(10)]
        [Toggle(_BACKLACE_LIQUID_LAYER)] _LiquidToggleLiquid ("Enable Liquid Layer", Float) = 0.0
        [Enum(Disabled, 0, Enabled, 1)] _LiquidEnabled ("Enable Liquid Effect", Int) = 1
        // mode controls
        [Enum(Watery, 0, Viscous, 1)] _LiquidFeel ("Liquid Feel", Int) = 0
        [Enum(Sweat, 0, Blood, 1, Oil, 2)] _LiquidLookWatery ("Watery Look", Int) = 0
        [Enum(Icing, 0, Slime, 1, Wax, 2, Mud, 3)] _LiquidLookViscous ("Viscous Look", Int) = 0
        // uv controls
        [Enum(UV, 0, World XY, 1, World XZ, 2, World YZ, 3, Object Position, 4, Triplanar, 5)] _LiquidSpace ("Mapping Mode", Float) = 0
        _LiquidMapScale ("Mapping Scale", Float) = 1.0
        _LiquidTriplanarSharpness ("Triplanar Sharpness", Range(1, 10)) = 4.0
        // global controls - misc
        _LiquidMaskMap ("Mask Map (White=Allow)", 2D) = "white" { }
        [Enum(Disabled, 0, Enabled, 1)] _LiquidUseForceMap ("Use Force Map", Int) = 0
        _LiquidForceMap ("Force Map (White=Force Fill)", 2D) = "black" { }
        [Enum(Lit, 0, Unlit, 1)] _LiquidSpecularLit ("Specular Mode", Int) = 0
        _LiquidGloss ("Gloss", Range(0, 1)) = 0.9
        _LiquidShine ("Shine", Range(0, 5)) = 1.0
        _LiquidShineTightness ("Shihe Tightness", Range(0, 1)) = 0.5
        _LiquidShadow ("Shadow Strength", Range(0, 1)) = 0.3
        _LiquidRim ("Rim Strength", Range(0, 5)) = 0.5
        _LiquidDepth ("Depth Strength", Range(0, 0.05)) = 0
        _LiquidNormalStrength ("Normal Strength", Range(0, 8)) = 2.0
        _LiquidOpacity ("Opacity", Range(0, 1)) = 0.9
        _LiquidDarken ("Skin Darkening", Range(0, 0.5)) = 0.2
        [Enum(Disabled, 0, Enabled, 1)] _LiquidManualDirection ("Enable Manual Direction", Int) = 0
        _LiquidDirectionOne ("Layer One Direction", Vector) = (0, -1, 0, 0)
        _LiquidDirectionTwo ("Layer Two Direction", Vector) = (0, -1, 0, 0)
        // global controls - layer one
        _LiquidLayerOneScale ("Layer One Scale", Float) = 6.0
        _LiquidLayerOneDensity ("Layer One Density", Range(0, 1)) = 0.5
        _LiquidLayerOneStretch ("Layer One Stretch", Float) = 1.5
        _LiquidLayerOneSpeed ("Layer One Speed", Float) = 0.1
        _LiquidLayerOneRandomness ("Layer One Randomness", Float) = 0.5
        _LiquidLayerOneSeed ("Layer One Seed", Float) = 4.20
        _LiquidLayerOneMod ("Layer One Mod (Trail/Wobble)", Range(0, 1)) = 0.4
        // global controls - layer two
        [Enum(Disabled, 0, Enabled, 1)] _LiquidUseLayerTwo ("Enable Layer Two", Int) = 0
        _LiquidLayerTwoScale ("Layer Two Scale", Float) = 16.0
        _LiquidLayerTwoDensity ("Layer Two Density", Range(0, 1)) = 0.5
        _LiquidLayerTwoStretch ("Layer Two Stretch", Float) = 1.5
        _LiquidLayerTwoSpeed ("Layer Two Speed", Float) = 0.1
        _LiquidLayerTwoRandomness ("Layer Two Randomness", Float) = 0.5
        _LiquidLayerTwoSeed ("Layer Two Seed", Float) = 9.69
        _LiquidLayerTwoAmount ("Layer Two Amount", Range(0, 1)) = 0.5
        _LiquidLayerTwoMod ("Layer Two Mod (Trail/Wobble)", Range(0, 1)) = 0.4
        // global controls - coverage
        _LiquidClusterScale ("Cluster Scale", Float) = 3.0
        _LiquidClusterSeed ("Cluster Seed", Float) = 6.9
        _LiquidThreshold ("Coverage Threshold", Range(0, 1)) = 0.5
        _LiquidSoftness ("Edge Softness", Range(0.01, 0.4)) = 0.12
        // watery-specific controls
        _LiquidWateryCoverage ("Coverage Amount", Range(0, 1)) = 0.5
        // viscous-specific controls
        _LiquidViscousSmooth ("Merge Radius", Range(0.05, 1.0)) = 0.35
        _LiquidViscousThinning ("Thinning Variance", Range(0, 1)) = 0.35
        _LiquidViscousThinSeed ("Thinning Seed", Float) = 0.0
        _LiquidViscousThinScale ("Thinning Scale", Float) = 3.0
        // sweat settings
        _LiquidSweatUseTint ("Use Tint", Range(0, 1)) = 0
        _LiquidSweatTintColor ("Tint Colour", Color) = (0.8, 0.9, 1, 1)
        // blood settings
        _LiquidBloodColorFresh ("Fresh Colour", Color) = (0.8, 0.05, 0.05, 1)
        _LiquidBloodColorDark ("Dried Colour", Color) = (0.4, 0.02, 0.02, 1)
        _LiquidBloodPooling ("Pooling Amount", Range(0, 1)) = 0.5
        _LiquidBloodDryingRate ("Drying Rate", Range(0, 1)) = 0.3
        _LiquidBloodDryGloss ("Dried Gloss", Range(0, 1)) = 0.15
        // oil settings
        _LiquidOilColor ("Oil Tint", Color) = (0.05, 0.04, 0.03, 1)
        _LiquidOilIridescence ("Iridescence", Range(0, 1)) = 0.8
        _LiquidOilIridescenceScale ("Iridescence Scale", Float) = 4.0
        // icing settings
        _LiquidIcingColor ("Icing Colour", Color) = (1, 1, 1, 1)
        [Enum(Disabled, 0, Enabled, 1)] _LiquidIcingColorVariation ("Use Colour Variation", Int) = 0
        _LiquidIcingColorMin ("Colour A", Color) = (1, 0.9, 0.95, 1)
        _LiquidIcingColorMax ("Colour B", Color) = (1, 1, 1, 1)
        _LiquidIcingColorScale ("Variation Scale", Float) = 2.0
        _LiquidIcingColorSeed ("Variation Seed", Float) = 0.0
        // wax settings
        _LiquidWaxColor ("Wax Colour", Color) = (1, 0.9, 0.7, 1)
        _LiquidWaxColorVariation ("Wax Colour Variation", Range(0, 1)) = 0.5
        _LiquidWaxCoolRate ("Cooling Rate", Float) = 0.5
        // slime settings
        _LiquidSlimeColor ("Slime Base Colour", Color) = (0.3, 0.9, 0.4, 1)
        _LiquidSlimeColorShift ("Slime Shift Colour", Color) = (0.5, 1, 0.6, 1)
        _LiquidSlimeTranslucency ("Slime Translucency", Range(0, 1)) = 0.6
        _LiquidSlimeIridescence ("Slime Iridescence", Range(0, 1)) = 0.4
        _LiquidSlimeStickiness ("Slime Stickiness", Range(0, 1)) = 0.35
        // mud settings
        _LiquidMudColor ("Mud Base Colour", Color) = (0.3, 0.2, 0.15, 1)
        _LiquidMudColorDark ("Mud Dark Colour", Color) = (0.18, 0.12, 0.09, 1)
        _LiquidMudRoughness ("Mud Surface Roughness", Range(0, 1)) = 0.6

        // STOCHASTIC SAMPLING
        // [Space(35)]
        // [Header(Stochastic Sampling)]
        // [Space(10)]
        [Toggle(_BACKLACE_STOCHASTIC)] _StochasticSampling ("Enable Stochastic Sampling", Int) = 0
        [Enum(Triangle Grid, 0, Contrast Aware, 1)] _StochasticSamplingMode ("Stochastic Sampling Mode", Int) = 0
        _StochasticTexture ("Stochastic Texture", 2D) = "white" { }
        _StochasticOpacity ("Overall Opacity", Range(0, 1)) = 1.0
        [Enum(Replace, 0, Additive, 1, Multiply, 2, Screen, 3)] _StochasticBlendMode ("Blend Mode", Int) = 0
        _StochasticScale ("Scale", Range(0.1, 50)) = 1.0
        _StochasticOffsetX ("Offset X", Float) = 0.0
        _StochasticOffsetY ("Offset Y", Float) = 0.0
        [HDR] _StochasticTint ("Tint", Color) = (1, 1, 1, 1)
        // triangle grid settings
        _StochasticBlend ("Blend", Range(0, 2)) = 1.0
        _StochasticRotationRange ("Rotation", Range(0, 180)) = 45
        // contrast settings
        [Enum(Competitive, 1, Naive, 0)] _StochasticPriority ("Sampling Priority", Int) = 1
        _StochasticContrastStrength ("Contrast Strength", Range(0.1, 5)) = 2.0
        _StochasticContrastThreshold ("Contrast Threshold", Range(0, 1)) = 0.5
        // height blend
        [Enum(Disabled, 0, Enabled, 1)] _StochasticHeightBlend ("Height Blending", Int) = 0
        _StochasticHeightMap ("Height Map", 2D) = "black" { }
        _StochasticHeightStrength ("Height Strength", Range(0, 10)) = 3.0
        // misc settings
        _StochasticMipBias ("Mip Bias", Range(-2, 2)) = 0
        [Enum(Disabled, 0, Enabled, 1)] _StochasticAlpha ("Affect Alpha Channel", Int) = 0
        [Enum(Disabled, 0, Enabled, 1)] _StochasticNormals ("Affect Normals", Int) = 0

        // SPLATTER MAPPING
        // [Space(35)]
        // [Header(Splatter Mapping)]
        // [Space(10)]
        // [Space(35)]
        // [Header(Splatter Overlay)]
        // [Space(10)]
        [Toggle(_BACKLACE_SPLATTER)] _SplatterMapping ("Enable Splatter Overlay", Int) = 0
        [Enum(Standard, 0, Projection, 1)] _SplatterMappingMode ("Mapping Mode", Int) = 0
        _SplatterControl ("Control Map (R=Layer1, G=Layer2)", 2D) = "black" { }
        [Enum(Disabled, 0, Enabled, 1)] _SplatterUseNormals ("Use Normal Maps", Int) = 0
        // layer 1
        _SplatterAlbedo0 ("Albedo", 2D) = "white" { }
        _SplatterNormal0 ("Normal", 2D) = "bump" { }
        _SplatterMasks0 ("Masks (R=Met G=AO B=H A=Sm)", 2D) = "white" { }
        _SplatterColor0 ("Tint", Color) = (1, 1, 1, 1)
        _SplatterTiling0 ("Tiling & Offset", Vector) = (1, 1, 0, 0)
        _SplatterNormalStrength0 ("Normal Strength", Range(0, 2)) = 1
        [Enum(Alpha Blend, 0, Additive, 1, Multiply, 2)] _SplatterBlendMode0 ("Blend Mode", Int) = 0
        // layer 2
        _SplatterAlbedo1 ("Albedo", 2D) = "white" { }
        _SplatterNormal1 ("Normal", 2D) = "bump" { }
        _SplatterMasks1 ("Masks", 2D) = "white" { }
        _SplatterColor1 ("Tint", Color) = (1, 1, 1, 1)
        _SplatterTiling1 ("Tiling & Offset", Vector) = (1, 1, 0, 0)
        _SplatterNormalStrength1 ("Normal Strength", Range(0, 2)) = 1
        [Enum(Alpha Blend, 0, Additive, 1, Multiply, 2)] _SplatterBlendMode1 ("Blend Mode", Int) = 0
        // settings
        _SplatterCullThreshold ("Cull Threshold", Range(0, 0.5)) = 0.3
        _SplatterBlendSharpness ("Control Sharpness", Range(1, 10)) = 1
        _SplatterMipBias ("Mip Bias", Range(-2, 2)) = 0
        [Enum(Disabled, 0, Enabled, 1)] _SplatterAlphaChannel ("Use Splatter Alpha", Int) = 0

        // TEXTURE BOMBING
        // [Space(35)]
        // [Header(Texture Bombing)]
        // [Space(10)]
        [Toggle(_BACKLACE_BOMBING)] _BombingTextures ("Enable Texture Bombing", Int) = 0
        [Enum(Jittered, 0, Layered, 1)] _BombingMode ("Bombing Mode", Int) = 1
        [Enum(Alpha Blend, 0, Additive, 1, Multiply, 2, Overlay, 3)] _BombingBlendMode ("Blend Mode", Int) = 0
        [Enum(UV, 0, Triplanar, 1)] _BombingMappingMode ("Mapping Mode", Float) = 0
        _BombingTriplanarSharpness ("Triplanar Sharpness", Range(1, 64)) = 8
        _BombingThreshold ("Density Threshold", Range(0, 1)) = 1
        _BombingOpacity ("Overall Opacity", Range(0, 1)) = 1.0
        _BombingTex ("Albedo (RGBA)", 2D) = "white" { }
        _BombingColor ("Tint", Color) = (1, 1, 1, 1)
        _BombingTiling ("Tiling", Float) = 1
        _BombingDensity ("Density", Range(0.1, 5)) = 1.0
        _BombingGlobalScale ("Global Scale", Range(0.1, 5)) = 1
        _BombingJitterAmount ("Position Jitter", Range(0, 1)) = 1
        // variation
        _BombingScaleVar ("Scale Variation", Range(0, 1)) = 0.2
        _BombingRotVar ("Rotation Variation", Range(0, 1)) = 1.0
        _BombingHueVar ("Hue Variation", Range(0, 1)) = 0
        _BombingSatVar ("Saturation Variation", Range(0, 1)) = 0
        _BombingValVar ("Value Variation", Range(0, 1)) = 0
        // normals
        [Enum(Disabled, 0, Enabled, 1)] _BombingUseNormal ("Use Normal Map", Int) = 0
        _BombingNormal ("Normal", 2D) = "bump" { }
        _BombingNormalStrength ("Normal Strength", Range(0, 2)) = 1
        // spritesheet
        [Enum(Disabled, 0, Enabled, 1)] _BombingUseSheet ("Use Spritesheet", Int) = 0
        _BombingSheetData ("Sheet Data (X=Cols, Y=Rows)", Vector) = (1, 1, 0, 0)
        // optimisation
        _BombingCullDist ("Cull Distance", Float) = 20
        _BombingCullFalloff ("Cull Falloff", Float) = 5
        
        // OUTLINE
        // [Space(70)]
        // [Header(Outline)]
        // [Space(10)]
        [Toggle(_BACKLACE_LIT_OUTLINE)] _ToggleLitOutline ("Enable Lit Outline", Float) = 0.0
        _OutlineLitMix ("Lit Outline Mix", Range(0, 1)) = 0.5
        _OutlineColor ("Outline Color", Color) = (0, 0, 0, 1)
        _OutlineWidth ("Outline Width", Range(0, 0.1)) = 0.005
        [Enum(Disabled, 0, Enabled, 1)] _OutlineVertexColorMask ("Use Vertex Color (R) Mask", Float) = 0.0
        [Enum(Disabled, 0, Enabled, 1)] _OutlineDistanceFade ("Enable Distance Fade", Float) = 0.0
        _OutlineFadeStart ("Fade Start Distance", Float) = 10.0
        _OutlineFadeEnd ("Fade End Distance", Float) = 15.0
        [Enum(Disabled, 0, Enabled, 1)] _OutlineHueShift ("Enable Hue Shift", Float) = 0.0
        _OutlineHueShiftSpeed ("Hue Shift Speed", Float) = 0.2
        _OutlineOpacity ("Outline Opacity", Range(0, 1)) = 1.0
        [Enum(View, 0, World, 1)] _OutlineSpace ("Outline Space", Int) = 0
        [Enum(Colour, 0, Texture, 1)] _OutlineMode ("Outline Mode", Int) = 0
        [Enum(Screen Space, 0, World Space, 1, UV Space, 2)] _OutlineTexMap ("Outline Texture Mapping Mode", Int) = 0
        _OutlineTex ("Outline Texture", 2D) = "white" { }
        _OutlineTexTiling ("Outline Texture Tiling", Vector) = (1, 1, 0, 0)
        _OutlineTexScroll ("Outline Texture Scroll", Vector) = (0, 0, 0, 0)
        _OutlineOffset ("Outline Offset", Vector) = (0, 0, 0, 0)
        [Enum(Outline, 0, Silhouette, 1)] _OutlineStyle ("Outline Style", Int) = 0
        // stencil
        [IntRange] _OutlineStencilRef ("Outline Stencil Reference", Range(0, 255)) = 0
        [Enum(UnityEngine.Rendering.CompareFunction)] _OutlineStencilComp ("Outline Stencil Comparison", Int) = 8 // Always
        [Enum(UnityEngine.Rendering.StencilOp)] _OutlineStencilPass ("Outline Stencil Pass Op", Int) = 0 // Keep
        [Enum(UnityEngine.Rendering.StencilOp)] _OutlineStencilFail ("Outline Stencil Fail Op", Int) = 0 // Keep
        [Enum(UnityEngine.Rendering.StencilOp)] _OutlineStencilZFail ("Outline Stencil ZFail Op", Int) = 0 // Keep

        // AUDIOLINK
        // [Space(35)]
        // [Header(AudioLink)]
        // [Space(10)]
        [Toggle(_BACKLACE_AUDIOLINK)] _ToggleAudioLink ("Enable AudioLink", Float) = 0.0
        _AudioLinkFallback ("Fallback Level", Range(0, 1)) = 1.0
        [Enum(Raw, 0, Smooth, 1, Chronotensity, 2)] _AudioLinkMode ("AudioLink Mode", Float) = 0
        [IntRange] _AudioLinkSmoothLevel ("Smoothing Level", Range(0, 15)) = 8
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
    }
    SubShader
    {

        // Rendering Settings
        // Tags { "RenderType" = "TransparentCutout" "Queue" = "AlphaTest" } or Transparent
        Tags { "RenderType" = "Transparent" "Queue" = "Transparent" "VRCFallback" = "Toon" "Backlace" = "3.0.0" }
        Blend [_SrcBlend] [_DstBlend]
        ZWrite [_ZWrite]
        Cull [_Cull]
        Stencil
        {
            Ref [_StencilRef] Comp [_StencilComp] Pass [_StencilPass] Fail [_StencilFail] ZFail [_StencilZFail]
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
            #include "./Variants/Backlace_SmallVanilla.cginc"
            #include "./Includes/Backlace_Forward.cginc"
            ENDCG
        }
        
        // Forward Add Pass
        Pass
        {
            Name "ForwardAdd"
            Tags { "LightMode" = "ForwardAdd" }
            Blend [_SrcBlend] One // make it, well, additive
            Fog
            {
                Color(0, 0, 0, 0)
            }// additive should have black fog
            ZWrite Off // don't write to depth for additive
            CGPROGRAM
            #ifndef UNITY_PASS_FORWARDADD
                #define UNITY_PASS_FORWARDADD
            #endif // UNITY_PASS_FORWARDADD
            #include "./Variants/Backlace_SmallVanilla.cginc"
            #include "./Includes/Backlace_Forward.cginc"
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
            #include "./Variants/Backlace_SmallVanilla.cginc"
            #include "./Includes/Backlace_Shadow.cginc"
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
            #include "./Variants/Backlace_SmallVanilla.cginc"
            #include "./Includes/Backlace_Meta.cginc"
            ENDCG
        }
    }
    CustomEditor "Luka.Backlace.Interface"
}