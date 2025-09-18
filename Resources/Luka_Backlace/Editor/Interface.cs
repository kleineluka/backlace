#if UNITY_EDITOR

// imports
using System.IO;
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;

// Interface.cs is the actual shader GUI that is displayed..
namespace Luka.Backlace
{

    // the material editor interface
    public class Interface : ShaderGUI
    {

        // editor states
        private static bool loaded = false;
        private static string loaded_material = null;
        private static List<ShaderVariant> detected_variants = null;
        // core ui components
        private static Header header = null;
        private static Announcement announcement = null;
        private static Theme theme = null;
        private static Languages languages = null;
        private static Config configs = null;
        private static Tab config_tab = null;
        private static ConfigMenu config_menu = null;
        private static Update update = null;
        private static Docs docs = null;
        private static Metadata meta = null;
        private static SocialsMenu socials_menu = null;
        // additional ui integrations
        private static Tab license_tab = null;
        private static LicenseMenu license_menu = null;
        private static Cushion cushion = null;
        private static BeautyBlender beauty_blender = null;
        private static Bags bags = null;
        private static Tab presets_tab = null;
        private static PresetsMenu presets_menu = null;
        
        #region Tabs
        // main
        private static Tab tab_main = null;
        private static Tab sub_tab_rendering = null;
        private static Tab sub_tab_textures = null;
        private static Tab sub_tab_uv_manipulation = null;
        private static Tab sub_tab_uv_effects = null;
        private static Tab sub_tab_vertex_manipulation = null;
        private static Tab sub_tab_decal_one = null;
        private static Tab sub_tab_decal_two = null;
        private static Tab sub_tab_post_processing = null;
        private static Tab sub_tab_uv_sets = null;
        // lighting
        private static Tab tab_lighting = null;
        private static Tab sub_tab_lighting_model = null;
        private static Tab sub_tab_anime = null;
        private static Tab sub_tab_emission = null;
        private static Tab sub_tab_light_limiting = null;
        // specular
        private static Tab tab_specular = null;
        private static Tab sub_tab_pbr_specular = null;
        private static Tab sub_tab_stylised_specular = null;
        // shading
        private static Tab tab_shading = null;
        private static Tab sub_tab_rim_lighting = null;
        private static Tab sub_tab_depth_rim = null;
        private static Tab sub_tab_clear_coat = null;
        private static Tab sub_tab_matcap = null;
        private static Tab sub_tab_cubemap = null;
        private static Tab sub_tab_parallax = null;
        private static Tab sub_tab_subsurface = null;
        private static Tab sub_tab_detail_map = null;
        private static Tab sub_tab_shadow_map = null;
        // effects
        private static Tab tab_effects = null;
        private static Tab sub_tab_dissolve = null;
        private static Tab sub_tab_pathing = null;
        private static Tab sub_tab_glitter = null;
        private static Tab sub_tab_distance_fading = null;
        private static Tab sub_tab_iridescence = null;
        private static Tab sub_tab_shadow_textures = null;
        private static Tab sub_tab_flatten_model = null;
        private static Tab sub_tab_world_aligned = null;
        private static Tab sub_tab_vrchat_mirror = null;
        private static Tab sub_tab_touch_interactions = null;
        private static Tab sub_tab_dither = null;
        private static Tab sub_tab_ps1 = null;
        private static Tab sub_tab_vertex_distortion = null;
        private static Tab sub_tab_refraction = null;
        private static Tab sub_tab_screenspace_reflection = null;
        // outline
        private static Tab tab_outline = null;
        // third party
        private static Tab tab_third_party = null;
        private static Tab sub_tab_audiolink = null;
        private static Tab sub_tab_superplug = null;
        private static Tab sub_tab_ltcgi = null;
        #endregion // Tabs

        #region Properties
        // rendering properties
        private MaterialProperty prop_BlendMode = null;
        private MaterialProperty prop_OverrideBaseBlend = null;
        private MaterialProperty prop_SrcBlend = null;
        private MaterialProperty prop_DstBlend = null;
        private MaterialProperty prop_BlendOp = null;
        private MaterialProperty prop_OverrideAddBlend = null;
        private MaterialProperty prop_AddSrcBlend = null;
        private MaterialProperty prop_AddDstBlend = null;
        private MaterialProperty prop_AddBlendOp = null;
        private MaterialProperty prop_OverrideZWrite = null;
        private MaterialProperty prop_ZWrite = null;
        private MaterialProperty prop_OverrideRenderQueue = null;
        private MaterialProperty prop_Cull = null;
        private MaterialProperty prop_ZTest = null;
        private MaterialProperty prop_StencilRef = null;
        private MaterialProperty prop_StencilComp = null;
        private MaterialProperty prop_StencilPass = null;
        private MaterialProperty prop_StencilFail = null;
        private MaterialProperty prop_StencilZFail = null;
        private MaterialProperty prop_OutlineStencilRef = null;
        private MaterialProperty prop_OutlineStencilComp = null;
        private MaterialProperty prop_OutlineStencilPass = null;
        private MaterialProperty prop_OutlineStencilFail = null;
        private MaterialProperty prop_OutlineStencilZFail = null;
        private MaterialProperty prop_VRCFallback = null;
        private MaterialProperty prop_ToggleFlipNormals = null;
        // texture properties
        private MaterialProperty prop_MainTex = null;
        private MaterialProperty prop_Color = null;
        private MaterialProperty prop_Cutoff = null;
        private MaterialProperty prop_BumpMap = null;
        private MaterialProperty prop_BumpScale = null;
        private MaterialProperty prop_Alpha = null;
        private MaterialProperty prop_DecalStage = null;
        // uv manipulation properties
        private MaterialProperty prop_UV_Offset_X = null;
        private MaterialProperty prop_UV_Offset_Y = null;
        private MaterialProperty prop_UV_Scale_X = null;
        private MaterialProperty prop_UV_Scale_Y = null;
        private MaterialProperty prop_UV_Rotation = null;
        private MaterialProperty prop_UV_Scroll_X_Speed = null;
        private MaterialProperty prop_UV_Scroll_Y_Speed = null;
        // uv effects properties
        private MaterialProperty prop_ToggleUVEffects = null;
        private MaterialProperty prop_UVTriplanarMapping = null;
        private MaterialProperty prop_UVTriplanarPosition = null;
        private MaterialProperty prop_UVTriplanarScale = null;
        private MaterialProperty prop_UVTriplanarRotation = null;
        private MaterialProperty prop_UVTriplanarSharpness = null;
        private MaterialProperty prop_UVScreenspaceMapping = null;
        private MaterialProperty prop_UVScreenspaceTiling = null;
        private MaterialProperty prop_UVFlipbook = null;
        private MaterialProperty prop_UVFlipbookRows = null;
        private MaterialProperty prop_UVFlipbookColumns = null;
        private MaterialProperty prop_UVFlipbookFrames = null;
        private MaterialProperty prop_UVFlipbookFPS = null;
        private MaterialProperty prop_UVFlipbookScrub = null;
        private MaterialProperty prop_UVFlowmap = null;
        private MaterialProperty prop_UVFlowmapTex = null;
        private MaterialProperty prop_UVFlowmapStrength = null;
        private MaterialProperty prop_UVFlowmapSpeed = null;
        private MaterialProperty prop_UVFlowmapDistortion = null;
        // vertex manipulation properties
        private MaterialProperty prop_VertexManipulationPosition = null;
        private MaterialProperty prop_VertexManipulationScale = null;
        // emission properties
        private MaterialProperty prop_ToggleEmission = null;
        private MaterialProperty prop_EmissionColor = null;
        private MaterialProperty prop_EmissionMap = null;
        private MaterialProperty prop_UseAlbedoAsEmission = null;
        private MaterialProperty prop_EmissionStrength = null;
        // light limiting properties
        private MaterialProperty prop_EnableBaseLightLimit = null;
        private MaterialProperty prop_BaseLightMin = null;
        private MaterialProperty prop_BaseLightMax = null;
        private MaterialProperty prop_EnableAddLightLimit = null;
        private MaterialProperty prop_AddLightMin = null;
        private MaterialProperty prop_AddLightMax = null;
        private MaterialProperty prop_GreyscaleLighting = null;
        private MaterialProperty prop_ForceLightColor = null;
        private MaterialProperty prop_ForcedLightColor = null;
        // lighting model properties
        private MaterialProperty prop_LightingColorMode = null;
        private MaterialProperty prop_LightingDirectionMode = null;
        private MaterialProperty prop_ForcedLightDirection = null;
        private MaterialProperty prop_ViewDirectionOffsetX = null;
        private MaterialProperty prop_ViewDirectionOffsetY = null;
        private MaterialProperty prop_DirectIntensity = null;
        private MaterialProperty prop_IndirectIntensity = null;
        private MaterialProperty prop_VertexIntensity = null;
        private MaterialProperty prop_AdditiveIntensity = null;
        private MaterialProperty prop_BakedDirectIntensity = null;
        private MaterialProperty prop_BakedIndirectIntensity = null;
        // toon lighting properties
        private MaterialProperty prop_ToggleAnimeLighting = null;
        private MaterialProperty prop_AnimeMode = null;
        private MaterialProperty prop_Ramp = null;
        private MaterialProperty prop_RampColor = null;
        private MaterialProperty prop_RampOffset = null;
        private MaterialProperty prop_ShadowIntensity = null;
        private MaterialProperty prop_OcclusionOffsetIntensity = null;
        private MaterialProperty prop_RampMin = null;
        private MaterialProperty prop_AnimeShadowColor = null;
        private MaterialProperty prop_AnimeShadowThreshold = null;
        private MaterialProperty prop_AnimeHalftoneColor = null;
        private MaterialProperty prop_AnimeHalftoneThreshold = null;
        private MaterialProperty prop_AnimeShadowSoftness = null;
        private MaterialProperty prop_ToggleAmbientGradient = null;
        private MaterialProperty prop_AnimeOcclusionToShadow = null;
        private MaterialProperty prop_AmbientUp = null;
        private MaterialProperty prop_AmbientSkyThreshold = null;
        private MaterialProperty prop_AmbientDown = null;
        private MaterialProperty prop_AmbientGroundThreshold = null;
        private MaterialProperty prop_AmbientIntensity = null;
        private MaterialProperty prop_TintMaskSource = null;
        private MaterialProperty prop_LitTint = null;
        private MaterialProperty prop_LitThreshold = null;
        private MaterialProperty prop_ShadowTint = null;
        private MaterialProperty prop_ShadowThreshold = null;
        // specular properties
        private MaterialProperty prop_ToggleSpecular = null;
        private MaterialProperty prop_ToggleVertexSpecular = null;
        private MaterialProperty prop_SpecularMode = null;
        private MaterialProperty prop_MSSO = null;
        private MaterialProperty prop_Metallic = null;
        private MaterialProperty prop_Glossiness = null;
        private MaterialProperty prop_Occlusion = null;
        private MaterialProperty prop_Specular = null;
        private MaterialProperty prop_SpecularIntensity = null;
        private MaterialProperty prop_SpecularTintTexture = null;
        private MaterialProperty prop_SpecularTint = null;
        private MaterialProperty prop_TangentMap = null;
        private MaterialProperty prop_Anisotropy = null;
        private MaterialProperty prop_ReplaceSpecular = null;
        private MaterialProperty prop_HighlightRamp = null;
        private MaterialProperty prop_HighlightHardness = null;
        private MaterialProperty prop_HighlightRampColor = null;
        private MaterialProperty prop_HighlightIntensity = null;
        private MaterialProperty prop_HighlightRampOffset = null;
        private MaterialProperty prop_HairFlowMap = null;
        private MaterialProperty prop_PrimarySpecularShift = null;
        private MaterialProperty prop_SecondarySpecularShift = null;
        private MaterialProperty prop_SecondarySpecularColor = null;
        private MaterialProperty prop_SpecularExponent = null;
        private MaterialProperty prop_SheenColor = null;
        private MaterialProperty prop_SheenIntensity = null;
        private MaterialProperty prop_SheenRoughness = null;
        // rim lighting properties
        private MaterialProperty prop_ToggleRimlight = null;
        private MaterialProperty prop_RimColor = null;
        private MaterialProperty prop_RimWidth = null;
        private MaterialProperty prop_RimIntensity = null;
        private MaterialProperty prop_RimLightBased = null;
        // clearcoat properties
        private MaterialProperty prop_ToggleClearcoat = null;
        private MaterialProperty prop_ClearcoatStrength = null;
        private MaterialProperty prop_ClearcoatReflectionStrength = null;
        private MaterialProperty prop_ClearcoatMap = null;
        private MaterialProperty prop_ClearcoatRoughness = null;
        private MaterialProperty prop_ClearcoatColor = null;
        // matcap properties
        private MaterialProperty prop_ToggleMatcap = null;
        private MaterialProperty prop_MatcapTex = null;
        private MaterialProperty prop_MatcapTint = null;
        private MaterialProperty prop_MatcapIntensity = null;
        private MaterialProperty prop_MatcapBlendMode = null;
        private MaterialProperty prop_MatcapMask = null;
        private MaterialProperty prop_MatcapSmoothnessEnabled = null;
        private MaterialProperty prop_MatcapSmoothness = null;
        // decal one properties
        private MaterialProperty prop_Decal1Enable = null;
        private MaterialProperty prop_Decal1Tex = null;
        private MaterialProperty prop_Decal1Tint = null;
        private MaterialProperty prop_Decal1BlendMode = null;
        private MaterialProperty prop_Decal1IsTriplanar = null;
        private MaterialProperty prop_Decal1Position = null;
        private MaterialProperty prop_Decal1Scale = null;
        private MaterialProperty prop_Decal1Rotation = null;
        private MaterialProperty prop_Decal1TriplanarPosition = null;
        private MaterialProperty prop_Decal1TriplanarScale = null;
        private MaterialProperty prop_Decal1TriplanarRotation = null;
        private MaterialProperty prop_Decal1TriplanarSharpness = null;
        private MaterialProperty prop_Decal1Repeat = null;
        private MaterialProperty prop_Decal1Scroll = null;
        private MaterialProperty prop_Decal1HueShift = null;
        private MaterialProperty prop_Decal1AutoCycleHue = null;
        private MaterialProperty prop_Decal1CycleSpeed = null;
        // decal two properties
        private MaterialProperty prop_Decal2Enable = null;
        private MaterialProperty prop_Decal2Tex = null;
        private MaterialProperty prop_Decal2Tint = null;
        private MaterialProperty prop_Decal2BlendMode = null;
        private MaterialProperty prop_Decal2IsTriplanar = null;
        private MaterialProperty prop_Decal2Position = null;
        private MaterialProperty prop_Decal2Scale = null;
        private MaterialProperty prop_Decal2Rotation = null;
        private MaterialProperty prop_Decal2TriplanarPosition = null;
        private MaterialProperty prop_Decal2TriplanarScale = null;
        private MaterialProperty prop_Decal2TriplanarRotation = null;
        private MaterialProperty prop_Decal2TriplanarSharpness = null;
        private MaterialProperty prop_Decal2Repeat = null;
        private MaterialProperty prop_Decal2Scroll = null;
        private MaterialProperty prop_Decal2HueShift = null;
        private MaterialProperty prop_Decal2AutoCycleHue = null;
        private MaterialProperty prop_Decal2CycleSpeed = null;
        // post processing properties
        private MaterialProperty prop_TogglePostProcessing = null;
        private MaterialProperty prop_RGBColor = null;
        private MaterialProperty prop_RGBBlendMode = null;
        private MaterialProperty prop_HSVMode = null;
        private MaterialProperty prop_HSVHue = null;
        private MaterialProperty prop_HSVSaturation = null;
        private MaterialProperty prop_HSVValue = null;
        private MaterialProperty prop_ToggleHueShift = null;
        private MaterialProperty prop_HueShift = null;
        private MaterialProperty prop_ToggleAutoCycle = null;
        private MaterialProperty prop_AutoCycleSpeed = null;
        private MaterialProperty prop_ColorGradingLUT = null;
        private MaterialProperty prop_ColorGradingIntensity = null;
        private MaterialProperty prop_BlackAndWhite = null;
        private MaterialProperty prop_Brightness = null;
        // cubemap properties
        private MaterialProperty prop_ToggleCubemap = null;
        private MaterialProperty prop_CubemapTex = null;
        private MaterialProperty prop_CubemapTint = null;
        private MaterialProperty prop_CubemapIntensity = null;
        private MaterialProperty prop_CubemapBlendMode = null;
        // parallax properties
        private MaterialProperty prop_ToggleParallax = null;
        private MaterialProperty prop_ParallaxMode = null;
        private MaterialProperty prop_ParallaxMap = null;
        private MaterialProperty prop_ParallaxStrength = null;
        private MaterialProperty prop_ParallaxSteps = null;
        private MaterialProperty prop_ToggleParallaxShadows = null;
        private MaterialProperty prop_ParallaxShadowSteps = null;
        private MaterialProperty prop_ParallaxShadowStrength = null;
        // subsurface properties
        private MaterialProperty prop_ToggleSSS = null;
        private MaterialProperty prop_SSSColor = null;
        private MaterialProperty prop_SSSStrength = null;
        private MaterialProperty prop_SSSPower = null;
        private MaterialProperty prop_SSSDistortion = null;
        private MaterialProperty prop_SSSThicknessMap = null;
        private MaterialProperty prop_SSSThickness = null;
        // shadow map properties
        private MaterialProperty prop_ToggleShadowMap = null;
        private MaterialProperty prop_ShadowMap = null;
        private MaterialProperty prop_ShadowMapIntensity = null;
        // detail map properties
        private MaterialProperty prop_ToggleDetail = null;
        private MaterialProperty prop_DetailAlbedoMap = null;
        private MaterialProperty prop_DetailNormalMap = null;
        private MaterialProperty prop_DetailTiling = null;
        private MaterialProperty prop_DetailNormalStrength = null;
        // dissolve properties
        private MaterialProperty prop_ToggleDissolve = null;
        private MaterialProperty prop_DissolveProgress = null;
        private MaterialProperty prop_DissolveType = null;
        private MaterialProperty prop_DissolveEdgeColor = null;
        private MaterialProperty prop_DissolveEdgeWidth = null;
        private MaterialProperty prop_DissolveEdgeMode = null;
        private MaterialProperty prop_DissolveEdgeSharpness = null;
        private MaterialProperty prop_DissolveNoiseTex = null;
        private MaterialProperty prop_DissolveNoiseScale = null;
        private MaterialProperty prop_DissolveDirection = null;
        private MaterialProperty prop_DissolveDirectionSpace = null;
        private MaterialProperty prop_DissolveDirectionBounds = null;
        private MaterialProperty prop_DissolveVoxelDensity = null;
        // pathing properties
        private MaterialProperty prop_TogglePathing = null;
        private MaterialProperty prop_PathingMappingMode = null;
        private MaterialProperty prop_PathingMap = null;
        private MaterialProperty prop_PathingScale = null;
        private MaterialProperty prop_PathingBlendMode = null;
        private MaterialProperty prop_PathingColor = null;
        private MaterialProperty prop_PathingEmission = null;
        private MaterialProperty prop_PathingType = null;
        private MaterialProperty prop_PathingSpeed = null;
        private MaterialProperty prop_PathingWidth = null;
        private MaterialProperty prop_PathingSoftness = null;
        private MaterialProperty prop_PathingOffset = null;
        private MaterialProperty prop_PathingColorMode = null;
        private MaterialProperty prop_PathingTexture = null;
        private MaterialProperty prop_PathingColor2 = null;
        // screen space rim lighting properties
        private MaterialProperty prop_ToggleDepthRim = null;
        private MaterialProperty prop_DepthRimColor = null;
        private MaterialProperty prop_DepthRimWidth = null;
        private MaterialProperty prop_DepthRimThreshold = null;
        private MaterialProperty prop_DepthRimSharpness = null;
        private MaterialProperty prop_DepthRimBlendMode = null;
        // audiolink properties
        private MaterialProperty prop_ToggleAudioLink = null;
        private MaterialProperty prop_AudioLinkFallback = null;
        private MaterialProperty prop_AudioLinkEmissionBand = null;
        private MaterialProperty prop_AudioLinkEmissionStrength = null;
        private MaterialProperty prop_AudioLinkEmissionRange = null;
        private MaterialProperty prop_AudioLinkRimBand = null;
        private MaterialProperty prop_AudioLinkRimStrength = null;
        private MaterialProperty prop_AudioLinkRimRange = null;
        private MaterialProperty prop_AudioLinkHueShiftBand = null;
        private MaterialProperty prop_AudioLinkHueShiftStrength = null;
        private MaterialProperty prop_AudioLinkHueShiftRange = null;
        private MaterialProperty prop_AudioLinkDecalHueBand = null;
        private MaterialProperty prop_AudioLinkDecalHueStrength = null;
        private MaterialProperty prop_AudioLinkDecalHueRange = null;
        private MaterialProperty prop_AudioLinkDecalEmissionBand = null;
        private MaterialProperty prop_AudioLinkDecalEmissionStrength = null;
        private MaterialProperty prop_AudioLinkDecalEmissionRange = null;
        private MaterialProperty prop_AudioLinkDecalOpacityBand = null;
        private MaterialProperty prop_AudioLinkDecalOpacityStrength = null;
        private MaterialProperty prop_AudioLinkDecalOpacityRange = null;
        private MaterialProperty prop_AudioLinkVertexBand = null;
        private MaterialProperty prop_AudioLinkVertexStrength = null;
        private MaterialProperty prop_AudioLinkVertexRange = null;
        private MaterialProperty prop_AudioLinkOutlineBand = null;
        private MaterialProperty prop_AudioLinkOutlineStrength = null;
        private MaterialProperty prop_AudioLinkOutlineRange = null;
        private MaterialProperty prop_AudioLinkMatcapBand = null;
        private MaterialProperty prop_AudioLinkMatcapStrength = null;
        private MaterialProperty prop_AudioLinkMatcapRange = null;
        private MaterialProperty prop_AudioLinkPathingBand = null;
        private MaterialProperty prop_AudioLinkPathingStrength = null;
        private MaterialProperty prop_AudioLinkPathingRange = null;
        private MaterialProperty prop_AudioLinkGlitterBand = null;
        private MaterialProperty prop_AudioLinkGlitterStrength = null;
        private MaterialProperty prop_AudioLinkGlitterRange = null;
        private MaterialProperty prop_AudioLinkIridescenceBand = null;
        private MaterialProperty prop_AudioLinkIridescenceStrength = null;
        private MaterialProperty prop_AudioLinkIridescenceRange = null;
        // ltcgi properties
        private MaterialProperty prop_ToggleLTCGI = null;
        // glitter properties
        private MaterialProperty prop_ToggleGlitter = null;
        private MaterialProperty prop_GlitterMode = null;
        private MaterialProperty prop_GlitterNoiseTex = null;
        private MaterialProperty prop_GlitterMask = null;
        private MaterialProperty prop_GlitterTint = null;
        private MaterialProperty prop_GlitterFrequency = null;
        private MaterialProperty prop_GlitterThreshold = null;
        private MaterialProperty prop_GlitterSize = null;
        private MaterialProperty prop_GlitterFlickerSpeed = null;
        private MaterialProperty prop_GlitterBrightness = null;
        private MaterialProperty prop_GlitterContrast = null;
        private MaterialProperty prop_ToggleGlitterRainbow = null;
        private MaterialProperty prop_GlitterRainbowSpeed = null;
        // distance fading properties
        private MaterialProperty prop_ToggleDistanceFade = null;
        private MaterialProperty prop_DistanceFadeReference = null;
        private MaterialProperty prop_ToggleNearFade = null;
        private MaterialProperty prop_NearFadeMode = null;
        private MaterialProperty prop_NearFadeDitherScale = null;
        private MaterialProperty prop_NearFadeStart = null;
        private MaterialProperty prop_NearFadeEnd = null;
        private MaterialProperty prop_ToggleFarFade = null;
        private MaterialProperty prop_FarFadeStart = null;
        private MaterialProperty prop_FarFadeEnd = null;
        // iridescence properties
        private MaterialProperty prop_ToggleIridescence = null;
        private MaterialProperty prop_IridescenceMode = null;
        private MaterialProperty prop_IridescenceMask = null;
        private MaterialProperty prop_IridescenceTint = null;
        private MaterialProperty prop_IridescenceIntensity = null;
        private MaterialProperty prop_IridescenceBlendMode = null;
        private MaterialProperty prop_IridescenceParallax = null;
        private MaterialProperty prop_IridescenceRamp = null;
        private MaterialProperty prop_IridescencePower = null;
        private MaterialProperty prop_IridescenceFrequency = null;
        // shadow textures properties
        private MaterialProperty prop_ToggleShadowTexture = null;
        private MaterialProperty prop_ShadowTextureMappingMode = null;
        private MaterialProperty prop_ShadowTextureIntensity = null;
        private MaterialProperty prop_ShadowTex = null;
        private MaterialProperty prop_ShadowPatternColor = null;
        private MaterialProperty prop_ShadowPatternScale = null;
        private MaterialProperty prop_ShadowPatternTriplanarSharpness = null;
        private MaterialProperty prop_ShadowPatternTransparency = null;
        // flatten model properties
        private MaterialProperty prop_ToggleFlatModel = null;
        private MaterialProperty prop_FlatModeAutoflip = null;
        private MaterialProperty prop_FlatModel = null;
        private MaterialProperty prop_FlatModelDepthCorrection = null;
        private MaterialProperty prop_FlatModelFacing = null;
        private MaterialProperty prop_FlatModelLockAxis = null;
        // world aligned properties
        private MaterialProperty prop_ToggleWorldEffect = null;
        private MaterialProperty prop_WorldEffectBlendMode = null;
        private MaterialProperty prop_WorldEffectTex = null;
        private MaterialProperty prop_WorldEffectColor = null;
        private MaterialProperty prop_WorldEffectDirection = null;
        private MaterialProperty prop_WorldEffectScale = null;
        private MaterialProperty prop_WorldEffectBlendSharpness = null;
        private MaterialProperty prop_WorldEffectIntensity = null;
        private MaterialProperty prop_WorldEffectPosition = null;
        private MaterialProperty prop_WorldEffectRotation = null;
        // vrchat mirror properties
        private MaterialProperty prop_ToggleMirrorDetection = null;
        private MaterialProperty prop_MirrorDetectionMode = null;
        private MaterialProperty prop_MirrorDetectionTexture = null;
        // touch reactive properties
        private MaterialProperty prop_ToggleTouchReactive = null;
        private MaterialProperty prop_TouchColor = null;
        private MaterialProperty prop_TouchRadius = null;
        private MaterialProperty prop_TouchHardness = null;
        private MaterialProperty prop_TouchMode = null;
        private MaterialProperty prop_TouchRainbowSpeed = null;
        private MaterialProperty prop_TouchRainbowSpread = null;
        // refraction properties
        private MaterialProperty prop_ToggleRefraction = null;
        private MaterialProperty prop_RefractionMask = null;
        private MaterialProperty prop_RefractionTint = null;
        private MaterialProperty prop_RefractionIOR = null;
        private MaterialProperty prop_RefractionFresnel = null;
        private MaterialProperty prop_RefractionOpacity = null;
        private MaterialProperty prop_RefractionSeeThrough = null;
        private MaterialProperty prop_RefractionMode = null;
        private MaterialProperty prop_RefractionMixStrength = null;
        private MaterialProperty prop_RefractionBlendMode = null;
        private MaterialProperty prop_CausticsTex = null;
        private MaterialProperty prop_CausticsColor = null;
        private MaterialProperty prop_CausticsTiling = null;
        private MaterialProperty prop_CausticsSpeed = null;
        private MaterialProperty prop_CausticsIntensity = null;
        private MaterialProperty prop_DistortionNoiseTex = null;
        private MaterialProperty prop_DistortionNoiseTiling = null;
        private MaterialProperty prop_DistortionNoiseStrength = null;
        private MaterialProperty prop_RefractionDistortionMode = null;
        private MaterialProperty prop_RefractionCAStrength = null;
        private MaterialProperty prop_RefractionBlurStrength = null;
        private MaterialProperty prop_RefractionCAUseFresnel = null;
        private MaterialProperty prop_RefractionCAEdgeFade = null;
        // dither properties
        private MaterialProperty prop_ToggleDither = null;
        private MaterialProperty prop_DitherAmount = null;
        private MaterialProperty prop_DitherScale = null;
        private MaterialProperty prop_DitherSpace = null;
        // ps1 properties
        private MaterialProperty prop_TogglePS1 = null;
        private MaterialProperty prop_PS1Rounding = null;
        private MaterialProperty prop_PS1RoundingPrecision = null;
        private MaterialProperty prop_PS1Affine = null;
        private MaterialProperty prop_PS1AffineStrength = null;
        private MaterialProperty prop_PS1Compression = null;
        private MaterialProperty prop_PS1CompressionPrecision = null;
        // vertex distortion properties
        private MaterialProperty prop_ToggleVertexDistortion = null;
        private MaterialProperty prop_VertexDistortionMode = null;
        private MaterialProperty prop_VertexDistortionStrength = null;
        private MaterialProperty prop_VertexDistortionSpeed = null;
        private MaterialProperty prop_VertexDistortionFrequency = null;
        // fake screenspace reflection properties
        private MaterialProperty prop_ToggleSSR = null;
        private MaterialProperty prop_SSRMask = null;
        private MaterialProperty prop_SSRTint = null;
        private MaterialProperty prop_SSRIntensity = null;
        private MaterialProperty prop_SSRBlendMode = null;
        private MaterialProperty prop_SSRFresnelPower = null;
        private MaterialProperty prop_SSRFresnelScale = null;
        private MaterialProperty prop_SSRFresnelBias = null;
        private MaterialProperty prop_SSRParallax = null;
        private MaterialProperty prop_SSRDistortionMap = null;
        private MaterialProperty prop_SSRDistortionStrength = null;
        private MaterialProperty prop_SSRWorldDistortion = null;
        private MaterialProperty prop_SSRBlur = null;
        private MaterialProperty prop_SSRMaxSteps = null;
        private MaterialProperty prop_SSRStepSize = null;
        private MaterialProperty prop_SSREdgeFade = null;
        private MaterialProperty prop_SSRCoverage = null;
        private MaterialProperty prop_SSRCamFade = null;
        private MaterialProperty prop_SSRCamFadeStart = null;
        private MaterialProperty prop_SSRCamFadeEnd = null;
        private MaterialProperty prop_SSRFlipUV = null;
        private MaterialProperty prop_SSRAdaptiveStep = null;
        private MaterialProperty prop_SSRThickness = null;
        private MaterialProperty prop_SSROutOfViewMode = null;
        private MaterialProperty prop_SSRMode = null;
        // outline properties
        private MaterialProperty prop_OutlineColor = null;
        private MaterialProperty prop_OutlineWidth = null;
        private MaterialProperty prop_OutlineVertexColorMask = null;
        private MaterialProperty prop_OutlineDistanceFade = null;
        private MaterialProperty prop_OutlineFadeStart = null;
        private MaterialProperty prop_OutlineFadeEnd = null;
        private MaterialProperty prop_OutlineHueShift = null;
        private MaterialProperty prop_OutlineHueShiftSpeed = null;
        private MaterialProperty prop_OutlineOpacity = null;
        // indirect lighting
        private MaterialProperty prop_IndirectFallbackMode = null;
        private MaterialProperty prop_IndirectOverride = null;
        private MaterialProperty prop_FallbackCubemap = null;
        // uv settings
        private MaterialProperty prop_MainTex_UV = null;
        private MaterialProperty prop_BumpMap_UV = null;
        private MaterialProperty prop_MSSO_UV = null;
        private MaterialProperty prop_SpecularTintTexture_UV = null;
        private MaterialProperty prop_TangentMap_UV = null;
        private MaterialProperty prop_EmissionMap_UV = null;
        private MaterialProperty prop_ClearcoatMap_UV = null;
        private MaterialProperty prop_MatcapMask_UV = null;
        private MaterialProperty prop_ParallaxMap_UV = null;
        private MaterialProperty prop_ThicknessMap_UV = null;
        private MaterialProperty prop_DetailMap_UV = null;
        private MaterialProperty prop_Decal1_UV = null;
        private MaterialProperty prop_Decal2_UV = null;
        private MaterialProperty prop_Glitter_UV = null;
        private MaterialProperty prop_IridescenceMask_UV = null;
        private MaterialProperty prop_GlitterMask_UV = null;
        private MaterialProperty prop_HairFlowMap_UV = null;
        private MaterialProperty prop_ShadowTex_UV = null;
        private MaterialProperty prop_Flowmap_UV = null;
        private MaterialProperty prop_MirrorDetectionTexture_UV = null;
        private MaterialProperty prop_RefractionMask_UV = null;
        private MaterialProperty prop_PathingMap_UV = null;
        private MaterialProperty prop_ShadowMap_UV = null;
        private MaterialProperty prop_PathingTexture_UV = null;
        private MaterialProperty prop_Dither_UV = null;
        #endregion // Properties

        // unload the interface (ex. on shader change)
        public static void unload()
        {
            loaded = false;
            detected_variants = null;
            configs = null;
            languages = null;
            theme = null;
            header = null;
            announcement = null;
            update = null;
            docs = null;
            socials_menu = null;
            cushion = null;
            beauty_blender = null;
            bags = null;
            meta = null;
            config_tab = null;
            license_tab = null;
            config_menu = null;
            presets_tab = null;
            license_menu = null;
            presets_menu = null;
            #region Tabs
            tab_main = null;
            sub_tab_rendering = null;
            sub_tab_textures = null;
            sub_tab_uv_manipulation = null;
            sub_tab_uv_effects = null;
            sub_tab_vertex_manipulation = null;
            sub_tab_decal_one = null;
            sub_tab_decal_two = null;
            sub_tab_post_processing = null;
            sub_tab_uv_sets = null;
            tab_lighting = null;
            sub_tab_lighting_model = null;
            sub_tab_anime = null;
            tab_specular = null;
            sub_tab_pbr_specular = null;
            sub_tab_stylised_specular = null;
            sub_tab_emission = null;
            sub_tab_light_limiting = null;
            tab_shading = null;
            sub_tab_rim_lighting = null;
            sub_tab_depth_rim = null;
            sub_tab_clear_coat = null;
            sub_tab_matcap = null;
            sub_tab_cubemap = null;
            sub_tab_parallax = null;
            sub_tab_subsurface = null;
            sub_tab_detail_map = null;
            sub_tab_shadow_map = null;
            tab_effects = null;
            sub_tab_dissolve = null;
            sub_tab_pathing = null;
            sub_tab_glitter = null;
            sub_tab_distance_fading = null;
            sub_tab_iridescence = null;
            sub_tab_shadow_textures = null;
            sub_tab_flatten_model = null;
            sub_tab_world_aligned = null;
            sub_tab_vrchat_mirror = null;
            sub_tab_touch_interactions = null;
            sub_tab_dither = null;
            sub_tab_ps1 = null;
            sub_tab_vertex_distortion = null;
            sub_tab_refraction = null;
            sub_tab_screenspace_reflection = null;
            tab_outline = null;
            tab_third_party = null;
            sub_tab_audiolink = null;
            sub_tab_superplug = null;
            sub_tab_ltcgi = null;
            #endregion // Tabs
        }

        // load (/reload) the interface (ex. on language change)
        public void load(ref Material targetMat)
        {
            loaded_material = AssetDatabase.AssetPathToGUID(AssetDatabase.GetAssetPath(targetMat));
            detected_variants = ShaderVariant.DetectCapabilities(ref targetMat);
            configs = new Config();
            languages = new Languages(configs.json_data.@interface.language);
            meta = new Metadata();
            theme = new Theme(ref configs, ref languages, ref meta);
            license_tab = new Tab(ref targetMat, ref theme, (int)Tab.tab_sizes.Primary, 0, languages.speak("tab_license"));
            config_tab = new Tab(ref targetMat, ref theme, (int)Tab.tab_sizes.Primary, 1, languages.speak("tab_config"));
            presets_tab = new Tab(ref targetMat, ref theme, (int)Tab.tab_sizes.Primary, 2, languages.speak("tab_presets"));
            config_menu = new ConfigMenu(ref theme, ref languages, ref configs, ref config_tab);
            license_menu = new LicenseMenu(ref theme, ref languages, ref license_tab);
            header = new Header(ref theme);
            announcement = new Announcement(ref theme);
            update = new Update(ref theme);
            docs = new Docs(ref theme);
            socials_menu = new SocialsMenu(ref theme);
            cushion = new Cushion(targetMat);
            beauty_blender = new BeautyBlender(targetMat);
            bags = new Bags(ref languages);
            presets_menu = new PresetsMenu(ref theme, ref bags, ref targetMat, ref presets_tab);
            #region Tabs
            tab_main = new Tab(ref targetMat, ref theme, (int)Tab.tab_sizes.Primary, 0, languages.speak("tab_main"));
            sub_tab_rendering = new Tab(ref targetMat, ref theme, (int)Tab.tab_sizes.Sub, 0, languages.speak("sub_tab_rendering"));
            sub_tab_textures = new Tab(ref targetMat, ref theme, (int)Tab.tab_sizes.Sub, 1, languages.speak("sub_tab_textures"));
            sub_tab_uv_manipulation = new Tab(ref targetMat, ref theme, (int)Tab.tab_sizes.Sub, 2, languages.speak("sub_tab_uv_manipulation"));
            sub_tab_uv_effects = new Tab(ref targetMat, ref theme, (int)Tab.tab_sizes.Sub, 3, languages.speak("sub_tab_uv_effects"), null, "_ToggleUVEffects");
            sub_tab_vertex_manipulation = new Tab(ref targetMat, ref theme, (int)Tab.tab_sizes.Sub, 4, languages.speak("sub_tab_vertex_manipulation"));
            sub_tab_decal_one = new Tab(ref targetMat, ref theme, (int)Tab.tab_sizes.Sub, 5, languages.speak("sub_tab_decal_one"), null, "_Decal1Enable");
            sub_tab_decal_two = new Tab(ref targetMat, ref theme, (int)Tab.tab_sizes.Sub, 6, languages.speak("sub_tab_decal_two"), null, "_Decal2Enable");
            sub_tab_post_processing = new Tab(ref targetMat, ref theme, (int)Tab.tab_sizes.Sub, 7, languages.speak("sub_tab_post_processing"), null, "_TogglePostProcessing");
            sub_tab_uv_sets = new Tab(ref targetMat, ref theme, (int)Tab.tab_sizes.Sub, 8, languages.speak("sub_tab_uv_sets"));
            tab_lighting = new Tab(ref targetMat, ref theme, (int)Tab.tab_sizes.Primary, 1, languages.speak("tab_lighting"));
            sub_tab_lighting_model = new Tab(ref targetMat, ref theme, (int)Tab.tab_sizes.Sub, 0, languages.speak("sub_tab_lighting_model"));
            sub_tab_anime = new Tab(ref targetMat, ref theme, (int)Tab.tab_sizes.Sub, 1, languages.speak("sub_tab_anime"), null, "_ToggleAnimeLighting");
            tab_specular = new Tab(ref targetMat, ref theme, (int)Tab.tab_sizes.Primary, 2, languages.speak("tab_specular"));
            sub_tab_pbr_specular = new Tab(ref targetMat, ref theme, (int)Tab.tab_sizes.Sub, 0, languages.speak("sub_tab_pbr_specular"));
            sub_tab_stylised_specular = new Tab(ref targetMat, ref theme, (int)Tab.tab_sizes.Sub, 1, languages.speak("sub_tab_stylised_specular"));
            sub_tab_emission = new Tab(ref targetMat, ref theme, (int)Tab.tab_sizes.Sub, 3, languages.speak("sub_tab_emission"), null, "_ToggleEmission");
            sub_tab_light_limiting = new Tab(ref targetMat, ref theme, (int)Tab.tab_sizes.Sub, 4, languages.speak("sub_tab_light_limiting"));
            tab_shading = new Tab(ref targetMat, ref theme, (int)Tab.tab_sizes.Primary, 3, languages.speak("tab_shading"));
            sub_tab_rim_lighting = new Tab(ref targetMat, ref theme, (int)Tab.tab_sizes.Sub, 0, languages.speak("sub_tab_rim_lighting"), null, "_ToggleRimlight");
            sub_tab_depth_rim = new Tab(ref targetMat, ref theme, (int)Tab.tab_sizes.Sub, 1, languages.speak("sub_tab_depth_rim"), null, "_ToggleDepthRim");
            sub_tab_clear_coat = new Tab(ref targetMat, ref theme, (int)Tab.tab_sizes.Sub, 2, languages.speak("sub_tab_clear_coat"), null, "_ToggleClearcoat");
            sub_tab_matcap = new Tab(ref targetMat, ref theme, (int)Tab.tab_sizes.Sub, 3, languages.speak("sub_tab_matcap"), null, "_ToggleMatcap");
            sub_tab_cubemap = new Tab(ref targetMat, ref theme, (int)Tab.tab_sizes.Sub, 4, languages.speak("sub_tab_cubemap"), null, "_ToggleCubemap");
            sub_tab_parallax = new Tab(ref targetMat, ref theme, (int)Tab.tab_sizes.Sub, 5, languages.speak("sub_tab_parallax"), null, "_ToggleParallax");
            sub_tab_subsurface = new Tab(ref targetMat, ref theme, (int)Tab.tab_sizes.Sub, 6, languages.speak("sub_tab_subsurface"), null, "_ToggleSSS");
            sub_tab_detail_map = new Tab(ref targetMat, ref theme, (int)Tab.tab_sizes.Sub, 7, languages.speak("sub_tab_detail_map"), null, "_ToggleDetail");
            sub_tab_shadow_map = new Tab(ref targetMat, ref theme, (int)Tab.tab_sizes.Sub, 8, languages.speak("sub_tab_shadow_map"), null, "_ToggleShadowMap");
            tab_effects = new Tab(ref targetMat, ref theme, (int)Tab.tab_sizes.Primary, 4, languages.speak("tab_effects"));
            sub_tab_dissolve = new Tab(ref targetMat, ref theme, (int)Tab.tab_sizes.Sub, 0, languages.speak("sub_tab_dissolve"), null, "_ToggleDissolve");
            sub_tab_pathing = new Tab(ref targetMat, ref theme, (int)Tab.tab_sizes.Sub, 1, languages.speak("sub_tab_pathing"), null, "_TogglePathing");
            sub_tab_glitter = new Tab(ref targetMat, ref theme, (int)Tab.tab_sizes.Sub, 3, languages.speak("sub_tab_glitter"), null, "_ToggleGlitter");
            sub_tab_distance_fading = new Tab(ref targetMat, ref theme, (int)Tab.tab_sizes.Sub, 4, languages.speak("sub_tab_distance_fading"), null, "_ToggleDistanceFade");
            sub_tab_iridescence = new Tab(ref targetMat, ref theme, (int)Tab.tab_sizes.Sub, 5, languages.speak("sub_tab_iridescence"), null, "_ToggleIridescence");
            sub_tab_shadow_textures = new Tab(ref targetMat, ref theme, (int)Tab.tab_sizes.Sub, 6, languages.speak("sub_tab_shadow_textures"), null, "_ToggleShadowTexture");
            sub_tab_flatten_model = new Tab(ref targetMat, ref theme, (int)Tab.tab_sizes.Sub, 7, languages.speak("sub_tab_flatten_model"), null, "_ToggleFlatModel");
            sub_tab_world_aligned = new Tab(ref targetMat, ref theme, (int)Tab.tab_sizes.Sub, 8, languages.speak("sub_tab_world_aligned"), null, "_ToggleWorldEffect");
            sub_tab_vrchat_mirror = new Tab(ref targetMat, ref theme, (int)Tab.tab_sizes.Sub, 9, languages.speak("sub_tab_vrchat_mirror"), null, "_ToggleMirrorDetection");
            sub_tab_touch_interactions = new Tab(ref targetMat, ref theme, (int)Tab.tab_sizes.Sub, 10, languages.speak("sub_tab_touch_interactions"), null, "_ToggleTouchReactive");
            sub_tab_dither = new Tab(ref targetMat, ref theme, (int)Tab.tab_sizes.Sub, 11, languages.speak("sub_tab_dither"), null, "_ToggleDither");
            sub_tab_ps1 = new Tab(ref targetMat, ref theme, (int)Tab.tab_sizes.Sub, 12, languages.speak("sub_tab_ps1"), null, "_TogglePS1");
            sub_tab_vertex_distortion = new Tab(ref targetMat, ref theme, (int)Tab.tab_sizes.Sub, 13, languages.speak("sub_tab_vertex_distortion"), null, "_ToggleVertexDistortion");
            sub_tab_refraction = new Tab(ref targetMat, ref theme, (int)Tab.tab_sizes.Sub, 14, languages.speak("sub_tab_refraction"), Project.shader_variants[2], "_ToggleRefraction");
            sub_tab_screenspace_reflection = new Tab(ref targetMat, ref theme, (int)Tab.tab_sizes.Sub, 15, languages.speak("sub_tab_screenspace_reflection"), Project.shader_variants[2], "_ToggleSSR");
            tab_outline = new Tab(ref targetMat, ref theme, (int)Tab.tab_sizes.Primary, 5, languages.speak("tab_outline"), Project.shader_variants[1]);
            tab_third_party = new Tab(ref targetMat, ref theme, (int)Tab.tab_sizes.Primary, 6, languages.speak("tab_third_party"));
            sub_tab_audiolink = new Tab(ref targetMat, ref theme, (int)Tab.tab_sizes.Sub, 0, languages.speak("sub_tab_audiolink"), null, "_ToggleAudioLink");
            sub_tab_superplug = new Tab(ref targetMat, ref theme, (int)Tab.tab_sizes.Sub, 1, languages.speak("sub_tab_superplug"));
            sub_tab_ltcgi = new Tab(ref targetMat, ref theme, (int)Tab.tab_sizes.Sub, 2, languages.speak("sub_tab_ltcgi"), null, "_ToggleLTCGI");
            #endregion // Tabs
            loaded = true;
        }

        // determine if a load is needed or not
        public void repaint_dazzle(ref Material targetMat)
        {
            // first time loading
            if (!loaded) 
            {
                load(ref targetMat);
                return;
            }
            // check if material changed
            if (loaded_material != AssetDatabase.AssetPathToGUID(AssetDatabase.GetAssetPath(targetMat))) 
            {
                unload();
                load(ref targetMat);
                return;
            }
            // always update variants in case of shader swap
            detected_variants = ShaderVariant.DetectCapabilities(ref targetMat);
        }

        // per-shader ui here
        public override void OnGUI(MaterialEditor materialEditor, MaterialProperty[] properties)
        {
            Material targetMat = materialEditor.target as Material;
            repaint_dazzle(ref targetMat);
            EditorGUI.BeginChangeCheck();
            header.draw();
            update.draw();
            #region Backlace
            // main tab
            tab_main.draw();
            if (tab_main.is_expanded) {
                Components.start_foldout();
                sub_tab_rendering.draw();
                if (sub_tab_rendering.is_expanded) {
                    // main - rendering
                    prop_BlendMode = FindProperty("_BlendMode", properties);
                    prop_OverrideBaseBlend = FindProperty("_OverrideBaseBlend", properties);
                    prop_SrcBlend = FindProperty("_SrcBlend", properties);
                    prop_DstBlend = FindProperty("_DstBlend", properties);
                    prop_BlendOp = FindProperty("_BlendOp", properties);
                    prop_OverrideAddBlend = FindProperty("_OverrideAddBlend", properties);
                    prop_AddSrcBlend = FindProperty("_AddSrcBlend", properties);
                    prop_AddDstBlend = FindProperty("_AddDstBlend", properties);
                    prop_AddBlendOp = FindProperty("_AddBlendOp", properties);
                    prop_OverrideZWrite = FindProperty("_OverrideZWrite", properties);
                    prop_ZWrite = FindProperty("_ZWrite", properties);
                    prop_OverrideRenderQueue = FindProperty("_OverrideRenderQueue", properties);
                    prop_Cull = FindProperty("_Cull", properties);
                    prop_ZTest = FindProperty("_ZTest", properties);
                    prop_StencilRef = FindProperty("_StencilRef", properties);
                    prop_StencilComp = FindProperty("_StencilComp", properties);
                    prop_StencilPass = FindProperty("_StencilPass", properties);
                    prop_StencilFail = FindProperty("_StencilFail", properties);
                    prop_StencilZFail = FindProperty("_StencilZFail", properties);
                    prop_OutlineStencilRef = FindProperty("_OutlineStencilRef", properties);
                    prop_OutlineStencilComp = FindProperty("_OutlineStencilComp", properties);
                    prop_OutlineStencilPass = FindProperty("_OutlineStencilPass", properties);
                    prop_OutlineStencilFail = FindProperty("_OutlineStencilFail", properties);
                    prop_OutlineStencilZFail = FindProperty("_OutlineStencilZFail", properties);
                    prop_VRCFallback = FindProperty("_VRCFallback", properties);
                    prop_ToggleFlipNormals = FindProperty("_ToggleFlipNormals", properties);
                    var blendModeNames = new string[] {
                        "Opaque", "Cutout", "Fade", "Opaque Fade", "Transparent", "Premultiply",
                        "Additive", "Soft Additive", "Multiplicative", "2x Multiplicative"
                    };
                    int currentMode = (int)prop_BlendMode.floatValue;
                    int newMode = EditorGUILayout.Popup(languages.speak("prop_BlendMode"), currentMode, blendModeNames);
                    if (newMode != currentMode)
                    {
                        prop_BlendMode.floatValue = newMode;
                    }
                    materialEditor.ShaderProperty(prop_VRCFallback, languages.speak("prop_VRCFallback"));
                    materialEditor.ShaderProperty(prop_OverrideBaseBlend, languages.speak("prop_OverrideBaseBlend"));
                    Components.start_dynamic_disable(!prop_OverrideBaseBlend.floatValue.Equals(1), configs);
                    EditorGUI.indentLevel++;
                    materialEditor.ShaderProperty(prop_SrcBlend, languages.speak("prop_SrcBlend"));
                    materialEditor.ShaderProperty(prop_DstBlend, languages.speak("prop_DstBlend"));
                    materialEditor.ShaderProperty(prop_BlendOp, languages.speak("prop_BlendOp"));
                    EditorGUI.indentLevel--;
                    Components.end_dynamic_disable(!prop_OverrideBaseBlend.floatValue.Equals(1), configs);
                    materialEditor.ShaderProperty(prop_OverrideAddBlend, languages.speak("prop_OverrideAddBlend"));
                    Components.start_dynamic_disable(!prop_OverrideAddBlend.floatValue.Equals(1), configs);
                    EditorGUI.indentLevel++;
                    materialEditor.ShaderProperty(prop_AddSrcBlend, languages.speak("prop_AddSrcBlend"));
                    materialEditor.ShaderProperty(prop_AddDstBlend, languages.speak("prop_AddDstBlend"));
                    materialEditor.ShaderProperty(prop_AddBlendOp, languages.speak("prop_AddBlendOp"));
                    EditorGUI.indentLevel--;
                    Components.end_dynamic_disable(!prop_OverrideAddBlend.floatValue.Equals(1), configs);
                    materialEditor.ShaderProperty(prop_OverrideZWrite, languages.speak("prop_OverrideZWrite"));
                    Components.start_dynamic_disable(!prop_OverrideZWrite.floatValue.Equals(1), configs);
                    EditorGUI.indentLevel++;
                    materialEditor.ShaderProperty(prop_ZWrite, languages.speak("prop_ZWrite"));
                    EditorGUI.indentLevel--;
                    Components.end_dynamic_disable(!prop_OverrideZWrite.floatValue.Equals(1), configs);
                    materialEditor.ShaderProperty(prop_OverrideRenderQueue, languages.speak("prop_OverrideRenderQueue"));
                    Components.start_dynamic_disable(!prop_OverrideRenderQueue.floatValue.Equals(1), configs);
                    EditorGUI.indentLevel++;
                    materialEditor.RenderQueueField();
                    EditorGUI.indentLevel--;
                    Components.end_dynamic_disable(!prop_OverrideRenderQueue.floatValue.Equals(1), configs);
                    materialEditor.ShaderProperty(prop_Cull, languages.speak("prop_Cull"));
                    materialEditor.ShaderProperty(prop_ZTest, languages.speak("prop_ZTest"));
                    materialEditor.ShaderProperty(prop_ToggleFlipNormals, languages.speak("prop_ToggleFlipNormals"));
                    materialEditor.ShaderProperty(prop_StencilRef, languages.speak("prop_StencilRef"));
                    Components.start_dynamic_disable(prop_StencilRef.floatValue.Equals(0), configs);
                    EditorGUI.indentLevel++;
                    materialEditor.ShaderProperty(prop_StencilComp, languages.speak("prop_StencilComp"));
                    materialEditor.ShaderProperty(prop_StencilPass, languages.speak("prop_StencilPass"));
                    materialEditor.ShaderProperty(prop_StencilFail, languages.speak("prop_StencilFail"));
                    materialEditor.ShaderProperty(prop_StencilZFail, languages.speak("prop_StencilZFail"));
                    EditorGUI.indentLevel--;
                    Components.end_dynamic_disable(prop_StencilRef.floatValue.Equals(0), configs);
                    materialEditor.ShaderProperty(prop_OutlineStencilRef, languages.speak("prop_OutlineStencilRef"));
                    Components.start_dynamic_disable(prop_OutlineStencilRef.floatValue.Equals(0), configs);
                    EditorGUI.indentLevel++;
                    materialEditor.ShaderProperty(prop_OutlineStencilComp, languages.speak("prop_OutlineStencilComp"));
                    materialEditor.ShaderProperty(prop_OutlineStencilPass, languages.speak("prop_OutlineStencilPass"));
                    materialEditor.ShaderProperty(prop_OutlineStencilFail, languages.speak("prop_OutlineStencilFail"));
                    materialEditor.ShaderProperty(prop_OutlineStencilZFail, languages.speak("prop_OutlineStencilZFail"));
                    EditorGUI.indentLevel--;
                    Components.end_dynamic_disable(prop_OutlineStencilRef.floatValue.Equals(0), configs);
                }
                sub_tab_textures.draw();
                if (sub_tab_textures.is_expanded) {
                    // main - textures
                    prop_MainTex = FindProperty("_MainTex", properties);
                    prop_Color = FindProperty("_Color", properties);
                    prop_Cutoff = FindProperty("_Cutoff", properties);
                    prop_BumpMap = FindProperty("_BumpMap", properties);
                    prop_BumpScale = FindProperty("_BumpScale", properties);
                    prop_Alpha = FindProperty("_Alpha", properties);
                    materialEditor.ShaderProperty(prop_MainTex, languages.speak("prop_MainTex"));
                    materialEditor.ShaderProperty(prop_Color, languages.speak("prop_Color"));
                    materialEditor.ShaderProperty(prop_BumpMap, languages.speak("prop_BumpMap"));
                    materialEditor.ShaderProperty(prop_BumpScale, languages.speak("prop_BumpScale"));
                    materialEditor.ShaderProperty(prop_Alpha, languages.speak("prop_Alpha"));
                    materialEditor.ShaderProperty(prop_Cutoff, languages.speak("prop_Cutoff"));
                }
                sub_tab_post_processing.draw();
                if (sub_tab_post_processing.is_expanded) {
                    // main - post processing
                    prop_TogglePostProcessing = FindProperty("_TogglePostProcessing", properties);
                    prop_RGBColor = FindProperty("_RGBColor", properties);
                    prop_RGBBlendMode = FindProperty("_RGBBlendMode", properties);
                    prop_HSVMode = FindProperty("_HSVMode", properties);
                    prop_HSVHue = FindProperty("_HSVHue", properties);
                    prop_HSVSaturation = FindProperty("_HSVSaturation", properties);
                    prop_HSVValue = FindProperty("_HSVValue", properties);
                    prop_ToggleHueShift = FindProperty("_ToggleHueShift", properties);
                    prop_HueShift = FindProperty("_HueShift", properties);
                    prop_ToggleAutoCycle = FindProperty("_ToggleAutoCycle", properties);
                    prop_AutoCycleSpeed = FindProperty("_AutoCycleSpeed", properties);
                    prop_ColorGradingLUT = FindProperty("_ColorGradingLUT", properties);
                    prop_ColorGradingIntensity = FindProperty("_ColorGradingIntensity", properties);
                    prop_BlackAndWhite = FindProperty("_BlackAndWhite", properties);
                    prop_Brightness = FindProperty("_Brightness", properties);
                    materialEditor.ShaderProperty(prop_TogglePostProcessing, languages.speak("prop_TogglePostProcessing"));
                    Components.start_dynamic_disable(!prop_TogglePostProcessing.floatValue.Equals(1), configs);
                    materialEditor.ShaderProperty(prop_RGBColor, languages.speak("prop_RGBColor"));
                    materialEditor.ShaderProperty(prop_RGBBlendMode, languages.speak("prop_RGBBlendMode"));
                    materialEditor.ShaderProperty(prop_HSVMode, languages.speak("prop_HSVMode"));
                    Components.start_dynamic_disable(prop_HSVMode.floatValue.Equals(0), configs);
                    EditorGUI.indentLevel++;
                    materialEditor.ShaderProperty(prop_HSVHue, languages.speak("prop_HSVHue"));
                    materialEditor.ShaderProperty(prop_HSVSaturation, languages.speak("prop_HSVSaturation"));
                    materialEditor.ShaderProperty(prop_HSVValue, languages.speak("prop_HSVValue"));
                    EditorGUI.indentLevel--;
                    Components.end_dynamic_disable(prop_HSVMode.floatValue.Equals(0), configs);
                    materialEditor.ShaderProperty(prop_ToggleHueShift, languages.speak("prop_ToggleHueShift"));
                    Components.start_dynamic_disable(!prop_ToggleHueShift.floatValue.Equals(1), configs);
                    EditorGUI.indentLevel++;
                    materialEditor.ShaderProperty(prop_HueShift, languages.speak("prop_HueShift"));
                    materialEditor.ShaderProperty(prop_ToggleAutoCycle, languages.speak("prop_ToggleAutoCycle"));
                    materialEditor.ShaderProperty(prop_AutoCycleSpeed, languages.speak("prop_AutoCycleSpeed"));
                    EditorGUI.indentLevel--;
                    Components.end_dynamic_disable(!prop_ToggleHueShift.floatValue.Equals(1), configs);
                    materialEditor.ShaderProperty(prop_ColorGradingIntensity, languages.speak("prop_ColorGradingIntensity"));
                    Components.start_dynamic_disable(prop_ColorGradingIntensity.floatValue.Equals(0), configs);
                    EditorGUI.indentLevel++;
                    materialEditor.ShaderProperty(prop_ColorGradingLUT, languages.speak("prop_ColorGradingLUT"));
                    EditorGUI.indentLevel--;
                    Components.end_dynamic_disable(prop_ColorGradingIntensity.floatValue.Equals(0), configs);
                    materialEditor.ShaderProperty(prop_BlackAndWhite, languages.speak("prop_BlackAndWhite"));
                    materialEditor.ShaderProperty(prop_Brightness, languages.speak("prop_Brightness"));
                    Components.end_dynamic_disable(!prop_TogglePostProcessing.floatValue.Equals(1), configs);
                }
                sub_tab_decal_one.draw();
                if (sub_tab_decal_one.is_expanded) {
                    // main - decal one
                    prop_Decal1Enable = FindProperty("_Decal1Enable", properties);
                    prop_Decal1Tex = FindProperty("_Decal1Tex", properties);
                    prop_Decal1Tint = FindProperty("_Decal1Tint", properties);
                    prop_Decal1BlendMode = FindProperty("_Decal1BlendMode", properties);
                    prop_Decal1IsTriplanar = FindProperty("_Decal1IsTriplanar", properties);
                    prop_Decal1Position = FindProperty("_Decal1Position", properties);
                    prop_Decal1Scale = FindProperty("_Decal1Scale", properties);
                    prop_Decal1Rotation = FindProperty("_Decal1Rotation", properties);
                    prop_Decal1TriplanarPosition = FindProperty("_Decal1TriplanarPosition", properties);
                    prop_Decal1TriplanarScale = FindProperty("_Decal1TriplanarScale", properties);
                    prop_Decal1TriplanarRotation = FindProperty("_Decal1TriplanarRotation", properties);
                    prop_Decal1TriplanarSharpness = FindProperty("_Decal1TriplanarSharpness", properties);
                    prop_Decal1Repeat = FindProperty("_Decal1Repeat", properties);
                    prop_Decal1Scroll = FindProperty("_Decal1Scroll", properties);
                    prop_Decal1HueShift = FindProperty("_Decal1HueShift", properties);
                    prop_Decal1AutoCycleHue = FindProperty("_Decal1AutoCycleHue", properties);
                    prop_Decal1CycleSpeed = FindProperty("_Decal1CycleSpeed", properties);
                    prop_DecalStage = FindProperty("_DecalStage", properties);
                    materialEditor.ShaderProperty(prop_Decal1Enable, languages.speak("prop_Decal1Enable"));
                    materialEditor.ShaderProperty(prop_DecalStage, languages.speak("prop_DecalStage"));
                    Components.start_dynamic_disable(!prop_Decal1Enable.floatValue.Equals(1), configs);
                    materialEditor.ShaderProperty(prop_Decal1Tex, languages.speak("prop_Decal1Tex"));
                    materialEditor.ShaderProperty(prop_Decal1Tint, languages.speak("prop_Decal1Tint"));
                    materialEditor.ShaderProperty(prop_Decal1BlendMode, languages.speak("prop_Decal1BlendMode"));
                    materialEditor.ShaderProperty(prop_Decal1IsTriplanar, languages.speak("prop_Decal1IsTriplanar"));
                    if (prop_Decal1IsTriplanar.floatValue.Equals(0)) {
                        // flat decal settings
                        Components.Vector2Property(materialEditor, prop_Decal1Position, languages.speak("prop_Decal1Position"));
                        Components.Vector2Property(materialEditor, prop_Decal1Scale, languages.speak("prop_Decal1Scale"));
                        materialEditor.ShaderProperty(prop_Decal1Rotation, languages.speak("prop_Decal1Rotation"));
                    } else {
                        // triplanar decal settings
                        Components.Vector3Property(materialEditor, prop_Decal1TriplanarPosition, languages.speak("prop_Decal1TriplanarPosition"));
                        materialEditor.ShaderProperty(prop_Decal1TriplanarScale, languages.speak("prop_Decal1TriplanarScale"));
                        materialEditor.ShaderProperty(prop_Decal1TriplanarRotation, languages.speak("prop_Decal1TriplanarRotation"));
                        Components.Vector3Property(materialEditor, prop_Decal1TriplanarSharpness, languages.speak("prop_Decal1TriplanarSharpness"));
                    }
                    materialEditor.ShaderProperty(prop_Decal1Repeat, languages.speak("prop_Decal1Repeat"));
                    Components.start_dynamic_disable(prop_Decal1Repeat.floatValue.Equals(0), configs);
                    EditorGUI.indentLevel++;
                    Components.Vector2Property(materialEditor, prop_Decal1Scroll, languages.speak("prop_Decal1Scroll"));
                    EditorGUI.indentLevel--;
                    Components.end_dynamic_disable(prop_Decal1Repeat.floatValue.Equals(0), configs);
                    materialEditor.ShaderProperty(prop_Decal1HueShift, languages.speak("prop_Decal1HueShift"));
                    Components.start_dynamic_disable(prop_Decal1HueShift.floatValue.Equals(0), configs);
                    EditorGUI.indentLevel++;
                    materialEditor.ShaderProperty(prop_Decal1AutoCycleHue, languages.speak("prop_Decal1AutoCycleHue"));
                    materialEditor.ShaderProperty(prop_Decal1CycleSpeed, languages.speak("prop_Decal1CycleSpeed"));
                    EditorGUI.indentLevel--;
                    Components.end_dynamic_disable(prop_Decal1HueShift.floatValue.Equals(0), configs);
                    Components.end_dynamic_disable(!prop_Decal1Enable.floatValue.Equals(1), configs);
                }
                sub_tab_decal_two.draw();
                if (sub_tab_decal_two.is_expanded) {
                    // main - decal two
                    prop_Decal2Enable = FindProperty("_Decal2Enable", properties);
                    prop_Decal2Tex = FindProperty("_Decal2Tex", properties);
                    prop_Decal2Tint = FindProperty("_Decal2Tint", properties);
                    prop_Decal2BlendMode = FindProperty("_Decal2BlendMode", properties);
                    prop_Decal2IsTriplanar = FindProperty("_Decal2IsTriplanar", properties);
                    prop_Decal2Position = FindProperty("_Decal2Position", properties);
                    prop_Decal2Scale = FindProperty("_Decal2Scale", properties);
                    prop_Decal2Rotation = FindProperty("_Decal2Rotation", properties);
                    prop_Decal2TriplanarPosition = FindProperty("_Decal2TriplanarPosition", properties);
                    prop_Decal2TriplanarScale = FindProperty("_Decal2TriplanarScale", properties);
                    prop_Decal2TriplanarRotation = FindProperty("_Decal2TriplanarRotation", properties);
                    prop_Decal2TriplanarSharpness = FindProperty("_Decal2TriplanarSharpness", properties);
                    prop_Decal2Repeat = FindProperty("_Decal2Repeat", properties);
                    prop_Decal2Scroll = FindProperty("_Decal2Scroll", properties);
                    prop_Decal2HueShift = FindProperty("_Decal2HueShift", properties);
                    prop_Decal2AutoCycleHue = FindProperty("_Decal2AutoCycleHue", properties);
                    prop_Decal2CycleSpeed = FindProperty("_Decal2CycleSpeed", properties);
                    prop_DecalStage = FindProperty("_DecalStage", properties);
                    materialEditor.ShaderProperty(prop_Decal2Enable, languages.speak("prop_Decal2Enable"));
                    materialEditor.ShaderProperty(prop_DecalStage, languages.speak("prop_DecalStage"));
                    Components.start_dynamic_disable(!prop_Decal2Enable.floatValue.Equals(1), configs);
                    materialEditor.ShaderProperty(prop_Decal2Tex, languages.speak("prop_Decal2Tex"));
                    materialEditor.ShaderProperty(prop_Decal2Tint, languages.speak("prop_Decal2Tint"));
                    materialEditor.ShaderProperty(prop_Decal2BlendMode, languages.speak("prop_Decal2BlendMode"));
                    materialEditor.ShaderProperty(prop_Decal2IsTriplanar, languages.speak("prop_Decal2IsTriplanar"));
                    if (prop_Decal2IsTriplanar.floatValue.Equals(0)) {
                        // flat decal settings
                        Components.Vector2Property(materialEditor, prop_Decal2Position, languages.speak("prop_Decal2Position"));
                        Components.Vector2Property(materialEditor, prop_Decal2Scale, languages.speak("prop_Decal2Scale"));
                        materialEditor.ShaderProperty(prop_Decal2Rotation, languages.speak("prop_Decal2Rotation"));
                    } else {
                        // triplanar decal settings
                        Components.Vector3Property(materialEditor, prop_Decal2TriplanarPosition, languages.speak("prop_Decal2TriplanarPosition"));
                        materialEditor.ShaderProperty(prop_Decal2TriplanarScale, languages.speak("prop_Decal2TriplanarScale"));
                        materialEditor.ShaderProperty(prop_Decal2TriplanarRotation, languages.speak("prop_Decal2TriplanarRotation"));
                        Components.Vector3Property(materialEditor, prop_Decal2TriplanarSharpness, languages.speak("prop_Decal2TriplanarSharpness"));
                    }
                    materialEditor.ShaderProperty(prop_Decal2Repeat, languages.speak("prop_Decal2Repeat"));
                    Components.start_dynamic_disable(prop_Decal2Repeat.floatValue.Equals(0), configs);
                    EditorGUI.indentLevel++;
                    Components.Vector2Property(materialEditor, prop_Decal2Scroll, languages.speak("prop_Decal2Scroll"));
                    EditorGUI.indentLevel--;
                    Components.end_dynamic_disable(prop_Decal2Repeat.floatValue.Equals(0), configs);
                    materialEditor.ShaderProperty(prop_Decal2HueShift, languages.speak("prop_Decal2HueShift"));
                    Components.start_dynamic_disable(prop_Decal2HueShift.floatValue.Equals(0), configs);
                    EditorGUI.indentLevel++;
                    materialEditor.ShaderProperty(prop_Decal2AutoCycleHue, languages.speak("prop_Decal2AutoCycleHue"));
                    materialEditor.ShaderProperty(prop_Decal2CycleSpeed, languages.speak("prop_Decal2CycleSpeed"));
                    EditorGUI.indentLevel--;
                    Components.end_dynamic_disable(prop_Decal2HueShift.floatValue.Equals(0), configs);
                    Components.end_dynamic_disable(!prop_Decal2Enable.floatValue.Equals(1), configs);
                }
                sub_tab_vertex_manipulation.draw();
                if (sub_tab_vertex_manipulation.is_expanded) {
                    // main - vertex manipulation
                    prop_VertexManipulationPosition = FindProperty("_VertexManipulationPosition", properties);
                    prop_VertexManipulationScale = FindProperty("_VertexManipulationScale", properties);
                    Components.Vector3Property(materialEditor, prop_VertexManipulationPosition, languages.speak("prop_VertexManipulationPosition"));
                    Components.Vector3Property(materialEditor, prop_VertexManipulationScale, languages.speak("prop_VertexManipulationScale"));
                }
                sub_tab_uv_manipulation.draw();
                if (sub_tab_uv_manipulation.is_expanded) {
                    // main - uv manipulation
                    prop_UV_Offset_X = FindProperty("_UV_Offset_X", properties);
                    prop_UV_Offset_Y = FindProperty("_UV_Offset_Y", properties);
                    prop_UV_Scale_X = FindProperty("_UV_Scale_X", properties);
                    prop_UV_Scale_Y = FindProperty("_UV_Scale_Y", properties);
                    prop_UV_Rotation = FindProperty("_UV_Rotation", properties);
                    prop_UV_Scroll_X_Speed = FindProperty("_UV_Scroll_X_Speed", properties);
                    prop_UV_Scroll_Y_Speed = FindProperty("_UV_Scroll_Y_Speed", properties);
                    materialEditor.ShaderProperty(prop_UV_Offset_X, languages.speak("prop_UV_Offset_X"));
                    materialEditor.ShaderProperty(prop_UV_Offset_Y, languages.speak("prop_UV_Offset_Y"));
                    materialEditor.ShaderProperty(prop_UV_Scale_X, languages.speak("prop_UV_Scale_X"));
                    materialEditor.ShaderProperty(prop_UV_Scale_Y, languages.speak("prop_UV_Scale_Y"));
                    materialEditor.ShaderProperty(prop_UV_Scroll_X_Speed, languages.speak("prop_UV_Scroll_X_Speed"));
                    materialEditor.ShaderProperty(prop_UV_Scroll_Y_Speed, languages.speak("prop_UV_Scroll_Y_Speed"));
                    materialEditor.ShaderProperty(prop_UV_Rotation, languages.speak("prop_UV_Rotation"));
                }
                sub_tab_uv_effects.draw();
                if (sub_tab_uv_effects.is_expanded) {
                    // main - uv effects
                    prop_ToggleUVEffects = FindProperty("_ToggleUVEffects", properties);
                    prop_UVTriplanarMapping = FindProperty("_UVTriplanarMapping", properties);
                    prop_UVTriplanarPosition = FindProperty("_UVTriplanarPosition", properties);
                    prop_UVTriplanarScale = FindProperty("_UVTriplanarScale", properties);
                    prop_UVTriplanarRotation = FindProperty("_UVTriplanarRotation", properties);
                    prop_UVTriplanarSharpness = FindProperty("_UVTriplanarSharpness", properties);
                    prop_UVScreenspaceMapping = FindProperty("_UVScreenspaceMapping", properties);
                    prop_UVScreenspaceTiling = FindProperty("_UVScreenspaceTiling", properties);
                    prop_UVFlipbook = FindProperty("_UVFlipbook", properties);
                    prop_UVFlipbookRows = FindProperty("_UVFlipbookRows", properties);
                    prop_UVFlipbookColumns = FindProperty("_UVFlipbookColumns", properties);
                    prop_UVFlipbookFrames = FindProperty("_UVFlipbookFrames", properties);
                    prop_UVFlipbookFPS = FindProperty("_UVFlipbookFPS", properties);
                    prop_UVFlipbookScrub = FindProperty("_UVFlipbookScrub", properties);
                    prop_UVFlowmap = FindProperty("_UVFlowmap", properties);
                    prop_UVFlowmapTex = FindProperty("_UVFlowmapTex", properties);
                    prop_UVFlowmapStrength = FindProperty("_UVFlowmapStrength", properties);
                    prop_UVFlowmapSpeed = FindProperty("_UVFlowmapSpeed", properties);
                    prop_UVFlowmapDistortion = FindProperty("_UVFlowmapDistortion", properties);
                    materialEditor.ShaderProperty(prop_ToggleUVEffects, languages.speak("prop_ToggleUVEffects"));
                    Components.start_dynamic_disable(!prop_ToggleUVEffects.floatValue.Equals(1), configs);
                    materialEditor.ShaderProperty(prop_UVTriplanarMapping, languages.speak("prop_UVTriplanarMapping"));
                    Components.start_dynamic_disable(prop_UVTriplanarMapping.floatValue.Equals(0), configs);
                    EditorGUI.indentLevel++;
                    materialEditor.ShaderProperty(prop_UVTriplanarPosition, languages.speak("prop_UVTriplanarPosition"));
                    materialEditor.ShaderProperty(prop_UVTriplanarScale, languages.speak("prop_UVTriplanarScale"));
                    materialEditor.ShaderProperty(prop_UVTriplanarRotation, languages.speak("prop_UVTriplanarRotation"));
                    materialEditor.ShaderProperty(prop_UVTriplanarSharpness, languages.speak("prop_UVTriplanarSharpness"));
                    EditorGUI.indentLevel--;
                    Components.end_dynamic_disable(prop_UVTriplanarMapping.floatValue.Equals(0), configs);
                    materialEditor.ShaderProperty(prop_UVScreenspaceMapping, languages.speak("prop_UVScreenspaceMapping"));
                    Components.start_dynamic_disable(prop_UVScreenspaceMapping.floatValue.Equals(0), configs);
                    EditorGUI.indentLevel++;
                    materialEditor.ShaderProperty(prop_UVScreenspaceTiling, languages.speak("prop_UVScreenspaceTiling"));
                    EditorGUI.indentLevel--;
                    Components.end_dynamic_disable(prop_UVScreenspaceMapping.floatValue.Equals(0), configs);
                    materialEditor.ShaderProperty(prop_UVFlipbook, languages.speak("prop_UVFlipbook"));
                    Components.start_dynamic_disable(!prop_UVFlipbook.floatValue.Equals(1), configs);
                    EditorGUI.indentLevel++;
                    materialEditor.ShaderProperty(prop_UVFlipbookRows, languages.speak("prop_UVFlipbookRows"));
                    materialEditor.ShaderProperty(prop_UVFlipbookColumns, languages.speak("prop_UVFlipbookColumns"));
                    materialEditor.ShaderProperty(prop_UVFlipbookFrames, languages.speak("prop_UVFlipbookFrames"));
                    materialEditor.ShaderProperty(prop_UVFlipbookFPS, languages.speak("prop_UVFlipbookFPS"));
                    materialEditor.ShaderProperty(prop_UVFlipbookScrub, languages.speak("prop_UVFlipbookScrub"));
                    EditorGUI.indentLevel--;
                    Components.end_dynamic_disable(!prop_UVFlipbook.floatValue.Equals(1), configs);
                    materialEditor.ShaderProperty(prop_UVFlowmap, languages.speak("prop_UVFlowmap"));
                    Components.start_dynamic_disable(!prop_UVFlowmap.floatValue.Equals(1), configs);
                    EditorGUI.indentLevel++;
                    materialEditor.ShaderProperty(prop_UVFlowmapTex, languages.speak("prop_UVFlowmapTex"));
                    materialEditor.ShaderProperty(prop_UVFlowmapStrength, languages.speak("prop_UVFlowmapStrength"));
                    materialEditor.ShaderProperty(prop_UVFlowmapSpeed, languages.speak("prop_UVFlowmapSpeed"));
                    materialEditor.ShaderProperty(prop_UVFlowmapDistortion, languages.speak("prop_UVFlowmapDistortion"));
                    EditorGUI.indentLevel--;
                    Components.end_dynamic_disable(!prop_UVFlowmap.floatValue.Equals(1), configs);
                    Components.end_dynamic_disable(!prop_ToggleUVEffects.floatValue.Equals(1), configs);
                }
                sub_tab_uv_sets.draw();
                if (sub_tab_uv_sets.is_expanded) {
                    // main - uv sets
                    prop_MainTex_UV = FindProperty("_MainTex_UV", properties);
                    prop_BumpMap_UV = FindProperty("_BumpMap_UV", properties);
                    prop_MSSO_UV = FindProperty("_MSSO_UV", properties);
                    prop_SpecularTintTexture_UV = FindProperty("_SpecularTintTexture_UV", properties);
                    prop_TangentMap_UV = FindProperty("_TangentMap_UV", properties);
                    prop_EmissionMap_UV = FindProperty("_EmissionMap_UV", properties);
                    prop_ClearcoatMap_UV = FindProperty("_ClearcoatMap_UV", properties);
                    prop_MatcapMask_UV = FindProperty("_MatcapMask_UV", properties);
                    prop_ParallaxMap_UV = FindProperty("_ParallaxMap_UV", properties);
                    prop_ThicknessMap_UV = FindProperty("_ThicknessMap_UV", properties);
                    prop_DetailMap_UV = FindProperty("_DetailMap_UV", properties);
                    prop_Decal1_UV = FindProperty("_Decal1_UV", properties);
                    prop_Decal2_UV = FindProperty("_Decal2_UV", properties);
                    prop_Glitter_UV = FindProperty("_Glitter_UV", properties);
                    prop_IridescenceMask_UV = FindProperty("_IridescenceMask_UV", properties);
                    prop_GlitterMask_UV = FindProperty("_GlitterMask_UV", properties);
                    prop_HairFlowMap_UV = FindProperty("_HairFlowMap_UV", properties);
                    prop_ShadowTex_UV = FindProperty("_ShadowTex_UV", properties);
                    prop_Flowmap_UV = FindProperty("_Flowmap_UV", properties);
                    prop_MirrorDetectionTexture_UV = FindProperty("_MirrorDetectionTexture_UV", properties);
                    prop_RefractionMask_UV = FindProperty("_RefractionMask_UV", properties);
                    prop_PathingMap_UV = FindProperty("_PathingMap_UV", properties);
                    prop_ShadowMap_UV = FindProperty("_ShadowMap_UV", properties);
                    prop_PathingTexture_UV = FindProperty("_PathingTexture_UV", properties);
                    prop_Dither_UV = FindProperty("_Dither_UV", properties);
                    materialEditor.ShaderProperty(prop_MainTex_UV, languages.speak("prop_MainTex_UV"));
                    materialEditor.ShaderProperty(prop_BumpMap_UV, languages.speak("prop_BumpMap_UV"));
                    materialEditor.ShaderProperty(prop_MSSO_UV, languages.speak("prop_MSSO_UV"));
                    materialEditor.ShaderProperty(prop_SpecularTintTexture_UV, languages.speak("prop_SpecularTintTexture_UV"));
                    materialEditor.ShaderProperty(prop_TangentMap_UV, languages.speak("prop_TangentMap_UV"));
                    materialEditor.ShaderProperty(prop_EmissionMap_UV, languages.speak("prop_EmissionMap_UV"));
                    materialEditor.ShaderProperty(prop_ClearcoatMap_UV, languages.speak("prop_ClearcoatMap_UV"));
                    materialEditor.ShaderProperty(prop_MatcapMask_UV, languages.speak("prop_MatcapMask_UV"));
                    materialEditor.ShaderProperty(prop_ParallaxMap_UV, languages.speak("prop_ParallaxMap_UV"));
                    materialEditor.ShaderProperty(prop_ThicknessMap_UV, languages.speak("prop_ThicknessMap_UV"));
                    materialEditor.ShaderProperty(prop_DetailMap_UV, languages.speak("prop_DetailMap_UV"));
                    materialEditor.ShaderProperty(prop_Decal1_UV, languages.speak("prop_Decal1_UV"));
                    materialEditor.ShaderProperty(prop_Decal2_UV, languages.speak("prop_Decal2_UV"));
                    materialEditor.ShaderProperty(prop_Glitter_UV, languages.speak("prop_Glitter_UV"));
                    materialEditor.ShaderProperty(prop_IridescenceMask_UV, languages.speak("prop_IridescenceMask_UV"));
                    materialEditor.ShaderProperty(prop_GlitterMask_UV, languages.speak("prop_GlitterMask_UV"));
                    materialEditor.ShaderProperty(prop_HairFlowMap_UV, languages.speak("prop_HairFlowMap_UV"));
                    materialEditor.ShaderProperty(prop_ShadowTex_UV, languages.speak("prop_ShadowTex_UV"));
                    materialEditor.ShaderProperty(prop_Flowmap_UV, languages.speak("prop_Flowmap_UV"));
                    materialEditor.ShaderProperty(prop_MirrorDetectionTexture_UV, languages.speak("prop_MirrorDetectionTexture_UV"));
                    materialEditor.ShaderProperty(prop_RefractionMask_UV, languages.speak("prop_RefractionMask_UV"));
                    materialEditor.ShaderProperty(prop_PathingMap_UV, languages.speak("prop_PathingMap_UV"));
                    materialEditor.ShaderProperty(prop_ShadowMap_UV, languages.speak("prop_ShadowMap_UV"));
                    materialEditor.ShaderProperty(prop_PathingTexture_UV, languages.speak("prop_PathingTexture_UV"));
                    materialEditor.ShaderProperty(prop_Dither_UV, languages.speak("prop_Dither_UV"));
                }
                Components.end_foldout();
            }
            // lighting tab
            tab_lighting.draw();
            if (tab_lighting.is_expanded) {
                Components.start_foldout();
                sub_tab_lighting_model.draw();
                if (sub_tab_lighting_model.is_expanded) {
                    // lighting - lighting model
                    prop_LightingColorMode = FindProperty("_LightingColorMode", properties);
                    prop_LightingDirectionMode = FindProperty("_LightingDirectionMode", properties);
                    prop_ForcedLightDirection = FindProperty("_ForcedLightDirection", properties);
                    prop_ViewDirectionOffsetX = FindProperty("_ViewDirectionOffsetX", properties);
                    prop_ViewDirectionOffsetY = FindProperty("_ViewDirectionOffsetY", properties);
                    prop_DirectIntensity = FindProperty("_DirectIntensity", properties);
                    prop_IndirectIntensity = FindProperty("_IndirectIntensity", properties);
                    prop_VertexIntensity = FindProperty("_VertexIntensity", properties);
                    prop_AdditiveIntensity = FindProperty("_AdditiveIntensity", properties);
                    prop_BakedDirectIntensity = FindProperty("_BakedDirectIntensity", properties);
                    prop_BakedIndirectIntensity = FindProperty("_BakedIndirectIntensity", properties);
                    materialEditor.ShaderProperty(prop_LightingColorMode, languages.speak("prop_LightingColorMode"));
                    materialEditor.ShaderProperty(prop_LightingDirectionMode, languages.speak("prop_LightingDirectionMode"));
                    switch ((int)prop_LightingDirectionMode.floatValue)
                    {
                        case 1: // forced light direction
                            materialEditor.ShaderProperty(prop_ForcedLightDirection, languages.speak("prop_ForcedLightDirection"));
                            break;
                        case 2: // view direction
                            materialEditor.ShaderProperty(prop_ViewDirectionOffsetX, languages.speak("prop_ViewDirectionOffsetX"));
                            materialEditor.ShaderProperty(prop_ViewDirectionOffsetY, languages.speak("prop_ViewDirectionOffsetY"));
                            break;
                    }
                    materialEditor.ShaderProperty(prop_DirectIntensity, languages.speak("prop_DirectIntensity"));
                    materialEditor.ShaderProperty(prop_IndirectIntensity, languages.speak("prop_IndirectIntensity"));
                    materialEditor.ShaderProperty(prop_VertexIntensity, languages.speak("prop_VertexIntensity"));
                    materialEditor.ShaderProperty(prop_AdditiveIntensity, languages.speak("prop_AdditiveIntensity"));
                    materialEditor.ShaderProperty(prop_BakedDirectIntensity, languages.speak("prop_BakedDirectIntensity"));
                    materialEditor.ShaderProperty(prop_BakedIndirectIntensity, languages.speak("prop_BakedIndirectIntensity"));
                    // todo: move these to another are?
                    prop_IndirectFallbackMode = FindProperty("_IndirectFallbackMode", properties);
                    prop_IndirectOverride = FindProperty("_IndirectOverride", properties);
                    prop_FallbackCubemap = FindProperty("_FallbackCubemap", properties);
                    materialEditor.ShaderProperty(prop_IndirectOverride, languages.speak("prop_IndirectOverride"));
                    materialEditor.ShaderProperty(prop_IndirectFallbackMode, languages.speak("prop_IndirectFallbackMode"));
                    materialEditor.ShaderProperty(prop_FallbackCubemap, languages.speak("prop_FallbackCubemap"));
                }
                sub_tab_anime.draw();
                if (sub_tab_anime.is_expanded) {
                    // lighting - diffuse
                    prop_ToggleAnimeLighting = FindProperty("_ToggleAnimeLighting", properties);
                    prop_AnimeMode = FindProperty("_AnimeMode", properties);
                    prop_Ramp = FindProperty("_Ramp", properties);
                    prop_RampColor = FindProperty("_RampColor", properties);
                    prop_RampOffset = FindProperty("_RampOffset", properties);
                    prop_ShadowIntensity = FindProperty("_ShadowIntensity", properties);
                    prop_OcclusionOffsetIntensity = FindProperty("_OcclusionOffsetIntensity", properties);
                    prop_RampMin = FindProperty("_RampMin", properties);
                    prop_AnimeShadowColor = FindProperty("_AnimeShadowColor", properties);
                    prop_AnimeShadowThreshold = FindProperty("_AnimeShadowThreshold", properties);
                    prop_AnimeHalftoneColor = FindProperty("_AnimeHalftoneColor", properties);
                    prop_AnimeHalftoneThreshold = FindProperty("_AnimeHalftoneThreshold", properties);
                    prop_AnimeShadowSoftness = FindProperty("_AnimeShadowSoftness", properties);
                    prop_ToggleAmbientGradient = FindProperty("_ToggleAmbientGradient", properties);
                    prop_AnimeOcclusionToShadow = FindProperty("_AnimeOcclusionToShadow", properties);
                    prop_AmbientUp = FindProperty("_AmbientUp", properties);
                    prop_AmbientSkyThreshold = FindProperty("_AmbientSkyThreshold", properties);
                    prop_AmbientDown = FindProperty("_AmbientDown", properties);
                    prop_AmbientGroundThreshold = FindProperty("_AmbientGroundThreshold", properties);
                    prop_AmbientIntensity = FindProperty("_AmbientIntensity", properties);
                    prop_TintMaskSource = FindProperty("_TintMaskSource", properties);
                    prop_LitTint = FindProperty("_LitTint", properties);
                    prop_LitThreshold = FindProperty("_LitThreshold", properties);
                    prop_ShadowTint = FindProperty("_ShadowTint", properties);
                    prop_ShadowThreshold = FindProperty("_ShadowThreshold", properties);
                    materialEditor.ShaderProperty(prop_ToggleAnimeLighting, languages.speak("prop_ToggleAnimeLighting"));
                    Components.start_dynamic_disable(!prop_ToggleAnimeLighting.floatValue.Equals(1), configs);
                    
                    materialEditor.ShaderProperty(prop_AnimeMode, languages.speak("prop_AnimeMode"));

                    // Ramp Mode
                    if ((int)prop_AnimeMode.floatValue == 0)
                    {
                        materialEditor.ShaderProperty(prop_Ramp, languages.speak("prop_Ramp"));
                        materialEditor.ShaderProperty(prop_RampColor, languages.speak("prop_RampColor"));
                        materialEditor.ShaderProperty(prop_RampOffset, languages.speak("prop_RampOffset"));
                        materialEditor.ShaderProperty(prop_ShadowIntensity, languages.speak("prop_ShadowIntensity"));
                        materialEditor.ShaderProperty(prop_OcclusionOffsetIntensity, languages.speak("prop_OcclusionOffsetIntensity"));
                        materialEditor.ShaderProperty(prop_RampMin, languages.speak("prop_RampMin"));
                    }
                    // Procedural Mode
                    else
                    {
                        materialEditor.ShaderProperty(prop_AnimeShadowColor, languages.speak("prop_AnimeShadowColor"));
                        materialEditor.ShaderProperty(prop_AnimeShadowThreshold, languages.speak("prop_AnimeShadowThreshold"));
                        materialEditor.ShaderProperty(prop_AnimeHalftoneColor, languages.speak("prop_AnimeHalftoneColor"));
                        materialEditor.ShaderProperty(prop_AnimeHalftoneThreshold, languages.speak("prop_AnimeHalftoneThreshold"));
                        materialEditor.ShaderProperty(prop_AnimeShadowSoftness, languages.speak("prop_AnimeShadowSoftness"));
                        materialEditor.ShaderProperty(prop_AnimeOcclusionToShadow, languages.speak("prop_AnimeOcclusionToShadow"));
                    }
                    // ambient gradient is used in both modes
                    Components.draw_divider();
                    materialEditor.ShaderProperty(prop_ToggleAmbientGradient, languages.speak("prop_ToggleAmbientGradient"));
                    Components.start_dynamic_disable(!prop_ToggleAmbientGradient.floatValue.Equals(1), configs);
                    materialEditor.ShaderProperty(prop_AmbientUp, languages.speak("prop_AmbientUp"));
                    materialEditor.ShaderProperty(prop_AmbientSkyThreshold, languages.speak("prop_AmbientSkyThreshold"));
                    materialEditor.ShaderProperty(prop_AmbientDown, languages.speak("prop_AmbientDown"));
                    materialEditor.ShaderProperty(prop_AmbientGroundThreshold, languages.speak("prop_AmbientGroundThreshold"));
                    materialEditor.ShaderProperty(prop_AmbientIntensity, languages.speak("prop_AmbientIntensity"));
                    Components.end_dynamic_disable(!prop_ToggleAmbientGradient.floatValue.Equals(1), configs);
                    // and tinting is also used in both modes
                    Components.draw_divider();
                    materialEditor.ShaderProperty(prop_TintMaskSource, languages.speak("prop_TintMaskSource"));
                    Components.start_dynamic_disable(prop_TintMaskSource.floatValue.Equals(0), configs);
                    materialEditor.ShaderProperty(prop_LitTint, languages.speak("prop_LitTint"));
                    materialEditor.ShaderProperty(prop_LitThreshold, languages.speak("prop_LitThreshold"));
                    materialEditor.ShaderProperty(prop_ShadowTint, languages.speak("prop_ShadowTint"));
                    materialEditor.ShaderProperty(prop_ShadowThreshold, languages.speak("prop_ShadowThreshold"));
                    Components.end_dynamic_disable(prop_TintMaskSource.floatValue.Equals(0), configs);
                }
                sub_tab_light_limiting.draw();
                if (sub_tab_light_limiting.is_expanded) {
                    // lighting - light limiting
                    prop_EnableBaseLightLimit = FindProperty("_EnableBaseLightLimit", properties);
                    prop_BaseLightMin = FindProperty("_BaseLightMin", properties);
                    prop_BaseLightMax = FindProperty("_BaseLightMax", properties);
                    prop_EnableAddLightLimit = FindProperty("_EnableAddLightLimit", properties);
                    prop_AddLightMin = FindProperty("_AddLightMin", properties);
                    prop_AddLightMax = FindProperty("_AddLightMax", properties);
                    prop_GreyscaleLighting = FindProperty("_GreyscaleLighting", properties);
                    prop_ForceLightColor = FindProperty("_ForceLightColor", properties);
                    prop_ForcedLightColor = FindProperty("_ForcedLightColor", properties);
                    materialEditor.ShaderProperty(prop_EnableBaseLightLimit, languages.speak("prop_EnableBaseLightLimit"));
                    Components.start_dynamic_disable(!prop_EnableBaseLightLimit.floatValue.Equals(1), configs);
                    materialEditor.ShaderProperty(prop_BaseLightMin, languages.speak("prop_BaseLightMin"));
                    materialEditor.ShaderProperty(prop_BaseLightMax, languages.speak("prop_BaseLightMax"));
                    Components.end_dynamic_disable(!prop_EnableBaseLightLimit.floatValue.Equals(1), configs);
                    materialEditor.ShaderProperty(prop_EnableAddLightLimit, languages.speak("prop_EnableAddLightLimit"));
                    Components.start_dynamic_disable(!prop_EnableAddLightLimit.floatValue.Equals(1), configs);
                    materialEditor.ShaderProperty(prop_AddLightMin, languages.speak("prop_AddLightMin"));
                    materialEditor.ShaderProperty(prop_AddLightMax, languages.speak("prop_AddLightMax"));
                    Components.end_dynamic_disable(!prop_EnableAddLightLimit.floatValue.Equals(1), configs);
                    materialEditor.ShaderProperty(prop_GreyscaleLighting, languages.speak("prop_GreyscaleLighting"));
                    materialEditor.ShaderProperty(prop_ForceLightColor, languages.speak("prop_ForceLightColor"));
                    Components.start_dynamic_disable(prop_ForceLightColor.floatValue.Equals(0), configs);
                    materialEditor.ShaderProperty(prop_ForcedLightColor, languages.speak("prop_ForcedLightColor"));
                    Components.end_dynamic_disable(prop_ForceLightColor.floatValue.Equals(0), configs);
                }
                sub_tab_emission.draw();
                if (sub_tab_emission.is_expanded) {
                    // lighting - emission
                    prop_ToggleEmission = FindProperty("_ToggleEmission", properties);
                    prop_EmissionColor = FindProperty("_EmissionColor", properties);
                    prop_EmissionMap = FindProperty("_EmissionMap", properties);
                    prop_UseAlbedoAsEmission = FindProperty("_UseAlbedoAsEmission", properties);
                    prop_EmissionStrength = FindProperty("_EmissionStrength", properties);
                    materialEditor.ShaderProperty(prop_ToggleEmission, languages.speak("prop_ToggleEmission"));
                    Components.start_dynamic_disable(!prop_ToggleEmission.floatValue.Equals(1), configs);
                    materialEditor.ShaderProperty(prop_EmissionMap, languages.speak("prop_EmissionMap"));
                    materialEditor.ShaderProperty(prop_EmissionColor, languages.speak("prop_EmissionColor"));
                    materialEditor.ShaderProperty(prop_UseAlbedoAsEmission, languages.speak("prop_UseAlbedoAsEmission"));
                    materialEditor.ShaderProperty(prop_EmissionStrength, languages.speak("prop_EmissionStrength"));
                    Components.end_dynamic_disable(!prop_ToggleEmission.floatValue.Equals(1), configs);
                }
                Components.end_foldout();
            }
            // specular tab
            tab_specular.draw();
            if (tab_specular.is_expanded)
            {
                Components.start_foldout();
                prop_ToggleSpecular = FindProperty("_ToggleSpecular", properties);
                prop_ToggleVertexSpecular = FindProperty("_ToggleVertexSpecular", properties);
                prop_SpecularMode = FindProperty("_SpecularMode", properties);
                materialEditor.ShaderProperty(prop_ToggleSpecular, languages.speak("prop_ToggleSpecular"));
                Components.start_dynamic_disable(!prop_ToggleSpecular.floatValue.Equals(1), configs);
                materialEditor.ShaderProperty(prop_ToggleVertexSpecular, languages.speak("prop_ToggleVertexSpecular"));
                materialEditor.ShaderProperty(prop_SpecularMode, languages.speak("prop_SpecularMode"));
                sub_tab_pbr_specular.draw();
                if (sub_tab_pbr_specular.is_expanded) {
                    // specular - pbr specualr
                    prop_MSSO = FindProperty("_MSSO", properties);
                    prop_Metallic = FindProperty("_Metallic", properties);
                    prop_Glossiness = FindProperty("_Glossiness", properties);
                    prop_Occlusion = FindProperty("_Occlusion", properties);
                    prop_Specular = FindProperty("_Specular", properties);
                    prop_SpecularIntensity = FindProperty("_SpecularIntensity", properties);
                    prop_SpecularTintTexture = FindProperty("_SpecularTintTexture", properties);
                    prop_SpecularTint = FindProperty("_SpecularTint", properties);
                    prop_ReplaceSpecular = FindProperty("_ReplaceSpecular", properties);
                    materialEditor.ShaderProperty(prop_MSSO, languages.speak("prop_MSSO"));
                    materialEditor.ShaderProperty(prop_Metallic, languages.speak("prop_Metallic"));
                    materialEditor.ShaderProperty(prop_Glossiness, languages.speak("prop_Glossiness"));
                    materialEditor.ShaderProperty(prop_Occlusion, languages.speak("prop_Occlusion"));
                    materialEditor.ShaderProperty(prop_Specular, languages.speak("prop_Specular"));
                    materialEditor.ShaderProperty(prop_SpecularIntensity, languages.speak("prop_SpecularIntensity"));
                    materialEditor.ShaderProperty(prop_SpecularTintTexture, languages.speak("prop_SpecularTintTexture"));
                    materialEditor.ShaderProperty(prop_SpecularTint, languages.speak("prop_SpecularTint"));
                    materialEditor.ShaderProperty(prop_ReplaceSpecular, languages.speak("prop_ReplaceSpecular"));
                }
                sub_tab_stylised_specular.draw();
                if (sub_tab_stylised_specular.is_expanded) {
                    // specular - stylised specular
                    prop_HighlightRamp = FindProperty("_HighlightRamp", properties);
                    prop_HighlightRampColor = FindProperty("_HighlightRampColor", properties);
                    prop_HighlightIntensity = FindProperty("_HighlightIntensity", properties);
                    prop_HighlightRampOffset = FindProperty("_HighlightRampOffset", properties);
                    prop_HighlightHardness = FindProperty("_HighlightHardness", properties);
                    prop_HairFlowMap = FindProperty("_HairFlowMap", properties);
                    prop_PrimarySpecularShift = FindProperty("_PrimarySpecularShift", properties);
                    prop_SecondarySpecularShift = FindProperty("_SecondarySpecularShift", properties);
                    prop_SecondarySpecularColor = FindProperty("_SecondarySpecularColor", properties);
                    prop_SpecularExponent = FindProperty("_SpecularExponent", properties);
                    prop_SheenColor = FindProperty("_SheenColor", properties);
                    prop_SheenIntensity = FindProperty("_SheenIntensity", properties);
                    prop_SheenRoughness = FindProperty("_SheenRoughness", properties);
                    prop_TangentMap = FindProperty("_TangentMap", properties);
                    prop_Anisotropy = FindProperty("_Anisotropy", properties);
                    prop_SpecularTint = FindProperty("_SpecularTint", properties); // hair uses it, so display twice
                    int specularMode = (int)prop_SpecularMode.floatValue;
                    switch (specularMode)
                    {
                        case 1: // anisotropic
                            materialEditor.ShaderProperty(prop_TangentMap, languages.speak("prop_TangentMap"));
                            materialEditor.ShaderProperty(prop_Anisotropy, languages.speak("prop_Anisotropy"));
                            break;
                        case 2: // toon
                            materialEditor.ShaderProperty(prop_HighlightRamp, languages.speak("prop_HighlightRamp"));
                            materialEditor.ShaderProperty(prop_HighlightRampColor, languages.speak("prop_HighlightRampColor"));
                            materialEditor.ShaderProperty(prop_HighlightIntensity, languages.speak("prop_HighlightIntensity"));
                            materialEditor.ShaderProperty(prop_HighlightRampOffset, languages.speak("prop_HighlightRampOffset"));
                            materialEditor.ShaderProperty(prop_HighlightHardness, languages.speak("prop_HighlightHardness"));
                            break;
                        case 3: // hair
                            materialEditor.ShaderProperty(prop_SpecularTint, languages.speak("prop_SpecularTint")); // hair uses this as primary color
                            materialEditor.ShaderProperty(prop_HairFlowMap, languages.speak("prop_HairFlowMap"));
                            materialEditor.ShaderProperty(prop_PrimarySpecularShift, languages.speak("prop_PrimarySpecularShift"));
                            materialEditor.ShaderProperty(prop_SecondarySpecularShift, languages.speak("prop_SecondarySpecularShift"));
                            materialEditor.ShaderProperty(prop_SecondarySpecularColor, languages.speak("prop_SecondarySpecularColor"));
                            materialEditor.ShaderProperty(prop_SpecularExponent, languages.speak("prop_SpecularExponent"));
                            break;
                        case 4: // cloth
                            materialEditor.ShaderProperty(prop_SheenColor, languages.speak("prop_SheenColor"));
                            materialEditor.ShaderProperty(prop_SheenIntensity, languages.speak("prop_SheenIntensity"));
                            materialEditor.ShaderProperty(prop_SheenRoughness, languages.speak("prop_SheenRoughness"));
                            break;
                        default: // none, just a label
                            GUIStyle boldWrap = new GUIStyle(EditorStyles.boldLabel);
                            boldWrap.wordWrap = true;
                            GUILayout.Label(theme.language_manager.speak("specular_standard_stylised_info"), boldWrap);
                            break;
                    }
                }
                Components.end_dynamic_disable(!prop_ToggleSpecular.floatValue.Equals(1), configs);
                Components.end_foldout();
            }
            // shading tab
            tab_shading.draw();
            if (tab_shading.is_expanded) {
                Components.start_foldout();
                sub_tab_rim_lighting.draw();
                if (sub_tab_rim_lighting.is_expanded) {
                    // shading - rim lighting
                    prop_ToggleRimlight = FindProperty("_ToggleRimlight", properties);
                    prop_RimColor = FindProperty("_RimColor", properties);
                    prop_RimWidth = FindProperty("_RimWidth", properties);
                    prop_RimIntensity = FindProperty("_RimIntensity", properties);
                    prop_RimLightBased = FindProperty("_RimLightBased", properties);
                    materialEditor.ShaderProperty(prop_ToggleRimlight, languages.speak("prop_ToggleRimlight"));
                    Components.start_dynamic_disable(!prop_ToggleRimlight.floatValue.Equals(1), configs);
                    materialEditor.ShaderProperty(prop_RimColor, languages.speak("prop_RimColor"));
                    materialEditor.ShaderProperty(prop_RimLightBased, languages.speak("prop_RimLightBased"));
                    materialEditor.ShaderProperty(prop_RimIntensity, languages.speak("prop_RimIntensity"));
                    materialEditor.ShaderProperty(prop_RimWidth, languages.speak("prop_RimWidth"));
                    Components.end_dynamic_disable(!prop_ToggleRimlight.floatValue.Equals(1), configs);
                }
                sub_tab_depth_rim.draw();
                if (sub_tab_depth_rim.is_expanded) {
                    // shading - depth rim
                    prop_ToggleDepthRim = FindProperty("_ToggleDepthRim", properties);
                    prop_DepthRimColor = FindProperty("_DepthRimColor", properties);
                    prop_DepthRimWidth = FindProperty("_DepthRimWidth", properties);
                    prop_DepthRimThreshold = FindProperty("_DepthRimThreshold", properties);
                    prop_DepthRimSharpness = FindProperty("_DepthRimSharpness", properties);
                    prop_DepthRimBlendMode = FindProperty("_DepthRimBlendMode", properties);
                    materialEditor.ShaderProperty(prop_ToggleDepthRim, languages.speak("prop_ToggleDepthRim"));
                    Components.start_dynamic_disable(!prop_ToggleDepthRim.floatValue.Equals(1), configs);
                    materialEditor.ShaderProperty(prop_DepthRimColor, languages.speak("prop_DepthRimColor"));
                    materialEditor.ShaderProperty(prop_DepthRimBlendMode, languages.speak("prop_DepthRimBlendMode"));
                    materialEditor.ShaderProperty(prop_DepthRimWidth, languages.speak("prop_DepthRimWidth"));
                    materialEditor.ShaderProperty(prop_DepthRimThreshold, languages.speak("prop_DepthRimThreshold"));
                    materialEditor.ShaderProperty(prop_DepthRimSharpness, languages.speak("prop_DepthRimSharpness"));
                    Components.end_dynamic_disable(!prop_ToggleDepthRim.floatValue.Equals(1), configs);
                }
                sub_tab_matcap.draw();
                if (sub_tab_matcap.is_expanded) {
                    // shading - matcap
                    prop_ToggleMatcap = FindProperty("_ToggleMatcap", properties);
                    prop_MatcapTex = FindProperty("_MatcapTex", properties);
                    prop_MatcapTint = FindProperty("_MatcapTint", properties);
                    prop_MatcapIntensity = FindProperty("_MatcapIntensity", properties);
                    prop_MatcapBlendMode = FindProperty("_MatcapBlendMode", properties);
                    prop_MatcapMask = FindProperty("_MatcapMask", properties);
                    prop_MatcapSmoothnessEnabled = FindProperty("_MatcapSmoothnessEnabled", properties);
                    prop_MatcapSmoothness = FindProperty("_MatcapSmoothness", properties);
                    materialEditor.ShaderProperty(prop_ToggleMatcap, languages.speak("prop_ToggleMatcap"));
                    Components.start_dynamic_disable(!prop_ToggleMatcap.floatValue.Equals(1), configs);
                    materialEditor.ShaderProperty(prop_MatcapTex, languages.speak("prop_MatcapTex"));
                    materialEditor.ShaderProperty(prop_MatcapMask, languages.speak("prop_MatcapMask"));
                    materialEditor.ShaderProperty(prop_MatcapTint, languages.speak("prop_MatcapTint"));
                    materialEditor.ShaderProperty(prop_MatcapBlendMode, languages.speak("prop_MatcapBlendMode"));
                    materialEditor.ShaderProperty(prop_MatcapIntensity, languages.speak("prop_MatcapIntensity"));
                    materialEditor.ShaderProperty(prop_MatcapSmoothnessEnabled, languages.speak("prop_MatcapSmoothnessEnabled"));
                    Components.start_dynamic_disable(!prop_MatcapSmoothnessEnabled.floatValue.Equals(1), configs);
                    materialEditor.ShaderProperty(prop_MatcapSmoothness, languages.speak("prop_MatcapSmoothness"));
                    Components.end_dynamic_disable(!prop_MatcapSmoothnessEnabled.floatValue.Equals(1), configs);
                    Components.end_dynamic_disable(!prop_ToggleMatcap.floatValue.Equals(1), configs);
                }
                sub_tab_cubemap.draw();
                if (sub_tab_cubemap.is_expanded) {
                    // shading - cubemap
                    prop_ToggleCubemap = FindProperty("_ToggleCubemap", properties);
                    prop_CubemapTex = FindProperty("_CubemapTex", properties);
                    prop_CubemapTint = FindProperty("_CubemapTint", properties);
                    prop_CubemapIntensity = FindProperty("_CubemapIntensity", properties);
                    prop_CubemapBlendMode = FindProperty("_CubemapBlendMode", properties);
                    materialEditor.ShaderProperty(prop_ToggleCubemap, languages.speak("prop_ToggleCubemap"));
                    Components.start_dynamic_disable(!prop_ToggleCubemap.floatValue.Equals(1), configs);
                    materialEditor.ShaderProperty(prop_CubemapTex, languages.speak("prop_CubemapTex"));
                    materialEditor.ShaderProperty(prop_CubemapTint, languages.speak("prop_CubemapTint"));
                    materialEditor.ShaderProperty(prop_CubemapBlendMode, languages.speak("prop_CubemapBlendMode"));
                    materialEditor.ShaderProperty(prop_CubemapIntensity, languages.speak("prop_CubemapIntensity"));
                    Components.end_dynamic_disable(!prop_ToggleCubemap.floatValue.Equals(1), configs);
                }
                sub_tab_clear_coat.draw();
                if (sub_tab_clear_coat.is_expanded) {
                    // shading - clear coat
                    prop_ToggleClearcoat = FindProperty("_ToggleClearcoat", properties);
                    prop_ClearcoatStrength = FindProperty("_ClearcoatStrength", properties);
                    prop_ClearcoatReflectionStrength = FindProperty("_ClearcoatReflectionStrength", properties);
                    prop_ClearcoatMap = FindProperty("_ClearcoatMap", properties);
                    prop_ClearcoatRoughness = FindProperty("_ClearcoatRoughness", properties);
                    prop_ClearcoatColor = FindProperty("_ClearcoatColor", properties);
                    materialEditor.ShaderProperty(prop_ToggleClearcoat, languages.speak("prop_ToggleClearcoat"));
                    Components.start_dynamic_disable(!prop_ToggleClearcoat.floatValue.Equals(1), configs);
                    materialEditor.ShaderProperty(prop_ClearcoatMap, languages.speak("prop_ClearcoatMap"));
                    materialEditor.ShaderProperty(prop_ClearcoatColor, languages.speak("prop_ClearcoatColor"));
                    materialEditor.ShaderProperty(prop_ClearcoatStrength, languages.speak("prop_ClearcoatStrength"));
                    materialEditor.ShaderProperty(prop_ClearcoatReflectionStrength, languages.speak("prop_ClearcoatReflectionStrength"));
                    materialEditor.ShaderProperty(prop_ClearcoatRoughness, languages.speak("prop_ClearcoatRoughness"));
                    Components.end_dynamic_disable(!prop_ToggleClearcoat.floatValue.Equals(1), configs);
                }
                sub_tab_subsurface.draw();
                if (sub_tab_subsurface.is_expanded) {
                    // shading - subsurface
                    prop_ToggleSSS = FindProperty("_ToggleSSS", properties);
                    prop_SSSColor = FindProperty("_SSSColor", properties);
                    prop_SSSStrength = FindProperty("_SSSStrength", properties);
                    prop_SSSPower = FindProperty("_SSSPower", properties);
                    prop_SSSDistortion = FindProperty("_SSSDistortion", properties);
                    prop_SSSThicknessMap = FindProperty("_SSSThicknessMap", properties);
                    prop_SSSThickness = FindProperty("_SSSThickness", properties);
                    materialEditor.ShaderProperty(prop_ToggleSSS, languages.speak("prop_ToggleSSS"));
                    Components.start_dynamic_disable(!prop_ToggleSSS.floatValue.Equals(1), configs);
                    materialEditor.ShaderProperty(prop_SSSColor, languages.speak("prop_SSSColor"));
                    materialEditor.ShaderProperty(prop_SSSStrength, languages.speak("prop_SSSStrength"));
                    materialEditor.ShaderProperty(prop_SSSPower, languages.speak("prop_SSSPower"));
                    materialEditor.ShaderProperty(prop_SSSDistortion, languages.speak("prop_SSSDistortion"));
                    materialEditor.ShaderProperty(prop_SSSThicknessMap, languages.speak("prop_SSSThicknessMap"));
                    Components.start_dynamic_disable(prop_SSSThicknessMap.textureValue == null, configs);
                    EditorGUI.indentLevel++;
                    materialEditor.ShaderProperty(prop_SSSThickness, languages.speak("prop_SSSThickness"));
                    EditorGUI.indentLevel--;
                    Components.end_dynamic_disable(prop_SSSThicknessMap.textureValue == null, configs);
                    Components.end_dynamic_disable(!prop_ToggleSSS.floatValue.Equals(1), configs);
                }
                sub_tab_parallax.draw();
                if (sub_tab_parallax.is_expanded) {
                    // shading - parallax
                    prop_ToggleParallax = FindProperty("_ToggleParallax", properties);
                    prop_ParallaxMode = FindProperty("_ParallaxMode", properties);
                    prop_ParallaxMap = FindProperty("_ParallaxMap", properties);
                    prop_ParallaxStrength = FindProperty("_ParallaxStrength", properties);
                    prop_ParallaxSteps = FindProperty("_ParallaxSteps", properties);
                    prop_ToggleParallaxShadows = FindProperty("_ToggleParallaxShadows", properties);
                    prop_ParallaxShadowSteps = FindProperty("_ParallaxShadowSteps", properties);
                    prop_ParallaxShadowStrength = FindProperty("_ParallaxShadowStrength", properties);
                    materialEditor.ShaderProperty(prop_ToggleParallax, languages.speak("prop_ToggleParallax"));
                    Components.start_dynamic_disable(!prop_ToggleParallax.floatValue.Equals(1), configs);
                    materialEditor.ShaderProperty(prop_ParallaxMode, languages.speak("prop_ParallaxMode"));
                    materialEditor.ShaderProperty(prop_ParallaxMap, languages.speak("prop_ParallaxMap"));
                    materialEditor.ShaderProperty(prop_ParallaxStrength, languages.speak("prop_ParallaxStrength"));
                    materialEditor.ShaderProperty(prop_ParallaxSteps, languages.speak("prop_ParallaxSteps"));
                    materialEditor.ShaderProperty(prop_ToggleParallaxShadows, languages.speak("prop_ToggleParallaxShadows"));
                    Components.start_dynamic_disable(!prop_ToggleParallaxShadows.floatValue.Equals(1), configs);
                    materialEditor.ShaderProperty(prop_ParallaxShadowSteps, languages.speak("prop_ParallaxShadowSteps"));
                    materialEditor.ShaderProperty(prop_ParallaxShadowStrength, languages.speak("prop_ParallaxShadowStrength"));
                    Components.end_dynamic_disable(!prop_ToggleParallaxShadows.floatValue.Equals(1), configs);
                    Components.end_dynamic_disable(!prop_ToggleParallax.floatValue.Equals(1), configs);
                }
                sub_tab_detail_map.draw();
                if (sub_tab_detail_map.is_expanded) {
                    // shading - detail map
                    prop_ToggleDetail = FindProperty("_ToggleDetail", properties);
                    prop_DetailAlbedoMap = FindProperty("_DetailAlbedoMap", properties);
                    prop_DetailNormalMap = FindProperty("_DetailNormalMap", properties);
                    prop_DetailTiling = FindProperty("_DetailTiling", properties);
                    prop_DetailNormalStrength = FindProperty("_DetailNormalStrength", properties);
                    materialEditor.ShaderProperty(prop_ToggleDetail, languages.speak("prop_ToggleDetail"));
                    Components.start_dynamic_disable(!prop_ToggleDetail.floatValue.Equals(1), configs);
                    materialEditor.ShaderProperty(prop_DetailAlbedoMap, languages.speak("prop_DetailAlbedoMap"));
                    materialEditor.ShaderProperty(prop_DetailNormalMap, languages.speak("prop_DetailNormalMap"));
                    materialEditor.ShaderProperty(prop_DetailTiling, languages.speak("prop_DetailTiling"));
                    materialEditor.ShaderProperty(prop_DetailNormalStrength, languages.speak("prop_DetailNormalStrength"));
                    Components.end_dynamic_disable(!prop_ToggleDetail.floatValue.Equals(1), configs);
                }
                sub_tab_shadow_map.draw();
                if (sub_tab_shadow_map.is_expanded) {
                    // shading - shadow map
                    prop_ToggleShadowMap = FindProperty("_ToggleShadowMap", properties);
                    prop_ShadowMap = FindProperty("_ShadowMap", properties);
                    prop_ShadowMapIntensity = FindProperty("_ShadowMapIntensity", properties);
                    materialEditor.ShaderProperty(prop_ToggleShadowMap, languages.speak("prop_ToggleShadowMap"));
                    Components.start_dynamic_disable(!prop_ToggleShadowMap.floatValue.Equals(1), configs);
                    materialEditor.ShaderProperty(prop_ShadowMap, languages.speak("prop_ShadowMap"));
                    materialEditor.ShaderProperty(prop_ShadowMapIntensity, languages.speak("prop_ShadowMapIntensity"));
                    Components.end_dynamic_disable(!prop_ToggleShadowMap.floatValue.Equals(1), configs);
                }
                Components.end_foldout();
            }
            // effects tab
            tab_effects.draw();
            if (tab_effects.is_expanded) {
                Components.start_foldout();
                sub_tab_dissolve.draw();
                if (sub_tab_dissolve.is_expanded) {
                    // effects - dissolve
                    prop_ToggleDissolve = FindProperty("_ToggleDissolve", properties);
                    prop_DissolveProgress = FindProperty("_DissolveProgress", properties);
                    prop_DissolveType = FindProperty("_DissolveType", properties);
                    prop_DissolveEdgeColor = FindProperty("_DissolveEdgeColor", properties);
                    prop_DissolveEdgeWidth = FindProperty("_DissolveEdgeWidth", properties);
                    prop_DissolveEdgeMode = FindProperty("_DissolveEdgeMode", properties);
                    prop_DissolveEdgeSharpness = FindProperty("_DissolveEdgeSharpness", properties);
                    prop_DissolveNoiseTex = FindProperty("_DissolveNoiseTex", properties);
                    prop_DissolveNoiseScale = FindProperty("_DissolveNoiseScale", properties);
                    prop_DissolveDirection = FindProperty("_DissolveDirection", properties);
                    prop_DissolveDirectionSpace = FindProperty("_DissolveDirectionSpace", properties);
                    prop_DissolveDirectionBounds = FindProperty("_DissolveDirectionBounds", properties);
                    prop_DissolveVoxelDensity = FindProperty("_DissolveVoxelDensity", properties);
                    materialEditor.ShaderProperty(prop_ToggleDissolve, languages.speak("prop_ToggleDissolve"));
                    Components.start_dynamic_disable(!prop_ToggleDissolve.floatValue.Equals(1), configs);
                    materialEditor.ShaderProperty(prop_DissolveType, languages.speak("prop_DissolveType"));
                    materialEditor.ShaderProperty(prop_DissolveProgress, languages.speak("prop_DissolveProgress"));
                    materialEditor.ShaderProperty(prop_DissolveEdgeMode, languages.speak("prop_DissolveEdgeMode"));
                    EditorGUI.indentLevel++;
                    Components.start_dynamic_disable(prop_DissolveEdgeMode.floatValue.Equals(1), configs);
                    materialEditor.ShaderProperty(prop_DissolveEdgeColor, languages.speak("prop_DissolveEdgeColor"));
                    Components.end_dynamic_disable(prop_DissolveEdgeMode.floatValue.Equals(1), configs);
                    materialEditor.ShaderProperty(prop_DissolveEdgeWidth, languages.speak("prop_DissolveEdgeWidth"));
                    materialEditor.ShaderProperty(prop_DissolveEdgeSharpness, languages.speak("prop_DissolveEdgeSharpness"));
                    EditorGUI.indentLevel--;
                    switch ((int)prop_DissolveType.floatValue) {
                        case 1: // directional
                            materialEditor.ShaderProperty(prop_DissolveDirection, languages.speak("prop_DissolveDirection"));
                            materialEditor.ShaderProperty(prop_DissolveDirectionSpace, languages.speak("prop_DissolveDirectionSpace"));
                            materialEditor.ShaderProperty(prop_DissolveDirectionBounds, languages.speak("prop_DissolveDirectionBounds"));
                            break;
                        case 2: // voxel
                            materialEditor.ShaderProperty(prop_DissolveVoxelDensity, languages.speak("prop_DissolveVoxelDensity"));
                            break;
                        default: // noise
                            materialEditor.ShaderProperty(prop_DissolveNoiseTex, languages.speak("prop_DissolveNoiseTex"));
                            materialEditor.ShaderProperty(prop_DissolveNoiseScale, languages.speak("prop_DissolveNoiseScale"));
                            break;
                    }
                    Components.end_dynamic_disable(!prop_ToggleDissolve.floatValue.Equals(1), configs);
                }
                sub_tab_distance_fading.draw();
                if (sub_tab_distance_fading.is_expanded) {
                    // effects - distance fading
                    prop_ToggleDistanceFade = FindProperty("_ToggleDistanceFade", properties);
                    prop_DistanceFadeReference = FindProperty("_DistanceFadeReference", properties);
                    prop_ToggleNearFade = FindProperty("_ToggleNearFade", properties);
                    prop_NearFadeMode = FindProperty("_NearFadeMode", properties);
                    prop_NearFadeDitherScale = FindProperty("_NearFadeDitherScale", properties);
                    prop_NearFadeStart = FindProperty("_NearFadeStart", properties);
                    prop_NearFadeEnd = FindProperty("_NearFadeEnd", properties);
                    prop_ToggleFarFade = FindProperty("_ToggleFarFade", properties);
                    prop_FarFadeStart = FindProperty("_FarFadeStart", properties);
                    prop_FarFadeEnd = FindProperty("_FarFadeEnd", properties);
                    materialEditor.ShaderProperty(prop_ToggleDistanceFade, languages.speak("prop_ToggleDistanceFade"));
                    Components.start_dynamic_disable(!prop_ToggleDistanceFade.floatValue.Equals(1), configs);
                    materialEditor.ShaderProperty(prop_DistanceFadeReference, languages.speak("prop_DistanceFadeReference"));
                    materialEditor.ShaderProperty(prop_ToggleNearFade, languages.speak("prop_ToggleNearFade"));
                    Components.start_dynamic_disable(!prop_ToggleNearFade.floatValue.Equals(1), configs);
                    EditorGUI.indentLevel++;
                    materialEditor.ShaderProperty(prop_NearFadeMode, languages.speak("prop_NearFadeMode"));
                    materialEditor.ShaderProperty(prop_NearFadeDitherScale, languages.speak("prop_NearFadeDitherScale"));
                    materialEditor.ShaderProperty(prop_NearFadeStart, languages.speak("prop_NearFadeStart"));
                    materialEditor.ShaderProperty(prop_NearFadeEnd, languages.speak("prop_NearFadeEnd"));
                    EditorGUI.indentLevel--;
                    Components.end_dynamic_disable(!prop_ToggleNearFade.floatValue.Equals(1), configs);
                    materialEditor.ShaderProperty(prop_ToggleFarFade, languages.speak("prop_ToggleFarFade"));
                    Components.start_dynamic_disable(!prop_ToggleFarFade.floatValue.Equals(1), configs);
                    EditorGUI.indentLevel++;
                    materialEditor.ShaderProperty(prop_FarFadeStart, languages.speak("prop_FarFadeStart"));
                    materialEditor.ShaderProperty(prop_FarFadeEnd, languages.speak("prop_FarFadeEnd"));
                    EditorGUI.indentLevel--;
                    Components.end_dynamic_disable(!prop_ToggleFarFade.floatValue.Equals(1), configs);
                    Components.end_dynamic_disable(!prop_ToggleDistanceFade.floatValue.Equals(1), configs);
                }
                sub_tab_vrchat_mirror.draw();
                if (sub_tab_vrchat_mirror.is_expanded) {
                    // effects - vrchat mirror
                    prop_ToggleMirrorDetection = FindProperty("_ToggleMirrorDetection", properties);
                    prop_MirrorDetectionMode = FindProperty("_MirrorDetectionMode", properties);
                    prop_MirrorDetectionTexture = FindProperty("_MirrorDetectionTexture", properties);
                    materialEditor.ShaderProperty(prop_ToggleMirrorDetection, languages.speak("prop_ToggleMirrorDetection"));
                    Components.start_dynamic_disable(!prop_ToggleMirrorDetection.floatValue.Equals(1), configs);
                    materialEditor.ShaderProperty(prop_MirrorDetectionMode, languages.speak("prop_MirrorDetectionMode"));
                    materialEditor.ShaderProperty(prop_MirrorDetectionTexture, languages.speak("prop_MirrorDetectionTexture"));
                    Components.end_dynamic_disable(!prop_ToggleMirrorDetection.floatValue.Equals(1), configs);
                }
                sub_tab_pathing.draw();
                if (sub_tab_pathing.is_expanded) {
                    // effects - pathing
                    prop_TogglePathing = FindProperty("_TogglePathing", properties);
                    prop_PathingMappingMode = FindProperty("_PathingMappingMode", properties);
                    prop_PathingMap = FindProperty("_PathingMap", properties);
                    prop_PathingScale = FindProperty("_PathingScale", properties);
                    prop_PathingBlendMode = FindProperty("_PathingBlendMode", properties);
                    prop_PathingColor = FindProperty("_PathingColor", properties);
                    prop_PathingEmission = FindProperty("_PathingEmission", properties);
                    prop_PathingType = FindProperty("_PathingType", properties);
                    prop_PathingSpeed = FindProperty("_PathingSpeed", properties);
                    prop_PathingWidth = FindProperty("_PathingWidth", properties);
                    prop_PathingSoftness = FindProperty("_PathingSoftness", properties);
                    prop_PathingOffset = FindProperty("_PathingOffset", properties);
                    prop_PathingColorMode = FindProperty("_PathingColorMode", properties);
                    prop_PathingTexture = FindProperty("_PathingTexture", properties);
                    prop_PathingColor2 = FindProperty("_PathingColor2", properties);
                    materialEditor.ShaderProperty(prop_TogglePathing, languages.speak("prop_TogglePathing"));
                    Components.start_dynamic_disable(!prop_TogglePathing.floatValue.Equals(1), configs);
                    materialEditor.ShaderProperty(prop_PathingMappingMode, languages.speak("prop_PathingMappingMode"));
                    EditorGUI.indentLevel++;
                    materialEditor.ShaderProperty(prop_PathingMap, languages.speak("prop_PathingMap"));
                    materialEditor.ShaderProperty(prop_PathingScale, languages.speak("prop_PathingScale"));
                    EditorGUI.indentLevel--;
                    materialEditor.ShaderProperty(prop_PathingColorMode, languages.speak("prop_PathingColorMode"));
                    EditorGUI.indentLevel++;
                    materialEditor.ShaderProperty(prop_PathingBlendMode, languages.speak("prop_PathingBlendMode"));
                    materialEditor.ShaderProperty(prop_PathingEmission, languages.speak("prop_PathingEmission"));
                    switch ((int)prop_PathingColorMode.floatValue) {
                        case 1: // texture
                            materialEditor.ShaderProperty(prop_PathingTexture, languages.speak("prop_PathingTexture"));
                            break;
                        case 2: // gradient
                            materialEditor.ShaderProperty(prop_PathingColor, languages.speak("prop_PathingColor"));
                            materialEditor.ShaderProperty(prop_PathingColor2, languages.speak("prop_PathingColor2"));
                            break;
                        default: // single color
                            materialEditor.ShaderProperty(prop_PathingColor, languages.speak("prop_PathingColor"));
                            break;
                    }
                    EditorGUI.indentLevel--;
                    materialEditor.ShaderProperty(prop_PathingType, languages.speak("prop_PathingType"));
                    EditorGUI.indentLevel++;
                    materialEditor.ShaderProperty(prop_PathingSpeed, languages.speak("prop_PathingSpeed"));
                    materialEditor.ShaderProperty(prop_PathingWidth, languages.speak("prop_PathingWidth"));
                    materialEditor.ShaderProperty(prop_PathingSoftness, languages.speak("prop_PathingSoftness"));
                    materialEditor.ShaderProperty(prop_PathingOffset, languages.speak("prop_PathingOffset"));
                    EditorGUI.indentLevel--;
                    Components.end_dynamic_disable(!prop_TogglePathing.floatValue.Equals(1), configs);
                }
                sub_tab_glitter.draw();
                if (sub_tab_glitter.is_expanded) {
                    // effects - glitter
                    prop_ToggleGlitter = FindProperty("_ToggleGlitter", properties);
                    prop_GlitterMode = FindProperty("_GlitterMode", properties);
                    prop_GlitterNoiseTex = FindProperty("_GlitterNoiseTex", properties);
                    prop_GlitterMask = FindProperty("_GlitterMask", properties);
                    prop_GlitterTint = FindProperty("_GlitterTint", properties);
                    prop_GlitterFrequency = FindProperty("_GlitterFrequency", properties);
                    prop_GlitterThreshold = FindProperty("_GlitterThreshold", properties);
                    prop_GlitterSize = FindProperty("_GlitterSize", properties);
                    prop_GlitterFlickerSpeed = FindProperty("_GlitterFlickerSpeed", properties);
                    prop_GlitterBrightness = FindProperty("_GlitterBrightness", properties);
                    prop_GlitterContrast = FindProperty("_GlitterContrast", properties);
                    prop_ToggleGlitterRainbow = FindProperty("_ToggleGlitterRainbow", properties);
                    prop_GlitterRainbowSpeed = FindProperty("_GlitterRainbowSpeed", properties);
                    materialEditor.ShaderProperty(prop_ToggleGlitter, languages.speak("prop_ToggleGlitter"));
                    Components.start_dynamic_disable(!prop_ToggleGlitter.floatValue.Equals(1), configs);
                    materialEditor.ShaderProperty(prop_GlitterMode, languages.speak("prop_GlitterMode"));
                    if (prop_GlitterMode.floatValue.Equals(1)) {
                        EditorGUI.indentLevel++;
                        materialEditor.ShaderProperty(prop_GlitterNoiseTex, languages.speak("prop_GlitterNoiseTex"));
                        EditorGUI.indentLevel--;
                    }
                    materialEditor.ShaderProperty(prop_GlitterMask, languages.speak("prop_GlitterMask"));
                    materialEditor.ShaderProperty(prop_GlitterTint, languages.speak("prop_GlitterTint"));
                    materialEditor.ShaderProperty(prop_GlitterFrequency, languages.speak("prop_GlitterFrequency"));
                    materialEditor.ShaderProperty(prop_GlitterThreshold, languages.speak("prop_GlitterThreshold"));
                    materialEditor.ShaderProperty(prop_GlitterSize, languages.speak("prop_GlitterSize"));
                    materialEditor.ShaderProperty(prop_GlitterFlickerSpeed, languages.speak("prop_GlitterFlickerSpeed"));
                    materialEditor.ShaderProperty(prop_GlitterBrightness, languages.speak("prop_GlitterBrightness"));
                    materialEditor.ShaderProperty(prop_GlitterContrast, languages.speak("prop_GlitterContrast"));
                    materialEditor.ShaderProperty(prop_ToggleGlitterRainbow, languages.speak("prop_ToggleGlitterRainbow"));
                    Components.start_dynamic_disable(!prop_ToggleGlitterRainbow.floatValue.Equals(1), configs);
                    materialEditor.ShaderProperty(prop_GlitterRainbowSpeed, languages.speak("prop_GlitterRainbowSpeed"));
                    Components.end_dynamic_disable(!prop_ToggleGlitterRainbow.floatValue.Equals(1), configs);
                    Components.end_dynamic_disable(!prop_ToggleGlitter.floatValue.Equals(1), configs);
                }
                sub_tab_iridescence.draw();
                if (sub_tab_iridescence.is_expanded) {
                    // effects - iridescence
                    prop_ToggleIridescence = FindProperty("_ToggleIridescence", properties);
                    prop_IridescenceMode = FindProperty("_IridescenceMode", properties);
                    prop_IridescenceMask = FindProperty("_IridescenceMask", properties);
                    prop_IridescenceTint = FindProperty("_IridescenceTint", properties);
                    prop_IridescenceIntensity = FindProperty("_IridescenceIntensity", properties);
                    prop_IridescenceBlendMode = FindProperty("_IridescenceBlendMode", properties);
                    prop_IridescenceParallax = FindProperty("_IridescenceParallax", properties);
                    prop_IridescenceRamp = FindProperty("_IridescenceRamp", properties);
                    prop_IridescencePower = FindProperty("_IridescencePower", properties);
                    prop_IridescenceFrequency = FindProperty("_IridescenceFrequency", properties);
                    materialEditor.ShaderProperty(prop_ToggleIridescence, languages.speak("prop_ToggleIridescence"));
                    Components.start_dynamic_disable(!prop_ToggleIridescence.floatValue.Equals(1), configs);
                    materialEditor.ShaderProperty(prop_IridescenceMode, languages.speak("prop_IridescenceMode"));
                    materialEditor.ShaderProperty(prop_IridescenceMask, languages.speak("prop_IridescenceMask"));
                    materialEditor.ShaderProperty(prop_IridescenceTint, languages.speak("prop_IridescenceTint"));
                    materialEditor.ShaderProperty(prop_IridescenceIntensity, languages.speak("prop_IridescenceIntensity"));
                    materialEditor.ShaderProperty(prop_IridescenceBlendMode, languages.speak("prop_IridescenceBlendMode"));
                    materialEditor.ShaderProperty(prop_IridescenceParallax, languages.speak("prop_IridescenceParallax"));
                    materialEditor.ShaderProperty(prop_IridescenceRamp, languages.speak("prop_IridescenceRamp"));
                    materialEditor.ShaderProperty(prop_IridescencePower, languages.speak("prop_IridescencePower"));
                    materialEditor.ShaderProperty(prop_IridescenceFrequency, languages.speak("prop_IridescenceFrequency"));
                    Components.end_dynamic_disable(!prop_ToggleIridescence.floatValue.Equals(1), configs);
                }
                sub_tab_shadow_textures.draw();
                if (sub_tab_shadow_textures.is_expanded) {
                    // effects - shadow textures
                    prop_ToggleShadowTexture = FindProperty("_ToggleShadowTexture", properties);
                    prop_ShadowTextureMappingMode = FindProperty("_ShadowTextureMappingMode", properties);
                    prop_ShadowTextureIntensity = FindProperty("_ShadowTextureIntensity", properties);
                    prop_ShadowTex = FindProperty("_ShadowTex", properties);
                    prop_ShadowPatternColor = FindProperty("_ShadowPatternColor", properties);
                    prop_ShadowPatternScale = FindProperty("_ShadowPatternScale", properties);
                    prop_ShadowPatternTriplanarSharpness = FindProperty("_ShadowPatternTriplanarSharpness", properties);
                    prop_ShadowPatternTransparency = FindProperty("_ShadowPatternTransparency", properties);
                    materialEditor.ShaderProperty(prop_ToggleShadowTexture, languages.speak("prop_ToggleShadowTexture"));
                    Components.start_dynamic_disable(!prop_ToggleShadowTexture.floatValue.Equals(1), configs);
                    materialEditor.ShaderProperty(prop_ShadowTextureMappingMode, languages.speak("prop_ShadowTextureMappingMode"));
                    materialEditor.ShaderProperty(prop_ShadowTextureIntensity, languages.speak("prop_ShadowTextureIntensity"));
                    materialEditor.ShaderProperty(prop_ShadowTex, languages.speak("prop_ShadowTex"));
                    materialEditor.ShaderProperty(prop_ShadowPatternColor, languages.speak("prop_ShadowPatternColor"));
                    materialEditor.ShaderProperty(prop_ShadowPatternScale, languages.speak("prop_ShadowPatternScale"));
                    materialEditor.ShaderProperty(prop_ShadowPatternTriplanarSharpness, languages.speak("prop_ShadowPatternTriplanarSharpness"));
                    materialEditor.ShaderProperty(prop_ShadowPatternTransparency, languages.speak("prop_ShadowPatternTransparency"));
                    Components.end_dynamic_disable(!prop_ToggleShadowTexture.floatValue.Equals(1), configs);
                }
                sub_tab_world_aligned.draw();
                if (sub_tab_world_aligned.is_expanded) {
                    // effects - world aligned
                    prop_ToggleWorldEffect = FindProperty("_ToggleWorldEffect", properties);
                    prop_WorldEffectBlendMode = FindProperty("_WorldEffectBlendMode", properties);
                    prop_WorldEffectTex = FindProperty("_WorldEffectTex", properties);
                    prop_WorldEffectColor = FindProperty("_WorldEffectColor", properties);
                    prop_WorldEffectDirection = FindProperty("_WorldEffectDirection", properties);
                    prop_WorldEffectScale = FindProperty("_WorldEffectScale", properties);
                    prop_WorldEffectBlendSharpness = FindProperty("_WorldEffectBlendSharpness", properties);
                    prop_WorldEffectIntensity = FindProperty("_WorldEffectIntensity", properties);
                    prop_WorldEffectPosition = FindProperty("_WorldEffectPosition", properties);
                    prop_WorldEffectRotation = FindProperty("_WorldEffectRotation", properties);
                    // Components.Vector3Property(materialEditor, prop_Decal1TriplanarPosition, languages.speak("prop_Decal1TriplanarPosition"));
                    materialEditor.ShaderProperty(prop_ToggleWorldEffect, languages.speak("prop_ToggleWorldEffect"));
                    Components.start_dynamic_disable(!prop_ToggleWorldEffect.floatValue.Equals(1), configs);
                    materialEditor.ShaderProperty(prop_WorldEffectBlendMode, languages.speak("prop_WorldEffectBlendMode"));
                    materialEditor.ShaderProperty(prop_WorldEffectTex, languages.speak("prop_WorldEffectTex"));
                    materialEditor.ShaderProperty(prop_WorldEffectColor, languages.speak("prop_WorldEffectColor"));
                    materialEditor.ShaderProperty(prop_WorldEffectScale, languages.speak("prop_WorldEffectScale"));
                    Components.Vector3Property(materialEditor, prop_WorldEffectDirection, languages.speak("prop_WorldEffectDirection"));
                    Components.Vector3Property(materialEditor, prop_WorldEffectPosition, languages.speak("prop_WorldEffectPosition"));
                    Components.Vector3Property(materialEditor, prop_WorldEffectRotation, languages.speak("prop_WorldEffectRotation"));
                    materialEditor.ShaderProperty(prop_WorldEffectBlendSharpness, languages.speak("prop_WorldEffectBlendSharpness"));
                    materialEditor.ShaderProperty(prop_WorldEffectIntensity, languages.speak("prop_WorldEffectIntensity"));
                    Components.end_dynamic_disable(!prop_ToggleWorldEffect.floatValue.Equals(1), configs);
                }
                sub_tab_touch_interactions.draw();
                if (sub_tab_touch_interactions.is_expanded) {
                    // effects - touch interactions
                    prop_ToggleTouchReactive = FindProperty("_ToggleTouchReactive", properties);
                    prop_TouchColor = FindProperty("_TouchColor", properties);
                    prop_TouchRadius = FindProperty("_TouchRadius", properties);
                    prop_TouchHardness = FindProperty("_TouchHardness", properties);
                    prop_TouchMode = FindProperty("_TouchMode", properties);
                    prop_TouchRainbowSpeed = FindProperty("_TouchRainbowSpeed", properties);
                    prop_TouchRainbowSpread = FindProperty("_TouchRainbowSpread", properties);
                    materialEditor.ShaderProperty(prop_ToggleTouchReactive, languages.speak("prop_ToggleTouchReactive"));
                    Components.start_dynamic_disable(!prop_ToggleTouchReactive.floatValue.Equals(1), configs);
                    materialEditor.ShaderProperty(prop_TouchColor, languages.speak("prop_TouchColor"));
                    materialEditor.ShaderProperty(prop_TouchRadius, languages.speak("prop_TouchRadius"));
                    materialEditor.ShaderProperty(prop_TouchHardness, languages.speak("prop_TouchHardness"));
                    materialEditor.ShaderProperty(prop_TouchMode, languages.speak("prop_TouchMode"));
                    Components.start_dynamic_disable(!prop_TouchMode.floatValue.Equals(3), configs); // rainbow mode
                    materialEditor.ShaderProperty(prop_TouchRainbowSpeed, languages.speak("prop_TouchRainbowSpeed"));
                    materialEditor.ShaderProperty(prop_TouchRainbowSpread, languages.speak("prop_TouchRainbowSpread"));
                    Components.end_dynamic_disable(!prop_TouchMode.floatValue.Equals(3), configs);
                    Components.end_dynamic_disable(!prop_ToggleTouchReactive.floatValue.Equals(1), configs);
                }
                sub_tab_flatten_model.draw();
                if (sub_tab_flatten_model.is_expanded) {
                    // effects - flatten model
                    prop_ToggleFlatModel = FindProperty("_ToggleFlatModel", properties);
                    prop_FlatModeAutoflip = FindProperty("_FlatModeAutoflip", properties);
                    prop_FlatModel = FindProperty("_FlatModel", properties);
                    prop_FlatModelDepthCorrection = FindProperty("_FlatModelDepthCorrection", properties);
                    prop_FlatModelFacing = FindProperty("_FlatModelFacing", properties);
                    prop_FlatModelLockAxis = FindProperty("_FlatModelLockAxis", properties);
                    materialEditor.ShaderProperty(prop_ToggleFlatModel, languages.speak("prop_ToggleFlatModel"));
                    Components.start_dynamic_disable(!prop_ToggleFlatModel.floatValue.Equals(1), configs);
                    materialEditor.ShaderProperty(prop_FlatModeAutoflip, languages.speak("prop_FlatModeAutoflip"));
                    materialEditor.ShaderProperty(prop_FlatModel, languages.speak("prop_FlatModel"));
                    materialEditor.ShaderProperty(prop_FlatModelDepthCorrection, languages.speak("prop_FlatModelDepthCorrection"));
                    materialEditor.ShaderProperty(prop_FlatModelFacing, languages.speak("prop_FlatModelFacing"));
                    materialEditor.ShaderProperty(prop_FlatModelLockAxis, languages.speak("prop_FlatModelLockAxis"));
                    Components.end_dynamic_disable(!prop_ToggleFlatModel.floatValue.Equals(1), configs);
                }
                sub_tab_vertex_distortion.draw();
                if (sub_tab_vertex_distortion.is_expanded) {
                    // effects - vertex distortion
                    prop_ToggleVertexDistortion = FindProperty("_ToggleVertexDistortion", properties);
                    prop_VertexDistortionMode = FindProperty("_VertexDistortionMode", properties);
                    prop_VertexDistortionStrength = FindProperty("_VertexDistortionStrength", properties);
                    prop_VertexDistortionSpeed = FindProperty("_VertexDistortionSpeed", properties);
                    prop_VertexDistortionFrequency = FindProperty("_VertexDistortionFrequency", properties);
                    materialEditor.ShaderProperty(prop_ToggleVertexDistortion, languages.speak("prop_ToggleVertexDistortion"));
                    Components.start_dynamic_disable(!prop_ToggleVertexDistortion.floatValue.Equals(1), configs);
                    materialEditor.ShaderProperty(prop_VertexDistortionMode, languages.speak("prop_VertexDistortionMode"));
                    Components.Vector3Property(materialEditor, prop_VertexDistortionStrength, languages.speak("prop_VertexDistortionStrength"));
                    Components.Vector3Property(materialEditor, prop_VertexDistortionSpeed, languages.speak("prop_VertexDistortionSpeed"));
                    Components.Vector3Property(materialEditor, prop_VertexDistortionFrequency, languages.speak("prop_VertexDistortionFrequency"));
                    Components.end_dynamic_disable(!prop_ToggleVertexDistortion.floatValue.Equals(1), configs);
                }
                sub_tab_dither.draw();
                if (sub_tab_dither.is_expanded) {
                    // effects - dither
                    prop_ToggleDither = FindProperty("_ToggleDither", properties);
                    prop_DitherAmount = FindProperty("_DitherAmount", properties);
                    prop_DitherScale = FindProperty("_DitherScale", properties);
                    prop_DitherSpace = FindProperty("_DitherSpace", properties);
                    materialEditor.ShaderProperty(prop_ToggleDither, languages.speak("prop_ToggleDither"));
                    Components.start_dynamic_disable(!prop_ToggleDither.floatValue.Equals(1), configs);
                    materialEditor.ShaderProperty(prop_DitherSpace, languages.speak("prop_DitherSpace"));
                    materialEditor.ShaderProperty(prop_DitherAmount, languages.speak("prop_DitherAmount"));
                    materialEditor.ShaderProperty(prop_DitherScale, languages.speak("prop_DitherScale"));
                    Components.end_dynamic_disable(!prop_ToggleDither.floatValue.Equals(1), configs);
                }
                sub_tab_ps1.draw();
                if (sub_tab_ps1.is_expanded) {
                    // effects - ps1
                    prop_TogglePS1 = FindProperty("_TogglePS1", properties);
                    prop_PS1Rounding = FindProperty("_PS1Rounding", properties);
                    prop_PS1RoundingPrecision = FindProperty("_PS1RoundingPrecision", properties);
                    prop_PS1Affine = FindProperty("_PS1Affine", properties);
                    prop_PS1Compression = FindProperty("_PS1Compression", properties);
                    prop_PS1CompressionPrecision = FindProperty("_PS1CompressionPrecision", properties);
                    materialEditor.ShaderProperty(prop_TogglePS1, languages.speak("prop_TogglePS1"));
                    Components.start_dynamic_disable(!prop_TogglePS1.floatValue.Equals(1), configs);
                    materialEditor.ShaderProperty(prop_PS1Rounding, languages.speak("prop_PS1Rounding"));
                    Components.start_dynamic_disable(prop_PS1Rounding.floatValue.Equals(0), configs);
                    EditorGUI.indentLevel++;
                    materialEditor.ShaderProperty(prop_PS1RoundingPrecision, languages.speak("prop_PS1RoundingPrecision"));
                    EditorGUI.indentLevel--;
                    Components.end_dynamic_disable(prop_PS1Rounding.floatValue.Equals(0), configs);
                    materialEditor.ShaderProperty(prop_PS1Affine, languages.speak("prop_PS1Affine"));
                    materialEditor.ShaderProperty(prop_PS1Compression, languages.speak("prop_PS1Compression"));
                    Components.start_dynamic_disable(prop_PS1Compression.floatValue.Equals(0), configs);
                    EditorGUI.indentLevel++;
                    materialEditor.ShaderProperty(prop_PS1CompressionPrecision, languages.speak("prop_PS1CompressionPrecision"));
                    EditorGUI.indentLevel--;
                    Components.end_dynamic_disable(prop_PS1Compression.floatValue.Equals(0), configs);
                    Components.end_dynamic_disable(!prop_TogglePS1.floatValue.Equals(1), configs);
                }
                sub_tab_refraction.draw();
                if (sub_tab_refraction.is_expanded) {
                    // effects - refraction
                    prop_ToggleRefraction = FindProperty("_ToggleRefraction", properties);
                    prop_RefractionMask = FindProperty("_RefractionMask", properties);
                    prop_RefractionTint = FindProperty("_RefractionTint", properties);
                    prop_RefractionIOR = FindProperty("_RefractionIOR", properties);
                    prop_RefractionFresnel = FindProperty("_RefractionFresnel", properties);
                    prop_RefractionOpacity = FindProperty("_RefractionOpacity", properties);
                    prop_RefractionSeeThrough = FindProperty("_RefractionSeeThrough", properties);
                    prop_RefractionMode = FindProperty("_RefractionMode", properties);
                    prop_RefractionMixStrength = FindProperty("_RefractionMixStrength", properties);
                    prop_RefractionBlendMode = FindProperty("_RefractionBlendMode", properties);
                    prop_CausticsTex = FindProperty("_CausticsTex", properties);
                    prop_CausticsColor = FindProperty("_CausticsColor", properties);
                    prop_CausticsTiling = FindProperty("_CausticsTiling", properties);
                    prop_CausticsSpeed = FindProperty("_CausticsSpeed", properties);
                    prop_CausticsIntensity = FindProperty("_CausticsIntensity", properties);
                    prop_DistortionNoiseTex = FindProperty("_DistortionNoiseTex", properties);
                    prop_DistortionNoiseTiling = FindProperty("_DistortionNoiseTiling", properties);
                    prop_DistortionNoiseStrength = FindProperty("_DistortionNoiseStrength", properties);
                    prop_RefractionDistortionMode = FindProperty("_RefractionDistortionMode", properties);
                    prop_RefractionCAStrength = FindProperty("_RefractionCAStrength", properties);
                    prop_RefractionBlurStrength = FindProperty("_RefractionBlurStrength", properties);
                    prop_RefractionCAUseFresnel = FindProperty("_RefractionCAUseFresnel", properties);
                    prop_RefractionCAEdgeFade = FindProperty("_RefractionCAEdgeFade", properties);
                    materialEditor.ShaderProperty(prop_ToggleRefraction, languages.speak("prop_ToggleRefraction"));
                    Components.start_dynamic_disable(!prop_ToggleRefraction.floatValue.Equals(1), configs);
                    materialEditor.ShaderProperty(prop_RefractionMask, languages.speak("prop_RefractionMask"));
                    materialEditor.ShaderProperty(prop_RefractionIOR, languages.speak("prop_RefractionIOR"));
                    materialEditor.ShaderProperty(prop_RefractionOpacity, languages.speak("prop_RefractionOpacity"));
                    materialEditor.ShaderProperty(prop_RefractionSeeThrough, languages.speak("prop_RefractionSeeThrough"));
                    materialEditor.ShaderProperty(prop_RefractionTint, languages.speak("prop_RefractionTint"));
                    materialEditor.ShaderProperty(prop_RefractionFresnel, languages.speak("prop_RefractionFresnel"));
                    materialEditor.ShaderProperty(prop_RefractionMode, languages.speak("prop_RefractionMode"));
                    EditorGUI.indentLevel++;
                    materialEditor.ShaderProperty(prop_RefractionMixStrength, languages.speak("prop_RefractionMixStrength"));
                    EditorGUI.indentLevel--;
                    materialEditor.ShaderProperty(prop_CausticsTex, languages.speak("prop_CausticsTex"));
                    Components.start_dynamic_disable(prop_CausticsTex.textureValue == null, configs);
                    EditorGUI.indentLevel++;
                    materialEditor.ShaderProperty(prop_CausticsColor, languages.speak("prop_CausticsColor"));
                    materialEditor.ShaderProperty(prop_CausticsTiling, languages.speak("prop_CausticsTiling"));
                    materialEditor.ShaderProperty(prop_RefractionBlendMode, languages.speak("prop_RefractionBlendMode"));
                    materialEditor.ShaderProperty(prop_CausticsSpeed, languages.speak("prop_CausticsSpeed"));
                    materialEditor.ShaderProperty(prop_CausticsIntensity, languages.speak("prop_CausticsIntensity"));
                    EditorGUI.indentLevel--;
                    Components.end_dynamic_disable(prop_CausticsTex.textureValue == null, configs);
                    materialEditor.ShaderProperty(prop_DistortionNoiseTex, languages.speak("prop_DistortionNoiseTex"));
                    Components.start_dynamic_disable(prop_DistortionNoiseTex.textureValue == null, configs);
                    EditorGUI.indentLevel++;
                    materialEditor.ShaderProperty(prop_DistortionNoiseTiling, languages.speak("prop_DistortionNoiseTiling"));
                    materialEditor.ShaderProperty(prop_DistortionNoiseStrength, languages.speak("prop_DistortionNoiseStrength"));
                    EditorGUI.indentLevel--;
                    Components.end_dynamic_disable(prop_DistortionNoiseTex.textureValue == null, configs);
                    materialEditor.ShaderProperty(prop_RefractionDistortionMode, languages.speak("prop_RefractionDistortionMode"));
                    EditorGUI.indentLevel++;
                    materialEditor.ShaderProperty(prop_RefractionCAStrength, languages.speak("prop_RefractionCAStrength"));
                    materialEditor.ShaderProperty(prop_RefractionBlurStrength, languages.speak("prop_RefractionBlurStrength"));
                    if (prop_RefractionDistortionMode.floatValue.Equals(1)) {
                        materialEditor.ShaderProperty(prop_RefractionCAUseFresnel, languages.speak("prop_RefractionCAUseFresnel"));
                        Components.start_dynamic_disable(!prop_RefractionCAUseFresnel.floatValue.Equals(1), configs);
                        materialEditor.ShaderProperty(prop_RefractionCAEdgeFade, languages.speak("prop_RefractionCAEdgeFade"));
                        Components.end_dynamic_disable(!prop_RefractionCAUseFresnel.floatValue.Equals(1), configs);
                    }
                    EditorGUI.indentLevel--;
                    Components.end_dynamic_disable(!prop_ToggleRefraction.floatValue.Equals(1), configs);
                }
                sub_tab_screenspace_reflection.draw();
                if (sub_tab_screenspace_reflection.is_expanded) {
                    // effects - screenspace reflection
                    prop_ToggleSSR = FindProperty("_ToggleSSR", properties);
                    prop_SSRMask = FindProperty("_SSRMask", properties);
                    prop_SSRTint = FindProperty("_SSRTint", properties);
                    prop_SSRIntensity = FindProperty("_SSRIntensity", properties);
                    prop_SSRBlendMode = FindProperty("_SSRBlendMode", properties);
                    prop_SSRFresnelPower = FindProperty("_SSRFresnelPower", properties);
                    prop_SSRFresnelScale = FindProperty("_SSRFresnelScale", properties);
                    prop_SSRFresnelBias = FindProperty("_SSRFresnelBias", properties);
                    prop_SSRParallax = FindProperty("_SSRParallax", properties);
                    prop_SSRDistortionMap = FindProperty("_SSRDistortionMap", properties);
                    prop_SSRDistortionStrength = FindProperty("_SSRDistortionStrength", properties);
                    prop_SSRWorldDistortion = FindProperty("_SSRWorldDistortion", properties);
                    prop_SSRBlur = FindProperty("_SSRBlur", properties);
                    prop_SSRMaxSteps = FindProperty("_SSRMaxSteps", properties);
                    prop_SSRStepSize = FindProperty("_SSRStepSize", properties);
                    prop_SSREdgeFade = FindProperty("_SSREdgeFade", properties);
                    prop_SSRCoverage = FindProperty("_SSRCoverage", properties);
                    prop_SSRCamFade = FindProperty("_SSRCamFade", properties);
                    prop_SSRCamFadeStart = FindProperty("_SSRCamFadeStart", properties);
                    prop_SSRCamFadeEnd = FindProperty("_SSRCamFadeEnd", properties);
                    prop_SSRFlipUV = FindProperty("_SSRFlipUV", properties);
                    prop_SSRAdaptiveStep = FindProperty("_SSRAdaptiveStep", properties);
                    prop_SSRThickness = FindProperty("_SSRThickness", properties);
                    prop_SSROutOfViewMode = FindProperty("_SSROutOfViewMode", properties);
                    prop_SSRMode = FindProperty("_SSRMode", properties);
                    materialEditor.ShaderProperty(prop_ToggleSSR, languages.speak("prop_ToggleSSR"));
                    Components.start_dynamic_disable(!prop_ToggleSSR.floatValue.Equals(1), configs);
                    materialEditor.ShaderProperty(prop_SSRMode, languages.speak("prop_SSRMode"));
                    materialEditor.ShaderProperty(prop_SSRMask, languages.speak("prop_SSRMask"));
                    materialEditor.ShaderProperty(prop_SSRTint, languages.speak("prop_SSRTint"));
                    materialEditor.ShaderProperty(prop_SSRBlendMode, languages.speak("prop_SSRBlendMode"));
                    materialEditor.ShaderProperty(prop_SSRIntensity, languages.speak("prop_SSRIntensity"));
                    materialEditor.ShaderProperty(prop_SSRFresnelPower, languages.speak("prop_SSRFresnelPower"));
                    materialEditor.ShaderProperty(prop_SSRFresnelScale, languages.speak("prop_SSRFresnelScale"));
                    materialEditor.ShaderProperty(prop_SSRFresnelBias, languages.speak("prop_SSRFresnelBias"));
                    materialEditor.ShaderProperty(prop_SSRCoverage, languages.speak("prop_SSRCoverage")); 
                    if (prop_SSRMode.floatValue.Equals(0)) {
                        // planar
                        materialEditor.ShaderProperty(prop_SSRParallax, languages.speak("prop_SSRParallax"));
                        materialEditor.ShaderProperty(prop_SSRBlur, languages.speak("prop_SSRBlur"));
                        materialEditor.ShaderProperty(prop_SSRDistortionMap, languages.speak("prop_SSRDistortionMap"));
                        Components.start_dynamic_disable(prop_SSRDistortionMap.textureValue == null, configs);
                        EditorGUI.indentLevel++;
                        materialEditor.ShaderProperty(prop_SSRDistortionStrength, languages.speak("prop_SSRDistortionStrength"));
                        materialEditor.ShaderProperty(prop_SSRWorldDistortion, languages.speak("prop_SSRWorldDistortion"));
                        EditorGUI.indentLevel--;
                        Components.end_dynamic_disable(prop_SSRDistortionMap.textureValue == null, configs);
                    } else {
                        // raymarched
                        materialEditor.ShaderProperty(prop_SSRFlipUV, languages.speak("prop_SSRFlipUV"));
                        materialEditor.ShaderProperty(prop_SSROutOfViewMode, languages.speak("prop_SSROutOfViewMode"));
                        materialEditor.ShaderProperty(prop_SSRAdaptiveStep, languages.speak("prop_SSRAdaptiveStep"));
                        materialEditor.ShaderProperty(prop_SSRMaxSteps, languages.speak("prop_SSRMaxSteps"));
                        materialEditor.ShaderProperty(prop_SSRStepSize, languages.speak("prop_SSRStepSize"));
                        materialEditor.ShaderProperty(prop_SSRThickness, languages.speak("prop_SSRThickness"));
                        materialEditor.ShaderProperty(prop_SSREdgeFade, languages.speak("prop_SSREdgeFade"));
                        materialEditor.ShaderProperty(prop_SSRCamFade, languages.speak("prop_SSRCamFade"));
                        Components.start_dynamic_disable(!prop_SSRCamFade.floatValue.Equals(1), configs);
                        EditorGUI.indentLevel++;
                        materialEditor.ShaderProperty(prop_SSRCamFadeStart, languages.speak("prop_SSRCamFadeStart"));
                        materialEditor.ShaderProperty(prop_SSRCamFadeEnd, languages.speak("prop_SSRCamFadeEnd"));
                        EditorGUI.indentLevel--;
                        Components.end_dynamic_disable(!prop_SSRCamFade.floatValue.Equals(1), configs);
                    }
                    Components.end_dynamic_disable(!prop_ToggleSSR.floatValue.Equals(1), configs);
                }
                Components.end_foldout();
            }
            // outline tab
            tab_outline.draw();
            if (tab_outline.is_expanded) {
                Components.start_foldout();
                // outline
                prop_OutlineColor = FindProperty("_OutlineColor", properties);
                prop_OutlineWidth = FindProperty("_OutlineWidth", properties);
                prop_OutlineVertexColorMask = FindProperty("_OutlineVertexColorMask", properties);
                prop_OutlineDistanceFade = FindProperty("_OutlineDistanceFade", properties);
                prop_OutlineFadeStart = FindProperty("_OutlineFadeStart", properties);
                prop_OutlineFadeEnd = FindProperty("_OutlineFadeEnd", properties);
                prop_OutlineHueShift = FindProperty("_OutlineHueShift", properties);
                prop_OutlineHueShiftSpeed = FindProperty("_OutlineHueShiftSpeed", properties);
                prop_OutlineOpacity = FindProperty("_OutlineOpacity", properties);
                materialEditor.ShaderProperty(prop_OutlineColor, languages.speak("prop_OutlineColor"));
                materialEditor.ShaderProperty(prop_OutlineWidth, languages.speak("prop_OutlineWidth"));
                materialEditor.ShaderProperty(prop_OutlineVertexColorMask, languages.speak("prop_OutlineVertexColorMask"));
                materialEditor.ShaderProperty(prop_OutlineDistanceFade, languages.speak("prop_OutlineDistanceFade"));
                Components.start_dynamic_disable(!prop_OutlineDistanceFade.floatValue.Equals(1), configs);
                EditorGUI.indentLevel++;
                materialEditor.ShaderProperty(prop_OutlineFadeStart, languages.speak("prop_OutlineFadeStart"));
                materialEditor.ShaderProperty(prop_OutlineFadeEnd, languages.speak("prop_OutlineFadeEnd"));
                EditorGUI.indentLevel--;
                Components.end_dynamic_disable(!prop_OutlineDistanceFade.floatValue.Equals(1), configs);
                materialEditor.ShaderProperty(prop_OutlineHueShift, languages.speak("prop_OutlineHueShift"));
                Components.start_dynamic_disable(!prop_OutlineHueShift.floatValue.Equals(1), configs);
                EditorGUI.indentLevel++;
                materialEditor.ShaderProperty(prop_OutlineHueShiftSpeed, languages.speak("prop_OutlineHueShiftSpeed"));
                materialEditor.ShaderProperty(prop_OutlineOpacity, languages.speak("prop_OutlineOpacity"));
                EditorGUI.indentLevel--;
                Components.end_dynamic_disable(!prop_OutlineHueShift.floatValue.Equals(1), configs);
                Components.end_foldout();
            }
            // third party tab
            tab_third_party.draw();
            if (tab_third_party.is_expanded) {
                Components.start_foldout();
                sub_tab_audiolink.draw();
                if (sub_tab_audiolink.is_expanded) {
                    // third party - audiolink
                    prop_ToggleAudioLink = FindProperty("_ToggleAudioLink", properties);
                    prop_AudioLinkFallback = FindProperty("_AudioLinkFallback", properties);
                    prop_AudioLinkEmissionBand = FindProperty("_AudioLinkEmissionBand", properties);
                    prop_AudioLinkEmissionStrength = FindProperty("_AudioLinkEmissionStrength", properties);
                    prop_AudioLinkEmissionRange = FindProperty("_AudioLinkEmissionRange", properties);
                    prop_AudioLinkRimBand = FindProperty("_AudioLinkRimBand", properties);
                    prop_AudioLinkRimStrength = FindProperty("_AudioLinkRimStrength", properties);
                    prop_AudioLinkRimRange = FindProperty("_AudioLinkRimRange", properties);
                    prop_AudioLinkHueShiftBand = FindProperty("_AudioLinkHueShiftBand", properties);
                    prop_AudioLinkHueShiftStrength = FindProperty("_AudioLinkHueShiftStrength", properties);
                    prop_AudioLinkHueShiftRange = FindProperty("_AudioLinkHueShiftRange", properties);
                    prop_AudioLinkDecalHueBand = FindProperty("_AudioLinkDecalHueBand", properties);
                    prop_AudioLinkDecalHueStrength = FindProperty("_AudioLinkDecalHueStrength", properties);
                    prop_AudioLinkDecalHueRange = FindProperty("_AudioLinkDecalHueRange", properties);
                    prop_AudioLinkDecalEmissionBand = FindProperty("_AudioLinkDecalEmissionBand", properties);
                    prop_AudioLinkDecalEmissionStrength = FindProperty("_AudioLinkDecalEmissionStrength", properties);
                    prop_AudioLinkDecalEmissionRange = FindProperty("_AudioLinkDecalEmissionRange", properties);
                    prop_AudioLinkDecalOpacityBand = FindProperty("_AudioLinkDecalOpacityBand", properties);
                    prop_AudioLinkDecalOpacityStrength = FindProperty("_AudioLinkDecalOpacityStrength", properties);
                    prop_AudioLinkDecalOpacityRange = FindProperty("_AudioLinkDecalOpacityRange", properties);
                    prop_AudioLinkVertexBand = FindProperty("_AudioLinkVertexBand", properties);
                    prop_AudioLinkVertexStrength = FindProperty("_AudioLinkVertexStrength", properties);
                    prop_AudioLinkVertexRange = FindProperty("_AudioLinkVertexRange", properties);
                    prop_AudioLinkOutlineBand = FindProperty("_AudioLinkOutlineBand", properties);
                    prop_AudioLinkOutlineStrength = FindProperty("_AudioLinkOutlineStrength", properties);
                    prop_AudioLinkOutlineRange = FindProperty("_AudioLinkOutlineRange", properties);
                    prop_AudioLinkMatcapBand = FindProperty("_AudioLinkMatcapBand", properties);
                    prop_AudioLinkMatcapStrength = FindProperty("_AudioLinkMatcapStrength", properties);
                    prop_AudioLinkMatcapRange = FindProperty("_AudioLinkMatcapRange", properties);
                    prop_AudioLinkPathingBand = FindProperty("_AudioLinkPathingBand", properties);
                    prop_AudioLinkPathingStrength = FindProperty("_AudioLinkPathingStrength", properties);
                    prop_AudioLinkPathingRange = FindProperty("_AudioLinkPathingRange", properties);
                    prop_AudioLinkGlitterBand = FindProperty("_AudioLinkGlitterBand", properties);
                    prop_AudioLinkGlitterStrength = FindProperty("_AudioLinkGlitterStrength", properties);
                    prop_AudioLinkGlitterRange = FindProperty("_AudioLinkGlitterRange", properties);
                    prop_AudioLinkIridescenceBand = FindProperty("_AudioLinkIridescenceBand", properties);
                    prop_AudioLinkIridescenceStrength = FindProperty("_AudioLinkIridescenceStrength", properties);
                    prop_AudioLinkIridescenceRange = FindProperty("_AudioLinkIridescenceRange", properties);
                    materialEditor.ShaderProperty(prop_ToggleAudioLink, languages.speak("prop_ToggleAudioLink"));
                    Components.start_dynamic_disable(!prop_ToggleAudioLink.floatValue.Equals(1), configs);
                    materialEditor.ShaderProperty(prop_AudioLinkFallback, languages.speak("prop_AudioLinkFallback"));
                    materialEditor.ShaderProperty(prop_AudioLinkEmissionBand, languages.speak("prop_AudioLinkEmissionBand"));
                    Components.start_dynamic_disable(prop_AudioLinkEmissionBand.floatValue.Equals(0), configs);
                    EditorGUI.indentLevel++;
                    materialEditor.ShaderProperty(prop_AudioLinkEmissionStrength, languages.speak("prop_AudioLinkEmissionStrength"));
                    materialEditor.ShaderProperty(prop_AudioLinkEmissionRange, languages.speak("prop_AudioLinkEmissionRange"));
                    EditorGUI.indentLevel--;
                    Components.end_dynamic_disable(prop_AudioLinkEmissionBand.floatValue.Equals(0), configs);
                    materialEditor.ShaderProperty(prop_AudioLinkRimBand, languages.speak("prop_AudioLinkRimBand"));
                    Components.start_dynamic_disable(prop_AudioLinkRimBand.floatValue.Equals(0), configs);
                    EditorGUI.indentLevel++;
                    materialEditor.ShaderProperty(prop_AudioLinkRimStrength, languages.speak("prop_AudioLinkRimStrength"));
                    materialEditor.ShaderProperty(prop_AudioLinkRimRange, languages.speak("prop_AudioLinkRimRange"));
                    EditorGUI.indentLevel--;
                    Components.end_dynamic_disable(prop_AudioLinkRimBand.floatValue.Equals(0), configs);
                    materialEditor.ShaderProperty(prop_AudioLinkHueShiftBand, languages.speak("prop_AudioLinkHueShiftBand"));
                    Components.start_dynamic_disable(prop_AudioLinkHueShiftBand.floatValue.Equals(0), configs);
                    EditorGUI.indentLevel++;
                    materialEditor.ShaderProperty(prop_AudioLinkHueShiftStrength, languages.speak("prop_AudioLinkHueShiftStrength"));
                    materialEditor.ShaderProperty(prop_AudioLinkHueShiftRange, languages.speak("prop_AudioLinkHueShiftRange"));
                    EditorGUI.indentLevel--;
                    Components.end_dynamic_disable(prop_AudioLinkHueShiftBand.floatValue.Equals(0), configs);
                    materialEditor.ShaderProperty(prop_AudioLinkDecalHueBand, languages.speak("prop_AudioLinkDecalHueBand"));
                    Components.start_dynamic_disable(prop_AudioLinkDecalHueBand.floatValue.Equals(0), configs);
                    EditorGUI.indentLevel++;
                    materialEditor.ShaderProperty(prop_AudioLinkDecalHueStrength, languages.speak("prop_AudioLinkDecalHueStrength"));
                    materialEditor.ShaderProperty(prop_AudioLinkDecalHueRange, languages.speak("prop_AudioLinkDecalHueRange"));
                    EditorGUI.indentLevel--;
                    Components.end_dynamic_disable(prop_AudioLinkDecalHueBand.floatValue.Equals(0), configs);
                    materialEditor.ShaderProperty(prop_AudioLinkDecalEmissionBand, languages.speak("prop_AudioLinkDecalEmissionBand"));
                    Components.start_dynamic_disable(prop_AudioLinkDecalEmissionBand.floatValue.Equals(0), configs);
                    EditorGUI.indentLevel++;
                    materialEditor.ShaderProperty(prop_AudioLinkDecalEmissionStrength, languages.speak("prop_AudioLinkDecalEmissionStrength"));
                    materialEditor.ShaderProperty(prop_AudioLinkDecalEmissionRange, languages.speak("prop_AudioLinkDecalEmissionRange"));
                    EditorGUI.indentLevel--;
                    Components.end_dynamic_disable(prop_AudioLinkDecalEmissionBand.floatValue.Equals(0), configs);
                    materialEditor.ShaderProperty(prop_AudioLinkDecalOpacityBand, languages.speak("prop_AudioLinkDecalOpacityBand"));
                    Components.start_dynamic_disable(prop_AudioLinkDecalOpacityBand.floatValue.Equals(0), configs);
                    EditorGUI.indentLevel++;
                    materialEditor.ShaderProperty(prop_AudioLinkDecalOpacityStrength, languages.speak("prop_AudioLinkDecalOpacityStrength"));
                    materialEditor.ShaderProperty(prop_AudioLinkDecalOpacityRange, languages.speak("prop_AudioLinkDecalOpacityRange"));
                    EditorGUI.indentLevel--;
                    Components.end_dynamic_disable(prop_AudioLinkDecalOpacityBand.floatValue.Equals(0), configs);
                    materialEditor.ShaderProperty(prop_AudioLinkVertexBand, languages.speak("prop_AudioLinkVertexBand"));
                    Components.start_dynamic_disable(prop_AudioLinkVertexBand.floatValue.Equals(0), configs);
                    EditorGUI.indentLevel++;
                    materialEditor.ShaderProperty(prop_AudioLinkVertexStrength, languages.speak("prop_AudioLinkVertexStrength"));
                    materialEditor.ShaderProperty(prop_AudioLinkVertexRange, languages.speak("prop_AudioLinkVertexRange"));
                    EditorGUI.indentLevel--;
                    Components.end_dynamic_disable(prop_AudioLinkVertexBand.floatValue.Equals(0), configs);
                    materialEditor.ShaderProperty(prop_AudioLinkOutlineBand, languages.speak("prop_AudioLinkOutlineBand"));
                    Components.start_dynamic_disable(prop_AudioLinkOutlineBand.floatValue.Equals(0), configs);
                    EditorGUI.indentLevel++;
                    materialEditor.ShaderProperty(prop_AudioLinkOutlineStrength, languages.speak("prop_AudioLinkOutlineStrength"));
                    materialEditor.ShaderProperty(prop_AudioLinkOutlineRange, languages.speak("prop_AudioLinkOutlineRange"));
                    EditorGUI.indentLevel--;
                    Components.end_dynamic_disable(prop_AudioLinkOutlineBand.floatValue.Equals(0), configs);
                    materialEditor.ShaderProperty(prop_AudioLinkMatcapBand, languages.speak("prop_AudioLinkMatcapBand"));
                    Components.start_dynamic_disable(prop_AudioLinkMatcapBand.floatValue.Equals(0), configs);
                    EditorGUI.indentLevel++;
                    materialEditor.ShaderProperty(prop_AudioLinkMatcapStrength, languages.speak("prop_AudioLinkMatcapStrength"));
                    materialEditor.ShaderProperty(prop_AudioLinkMatcapRange, languages.speak("prop_AudioLinkMatcapRange"));
                    EditorGUI.indentLevel--;
                    Components.end_dynamic_disable(prop_AudioLinkMatcapBand.floatValue.Equals(0), configs);
                    materialEditor.ShaderProperty(prop_AudioLinkPathingBand, languages.speak("prop_AudioLinkPathingBand"));
                    Components.start_dynamic_disable(prop_AudioLinkPathingBand.floatValue.Equals(0), configs);
                    EditorGUI.indentLevel++;
                    materialEditor.ShaderProperty(prop_AudioLinkPathingStrength, languages.speak("prop_AudioLinkPathingStrength"));
                    materialEditor.ShaderProperty(prop_AudioLinkPathingRange, languages.speak("prop_AudioLinkPathingRange"));
                    EditorGUI.indentLevel--;
                    Components.end_dynamic_disable(prop_AudioLinkPathingBand.floatValue.Equals(0), configs);
                    materialEditor.ShaderProperty(prop_AudioLinkGlitterBand, languages.speak("prop_AudioLinkGlitterBand"));
                    Components.start_dynamic_disable(prop_AudioLinkGlitterBand.floatValue.Equals(0), configs);
                    EditorGUI.indentLevel++;
                    materialEditor.ShaderProperty(prop_AudioLinkGlitterStrength, languages.speak("prop_AudioLinkGlitterStrength"));
                    materialEditor.ShaderProperty(prop_AudioLinkGlitterRange, languages.speak("prop_AudioLinkGlitterRange"));
                    EditorGUI.indentLevel--;
                    Components.end_dynamic_disable(prop_AudioLinkGlitterBand.floatValue.Equals(0), configs);
                    materialEditor.ShaderProperty(prop_AudioLinkIridescenceBand, languages.speak("prop_AudioLinkIridescenceBand"));
                    Components.start_dynamic_disable(prop_AudioLinkIridescenceBand.floatValue.Equals(0), configs);
                    EditorGUI.indentLevel++;
                    materialEditor.ShaderProperty(prop_AudioLinkIridescenceStrength, languages.speak("prop_AudioLinkIridescenceStrength"));
                    materialEditor.ShaderProperty(prop_AudioLinkIridescenceRange, languages.speak("prop_AudioLinkIridescenceRange"));
                    EditorGUI.indentLevel--;
                    Components.end_dynamic_disable(prop_AudioLinkIridescenceBand.floatValue.Equals(0), configs);
                    Components.end_dynamic_disable(!prop_ToggleAudioLink.floatValue.Equals(1), configs);
                }
                sub_tab_superplug.draw();
                if (sub_tab_superplug.is_expanded) {
                    // third party - superplug
                    GUIStyle boldWrap = new GUIStyle(EditorStyles.boldLabel);
                    boldWrap.wordWrap = true;
                    GUILayout.Label(theme.language_manager.speak("superplug_notice"), boldWrap);
                    if (GUILayout.Button(theme.language_manager.speak("superplug_button"))) {
                        Components.open_external_website("https://vrcfury.com/sps/", ref theme);
                    }
                }
                sub_tab_ltcgi.draw();
                if (sub_tab_ltcgi.is_expanded) {
                    // third party - ltcgi
                    prop_ToggleLTCGI = FindProperty("_ToggleLTCGI", properties);
                    materialEditor.ShaderProperty(prop_ToggleLTCGI, languages.speak("prop_ToggleLTCGI"));
                    GUIStyle boldWrap = new GUIStyle(EditorStyles.boldLabel);
                    boldWrap.wordWrap = true;
                    GUILayout.Label(theme.language_manager.speak("ltcgi_notice"), boldWrap);
                    if (GUILayout.Button(theme.language_manager.speak("ltcgi_button"))) {
                        Components.open_external_website("https://github.com/PiMaker/ltcgi/", ref theme);
                    }                  
                }
                Components.end_foldout();
            }
            #endregion // Backlace
            license_menu.draw();
            config_menu.draw();
            presets_menu.draw();
            announcement.draw();
            docs.draw();
            socials_menu.draw();
            if (EditorGUI.EndChangeCheck())
            {
                cushion.Update(targetMat);
                beauty_blender.Update(targetMat);
            }
        }

    }

}
#endif // UNITY_EDITOR

//
//⠀⠀⠀⠀⠀⠀⠀   ⠀⠀⠀ ⣀⣀⣀⣀⣀⣀⣀⣀⣀⣀⣀⣀⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
//⠀⠀⠀⠀⠀⠀⠀⠀⠀⠠⣶⣟⣛⠛⠋⠉⠉⠉⠉⠉⠉⠉⠉⠉⠙⢛⣛⣷⡦⠀⠀⠀⠀⠀⠀
//⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠉⠛⠛⠛⠛⠛⠛⠛⠛⠛⠛⠛⠛⠛⠛⠋⠉
//⠀⠀⠀⠀⠀⠀⠀⠀⠀      
//                Made by an Angel.
// ⠀ ⠀⣀⣀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣀⢀⡀⠀
//  ⣴⠛⠉⠉⠱⢦⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⡴⠞⠉⠉⠙⣦
//  ⣧⠀⠀⠀⠀⠀⠙⢦⣄⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣠⡴⠋⠀⠀⠀⠀⠀⣼
//  ⠹⣄⠀⠀⠀⠀⠀⠀⠈⠙⠲⠦⣄⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣠⡴⠖⠋⠀⠀⠀⠀⠀⠀⠀⣠⠏
//  ⠀⠙⢶⣄⡀⠀⠀⠀⠀⠀⠀⠀⠈⠙⢦⡀⠀⠀⠀⠀⠀⢀⡴⠋⠁⠀⠀⠀⠀⠀⠀⠀⣀⣠⡾⠋⠀
// ⠀ ⠀⡼⠋⠉⠀⠀⠀⠀⠀⠀⠀⢀⡀⠀⢹⡄⠀⠀⠀⢠⡟⠀⢀⡀⠀⠀⠀⠀⠀⠀⠀⠉⠙⢧⠀⠀
// ⠀ ⠈⢧⡀⠀⠀⠀⠀⠀⢀⠀⣴⠋⡉⢳⡄⣷⠀⠀⠀⣾⢠⡞⠉⠙⣦⠀⠀⢀⠀⠀⠀⠀⢀⡼⠀⠀
//  ⠀⠀⠈⠙⠒⢲⡟⠀⠀⠀⠀⢻⣄⠙⠛⣱⠇⠀⠀⠀⠸⣎⠛⠋⣠⡟⠀⠀⠈⠀⢻⡗⠒⠋⠁⠀⠀
//⠀ ⠀⠀ ⠀⠀⠈⠷⣄⣀⣀⣀⣤⠟⠛⠛⠁⠀⠀⠀⠀⠀⠈⠛⠛⠻⣤⣀⣀⣀⣤⠾⠁⠀⠀⠀⠀⠀
//⠀⠀  ⠀⠀⠀⠀⠀⠈⠁⠉⠈⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠁⠉⠈⠀⠀⠀⠀⠀⠀⠀⠀
//
//         more of me: https://www.luka.moe
//