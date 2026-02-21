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
        private static bool has_indexed = false;
        private static string loaded_material = null;
        private static int loaded_material_id = -1;
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
        private static Footer footer = null;
        private static SearchBar search_bar = null;
        // additional ui integrations
        private static Tab license_tab = null;
        private static LicenseMenu license_menu = null;
        private static Cushion cushion = null;
        private static BeautyBlender beauty_blender = null;
        private static Bags bags = null;
        private static Tab presets_tab = null;
        private static PresetsMenu presets_menu = null;
        private static Tab premonition_tab = null;
        private static PremonitionMenu premonition_menu = null;
        private static Tab debug_tab = null;
        private static DevMenu debug_menu = null;
        private static NoticeBox compact_notice = null;
        private static VariantSwitcher variant_switcher = null;
        private static bool is_compact = false;
        
        #region Tabs
        // main
        private static Tab tab_main = null;
        private static Tab sub_tab_rendering = null;
        private static Tab sub_tab_main_textures = null;
        private static Tab sub_tab_stitching = null;
        private static Tab sub_tab_uv_manipulation = null;
        private static Tab sub_tab_uv_effects = null;
        private static Tab sub_tab_vertex_manipulation = null;
        private static Tab sub_tab_post_processing = null;
        private static Tab sub_tab_uv_sets = null;
        private static Tab sub_tab_legacy_mode = null;
        // lighting
        private static Tab tab_lighting = null;
        private static Tab sub_tab_lighting_model = null;
        private static Tab sub_tab_intensity = null;
        private static Tab sub_tab_emission = null;
        private static Tab sub_tab_attenuation = null;
        private static Tab sub_tab_light_limiting = null;
        // specular
        private static Tab tab_specular = null;
        // shading
        private static Tab tab_shading = null;
        // anime
        private static Tab tab_anime = null;
        private static Tab sub_tab_ambient_gradient = null;
        private static Tab sub_tab_sdf_shadow = null;
        private static Tab sub_tab_manual_normals = null;
        private static Tab sub_tab_stocking = null;
        private static Tab sub_tab_eye_parallax = null;
        private static Tab sub_tab_translucent_hair = null;
        private static Tab sub_tab_expression_map = null;
        private static Tab sub_tab_face_map = null;
        private static Tab sub_tab_gradient = null;
        private static Tab sub_tab_toon_highlights = null;
        private static Tab sub_tab_angel_rings = null;
        // stylise
        private static Tab tab_stylise = null;
        private static Tab sub_tab_rim_lighting = null;
        private static Tab sub_tab_clear_coat = null;
        private static Tab sub_tab_matcap = null;
        private static Tab sub_tab_cubemap = null;
        private static Tab sub_tab_parallax = null;
        private static Tab sub_tab_subsurface = null;
        private static Tab sub_tab_detail_map = null;
        private static Tab sub_tab_shadow_map = null;
        // stickers
        private static Tab tab_stickers = null;
        private static Tab sub_tab_decal1_settings = null;
        private static Tab sub_tab_decal1_effects = null;
        private static Tab sub_tab_decal2_settings = null;
        private static Tab sub_tab_decal2_effects = null;
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
        private static Tab sub_tab_liquid_layer = null;
        // world
        private static Tab tab_world = null;
        private static Tab sub_tab_stochastic = null;
        private static Tab sub_tab_splatter = null;
        private static Tab sub_tab_bombing = null;
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
        // main maps and alpha
        private MaterialProperty prop_MainTex = null;
        private MaterialProperty prop_Color = null;
        private MaterialProperty prop_Cutoff = null;
        private MaterialProperty prop_UseBump = null;
        private MaterialProperty prop_BumpMap = null;
        private MaterialProperty prop_BumpScale = null;
        private MaterialProperty prop_BumpFromAlbedo = null;
        private MaterialProperty prop_BumpFromAlbedoOffset = null;
        private MaterialProperty prop_Alpha = null;
        // texture stitching
        private MaterialProperty prop_UseTextureStitching = null;
        private MaterialProperty prop_StitchTex = null;
        private MaterialProperty prop_StitchAxis = null;
        private MaterialProperty prop_StitchOffset = null;
        // uv manipulation
        private MaterialProperty prop_UVOffsetX = null;
        private MaterialProperty prop_UVOffsetY = null;
        private MaterialProperty prop_UVScaleX = null;
        private MaterialProperty prop_UVScaleY = null;
        private MaterialProperty prop_UVRotation = null;
        private MaterialProperty prop_UVScrollXSpeed = null;
        private MaterialProperty prop_UVScrollYSpeed = null;
        // uv effects
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
        // vertex manipulation
        private MaterialProperty prop_VertexManipulationPosition = null;
        private MaterialProperty prop_VertexManipulationScale = null;
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
        private MaterialProperty prop_ColorGradingMode = null;
        private MaterialProperty prop_ColorGradingLUT = null;
        private MaterialProperty prop_ColorGradingIntensity = null;
        private MaterialProperty prop_GTShadows = null;
        private MaterialProperty prop_GTHighlights = null;
        private MaterialProperty prop_LCWLift = null;
        private MaterialProperty prop_LCWGamma = null;
        private MaterialProperty prop_LCWGain = null;
        private MaterialProperty prop_BlackAndWhite = null;
        private MaterialProperty prop_Brightness = null;
        // uv sets
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
        private MaterialProperty prop_StitchTex_UV = null;
        private MaterialProperty prop_SDFShadowTexture_UV = null;
        private MaterialProperty prop_StockingsMap_UV = null;
        private MaterialProperty prop_EyeParallaxIrisTex_UV = null;
        private MaterialProperty prop_EyeParallaxEyeMaskTex_UV = null;
        private MaterialProperty prop_HairMaskTex_UV = null;
        private MaterialProperty prop_ExpressionMap_UV = null;
        private MaterialProperty prop_FaceMap_UV = null;
        private MaterialProperty prop_NPRSpecularMask_UV = null;
        private MaterialProperty prop_PackedMapOne_UV = null;
        private MaterialProperty prop_PackedMapTwo_UV = null;
        private MaterialProperty prop_PackedMapThree_UV = null;
        private MaterialProperty prop_SkinLUT_UV = null;
        // lighting models
        private MaterialProperty prop_LightingColorMode = null;
        private MaterialProperty prop_LightingDirectionMode = null;
        private MaterialProperty prop_LightingSource = null;
        private MaterialProperty prop_IndirectAlbedo = null;
        private MaterialProperty prop_DirectDiffuse = null;
        private MaterialProperty prop_IndirectDiffuse = null;
        private MaterialProperty prop_DirectionalAmbience = null;
        private MaterialProperty prop_IndirectAdditive = null;
        private MaterialProperty prop_ForcedLightDirection = null;
        private MaterialProperty prop_ViewDirectionOffsetX = null;
        private MaterialProperty prop_ViewDirectionOffsetY = null;
        private MaterialProperty prop_DirectIntensity = null;
        private MaterialProperty prop_IndirectIntensity = null;
        private MaterialProperty prop_VertexIntensity = null;
        private MaterialProperty prop_AdditiveIntensity = null;
        private MaterialProperty prop_BakedDirectIntensity = null;
        private MaterialProperty prop_BakedIndirectIntensity = null;
        private MaterialProperty prop_IndirectOverride = null;
        private MaterialProperty prop_IndirectFallbackMode = null;
        private MaterialProperty prop_FallbackCubemap = null;
        // emission
        private MaterialProperty prop_ToggleEmission = null;
        private MaterialProperty prop_EmissionColor = null;
        private MaterialProperty prop_EmissionMap = null;
        private MaterialProperty prop_UseAlbedoAsEmission = null;
        private MaterialProperty prop_EmissionStrength = null;
        // attenuation
        private MaterialProperty prop_AttenuationOverride = null;
        private MaterialProperty prop_AttenuationShaded = null;
        private MaterialProperty prop_AttenuationManual = null;
        private MaterialProperty prop_AttenuationMin = null;
        private MaterialProperty prop_AttenuationMax = null;
        private MaterialProperty prop_AttenuationMultiplier = null;
        private MaterialProperty prop_AttenuationBoost = null;
        // light limiting
        private MaterialProperty prop_EnableBaseLightLimit = null;
        private MaterialProperty prop_BaseLightMin = null;
        private MaterialProperty prop_BaseLightMax = null;
        private MaterialProperty prop_EnableAddLightLimit = null;
        private MaterialProperty prop_AddLightMin = null;
        private MaterialProperty prop_AddLightMax = null;
        private MaterialProperty prop_GreyscaleLighting = null;
        private MaterialProperty prop_ForceLightColor = null;
        private MaterialProperty prop_ForcedLightColor = null;
        // shading properties
        private MaterialProperty prop_AnimeMode = null;
        private MaterialProperty prop_RampMode = null;
        private MaterialProperty prop_Ramp = null;
        private MaterialProperty prop_RampColor = null;
        private MaterialProperty prop_RampOffset = null;
        private MaterialProperty prop_RampShadows = null;
        private MaterialProperty prop_RampOcclusionOffset = null;
        private MaterialProperty prop_RampMin = null;
        private MaterialProperty prop_RampProceduralShift = null;
        private MaterialProperty prop_RampProceduralToony = null;
        private MaterialProperty prop_RampNormalIntensity = null;
        private MaterialProperty prop_RampIndex = null;
        private MaterialProperty prop_RampTotal = null;
        private MaterialProperty prop_CelMode = null;
        private MaterialProperty prop_CelThreshold = null;
        private MaterialProperty prop_CelFeather = null;
        private MaterialProperty prop_CelCastShadowFeather = null;
        private MaterialProperty prop_CelCastShadowPower = null;
        private MaterialProperty prop_CelShadowTint = null;
        private MaterialProperty prop_CelLitTint = null;
        private MaterialProperty prop_CelSmoothGradientPower = null;
        private MaterialProperty prop_CelSmoothOcclusionStrength = null;
        private MaterialProperty prop_NPRDiffMin = null;
        private MaterialProperty prop_NPRDiffMax = null;
        private MaterialProperty prop_NPRLitColor = null;
        private MaterialProperty prop_NPRShadowColor = null;
        private MaterialProperty prop_NPRSpecularMask = null;
        private MaterialProperty prop_NPRForwardSpecular = null;
        private MaterialProperty prop_NPRForwardSpecularRange = null;
        private MaterialProperty prop_NPRForwardSpecularMultiplier = null;
        private MaterialProperty prop_NPRForwardSpecularColor = null;
        private MaterialProperty prop_NPRBlinn = null;
        private MaterialProperty prop_NPRBlinnPower = null;
        private MaterialProperty prop_NPRBlinnMin = null;
        private MaterialProperty prop_NPRBlinnMax = null;
        private MaterialProperty prop_NPRBlinnColor = null;
        private MaterialProperty prop_NPRBlinnMultiplier = null;
        private MaterialProperty prop_NPRSSS = null;
        private MaterialProperty prop_NPRSSSExp = null;
        private MaterialProperty prop_NPRSSSRef = null;
        private MaterialProperty prop_NPRSSSMin = null;
        private MaterialProperty prop_NPRSSSMax = null;
        private MaterialProperty prop_NPRSSSShadows = null;
        private MaterialProperty prop_NPRSSSColor = null;
        private MaterialProperty prop_NPRRim = null;
        private MaterialProperty prop_NPRRimExp = null;
        private MaterialProperty prop_NPRRimMin = null;
        private MaterialProperty prop_NPRRimMax = null;
        private MaterialProperty prop_NPRRimColor = null;
        private MaterialProperty prop_PackedMapStyle = null;
        private MaterialProperty prop_PackedMapOne = null;
        private MaterialProperty prop_PackedMapTwo = null;
        private MaterialProperty prop_PackedMapThree = null;
        private MaterialProperty prop_PackedLitColor = null;
        private MaterialProperty prop_PackedShadowColor = null;
        private MaterialProperty prop_PackedShadowSmoothness = null;
        private MaterialProperty prop_PackedRimLight = null;
        private MaterialProperty prop_PackedRimColor = null;
        private MaterialProperty prop_PackedRimThreshold = null;
        private MaterialProperty prop_PackedRimPower = null;
        private MaterialProperty prop_PackedMapMetals = null;
        private MaterialProperty prop_PackedAmbient = null;
        private MaterialProperty prop_PackedUmaSpecularBoost = null;
        private MaterialProperty prop_PackedUmaMetalDark = null;
        private MaterialProperty prop_PackedUmaMetalLight = null;
        private MaterialProperty prop_PackedGGSpecularSize = null;
        private MaterialProperty prop_PackedGGSpecularIntensity = null;
        private MaterialProperty prop_PackedGGSpecularTint = null;
        private MaterialProperty prop_PackedGGShadow1Push = null;
        private MaterialProperty prop_PackedGGShadow1Smoothness = null;
        private MaterialProperty prop_PackedGGShadow2Push = null;
        private MaterialProperty prop_PackedGGShadow2Smoothness = null;
        private MaterialProperty prop_PackedGGShadow1Tint = null;
        private MaterialProperty prop_PackedGGShadow2Tint = null;
        private MaterialProperty prop_TriBandSmoothness = null;
        private MaterialProperty prop_TriBandThreshold = null;
        private MaterialProperty prop_TriBandShallowWidth = null;
        private MaterialProperty prop_TriBandShadowColor = null;
        private MaterialProperty prop_TriBandShallowColor = null;
        private MaterialProperty prop_TriBandLitColor = null;
        private MaterialProperty prop_TriBandPostShadowTint = null;
        private MaterialProperty prop_TriBandPostShallowTint = null;
        private MaterialProperty prop_TriBandPostLitTint = null;
        private MaterialProperty prop_TriBandAttenuatedShadows = null;
        private MaterialProperty prop_TriBandIndirectShallow = null;
        private MaterialProperty prop_SkinLUT = null;
        private MaterialProperty prop_SkinShadowColor = null;
        private MaterialProperty prop_SkinScattering = null;
        private MaterialProperty prop_WrapFactor = null;
        private MaterialProperty prop_WrapNormalization = null;
        private MaterialProperty prop_WrapColorHigh = null;
        private MaterialProperty prop_WrapColorLow = null;
        // anime extras
        private MaterialProperty prop_ToggleAnimeExtras = null;
        // ambient gradient
        private MaterialProperty prop_ToggleAmbientGradient = null;
        private MaterialProperty prop_AnimeOcclusionToShadow = null;
        private MaterialProperty prop_AmbientUp = null;
        private MaterialProperty prop_AmbientSkyThreshold = null;
        private MaterialProperty prop_AmbientDown = null;
        private MaterialProperty prop_AmbientGroundThreshold = null;
        private MaterialProperty prop_AmbientIntensity = null;
        // manual normals
        private MaterialProperty prop_ToggleManualNormals = null;
        private MaterialProperty prop_ManualNormalPreview = null;
        private MaterialProperty prop_ManualNormalOffset = null;
        private MaterialProperty prop_ManualNormalScale = null;
        private MaterialProperty prop_ManualApplication = null;
        private MaterialProperty prop_ManualNormalSharpness = null;
        // sdf shadow
        private MaterialProperty prop_ToggleSDFShadow = null;
        private MaterialProperty prop_SDFMode = null;
        private MaterialProperty prop_SDFLocalForward = null;
        private MaterialProperty prop_SDFLocalRight = null;
        private MaterialProperty prop_SDFShadowTexture = null;
        private MaterialProperty prop_SDFShadowThreshold = null;
        private MaterialProperty prop_SDFShadowSoftness = null;
        private MaterialProperty prop_SDFShadowSoftnessLow = null;
        // stocking feature
        private MaterialProperty prop_ToggleStockings = null;
        private MaterialProperty prop_StockingsMap = null;
        private MaterialProperty prop_StockingsPower = null;
        private MaterialProperty prop_StockingsDarkWidth = null;
        private MaterialProperty prop_StockingsLightedWidth = null;
        private MaterialProperty prop_StockingsLightedIntensity = null;
        private MaterialProperty prop_StockingsRoughness = null;
        private MaterialProperty prop_StockingsColor = null;
        private MaterialProperty prop_StockingsColorDark = null;
        // parallax eye
        private MaterialProperty prop_ToggleEyeParallax = null;
        private MaterialProperty prop_EyeParallaxIrisTex = null;
        private MaterialProperty prop_EyeParallaxEyeMaskTex = null;
        private MaterialProperty prop_EyeParallaxStrength = null;
        private MaterialProperty prop_EyeParallaxClamp = null;
        private MaterialProperty prop_ToggleEyeParallaxBreathing = null;
        private MaterialProperty prop_EyeParallaxBreathStrength = null;
        private MaterialProperty prop_EyeParallaxBreathSpeed = null;
        // translucent hair
        private MaterialProperty prop_ToggleHairTransparency = null;
        private MaterialProperty prop_HairHeadForward = null;
        private MaterialProperty prop_HairHeadUp = null;
        private MaterialProperty prop_HairHeadRight = null;
        private MaterialProperty prop_HairBlendAlpha = null;
        private MaterialProperty prop_HairTransparencyStrength = null;
        private MaterialProperty prop_HairHeadMaskMode = null;
        private MaterialProperty prop_HairSDFPreview = null;
        private MaterialProperty prop_HairHeadCenter = null;
        private MaterialProperty prop_HairSDFScale = null;
        private MaterialProperty prop_HairSDFSoftness = null;
        private MaterialProperty prop_HairSDFBlend = null;
        private MaterialProperty prop_HairDistanceFalloffStart = null;
        private MaterialProperty prop_HairDistanceFalloffEnd = null;
        private MaterialProperty prop_HairDistanceFalloffStrength = null;
        private MaterialProperty prop_HairMaskTex = null;
        private MaterialProperty prop_HairMaskStrength = null;
        private MaterialProperty prop_HairExtremeAngleGuard = null;
        private MaterialProperty prop_HairAngleFadeStart = null;
        private MaterialProperty prop_HairAngleFadeEnd = null;
        private MaterialProperty prop_HairAngleGuardStrength = null;
        // expression map
        private MaterialProperty prop_ToggleExpressionMap = null;
        private MaterialProperty prop_ExpressionMap = null;
        private MaterialProperty prop_ExCheekColor = null;
        private MaterialProperty prop_ExCheekIntensity = null;
        private MaterialProperty prop_ExShyColor = null;
        private MaterialProperty prop_ExShyIntensity = null;
        private MaterialProperty prop_ExShadowColor = null;
        private MaterialProperty prop_ExShadowIntensity = null;
        // face map
        private MaterialProperty prop_ToggleFaceMap = null;
        private MaterialProperty prop_FaceHeadForward = null;
        private MaterialProperty prop_FaceMap = null;
        private MaterialProperty prop_ToggleNoseLine = null;
        private MaterialProperty prop_NoseLinePower = null;
        private MaterialProperty prop_NoseLineColor = null;
        private MaterialProperty prop_ToggleEyeShadow = null;
        private MaterialProperty prop_ExEyeColor = null;
        private MaterialProperty prop_EyeShadowIntensity = null;
        private MaterialProperty prop_ToggleLipOutline = null;
        private MaterialProperty prop_LipOutlineColor = null;
        private MaterialProperty prop_LipOutlineIntensity = null;
        // anime gradient
        private MaterialProperty prop_ToggleAnimeGradient = null;
        private MaterialProperty prop_AnimeGradientMode = null;
        private MaterialProperty prop_AnimeGradientDirection = null;
        private MaterialProperty prop_AnimeGradientColourA = null;
        private MaterialProperty prop_AnimeGradientColourB = null;
        private MaterialProperty prop_AnimeGradientOffset = null;
        private MaterialProperty prop_AnimeGradientMultiplier = null;
        // toon highlights
        private MaterialProperty prop_ToggleSpecularToon = null;
        private MaterialProperty prop_SpecularToonShininess = null;
        private MaterialProperty prop_SpecularToonRoughness = null;
        private MaterialProperty prop_SpecularToonSharpness = null;
        private MaterialProperty prop_SpecularToonIntensity = null;
        private MaterialProperty prop_SpecularToonThreshold = null;
        private MaterialProperty prop_SpecularToonColor = null;
        private MaterialProperty prop_SpecularToonUseLighting = null;
        // angel rings
        private MaterialProperty prop_AngelRingMode = null;
        private MaterialProperty prop_AngelRingSharpness = null;
        private MaterialProperty prop_AngelRingThreshold = null;
        private MaterialProperty prop_AngelRingSoftness = null;
        private MaterialProperty prop_AngelRing1Position = null;
        private MaterialProperty prop_AngelRing1Width = null;
        private MaterialProperty prop_AngelRing1Color = null;
        private MaterialProperty prop_UseSecondaryRing = null;
        private MaterialProperty prop_AngelRing2Position = null;
        private MaterialProperty prop_AngelRing2Width = null;
        private MaterialProperty prop_AngelRing2Color = null;
        private MaterialProperty prop_UseTertiaryRing = null;
        private MaterialProperty prop_AngelRing3Position = null;
        private MaterialProperty prop_AngelRing3Width = null;
        private MaterialProperty prop_AngelRing3Color = null;
        private MaterialProperty prop_AngelRingHeightDirection = null;
        private MaterialProperty prop_AngelRingHeightScale = null;
        private MaterialProperty prop_AngelRingHeightOffset = null;
        private MaterialProperty prop_AngelRingBlendMode = null;
        private MaterialProperty prop_AngelRingManualOffset = null;
        private MaterialProperty prop_AngelRingManualScale = null;
        private MaterialProperty prop_AngelRingBreakup = null;
        private MaterialProperty prop_AngelRingBreakupDensity = null;
        private MaterialProperty prop_AngelRingBreakupWidthMin = null;
        private MaterialProperty prop_AngelRingBreakupWidthMax = null;
        private MaterialProperty prop_AngelRingBreakupSoftness = null;
        private MaterialProperty prop_AngelRingBreakupHeight = null;
        private MaterialProperty prop_AngelRingUseLighting = null;
        // specular
        private MaterialProperty prop_ToggleSpecular = null;
        private MaterialProperty prop_ToggleVertexSpecular = null;
        private MaterialProperty prop_SpecularMode = null;
        private MaterialProperty prop_SpecularEnergyMode = null;
        private MaterialProperty prop_SpecularEnergyMin = null;
        private MaterialProperty prop_SpecularEnergyMax = null;
        private MaterialProperty prop_SpecularEnergy = null;
        private MaterialProperty prop_MSSO = null;
        private MaterialProperty prop_Metallic = null;
        private MaterialProperty prop_Glossiness = null;
        private MaterialProperty prop_Occlusion = null;
        private MaterialProperty prop_SpecularIntensity = null;
        private MaterialProperty prop_Specular = null;
        private MaterialProperty prop_SpecularTintTexture = null;
        private MaterialProperty prop_SpecularTint = null;
        private MaterialProperty prop_TangentMap = null;
        private MaterialProperty prop_Anisotropy = null;
        private MaterialProperty prop_ReplaceSpecular = null;
        private MaterialProperty prop_PreserveShadows = null;
        // rim lighting
        private MaterialProperty prop_RimMode = null;
        private MaterialProperty prop_RimColor = null;
        private MaterialProperty prop_RimWidth = null;
        private MaterialProperty prop_RimIntensity = null;
        private MaterialProperty prop_RimLightBased = null;
        private MaterialProperty prop_DepthRimColor = null;
        private MaterialProperty prop_DepthRimWidth = null;
        private MaterialProperty prop_DepthRimThreshold = null;
        private MaterialProperty prop_DepthRimSharpness = null;
        private MaterialProperty prop_DepthRimBlendMode = null;
        private MaterialProperty prop_OffsetRimColor = null;
        private MaterialProperty prop_OffsetRimWidth = null;
        private MaterialProperty prop_OffsetRimHardness = null;
        private MaterialProperty prop_OffsetRimLightBased = null;
        private MaterialProperty prop_OffsetRimBlendMode = null;
        // clear coat
        private MaterialProperty prop_ToggleClearcoat = null;
        private MaterialProperty prop_ClearcoatStrength = null;
        private MaterialProperty prop_ClearcoatReflectionStrength = null;
        private MaterialProperty prop_ClearcoatMap = null;
        private MaterialProperty prop_ClearcoatRoughness = null;
        private MaterialProperty prop_ClearcoatColor = null;
        // matcap
        private MaterialProperty prop_ToggleMatcap = null;
        private MaterialProperty prop_MatcapTex = null;
        private MaterialProperty prop_MatcapTint = null;
        private MaterialProperty prop_MatcapIntensity = null;
        private MaterialProperty prop_MatcapBlendMode = null;
        private MaterialProperty prop_MatcapMask = null;
        private MaterialProperty prop_MatcapSmoothnessEnabled = null;
        private MaterialProperty prop_MatcapSmoothness = null;
        // cubemap
        private MaterialProperty prop_ToggleCubemap = null;
        private MaterialProperty prop_CubemapTex = null;
        private MaterialProperty prop_CubemapTint = null;
        private MaterialProperty prop_CubemapIntensity = null;
        private MaterialProperty prop_CubemapBlendMode = null;
        // parallax mapping
        private MaterialProperty prop_ToggleParallax = null;
        private MaterialProperty prop_ParallaxMode = null;
        private MaterialProperty prop_ParallaxMap = null;
        private MaterialProperty prop_ParallaxStrength = null;
        private MaterialProperty prop_ParallaxSteps = null;
        private MaterialProperty prop_ParallaxBlend = null;
        private MaterialProperty prop_InteriorCubemap = null;
        private MaterialProperty prop_InteriorColor = null;
        private MaterialProperty prop_InteriorTiling = null;
        private MaterialProperty prop_ParallaxLayer1 = null;
        private MaterialProperty prop_ParallaxLayer2 = null;
        private MaterialProperty prop_ParallaxLayer3 = null;
        private MaterialProperty prop_ParallaxLayerDepth1 = null;
        private MaterialProperty prop_ParallaxLayerDepth2 = null;
        private MaterialProperty prop_ParallaxLayerDepth3 = null;
        private MaterialProperty prop_ParallaxStack = null;
        private MaterialProperty prop_ParallaxBlendWeight = null;
        private MaterialProperty prop_ParallaxTile = null;
        // subsurface scattering
        private MaterialProperty prop_ToggleSSS = null;
        private MaterialProperty prop_SSSColor = null;
        private MaterialProperty prop_SSSStrength = null;
        private MaterialProperty prop_SSSPower = null;
        private MaterialProperty prop_SSSDistortion = null;
        private MaterialProperty prop_SSSThicknessMap = null;
        private MaterialProperty prop_SSSThickness = null;
        // detail mapping
        private MaterialProperty prop_ToggleDetail = null;
        private MaterialProperty prop_DetailAlbedoMap = null;
        private MaterialProperty prop_DetailNormalMap = null;
        private MaterialProperty prop_DetailTiling = null;
        private MaterialProperty prop_DetailNormalStrength = null;
        // shadow map
        private MaterialProperty prop_ToggleShadowMap = null;
        private MaterialProperty prop_ShadowMap = null;
        private MaterialProperty prop_ShadowMapIntensity = null;
        // decals
        private MaterialProperty prop_ToggleDecals = null;
        private MaterialProperty prop_DecalStage = null;
        // decal 1
        private MaterialProperty prop_Decal1Enable = null;
        private MaterialProperty prop_Decal1Tex = null;
        private MaterialProperty prop_Decal1Tint = null;
        private MaterialProperty prop_Decal1BlendMode = null;
        private MaterialProperty prop_Decal1Space = null;
        private MaterialProperty prop_Decal1Behavior = null;
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
        private MaterialProperty prop_Decal1Spritesheet = null;
        private MaterialProperty prop_Decal1SheetCols = null;
        private MaterialProperty prop_Decal1SheetRows = null;
        private MaterialProperty prop_Decal1SheetFPS = null;
        private MaterialProperty prop_Decal1SheetSlider = null;
        private MaterialProperty prop_Decal1SpecialEffect = null;
        private MaterialProperty prop_Decal1DistortionControls = null;
        private MaterialProperty prop_Decal1DistortionSpeed = null;
        private MaterialProperty prop_Decal1GlitchControls = null;
        // decal 2
        private MaterialProperty prop_Decal2Enable = null;
        private MaterialProperty prop_Decal2Tex = null;
        private MaterialProperty prop_Decal2Tint = null;
        private MaterialProperty prop_Decal2BlendMode = null;
        private MaterialProperty prop_Decal2Space = null;
        private MaterialProperty prop_Decal2Behavior = null;
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
        private MaterialProperty prop_Decal2Spritesheet = null;
        private MaterialProperty prop_Decal2SheetCols = null;
        private MaterialProperty prop_Decal2SheetRows = null;
        private MaterialProperty prop_Decal2SheetFPS = null;
        private MaterialProperty prop_Decal2SheetSlider = null;
        private MaterialProperty prop_Decal2SpecialEffect = null;
        private MaterialProperty prop_Decal2DistortionControls = null;
        private MaterialProperty prop_Decal2DistortionSpeed = null;
        private MaterialProperty prop_Decal2GlitchControls = null;
        // effect toggles
        private MaterialProperty prop_ToggleDissolve = null;
        private MaterialProperty prop_TogglePathing = null;
        private MaterialProperty prop_ToggleGlitter = null;
        private MaterialProperty prop_ToggleDistanceFade = null;
        private MaterialProperty prop_ToggleIridescence = null;
        private MaterialProperty prop_ToggleShadowTexture = null;
        private MaterialProperty prop_ToggleFlatModel = null;
        private MaterialProperty prop_ToggleWorldEffect = null;
        private MaterialProperty prop_ToggleMirrorDetection = null;
        private MaterialProperty prop_ToggleTouchReactive = null;
        private MaterialProperty prop_ToggleDither = null;
        private MaterialProperty prop_TogglePS1 = null;
        private MaterialProperty prop_ToggleVertexDistortion = null;
        private MaterialProperty prop_ToggleRefraction = null;
        private MaterialProperty prop_ToggleSSR = null;
        private MaterialProperty prop_LiquidToggleLiquid = null;
        // dissolve
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
        // pathing
        private MaterialProperty prop_PathingMappingMode = null;
        private MaterialProperty prop_PathingMap = null;
        private MaterialProperty prop_PathingScale = null;
        private MaterialProperty prop_PathingBlendMode = null;
        private MaterialProperty prop_PathingColorMode = null;
        private MaterialProperty prop_PathingTexture = null;
        private MaterialProperty prop_PathingColor = null;
        private MaterialProperty prop_PathingColor2 = null;
        private MaterialProperty prop_PathingEmission = null;
        private MaterialProperty prop_PathingType = null;
        private MaterialProperty prop_PathingSpeed = null;
        private MaterialProperty prop_PathingWidth = null;
        private MaterialProperty prop_PathingSoftness = null;
        private MaterialProperty prop_PathingOffset = null;
        private MaterialProperty prop_PathingStart = null;
        private MaterialProperty prop_PathingEnd = null;
        // glitter
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
        // distance fading
        private MaterialProperty prop_DistanceFadeReference = null;
        private MaterialProperty prop_ToggleNearFade = null;
        private MaterialProperty prop_NearFadeMode = null;
        private MaterialProperty prop_NearFadeDitherScale = null;
        private MaterialProperty prop_NearFadeStart = null;
        private MaterialProperty prop_NearFadeEnd = null;
        private MaterialProperty prop_ToggleFarFade = null;
        private MaterialProperty prop_FarFadeStart = null;
        private MaterialProperty prop_FarFadeEnd = null;
        // iridescence
        private MaterialProperty prop_IridescenceMode = null;
        private MaterialProperty prop_IridescenceMask = null;
        private MaterialProperty prop_IridescenceTint = null;
        private MaterialProperty prop_IridescenceIntensity = null;
        private MaterialProperty prop_IridescenceBlendMode = null;
        private MaterialProperty prop_IridescenceParallax = null;
        private MaterialProperty prop_IridescenceRamp = null;
        private MaterialProperty prop_IridescencePower = null;
        private MaterialProperty prop_IridescenceFrequency = null;
        // shadow texture
        private MaterialProperty prop_ShadowTextureMappingMode = null;
        private MaterialProperty prop_ShadowTextureBlendMode = null;
        private MaterialProperty prop_ShadowTextureIntensity = null;
        private MaterialProperty prop_ShadowTex = null;
        private MaterialProperty prop_ShadowPatternColor = null;
        private MaterialProperty prop_ShadowPatternScale = null;
        private MaterialProperty prop_ShadowPatternTriplanarSharpness = null;
        private MaterialProperty prop_ShadowPatternTransparency = null;
        private MaterialProperty prop_ShadowPatternLightBased = null;
        private MaterialProperty prop_ShadowPatternLit = null;
        // flat model
        private MaterialProperty prop_FlatModeAutoflip = null;
        private MaterialProperty prop_FlatModel = null;
        private MaterialProperty prop_FlatModelDepthCorrection = null;
        private MaterialProperty prop_FlatModelFacing = null;
        private MaterialProperty prop_FlatModelLockAxis = null;
        // world aligned
        private MaterialProperty prop_WorldEffectBlendMode = null;
        private MaterialProperty prop_WorldEffectTex = null;
        private MaterialProperty prop_WorldEffectMask = null;
        private MaterialProperty prop_WorldEffectColor = null;
        private MaterialProperty prop_WorldEffectDirection = null;
        private MaterialProperty prop_WorldEffectScale = null;
        private MaterialProperty prop_WorldEffectBlendSharpness = null;
        private MaterialProperty prop_WorldEffectIntensity = null;
        private MaterialProperty prop_WorldEffectPosition = null;
        private MaterialProperty prop_WorldEffectRotation = null;
        // vrchat mirror detection
        private MaterialProperty prop_MirrorDetectionMode = null;
        private MaterialProperty prop_MirrorDetectionTexture = null;
        // touch reactive
        private MaterialProperty prop_TouchColor = null;
        private MaterialProperty prop_TouchRadius = null;
        private MaterialProperty prop_TouchHardness = null;
        private MaterialProperty prop_TouchMode = null;
        private MaterialProperty prop_TouchRainbowSpeed = null;
        private MaterialProperty prop_TouchRainbowSpread = null;
        // dither
        private MaterialProperty prop_DitherSpace = null;
        private MaterialProperty prop_DitherAmount = null;
        private MaterialProperty prop_DitherScale = null;
        // low precision (ps1)
        private MaterialProperty prop_PS1Rounding = null;
        private MaterialProperty prop_PS1RoundingPrecision = null;
        private MaterialProperty prop_PS1Compression = null;
        private MaterialProperty prop_PS1CompressionPrecision = null;
        // vertex distortion
        private MaterialProperty prop_VertexEffectType = null;
        private MaterialProperty prop_VertexDistortionMode = null;
        private MaterialProperty prop_VertexGlitchMode = null;
        private MaterialProperty prop_VertexDistortionColorMask = null;
        private MaterialProperty prop_VertexDistortionStrength = null;
        private MaterialProperty prop_VertexDistortionSpeed = null;
        private MaterialProperty prop_VertexDistortionFrequency = null;
        private MaterialProperty prop_WindStrength = null;
        private MaterialProperty prop_WindSpeed = null;
        private MaterialProperty prop_WindScale = null;
        private MaterialProperty prop_WindDirection = null;
        private MaterialProperty prop_WindNoiseTex = null;
        private MaterialProperty prop_BreathingStrength = null;
        private MaterialProperty prop_BreathingSpeed = null;
        private MaterialProperty prop_GlitchFrequency = null;
        // refraction
        private MaterialProperty prop_RefractionSourceMode = null;
        private MaterialProperty prop_RefractionTexture = null;
        private MaterialProperty prop_RefractionMask = null;
        private MaterialProperty prop_RefractionTint = null;
        private MaterialProperty prop_RefractionIOR = null;
        private MaterialProperty prop_RefractionFresnel = null;
        private MaterialProperty prop_RefractionOpacity = null;
        private MaterialProperty prop_RefractionSeeThrough = null;
        private MaterialProperty prop_RefractionMode = null;
        private MaterialProperty prop_RefractionMixStrength = null;
        private MaterialProperty prop_RefractionBlendMode = null;
        private MaterialProperty prop_RefractionGrabpassTint = null;
        private MaterialProperty prop_RefractionZoomToggle = null;
        private MaterialProperty prop_RefractionZoom = null;
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
        // screen space reflections
        private MaterialProperty prop_SSRSourceMode = null;
        private MaterialProperty prop_SSRTexture = null;
        private MaterialProperty prop_SSRMode = null;
        private MaterialProperty prop_SSRMask = null;
        private MaterialProperty prop_SSRTint = null;
        private MaterialProperty prop_SSRIntensity = null;
        private MaterialProperty prop_SSRBlendMode = null;
        private MaterialProperty prop_SSRFresnelPower = null;
        private MaterialProperty prop_SSRFresnelScale = null;
        private MaterialProperty prop_SSRFresnelBias = null;
        private MaterialProperty prop_SSRCoverage = null;
        private MaterialProperty prop_SSRParallax = null;
        private MaterialProperty prop_SSRDistortionMap = null;
        private MaterialProperty prop_SSRDistortionStrength = null;
        private MaterialProperty prop_SSRWorldDistortion = null;
        private MaterialProperty prop_SSRBlur = null;
        private MaterialProperty prop_SSRMaxSteps = null;
        private MaterialProperty prop_SSRStepSize = null;
        private MaterialProperty prop_SSREdgeFade = null;
        private MaterialProperty prop_SSRCamFade = null;
        private MaterialProperty prop_SSRCamFadeStart = null;
        private MaterialProperty prop_SSRCamFadeEnd = null;
        private MaterialProperty prop_SSRFlipUV = null;
        private MaterialProperty prop_SSRAdaptiveStep = null;
        private MaterialProperty prop_SSRThickness = null;
        private MaterialProperty prop_SSROutOfViewMode = null;
        // liquid layer
        private MaterialProperty prop_LiquidEnabled = null;
        private MaterialProperty prop_LiquidFeel = null;
        private MaterialProperty prop_LiquidLookWatery = null;
        private MaterialProperty prop_LiquidLookViscous = null;
        private MaterialProperty prop_LiquidSpace = null;
        private MaterialProperty prop_LiquidMapScale = null;
        private MaterialProperty prop_LiquidTriplanarSharpness = null;
        private MaterialProperty prop_LiquidMaskMap = null;
        private MaterialProperty prop_LiquidUseForceMap = null;
        private MaterialProperty prop_LiquidForceMap = null;
        private MaterialProperty prop_LiquidSpecularLit = null;
        private MaterialProperty prop_LiquidGloss = null;
        private MaterialProperty prop_LiquidShine = null;
        private MaterialProperty prop_LiquidShineTightness = null;
        private MaterialProperty prop_LiquidShadow = null;
        private MaterialProperty prop_LiquidRim = null;
        private MaterialProperty prop_LiquidDepth = null;
        private MaterialProperty prop_LiquidNormalStrength = null;
        private MaterialProperty prop_LiquidOpacity = null;
        private MaterialProperty prop_LiquidDarken = null;
        private MaterialProperty prop_LiquidManualDirection = null;
        private MaterialProperty prop_LiquidDirectionOne = null;
        private MaterialProperty prop_LiquidDirectionTwo = null;
        private MaterialProperty prop_LiquidLayerOneScale = null;
        private MaterialProperty prop_LiquidLayerOneDensity = null;
        private MaterialProperty prop_LiquidLayerOneStretch = null;
        private MaterialProperty prop_LiquidLayerOneSpeed = null;
        private MaterialProperty prop_LiquidLayerOneRandomness = null;
        private MaterialProperty prop_LiquidLayerOneSeed = null;
        private MaterialProperty prop_LiquidLayerOneMod = null;
        private MaterialProperty prop_LiquidUseLayerTwo = null;
        private MaterialProperty prop_LiquidLayerTwoScale = null;
        private MaterialProperty prop_LiquidLayerTwoDensity = null;
        private MaterialProperty prop_LiquidLayerTwoStretch = null;
        private MaterialProperty prop_LiquidLayerTwoSpeed = null;
        private MaterialProperty prop_LiquidLayerTwoRandomness = null;
        private MaterialProperty prop_LiquidLayerTwoSeed = null;
        private MaterialProperty prop_LiquidLayerTwoAmount = null;
        private MaterialProperty prop_LiquidLayerTwoMod = null;
        private MaterialProperty prop_LiquidUseCluster = null;
        private MaterialProperty prop_LiquidClusterScale = null;
        private MaterialProperty prop_LiquidClusterSeed = null;
        private MaterialProperty prop_LiquidThreshold = null;
        private MaterialProperty prop_LiquidSoftness = null;
        private MaterialProperty prop_LiquidWateryCoverage = null;
        private MaterialProperty prop_LiquidViscousSmooth = null;
        private MaterialProperty prop_LiquidViscousThinning = null;
        private MaterialProperty prop_LiquidViscousThinSeed = null;
        private MaterialProperty prop_LiquidViscousThinScale = null;
        private MaterialProperty prop_LiquidSweatUseTint = null;
        private MaterialProperty prop_LiquidSweatTintColor = null;
        private MaterialProperty prop_LiquidBloodColorFresh = null;
        private MaterialProperty prop_LiquidBloodColorDark = null;
        private MaterialProperty prop_LiquidBloodPooling = null;
        private MaterialProperty prop_LiquidBloodDryingRate = null;
        private MaterialProperty prop_LiquidBloodDryGloss = null;
        private MaterialProperty prop_LiquidOilColor = null;
        private MaterialProperty prop_LiquidOilIridescence = null;
        private MaterialProperty prop_LiquidOilIridescenceScale = null;
        private MaterialProperty prop_LiquidOilViewBased = null;
        private MaterialProperty prop_LiquidOilViewBasedCoverage = null;
        private MaterialProperty prop_LiquidIcingColor = null;
        private MaterialProperty prop_LiquidIcingColorVariation = null;
        private MaterialProperty prop_LiquidIcingColorMin = null;
        private MaterialProperty prop_LiquidIcingColorMax = null;
        private MaterialProperty prop_LiquidIcingColorScale = null;
        private MaterialProperty prop_LiquidIcingColorSeed = null;
        private MaterialProperty prop_LiquidWaxColor = null;
        private MaterialProperty prop_LiquidWaxColorVariation = null;
        private MaterialProperty prop_LiquidWaxCoolRate = null;
        private MaterialProperty prop_LiquidSlimeColor = null;
        private MaterialProperty prop_LiquidSlimeColorShift = null;
        private MaterialProperty prop_LiquidSlimeTranslucency = null;
        private MaterialProperty prop_LiquidSlimeIridescence = null;
        private MaterialProperty prop_LiquidSlimeStickiness = null;
        private MaterialProperty prop_LiquidMudColor = null;
        private MaterialProperty prop_LiquidMudColorDark = null;
        private MaterialProperty prop_LiquidMudRoughness = null;
        // stochastic sampling
        private MaterialProperty prop_StochasticSampling = null;
        private MaterialProperty prop_StochasticSamplingMode = null;
        private MaterialProperty prop_StochasticTexture = null;
        private MaterialProperty prop_StochasticOpacity = null;
        private MaterialProperty prop_StochasticBlendMode = null;
        private MaterialProperty prop_StochasticScale = null;
        private MaterialProperty prop_StochasticOffsetX = null;
        private MaterialProperty prop_StochasticOffsetY = null;
        private MaterialProperty prop_StochasticTint = null;
        private MaterialProperty prop_StochasticBlend = null;
        private MaterialProperty prop_StochasticRotationRange = null;
        private MaterialProperty prop_StochasticPriority = null;
        private MaterialProperty prop_StochasticContrastStrength = null;
        private MaterialProperty prop_StochasticContrastThreshold = null;
        private MaterialProperty prop_StochasticHeightBlend = null;
        private MaterialProperty prop_StochasticHeightMap = null;
        private MaterialProperty prop_StochasticHeightStrength = null;
        private MaterialProperty prop_StochasticMipBias = null;
        private MaterialProperty prop_StochasticAlpha = null;
        private MaterialProperty prop_StochasticNormals = null;
        // splatter mapping
        private MaterialProperty prop_SplatterMapping = null;
        private MaterialProperty prop_SplatterMappingMode = null;
        private MaterialProperty prop_SplatterControl = null;
        private MaterialProperty prop_SplatterUseNormals = null;
        private MaterialProperty prop_SplatterAlbedo0 = null;
        private MaterialProperty prop_SplatterNormal0 = null;
        private MaterialProperty prop_SplatterMasks0 = null;
        private MaterialProperty prop_SplatterColor0 = null;
        private MaterialProperty prop_SplatterTiling0 = null;
        private MaterialProperty prop_SplatterNormalStrength0 = null;
        private MaterialProperty prop_SplatterBlendMode0 = null;
        private MaterialProperty prop_SplatterAlbedo1 = null;
        private MaterialProperty prop_SplatterNormal1 = null;
        private MaterialProperty prop_SplatterMasks1 = null;
        private MaterialProperty prop_SplatterColor1 = null;
        private MaterialProperty prop_SplatterTiling1 = null;
        private MaterialProperty prop_SplatterNormalStrength1 = null;
        private MaterialProperty prop_SplatterBlendMode1 = null;
        private MaterialProperty prop_SplatterCullThreshold = null;
        private MaterialProperty prop_SplatterBlendSharpness = null;
        private MaterialProperty prop_SplatterMipBias = null;
        private MaterialProperty prop_SplatterAlphaChannel = null;
        // texture bombing
        private MaterialProperty prop_BombingTextures = null;
        private MaterialProperty prop_BombingMode = null;
        private MaterialProperty prop_BombingBlendMode = null;
        private MaterialProperty prop_BombingMappingMode = null;
        private MaterialProperty prop_BombingTriplanarSharpness = null;
        private MaterialProperty prop_BombingThreshold = null;
        private MaterialProperty prop_BombingOpacity = null;
        private MaterialProperty prop_BombingTex = null;
        private MaterialProperty prop_BombingColor = null;
        private MaterialProperty prop_BombingTiling = null;
        private MaterialProperty prop_BombingDensity = null;
        private MaterialProperty prop_BombingGlobalScale = null;
        private MaterialProperty prop_BombingJitterAmount = null;
        private MaterialProperty prop_BombingScaleVar = null;
        private MaterialProperty prop_BombingRotVar = null;
        private MaterialProperty prop_BombingHueVar = null;
        private MaterialProperty prop_BombingSatVar = null;
        private MaterialProperty prop_BombingValVar = null;
        private MaterialProperty prop_BombingUseNormal = null;
        private MaterialProperty prop_BombingNormal = null;
        private MaterialProperty prop_BombingNormalStrength = null;
        private MaterialProperty prop_BombingUseSheet = null;
        private MaterialProperty prop_BombingSheetData = null;
        private MaterialProperty prop_BombingCullDist = null;
        private MaterialProperty prop_BombingCullFalloff = null;
        // outline
        private MaterialProperty prop_ToggleLitOutline = null;
        private MaterialProperty prop_OutlineLitMix = null;
        private MaterialProperty prop_OutlineColor = null;
        private MaterialProperty prop_OutlineWidth = null;
        private MaterialProperty prop_OutlineVertexColorMask = null;
        private MaterialProperty prop_OutlineDistanceFade = null;
        private MaterialProperty prop_OutlineFadeStart = null;
        private MaterialProperty prop_OutlineFadeEnd = null;
        private MaterialProperty prop_OutlineHueShift = null;
        private MaterialProperty prop_OutlineHueShiftSpeed = null;
        private MaterialProperty prop_OutlineOpacity = null;
        private MaterialProperty prop_OutlineSpace = null;
        private MaterialProperty prop_OutlineMode = null;
        private MaterialProperty prop_OutlineTexMap = null;
        private MaterialProperty prop_OutlineTex = null;
        private MaterialProperty prop_OutlineTexTiling = null;
        private MaterialProperty prop_OutlineTexScroll = null;
        private MaterialProperty prop_OutlineOffset = null;
        private MaterialProperty prop_OutlineStyle = null;
        // audiolink
        private MaterialProperty prop_ToggleAudioLink = null;
        private MaterialProperty prop_AudioLinkFallback = null;
        private MaterialProperty prop_AudioLinkMode = null;
        private MaterialProperty prop_AudioLinkSmoothLevel = null;
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
        // ltcgi
        private MaterialProperty prop_ToggleLTCGI = null;
        #endregion // Properties
        
        // unload the material (ex. on shader change)
        public static void close_all_tabs()
        {
            if (config_tab != null) { config_tab.is_expanded = false; config_tab.is_active = false; }
            if (license_tab != null) { license_tab.is_expanded = false; license_tab.is_active = false; }
            if (presets_tab != null) { presets_tab.is_expanded = false; presets_tab.is_active = false; }
            if (premonition_tab != null) { premonition_tab.is_expanded = false; premonition_tab.is_active = false; }
            if (tab_main != null) { tab_main.is_expanded = false; tab_main.is_active = false; }
            if (sub_tab_rendering != null) { sub_tab_rendering.is_expanded = false; sub_tab_rendering.is_active = false; }
            if (sub_tab_main_textures != null) { sub_tab_main_textures.is_expanded = false; sub_tab_main_textures.is_active = false; }
            if (sub_tab_stitching != null) { sub_tab_stitching.is_expanded = false; sub_tab_stitching.is_active = false; }
            if (sub_tab_uv_manipulation != null) { sub_tab_uv_manipulation.is_expanded = false; sub_tab_uv_manipulation.is_active = false; }
            if (sub_tab_uv_effects != null) { sub_tab_uv_effects.is_expanded = false; sub_tab_uv_effects.is_active = false; }
            if (sub_tab_vertex_manipulation != null) { sub_tab_vertex_manipulation.is_expanded = false; sub_tab_vertex_manipulation.is_active = false; }
            if (sub_tab_post_processing != null) { sub_tab_post_processing.is_expanded = false; sub_tab_post_processing.is_active = false; }
            if (sub_tab_uv_sets != null) { sub_tab_uv_sets.is_expanded = false; sub_tab_uv_sets.is_active = false; }
            if (sub_tab_legacy_mode != null) { sub_tab_legacy_mode.is_expanded = false; sub_tab_legacy_mode.is_active = false; }
            if (tab_lighting != null) { tab_lighting.is_expanded = false; tab_lighting.is_active = false; }
            if (sub_tab_lighting_model != null) { sub_tab_lighting_model.is_expanded = false; sub_tab_lighting_model.is_active = false; }
            if (sub_tab_intensity != null) { sub_tab_intensity.is_expanded = false; sub_tab_intensity.is_active = false; }
            if (sub_tab_emission != null) { sub_tab_emission.is_expanded = false; sub_tab_emission.is_active = false; }
            if (sub_tab_attenuation != null) { sub_tab_attenuation.is_expanded = false; sub_tab_attenuation.is_active = false; }
            if (sub_tab_light_limiting != null) { sub_tab_light_limiting.is_expanded = false; sub_tab_light_limiting.is_active = false; }
            if (tab_specular != null) { tab_specular.is_expanded = false; tab_specular.is_active = false; }
            if (tab_shading != null) { tab_shading.is_expanded = false; tab_shading.is_active = false; }
            if (tab_anime != null) { tab_anime.is_expanded = false; tab_anime.is_active = false; }
            if (sub_tab_ambient_gradient != null) { sub_tab_ambient_gradient.is_expanded = false; sub_tab_ambient_gradient.is_active = false; }
            if (sub_tab_sdf_shadow != null) { sub_tab_sdf_shadow.is_expanded = false; sub_tab_sdf_shadow.is_active = false; }
            if (sub_tab_manual_normals != null) { sub_tab_manual_normals.is_expanded = false; sub_tab_manual_normals.is_active = false; }
            if (sub_tab_stocking != null) { sub_tab_stocking.is_expanded = false; sub_tab_stocking.is_active = false; }
            if (sub_tab_eye_parallax != null) { sub_tab_eye_parallax.is_expanded = false; sub_tab_eye_parallax.is_active = false; }
            if (sub_tab_translucent_hair != null) { sub_tab_translucent_hair.is_expanded = false; sub_tab_translucent_hair.is_active = false; }
            if (sub_tab_expression_map != null) { sub_tab_expression_map.is_expanded = false; sub_tab_expression_map.is_active = false; }
            if (sub_tab_face_map != null) { sub_tab_face_map.is_expanded = false; sub_tab_face_map.is_active = false; }
            if (sub_tab_gradient != null) { sub_tab_gradient.is_expanded = false; sub_tab_gradient.is_active = false; }
            if (sub_tab_toon_highlights != null) { sub_tab_toon_highlights.is_expanded = false; sub_tab_toon_highlights.is_active = false; }
            if (sub_tab_angel_rings != null) { sub_tab_angel_rings.is_expanded = false; sub_tab_angel_rings.is_active = false; }
            if (tab_stylise != null) { tab_stylise.is_expanded = false; tab_stylise.is_active = false; }
            if (sub_tab_rim_lighting != null) { sub_tab_rim_lighting.is_expanded = false; sub_tab_rim_lighting.is_active = false; }
            if (sub_tab_clear_coat != null) { sub_tab_clear_coat.is_expanded = false; sub_tab_clear_coat.is_active = false; }
            if (sub_tab_matcap != null) { sub_tab_matcap.is_expanded = false; sub_tab_matcap.is_active = false; }
            if (sub_tab_cubemap != null) { sub_tab_cubemap.is_expanded = false; sub_tab_cubemap.is_active = false; }
            if (sub_tab_parallax != null) { sub_tab_parallax.is_expanded = false; sub_tab_parallax.is_active = false; }
            if (sub_tab_subsurface != null) { sub_tab_subsurface.is_expanded = false; sub_tab_subsurface.is_active = false; }
            if (sub_tab_detail_map != null) { sub_tab_detail_map.is_expanded = false; sub_tab_detail_map.is_active = false; }
            if (sub_tab_shadow_map != null) { sub_tab_shadow_map.is_expanded = false; sub_tab_shadow_map.is_active = false; }
            if (tab_stickers != null) { tab_stickers.is_expanded = false; tab_stickers.is_active = false; }
            if (sub_tab_decal1_settings != null) { sub_tab_decal1_settings.is_expanded = false; sub_tab_decal1_settings.is_active = false; }
            if (sub_tab_decal1_effects != null) { sub_tab_decal1_effects.is_expanded = false; sub_tab_decal1_effects.is_active = false; }
            if (sub_tab_decal2_settings != null) { sub_tab_decal2_settings.is_expanded = false; sub_tab_decal2_settings.is_active = false; }
            if (sub_tab_decal2_effects != null) { sub_tab_decal2_effects.is_expanded = false; sub_tab_decal2_effects.is_active = false; }
            if (tab_effects != null) { tab_effects.is_expanded = false; tab_effects.is_active = false; }
            if (sub_tab_dissolve != null) { sub_tab_dissolve.is_expanded = false; sub_tab_dissolve.is_active = false; }
            if (sub_tab_pathing != null) { sub_tab_pathing.is_expanded = false; sub_tab_pathing.is_active = false; }
            if (sub_tab_glitter != null) { sub_tab_glitter.is_expanded = false; sub_tab_glitter.is_active = false; }
            if (sub_tab_distance_fading != null) { sub_tab_distance_fading.is_expanded = false; sub_tab_distance_fading.is_active = false; }
            if (sub_tab_iridescence != null) { sub_tab_iridescence.is_expanded = false; sub_tab_iridescence.is_active = false; }
            if (sub_tab_shadow_textures != null) { sub_tab_shadow_textures.is_expanded = false; sub_tab_shadow_textures.is_active = false; }
            if (sub_tab_flatten_model != null) { sub_tab_flatten_model.is_expanded = false; sub_tab_flatten_model.is_active = false; }
            if (sub_tab_world_aligned != null) { sub_tab_world_aligned.is_expanded = false; sub_tab_world_aligned.is_active = false; }
            if (sub_tab_vrchat_mirror != null) { sub_tab_vrchat_mirror.is_expanded = false; sub_tab_vrchat_mirror.is_active = false; }
            if (sub_tab_touch_interactions != null) { sub_tab_touch_interactions.is_expanded = false; sub_tab_touch_interactions.is_active = false; }
            if (sub_tab_dither != null) { sub_tab_dither.is_expanded = false; sub_tab_dither.is_active = false; }
            if (sub_tab_ps1 != null) { sub_tab_ps1.is_expanded = false; sub_tab_ps1.is_active = false; }
            if (sub_tab_vertex_distortion != null) { sub_tab_vertex_distortion.is_expanded = false; sub_tab_vertex_distortion.is_active = false; }
            if (sub_tab_refraction != null) { sub_tab_refraction.is_expanded = false; sub_tab_refraction.is_active = false; }
            if (sub_tab_screenspace_reflection != null) { sub_tab_screenspace_reflection.is_expanded = false; sub_tab_screenspace_reflection.is_active = false; }
            if (sub_tab_liquid_layer != null) { sub_tab_liquid_layer.is_expanded = false; sub_tab_liquid_layer.is_active = false; }
            if (tab_outline != null) { tab_outline.is_expanded = false; tab_outline.is_active = false; }
            if (tab_world != null) { tab_world.is_expanded = false; tab_world.is_active = false; }
            if (sub_tab_stochastic != null) { sub_tab_stochastic.is_expanded = false; sub_tab_stochastic.is_active = false; }
            if (sub_tab_splatter != null) { sub_tab_splatter.is_expanded = false; sub_tab_splatter.is_active = false; }
            if (sub_tab_bombing != null) { sub_tab_bombing.is_expanded = false; sub_tab_bombing.is_active = false; }
            if (tab_third_party != null) { tab_third_party.is_expanded = false; tab_third_party.is_active = false; }
            if (sub_tab_audiolink != null) { sub_tab_audiolink.is_expanded = false; sub_tab_audiolink.is_active = false; }
            if (sub_tab_superplug != null) { sub_tab_superplug.is_expanded = false; sub_tab_superplug.is_active = false; }
            if (sub_tab_ltcgi != null) { sub_tab_ltcgi.is_expanded = false; sub_tab_ltcgi.is_active = false; }
        }

        public static void unload_material()
        {
            loaded = false;
            has_indexed = false;
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
            search_bar = null;
            config_tab = null;
            license_tab = null;
            config_menu = null;
            presets_tab = null;
            license_menu = null;
            presets_menu = null;
            footer = null;
            premonition_tab = null;
            is_compact = false;
            compact_notice = null;
            variant_switcher = null;
            premonition_menu = null;
            #region Tabs
            tab_main = null;
            sub_tab_rendering = null;
            sub_tab_stitching = null;
            sub_tab_main_textures = null;
            sub_tab_uv_manipulation = null;
            sub_tab_uv_effects = null;
            sub_tab_vertex_manipulation = null;
            sub_tab_post_processing = null;
            sub_tab_uv_sets = null;
            sub_tab_legacy_mode = null;
            tab_lighting = null;
            sub_tab_lighting_model = null;
            sub_tab_intensity = null;
            tab_specular = null;
            sub_tab_emission = null;
            sub_tab_attenuation = null;
            sub_tab_light_limiting = null;
            tab_shading = null;
            tab_anime = null;
            sub_tab_ambient_gradient = null;
            sub_tab_sdf_shadow = null;
            sub_tab_manual_normals = null;
            sub_tab_stocking = null;
            sub_tab_eye_parallax = null;
            sub_tab_translucent_hair = null;
            sub_tab_expression_map = null;
            sub_tab_face_map = null;
            sub_tab_gradient = null;
            sub_tab_toon_highlights = null;
            sub_tab_angel_rings = null;
            tab_stylise = null;
            sub_tab_rim_lighting = null;
            sub_tab_clear_coat = null;
            sub_tab_matcap = null;
            sub_tab_cubemap = null;
            sub_tab_parallax = null;
            sub_tab_subsurface = null;
            sub_tab_detail_map = null;
            sub_tab_shadow_map = null;
            tab_stickers = null;
            sub_tab_decal1_settings = null;
            sub_tab_decal1_effects = null;
            sub_tab_decal2_settings = null;
            sub_tab_decal2_effects = null;
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
            sub_tab_liquid_layer = null;
            tab_world = null;
            sub_tab_stochastic = null;
            sub_tab_splatter = null;
            sub_tab_bombing = null;
            tab_outline = null;
            tab_third_party = null;
            sub_tab_audiolink = null;
            sub_tab_superplug = null;
            sub_tab_ltcgi = null;
            #endregion // Tabs
        }

        // unload the whole interface (ex. on settings change)
        public static void unload_interface()
        {
            unload_material();
            CacheManager.clear_cache();
        }

        // load (/reload) the interface (ex. on language change)
        public void load(ref Material targetMat)
        {
            CacheManager.init_cache();
            loaded_material = AssetDatabase.AssetPathToGUID(AssetDatabase.GetAssetPath(targetMat));
            loaded_material_id = targetMat.GetInstanceID();
            detected_variants = ShaderVariant.DetectCapabilities(ref targetMat);
            // load from shared cache
            configs = CacheManager.configs;
            languages = CacheManager.languages;
            meta = CacheManager.meta;
            theme = CacheManager.theme;
            socials_menu = CacheManager.socials_menu;
            header = CacheManager.header;
            announcement = CacheManager.announcement;
            update = CacheManager.update;
            docs = CacheManager.docs;
            footer = CacheManager.footer;
            // per-material loading
            search_bar = new SearchBar();
            license_tab = new Tab(ref targetMat, ref theme, (int)Tab.tab_sizes.Primary, 10, languages.speak("tab_license"));
            config_tab = new Tab(ref targetMat, ref theme, (int)Tab.tab_sizes.Primary, 7, languages.speak("tab_config"));
            presets_tab = new Tab(ref targetMat, ref theme, (int)Tab.tab_sizes.Primary, 8, languages.speak("tab_presets"));
            debug_tab = new Tab(ref targetMat, ref theme, (int)Tab.tab_sizes.Primary, 999, languages.speak("tab_debug"));
            config_menu = new ConfigMenu(ref theme, ref languages, ref configs, ref config_tab);
            license_menu = new LicenseMenu(ref theme, ref languages, ref license_tab);
            cushion = new Cushion(targetMat);
            beauty_blender = new BeautyBlender(targetMat);
            bags = new Bags(ref languages);
            presets_menu = new PresetsMenu(ref theme, ref bags, ref targetMat, ref presets_tab, ref configs);
            debug_menu = new DevMenu(ref theme, ref languages, ref debug_tab);
            premonition_tab = new Tab(ref targetMat, ref theme, (int)Tab.tab_sizes.Primary, 9, languages.speak("tab_premonition"));
            is_compact = targetMat.shader.name.ToLower().Contains("_compact_");
            compact_notice = new NoticeBox(ref theme, languages.speak("premonition_compact_notice"));
            premonition_menu = new PremonitionMenu(ref theme, ref targetMat, ref premonition_tab, is_compact);
            variant_switcher = new VariantSwitcher(ref theme, ref targetMat);
            #region Tabs
            tab_main = new Tab(ref targetMat, ref theme, (int)Tab.tab_sizes.Primary, 0, languages.speak("tab_main"));
            sub_tab_rendering = new Tab(ref targetMat, ref theme, (int)Tab.tab_sizes.Sub, 0, languages.speak("sub_tab_rendering"), null, null, null, null, Project.blend_mode_badges);
            sub_tab_main_textures = new Tab(ref targetMat, ref theme, (int)Tab.tab_sizes.Sub, 1, languages.speak("sub_tab_main_textures"));
            sub_tab_stitching = new Tab(ref targetMat, ref theme, (int)Tab.tab_sizes.Sub, 2, languages.speak("sub_tab_stitching"));
            sub_tab_uv_manipulation = new Tab(ref targetMat, ref theme, (int)Tab.tab_sizes.Sub, 3, languages.speak("sub_tab_uv_manipulation"));
            sub_tab_uv_effects = new Tab(ref targetMat, ref theme, (int)Tab.tab_sizes.Sub, 4, languages.speak("sub_tab_uv_effects"), null, "_ToggleUVEffects");
            sub_tab_vertex_manipulation = new Tab(ref targetMat, ref theme, (int)Tab.tab_sizes.Sub, 5, languages.speak("sub_tab_vertex_manipulation"));
            sub_tab_post_processing = new Tab(ref targetMat, ref theme, (int)Tab.tab_sizes.Sub, 6, languages.speak("sub_tab_post_processing"), null, "_TogglePostProcessing");
            sub_tab_uv_sets = new Tab(ref targetMat, ref theme, (int)Tab.tab_sizes.Sub, 7, languages.speak("sub_tab_uv_sets"));
            sub_tab_legacy_mode = new Tab(ref targetMat, ref theme, (int)Tab.tab_sizes.Sub, 8, languages.speak("tab_legacy_mode"));
            tab_lighting = new Tab(ref targetMat, ref theme, (int)Tab.tab_sizes.Primary, 1, languages.speak("tab_lighting"));
            sub_tab_lighting_model = new Tab(ref targetMat, ref theme, (int)Tab.tab_sizes.Sub, 0, languages.speak("sub_tab_lighting_model"), null, null, null, null, Project.lighting_mode_badges);
            sub_tab_intensity = new Tab(ref targetMat, ref theme, (int)Tab.tab_sizes.Sub, 1, languages.speak("sub_tab_intensity"));
            tab_shading = new Tab(ref targetMat, ref theme, (int)Tab.tab_sizes.Primary, 2, languages.speak("tab_shading"));
            tab_anime = new Tab(ref targetMat, ref theme, (int)Tab.tab_sizes.Primary, 3, languages.speak("tab_anime"), null, "_ToggleAnimeExtras");
            sub_tab_ambient_gradient = new Tab(ref targetMat, ref theme, (int)Tab.tab_sizes.Sub, 0, languages.speak("sub_tab_ambient_gradient"), null, "_ToggleAmbientGradient");
            sub_tab_sdf_shadow = new Tab(ref targetMat, ref theme, (int)Tab.tab_sizes.Sub, 1, languages.speak("sub_tab_sdf_shadow"), null, "_ToggleSDFShadow");
            sub_tab_manual_normals = new Tab(ref targetMat, ref theme, (int)Tab.tab_sizes.Sub, 2, languages.speak("sub_tab_manual_normals"), null, "_ToggleManualNormals");
            sub_tab_stocking = new Tab(ref targetMat, ref theme, (int)Tab.tab_sizes.Sub, 3, languages.speak("sub_tab_stocking"), null, "_ToggleStockings");
            sub_tab_eye_parallax = new Tab(ref targetMat, ref theme, (int)Tab.tab_sizes.Sub, 4, languages.speak("sub_tab_eye_parallax"), null, "_ToggleEyeParallax");
            sub_tab_translucent_hair = new Tab(ref targetMat, ref theme, (int)Tab.tab_sizes.Sub, 5, languages.speak("sub_tab_translucent_hair"), null, "_HairHeadMaskMode");
            sub_tab_expression_map = new Tab(ref targetMat, ref theme, (int)Tab.tab_sizes.Sub, 6, languages.speak("sub_tab_expression_map"), null, "_ToggleExpressionMap");
            sub_tab_face_map = new Tab(ref targetMat, ref theme, (int)Tab.tab_sizes.Sub, 7, languages.speak("sub_tab_face_map"), null, "_ToggleFaceMap");
            sub_tab_gradient = new Tab(ref targetMat, ref theme, (int)Tab.tab_sizes.Sub, 8, languages.speak("sub_tab_gradient"), null, "_ToggleAnimeGradient");
            sub_tab_toon_highlights = new Tab(ref targetMat, ref theme, (int)Tab.tab_sizes.Sub, 9, languages.speak("sub_tab_toon_highlights"), null, "_ToggleSpecularToon");
            sub_tab_angel_rings = new Tab(ref targetMat, ref theme, (int)Tab.tab_sizes.Sub, 10, languages.speak("sub_tab_angel_rings"), null, "_AngelRingMode");
            tab_specular = new Tab(ref targetMat, ref theme, (int)Tab.tab_sizes.Primary, 4, languages.speak("tab_specular"));
            sub_tab_emission = new Tab(ref targetMat, ref theme, (int)Tab.tab_sizes.Sub, 3, languages.speak("sub_tab_emission"), null, "_ToggleEmission");
            sub_tab_attenuation = new Tab(ref targetMat, ref theme, (int)Tab.tab_sizes.Sub, 4, languages.speak("sub_tab_attenuation"));
            sub_tab_light_limiting = new Tab(ref targetMat, ref theme, (int)Tab.tab_sizes.Sub, 5, languages.speak("sub_tab_light_limiting"));
            tab_stylise = new Tab(ref targetMat, ref theme, (int)Tab.tab_sizes.Primary, 5, languages.speak("tab_stylise"));
            sub_tab_rim_lighting = new Tab(ref targetMat, ref theme, (int)Tab.tab_sizes.Sub, 0, languages.speak("sub_tab_new_rim_lighting"), null, "_RimMode");
            sub_tab_clear_coat = new Tab(ref targetMat, ref theme, (int)Tab.tab_sizes.Sub, 1, languages.speak("sub_tab_clear_coat"), null, "_ToggleClearcoat");
            sub_tab_matcap = new Tab(ref targetMat, ref theme, (int)Tab.tab_sizes.Sub, 2, languages.speak("sub_tab_matcap"), null, "_ToggleMatcap");
            sub_tab_cubemap = new Tab(ref targetMat, ref theme, (int)Tab.tab_sizes.Sub, 3, languages.speak("sub_tab_cubemap"), null, "_ToggleCubemap");
            sub_tab_parallax = new Tab(ref targetMat, ref theme, (int)Tab.tab_sizes.Sub, 4, languages.speak("sub_tab_parallax"), null, "_ToggleParallax", null, null, Project.parallax_mode_badges);
            sub_tab_subsurface = new Tab(ref targetMat, ref theme, (int)Tab.tab_sizes.Sub, 5, languages.speak("sub_tab_subsurface"), null, "_ToggleSSS");
            sub_tab_detail_map = new Tab(ref targetMat, ref theme, (int)Tab.tab_sizes.Sub, 6, languages.speak("sub_tab_detail_map"), null, "_ToggleDetail");
            sub_tab_shadow_map = new Tab(ref targetMat, ref theme, (int)Tab.tab_sizes.Sub, 7, languages.speak("sub_tab_shadow_map"), null, "_ToggleShadowMap");
            tab_stickers = new Tab(ref targetMat, ref theme, (int)Tab.tab_sizes.Primary, 6, languages.speak("tab_stickers"), null, "_ToggleDecals");
            sub_tab_decal1_settings = new Tab(ref targetMat, ref theme, (int)Tab.tab_sizes.Sub, 0, languages.speak("sub_tab_decal1_settings"));
            sub_tab_decal1_effects = new Tab(ref targetMat, ref theme, (int)Tab.tab_sizes.Sub, 1, languages.speak("sub_tab_decal1_effects"));
            sub_tab_decal2_settings = new Tab(ref targetMat, ref theme, (int)Tab.tab_sizes.Sub, 2, languages.speak("sub_tab_decal2_settings"));
            sub_tab_decal2_effects = new Tab(ref targetMat, ref theme, (int)Tab.tab_sizes.Sub, 3, languages.speak("sub_tab_decal2_effects"));
            tab_effects = new Tab(ref targetMat, ref theme, (int)Tab.tab_sizes.Primary, 7, languages.speak("tab_effects"));
            sub_tab_dissolve = new Tab(ref targetMat, ref theme, (int)Tab.tab_sizes.Sub, 0, languages.speak("sub_tab_dissolve"), null, "_ToggleDissolve", null, null, Project.dissolve_mode_badges);
            sub_tab_pathing = new Tab(ref targetMat, ref theme, (int)Tab.tab_sizes.Sub, 1, languages.speak("sub_tab_pathing"), null, "_TogglePathing");
            sub_tab_glitter = new Tab(ref targetMat, ref theme, (int)Tab.tab_sizes.Sub, 3, languages.speak("sub_tab_glitter"), null, "_ToggleGlitter", null, null, Project.glitter_mode_badges);
            sub_tab_distance_fading = new Tab(ref targetMat, ref theme, (int)Tab.tab_sizes.Sub, 4, languages.speak("sub_tab_distance_fading"), null, "_ToggleDistanceFade");
            sub_tab_iridescence = new Tab(ref targetMat, ref theme, (int)Tab.tab_sizes.Sub, 5, languages.speak("sub_tab_iridescence"), null, "_ToggleIridescence",  null, null, Project.iridescence_mode_badges);
            sub_tab_shadow_textures = new Tab(ref targetMat, ref theme, (int)Tab.tab_sizes.Sub, 6, languages.speak("sub_tab_shadow_textures"), null, "_ToggleShadowTexture");
            sub_tab_flatten_model = new Tab(ref targetMat, ref theme, (int)Tab.tab_sizes.Sub, 7, languages.speak("sub_tab_flatten_model"), null, "_ToggleFlatModel");
            sub_tab_world_aligned = new Tab(ref targetMat, ref theme, (int)Tab.tab_sizes.Sub, 8, languages.speak("sub_tab_world_aligned"), null, "_ToggleWorldEffect");
            sub_tab_vrchat_mirror = new Tab(ref targetMat, ref theme, (int)Tab.tab_sizes.Sub, 9, languages.speak("sub_tab_vrchat_mirror"), null, "_ToggleMirrorDetection");
            sub_tab_touch_interactions = new Tab(ref targetMat, ref theme, (int)Tab.tab_sizes.Sub, 10, languages.speak("sub_tab_touch_interactions"), null, "_ToggleTouchReactive", Project.shader_capabilities[0]);
            sub_tab_dither = new Tab(ref targetMat, ref theme, (int)Tab.tab_sizes.Sub, 11, languages.speak("sub_tab_dither"), null, "_ToggleDither");
            sub_tab_ps1 = new Tab(ref targetMat, ref theme, (int)Tab.tab_sizes.Sub, 12, languages.speak("sub_tab_ps1"), null, "_TogglePS1");
            sub_tab_vertex_distortion = new Tab(ref targetMat, ref theme, (int)Tab.tab_sizes.Sub, 13, languages.speak("sub_tab_vertex_distortion"), null, "_ToggleVertexDistortion", null, null, Project.distortion_mode_badges);
            sub_tab_refraction = new Tab(ref targetMat, ref theme, (int)Tab.tab_sizes.Sub, 14, languages.speak("sub_tab_refraction"), Project.shader_variants[2], "_ToggleRefraction");
            sub_tab_screenspace_reflection = new Tab(ref targetMat, ref theme, (int)Tab.tab_sizes.Sub, 15, languages.speak("sub_tab_screenspace_reflection"), Project.shader_variants[2], "_ToggleSSR");
            sub_tab_liquid_layer = new Tab(ref targetMat, ref theme, (int)Tab.tab_sizes.Sub, 16, languages.speak("sub_tab_liquid_layer"), null, "_LiquidToggleLiquid");
            tab_world = new Tab(ref targetMat, ref theme, (int)Tab.tab_sizes.Primary, 8, languages.speak("tab_world"),  Project.shader_variants[4]);
            sub_tab_stochastic = new Tab(ref targetMat, ref theme, (int)Tab.tab_sizes.Sub, 0, languages.speak("sub_tab_stochastic"), null, "_StochasticSampling");
            sub_tab_splatter = new Tab(ref targetMat, ref theme, (int)Tab.tab_sizes.Sub, 1, languages.speak("sub_tab_splatter"), null, "_SplatterMapping");
            sub_tab_bombing = new Tab(ref targetMat, ref theme, (int)Tab.tab_sizes.Sub, 2, languages.speak("sub_tab_bombing"), null, "_BombingTextures");
            tab_outline = new Tab(ref targetMat, ref theme, (int)Tab.tab_sizes.Primary, 9, languages.speak("tab_outline"), Project.shader_variants[1]);
            tab_third_party = new Tab(ref targetMat, ref theme, (int)Tab.tab_sizes.Primary, 10, languages.speak("tab_third_party"));
            sub_tab_audiolink = new Tab(ref targetMat, ref theme, (int)Tab.tab_sizes.Sub, 0, languages.speak("sub_tab_audiolink"), null, "_ToggleAudioLink", null);
            sub_tab_superplug = new Tab(ref targetMat, ref theme, (int)Tab.tab_sizes.Sub, 1, languages.speak("sub_tab_superplug"), null, null, null, Project.dependencies[1]);
            sub_tab_ltcgi = new Tab(ref targetMat, ref theme, (int)Tab.tab_sizes.Sub, 2, languages.speak("sub_tab_ltcgi"), null, "_ToggleLTCGI", null, Project.dependencies[0]);
            #endregion // Tabs
            loaded = true;
        }

        // determine if a load is needed or not
        public void repaint_dazzle(MaterialEditor materialEditor, MaterialProperty[] properties, ref Material targetMat)
        {
            // first time loading
            if (!loaded) 
            {
                load(ref targetMat);
            }
            // check if material changed
            else
            {
                string new_guid = AssetDatabase.AssetPathToGUID(AssetDatabase.GetAssetPath(targetMat));
                if (loaded_material != new_guid || loaded_material_id != targetMat.GetInstanceID()) 
                {
                    unload_material();
                    load(ref targetMat);
                }
                else
                {
                    // always update variants in case of shader swap
                    detected_variants = ShaderVariant.DetectCapabilities(ref targetMat);
                }
            }
            // indexing pass
            if (!has_indexed && Event.current.type == EventType.Layout)
            {
                Tab.is_indexing = true;
                try {
                    DrawUI(materialEditor, properties);
                } catch { }
                Tab.is_indexing = false;
                has_indexed = true;
            }
        }

        // per-shader ui here
        public override void OnGUI(MaterialEditor materialEditor, MaterialProperty[] properties)
        {
            Material targetMat = materialEditor.target as Material;
            repaint_dazzle(materialEditor, properties, ref targetMat);
            DrawUI(materialEditor, properties);
        }

        // wrapper around FindProperty that also registers the property name with the current tab for reset
        private MaterialProperty TrackProperty(string name, MaterialProperty[] props)
        {
            Tab.RegisterPropertyName(name);
            return FindProperty(name, props);
        }

        private void DrawUI(MaterialEditor materialEditor, MaterialProperty[] properties)
        {
            Material targetMat = materialEditor.target as Material;
            // fetch properties
            prop_TogglePostProcessing = TrackProperty("_TogglePostProcessing", properties);
            prop_RGBColor = TrackProperty("_RGBColor", properties);
            prop_RGBBlendMode = TrackProperty("_RGBBlendMode", properties);
            prop_HSVMode = TrackProperty("_HSVMode", properties);
            prop_HSVHue = TrackProperty("_HSVHue", properties);
            prop_HSVSaturation = TrackProperty("_HSVSaturation", properties);
            prop_HSVValue = TrackProperty("_HSVValue", properties);
            prop_ToggleHueShift = TrackProperty("_ToggleHueShift", properties);
            prop_HueShift = TrackProperty("_HueShift", properties);
            prop_ToggleAutoCycle = TrackProperty("_ToggleAutoCycle", properties);
            prop_AutoCycleSpeed = TrackProperty("_AutoCycleSpeed", properties);
            prop_ColorGradingMode = TrackProperty("_ColorGradingMode", properties);
            prop_ColorGradingLUT = TrackProperty("_ColorGradingLUT", properties);
            prop_ColorGradingIntensity = TrackProperty("_ColorGradingIntensity", properties);
            prop_GTShadows = TrackProperty("_GTShadows", properties);
            prop_GTHighlights = TrackProperty("_GTHighlights", properties);
            prop_LCWLift = TrackProperty("_LCWLift", properties);
            prop_LCWGamma = TrackProperty("_LCWGamma", properties);
            prop_LCWGain = TrackProperty("_LCWGain", properties);
            prop_BlackAndWhite = TrackProperty("_BlackAndWhite", properties);
            prop_Brightness = TrackProperty("_Brightness", properties);

            EditorGUI.BeginChangeCheck();
            header.draw();
            if (is_compact) {
                compact_notice.draw();
                GUILayout.Space(4);
            }
            if (variant_switcher != null && variant_switcher.draw())
            {
                return;
            }
            search_bar.draw(ref theme);
            #region Backlace
            // main tab
            tab_main.process(() => {
                Components.start_foldout();
                sub_tab_rendering.process(() => {
                    prop_BlendMode = TrackProperty("_BlendMode", properties);
                    prop_OverrideBaseBlend = TrackProperty("_OverrideBaseBlend", properties);
                    prop_SrcBlend = TrackProperty("_SrcBlend", properties);
                    prop_DstBlend = TrackProperty("_DstBlend", properties);
                    prop_BlendOp = TrackProperty("_BlendOp", properties);
                    prop_OverrideAddBlend = TrackProperty("_OverrideAddBlend", properties);
                    prop_AddSrcBlend = TrackProperty("_AddSrcBlend", properties);
                    prop_AddDstBlend = TrackProperty("_AddDstBlend", properties);
                    prop_AddBlendOp = TrackProperty("_AddBlendOp", properties);
                    prop_OverrideZWrite = TrackProperty("_OverrideZWrite", properties);
                    prop_ZWrite = TrackProperty("_ZWrite", properties);
                    prop_OverrideRenderQueue = TrackProperty("_OverrideRenderQueue", properties);
                    prop_Cull = TrackProperty("_Cull", properties);
                    prop_ZTest = TrackProperty("_ZTest", properties);
                    prop_StencilRef = TrackProperty("_StencilRef", properties);
                    prop_StencilComp = TrackProperty("_StencilComp", properties);
                    prop_StencilPass = TrackProperty("_StencilPass", properties);
                    prop_StencilFail = TrackProperty("_StencilFail", properties);
                    prop_StencilZFail = TrackProperty("_StencilZFail", properties);
                    prop_VRCFallback = TrackProperty("_VRCFallback", properties);
                    prop_ToggleFlipNormals = TrackProperty("_ToggleFlipNormals", properties);
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
                    materialEditor.LightmapEmissionProperty();
                    materialEditor.EnableInstancingField();
                    materialEditor.DoubleSidedGIField();
                });
                sub_tab_main_textures.process(() => {
                    prop_MainTex = TrackProperty("_MainTex", properties);
                    prop_Color = TrackProperty("_Color", properties);
                    prop_Cutoff = TrackProperty("_Cutoff", properties);
                    prop_UseBump = TrackProperty("_UseBump", properties);
                    prop_BumpMap = TrackProperty("_BumpMap", properties);
                    prop_BumpScale = TrackProperty("_BumpScale", properties);
                    prop_BumpFromAlbedo = TrackProperty("_BumpFromAlbedo", properties);
                    prop_BumpFromAlbedoOffset = TrackProperty("_BumpFromAlbedoOffset", properties);
                    prop_Alpha = TrackProperty("_Alpha", properties);
                    materialEditor.ShaderProperty(prop_MainTex, languages.speak("prop_MainTex"));
                    materialEditor.ShaderProperty(prop_Color, languages.speak("prop_Color"));
                    materialEditor.ShaderProperty(prop_Cutoff, languages.speak("prop_Cutoff"));
                    materialEditor.ShaderProperty(prop_UseBump, languages.speak("prop_UseBump"));
                    Components.start_dynamic_disable(!prop_UseBump.floatValue.Equals(1), configs);
                    EditorGUI.indentLevel++;
                    materialEditor.TexturePropertySingleLine(new GUIContent(languages.speak("prop_BumpMap")), prop_BumpMap, prop_BumpScale);
                    materialEditor.ShaderProperty(prop_BumpFromAlbedo, languages.speak("prop_BumpFromAlbedo"));
                    materialEditor.ShaderProperty(prop_BumpFromAlbedoOffset, languages.speak("prop_BumpFromAlbedoOffset"));
                    EditorGUI.indentLevel--;
                    Components.end_dynamic_disable(!prop_UseBump.floatValue.Equals(1), configs);
                    materialEditor.ShaderProperty(prop_Alpha, languages.speak("prop_Alpha"));
                });
                sub_tab_stitching.process(() => {
                    prop_UseTextureStitching = TrackProperty("_UseTextureStitching", properties);
                    prop_StitchTex = TrackProperty("_StitchTex", properties);
                    prop_StitchAxis = TrackProperty("_StitchAxis", properties);
                    prop_StitchOffset = TrackProperty("_StitchOffset", properties);
                    materialEditor.ShaderProperty(prop_UseTextureStitching, languages.speak("prop_UseTextureStitching"));
                    Components.start_dynamic_disable(!prop_UseTextureStitching.floatValue.Equals(1), configs);
                    materialEditor.TexturePropertySingleLine(new GUIContent(languages.speak("prop_StitchTex")), prop_StitchTex);
                    int currentAxis = (int)prop_StitchAxis.floatValue;
                    int newAxis = EditorGUILayout.Popup(languages.speak("prop_StitchAxis"), currentAxis, new string[] { "X Axis", "Y Axis", "Z Axis" });
                    if (newAxis != currentAxis) prop_StitchAxis.floatValue = newAxis;
                    materialEditor.ShaderProperty(prop_StitchOffset, languages.speak("prop_StitchOffset"));
                    Components.end_dynamic_disable(!prop_UseTextureStitching.floatValue.Equals(1), configs);
                });
                sub_tab_uv_manipulation.process(() => {
                    prop_UVOffsetX = TrackProperty("_UV_Offset_X", properties);
                    prop_UVOffsetY = TrackProperty("_UV_Offset_Y", properties);
                    prop_UVScaleX = TrackProperty("_UV_Scale_X", properties);
                    prop_UVScaleY = TrackProperty("_UV_Scale_Y", properties);
                    prop_UVRotation = TrackProperty("_UV_Rotation", properties);
                    prop_UVScrollXSpeed = TrackProperty("_UV_Scroll_X_Speed", properties);
                    prop_UVScrollYSpeed = TrackProperty("_UV_Scroll_Y_Speed", properties);
                    materialEditor.ShaderProperty(prop_UVOffsetX, languages.speak("prop_UV_Offset_X"));
                    materialEditor.ShaderProperty(prop_UVOffsetY, languages.speak("prop_UV_Offset_Y"));
                    materialEditor.ShaderProperty(prop_UVScaleX, languages.speak("prop_UV_Scale_X"));
                    materialEditor.ShaderProperty(prop_UVScaleY, languages.speak("prop_UV_Scale_Y"));
                    materialEditor.ShaderProperty(prop_UVRotation, languages.speak("prop_UV_Rotation"));
                    materialEditor.ShaderProperty(prop_UVScrollXSpeed, languages.speak("prop_UV_Scroll_X_Speed"));
                    materialEditor.ShaderProperty(prop_UVScrollYSpeed, languages.speak("prop_UV_Scroll_Y_Speed"));
                });
                sub_tab_uv_effects.process(() => {
                    prop_ToggleUVEffects = TrackProperty("_ToggleUVEffects", properties);
                    prop_UVTriplanarMapping = TrackProperty("_UVTriplanarMapping", properties);
                    prop_UVTriplanarPosition = TrackProperty("_UVTriplanarPosition", properties);
                    prop_UVTriplanarScale = TrackProperty("_UVTriplanarScale", properties);
                    prop_UVTriplanarRotation = TrackProperty("_UVTriplanarRotation", properties);
                    prop_UVTriplanarSharpness = TrackProperty("_UVTriplanarSharpness", properties);
                    prop_UVScreenspaceMapping = TrackProperty("_UVScreenspaceMapping", properties);
                    prop_UVScreenspaceTiling = TrackProperty("_UVScreenspaceTiling", properties);
                    prop_UVFlipbook = TrackProperty("_UVFlipbook", properties);
                    prop_UVFlipbookRows = TrackProperty("_UVFlipbookRows", properties);
                    prop_UVFlipbookColumns = TrackProperty("_UVFlipbookColumns", properties);
                    prop_UVFlipbookFrames = TrackProperty("_UVFlipbookFrames", properties);
                    prop_UVFlipbookFPS = TrackProperty("_UVFlipbookFPS", properties);
                    prop_UVFlipbookScrub = TrackProperty("_UVFlipbookScrub", properties);
                    prop_UVFlowmap = TrackProperty("_UVFlowmap", properties);
                    prop_UVFlowmapTex = TrackProperty("_UVFlowmapTex", properties);
                    prop_UVFlowmapStrength = TrackProperty("_UVFlowmapStrength", properties);
                    prop_UVFlowmapSpeed = TrackProperty("_UVFlowmapSpeed", properties);
                    prop_UVFlowmapDistortion = TrackProperty("_UVFlowmapDistortion", properties);
                    materialEditor.ShaderProperty(prop_ToggleUVEffects, languages.speak("prop_ToggleUVEffects"));
                    Components.start_dynamic_disable(!prop_ToggleUVEffects.floatValue.Equals(1), configs);
                    // triplanar
                    materialEditor.ShaderProperty(prop_UVTriplanarMapping, languages.speak("prop_UVTriplanarMapping"));
                    Components.start_dynamic_disable(!prop_UVTriplanarMapping.floatValue.Equals(1), configs);
                    EditorGUI.indentLevel++;
                    materialEditor.ShaderProperty(prop_UVTriplanarPosition, languages.speak("prop_UVTriplanarPosition"));
                    materialEditor.ShaderProperty(prop_UVTriplanarScale, languages.speak("prop_UVTriplanarScale"));
                    materialEditor.ShaderProperty(prop_UVTriplanarRotation, languages.speak("prop_UVTriplanarRotation"));
                    materialEditor.ShaderProperty(prop_UVTriplanarSharpness, languages.speak("prop_UVTriplanarSharpness"));
                    EditorGUI.indentLevel--;
                    Components.end_dynamic_disable(!prop_UVTriplanarMapping.floatValue.Equals(1), configs);
                    // screenspace
                    materialEditor.ShaderProperty(prop_UVScreenspaceMapping, languages.speak("prop_UVScreenspaceMapping"));
                    Components.start_dynamic_disable(!prop_UVScreenspaceMapping.floatValue.Equals(1), configs);
                    EditorGUI.indentLevel++;
                    materialEditor.ShaderProperty(prop_UVScreenspaceTiling, languages.speak("prop_UVScreenspaceTiling"));
                    EditorGUI.indentLevel--;
                    Components.end_dynamic_disable(!prop_UVScreenspaceMapping.floatValue.Equals(1), configs);
                    // flipbook
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
                    // flowmap
                    materialEditor.ShaderProperty(prop_UVFlowmap, languages.speak("prop_UVFlowmap"));
                    Components.start_dynamic_disable(!prop_UVFlowmap.floatValue.Equals(1), configs);
                    EditorGUI.indentLevel++;
                    materialEditor.TexturePropertySingleLine(new GUIContent(languages.speak("prop_UVFlowmapTex")), prop_UVFlowmapTex);
                    materialEditor.ShaderProperty(prop_UVFlowmapStrength, languages.speak("prop_UVFlowmapStrength"));
                    materialEditor.ShaderProperty(prop_UVFlowmapSpeed, languages.speak("prop_UVFlowmapSpeed"));
                    materialEditor.ShaderProperty(prop_UVFlowmapDistortion, languages.speak("prop_UVFlowmapDistortion"));
                    EditorGUI.indentLevel--;
                    Components.end_dynamic_disable(!prop_UVFlowmap.floatValue.Equals(1), configs);
                    Components.end_dynamic_disable(!prop_ToggleUVEffects.floatValue.Equals(1), configs);
                });
                sub_tab_vertex_manipulation.process(() => {
                    prop_VertexManipulationPosition = TrackProperty("_VertexManipulationPosition", properties);
                    prop_VertexManipulationScale = TrackProperty("_VertexManipulationScale", properties);
                    materialEditor.ShaderProperty(prop_VertexManipulationPosition, languages.speak("prop_VertexManipulationPosition"));
                    materialEditor.ShaderProperty(prop_VertexManipulationScale, languages.speak("prop_VertexManipulationScale"));
                });
                sub_tab_post_processing.process(() => {
                    prop_TogglePostProcessing = TrackProperty("_TogglePostProcessing", properties);
                    prop_RGBColor = TrackProperty("_RGBColor", properties);
                    prop_RGBBlendMode = TrackProperty("_RGBBlendMode", properties);
                    prop_Brightness = TrackProperty("_Brightness", properties);
                    prop_BlackAndWhite = TrackProperty("_BlackAndWhite", properties);
                    prop_HSVMode = TrackProperty("_HSVMode", properties);
                    prop_HSVHue = TrackProperty("_HSVHue", properties);
                    prop_HSVSaturation = TrackProperty("_HSVSaturation", properties);
                    prop_HSVValue = TrackProperty("_HSVValue", properties);
                    prop_ToggleHueShift = TrackProperty("_ToggleHueShift", properties);
                    prop_HueShift = TrackProperty("_HueShift", properties);
                    prop_ToggleAutoCycle = TrackProperty("_ToggleAutoCycle", properties);
                    prop_AutoCycleSpeed = TrackProperty("_AutoCycleSpeed", properties);
                    prop_ColorGradingMode = TrackProperty("_ColorGradingMode", properties);
                    prop_ColorGradingIntensity = TrackProperty("_ColorGradingIntensity", properties);
                    prop_ColorGradingLUT = TrackProperty("_ColorGradingLUT", properties);
                    prop_GTShadows = TrackProperty("_GTShadows", properties);
                    prop_GTHighlights = TrackProperty("_GTHighlights", properties);
                    prop_LCWLift = TrackProperty("_LCWLift", properties);
                    prop_LCWGamma = TrackProperty("_LCWGamma", properties);
                    prop_LCWGain = TrackProperty("_LCWGain", properties);
                    materialEditor.ShaderProperty(prop_TogglePostProcessing, languages.speak("prop_TogglePostProcessing"));
                    Components.start_dynamic_disable(!prop_TogglePostProcessing.floatValue.Equals(1), configs);
                    materialEditor.ShaderProperty(prop_RGBColor, languages.speak("prop_RGBColor"));
                    materialEditor.ShaderProperty(prop_RGBBlendMode, languages.speak("prop_RGBBlendMode"));
                    materialEditor.ShaderProperty(prop_Brightness, languages.speak("prop_Brightness"));
                    materialEditor.ShaderProperty(prop_BlackAndWhite, languages.speak("prop_BlackAndWhite"));
                    materialEditor.ShaderProperty(prop_HSVMode, languages.speak("prop_HSVMode"));
                    Components.start_dynamic_disable(prop_HSVMode.floatValue == 0, configs);    
                    EditorGUI.indentLevel++;
                    materialEditor.ShaderProperty(prop_HSVHue, languages.speak("prop_HSVHue"));
                    materialEditor.ShaderProperty(prop_HSVSaturation, languages.speak("prop_HSVSaturation"));
                    materialEditor.ShaderProperty(prop_HSVValue, languages.speak("prop_HSVValue"));
                    EditorGUI.indentLevel--;
                    Components.end_dynamic_disable(prop_HSVMode.floatValue == 0, configs);
                    materialEditor.ShaderProperty(prop_ToggleHueShift, languages.speak("prop_ToggleHueShift"));
                    Components.start_dynamic_disable(prop_ToggleHueShift.floatValue == 0, configs);
                    EditorGUI.indentLevel++;
                    materialEditor.ShaderProperty(prop_HueShift, languages.speak("prop_HueShift"));
                    materialEditor.ShaderProperty(prop_ToggleAutoCycle, languages.speak("prop_ToggleAutoCycle"));
                    Components.start_dynamic_disable(prop_ToggleAutoCycle.floatValue == 0, configs);
                    materialEditor.ShaderProperty(prop_AutoCycleSpeed, languages.speak("prop_AutoCycleSpeed"));
                    EditorGUI.indentLevel--;
                    Components.end_dynamic_disable(prop_ToggleAutoCycle.floatValue == 0, configs);
                    Components.end_dynamic_disable(prop_ToggleHueShift.floatValue == 0, configs);
                    materialEditor.ShaderProperty(prop_ColorGradingMode, languages.speak("prop_ColorGradingMode"));
                    EditorGUI.indentLevel++;
                    Components.start_dynamic_disable(prop_ColorGradingMode.floatValue == 0, configs);
                    int gradingMode = (int)prop_ColorGradingMode.floatValue;
                    if (gradingMode != 0)
                    {
                        materialEditor.ShaderProperty(prop_ColorGradingIntensity, languages.speak("prop_ColorGradingIntensity"));
                        if (gradingMode == 1) materialEditor.TexturePropertySingleLine(new GUIContent(languages.speak("prop_ColorGradingLUT")), prop_ColorGradingLUT);
                        if (gradingMode == 3)
                        {
                            materialEditor.ShaderProperty(prop_GTShadows, languages.speak("prop_GTShadows"));
                            materialEditor.ShaderProperty(prop_GTHighlights, languages.speak("prop_GTHighlights"));
                        }
                        if (gradingMode == 4)
                        {
                            materialEditor.ShaderProperty(prop_LCWLift, languages.speak("prop_LCWLift"));
                            materialEditor.ShaderProperty(prop_LCWGamma, languages.speak("prop_LCWGamma"));
                            materialEditor.ShaderProperty(prop_LCWGain, languages.speak("prop_LCWGain"));
                        }
                    }
                    EditorGUI.indentLevel--;
                    Components.end_dynamic_disable(prop_ColorGradingMode.floatValue == 0, configs);
                    Components.end_dynamic_disable(!prop_TogglePostProcessing.floatValue.Equals(1), configs);
                });
                sub_tab_uv_sets.process(() => {
                    prop_MainTex_UV = TrackProperty("_MainTex_UV", properties);
                    prop_BumpMap_UV = TrackProperty("_BumpMap_UV", properties);
                    prop_MSSO_UV = TrackProperty("_MSSO_UV", properties);
                    prop_SpecularTintTexture_UV = TrackProperty("_SpecularTintTexture_UV", properties);
                    prop_TangentMap_UV = TrackProperty("_TangentMap_UV", properties);
                    prop_EmissionMap_UV = TrackProperty("_EmissionMap_UV", properties);
                    prop_ClearcoatMap_UV = TrackProperty("_ClearcoatMap_UV", properties);
                    prop_MatcapMask_UV = TrackProperty("_MatcapMask_UV", properties);
                    prop_ParallaxMap_UV = TrackProperty("_ParallaxMap_UV", properties);
                    prop_ThicknessMap_UV = TrackProperty("_ThicknessMap_UV", properties);
                    prop_DetailMap_UV = TrackProperty("_DetailMap_UV", properties);
                    prop_Decal1_UV = TrackProperty("_Decal1_UV", properties);
                    prop_Decal2_UV = TrackProperty("_Decal2_UV", properties);
                    prop_Glitter_UV = TrackProperty("_Glitter_UV", properties);
                    prop_IridescenceMask_UV = TrackProperty("_IridescenceMask_UV", properties);
                    prop_GlitterMask_UV = TrackProperty("_GlitterMask_UV", properties);
                    prop_HairFlowMap_UV = TrackProperty("_HairFlowMap_UV", properties);
                    prop_ShadowTex_UV = TrackProperty("_ShadowTex_UV", properties);
                    prop_Flowmap_UV = TrackProperty("_Flowmap_UV", properties);
                    prop_MirrorDetectionTexture_UV = TrackProperty("_MirrorDetectionTexture_UV", properties);
                    prop_RefractionMask_UV = TrackProperty("_RefractionMask_UV", properties);
                    prop_PathingMap_UV = TrackProperty("_PathingMap_UV", properties);
                    prop_ShadowMap_UV = TrackProperty("_ShadowMap_UV", properties);
                    prop_PathingTexture_UV = TrackProperty("_PathingTexture_UV", properties);
                    prop_Dither_UV = TrackProperty("_Dither_UV", properties);
                    prop_StitchTex_UV = TrackProperty("_StitchTex_UV", properties);
                    prop_SDFShadowTexture_UV = TrackProperty("_SDFShadowTexture_UV", properties);
                    prop_StockingsMap_UV = TrackProperty("_StockingsMap_UV", properties);
                    prop_EyeParallaxIrisTex_UV = TrackProperty("_EyeParallaxIrisTex_UV", properties);
                    prop_EyeParallaxEyeMaskTex_UV = TrackProperty("_EyeParallaxEyeMaskTex_UV", properties);
                    prop_HairMaskTex_UV = TrackProperty("_HairMaskTex_UV", properties);
                    prop_ExpressionMap_UV = TrackProperty("_ExpressionMap_UV", properties);
                    prop_FaceMap_UV = TrackProperty("_FaceMap_UV", properties);
                    prop_NPRSpecularMask_UV = TrackProperty("_NPRSpecularMask_UV", properties);
                    prop_PackedMapOne_UV = TrackProperty("_PackedMapOne_UV", properties);
                    prop_PackedMapTwo_UV = TrackProperty("_PackedMapTwo_UV", properties);
                    prop_PackedMapThree_UV = TrackProperty("_PackedMapThree_UV", properties);
                    prop_SkinLUT_UV = TrackProperty("_SkinLUT_UV", properties);
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
                    materialEditor.ShaderProperty(prop_StitchTex_UV, languages.speak("prop_StitchTex_UV"));
                    materialEditor.ShaderProperty(prop_SDFShadowTexture_UV, languages.speak("prop_SDFShadowTexture_UV"));
                    materialEditor.ShaderProperty(prop_StockingsMap_UV, languages.speak("prop_StockingsMap_UV"));
                    materialEditor.ShaderProperty(prop_EyeParallaxIrisTex_UV, languages.speak("prop_EyeParallaxIrisTex_UV"));
                    materialEditor.ShaderProperty(prop_EyeParallaxEyeMaskTex_UV, languages.speak("prop_EyeParallaxEyeMaskTex_UV"));
                    materialEditor.ShaderProperty(prop_HairMaskTex_UV, languages.speak("prop_HairMaskTex_UV"));
                    materialEditor.ShaderProperty(prop_ExpressionMap_UV, languages.speak("prop_ExpressionMap_UV"));
                    materialEditor.ShaderProperty(prop_FaceMap_UV, languages.speak("prop_FaceMap_UV"));
                    materialEditor.ShaderProperty(prop_NPRSpecularMask_UV, languages.speak("prop_NPRSpecularMask_UV"));
                    materialEditor.ShaderProperty(prop_PackedMapOne_UV, languages.speak("prop_PackedMapOne_UV"));
                    materialEditor.ShaderProperty(prop_PackedMapTwo_UV, languages.speak("prop_PackedMapTwo_UV"));
                    materialEditor.ShaderProperty(prop_PackedMapThree_UV, languages.speak("prop_PackedMapThree_UV"));
                    materialEditor.ShaderProperty(prop_SkinLUT_UV, languages.speak("prop_SkinLUT_UV"));
                });
                sub_tab_legacy_mode.process(() => {
                    GUIStyle wrappedStyle = new GUIStyle(EditorStyles.label);
                    wrappedStyle.wordWrap = true;
                    GUILayout.Label(theme.language_manager.speak("legacy_mode_new"), wrappedStyle);
                });
                Components.end_foldout();
            });
            // lighting tab
            tab_lighting.process(() => {
                Components.start_foldout();
                sub_tab_lighting_model.process(() => {
                    prop_LightingColorMode = TrackProperty("_LightingColorMode", properties);
                    prop_LightingDirectionMode = TrackProperty("_LightingDirectionMode", properties);
                    prop_LightingSource = TrackProperty("_LightingSource", properties);
                    prop_IndirectAlbedo = TrackProperty("_IndirectAlbedo", properties);
                    prop_DirectDiffuse = TrackProperty("_DirectDiffuse", properties);
                    prop_IndirectDiffuse = TrackProperty("_IndirectDiffuse", properties);
                    prop_DirectionalAmbience = TrackProperty("_DirectionalAmbience", properties);
                    prop_IndirectAdditive = TrackProperty("_IndirectAdditive", properties);
                    prop_ForcedLightDirection = TrackProperty("_ForcedLightDirection", properties);
                    prop_ViewDirectionOffsetX = TrackProperty("_ViewDirectionOffsetX", properties);
                    prop_ViewDirectionOffsetY = TrackProperty("_ViewDirectionOffsetY", properties);
                    prop_IndirectOverride = TrackProperty("_IndirectOverride", properties);
                    prop_IndirectFallbackMode = TrackProperty("_IndirectFallbackMode", properties);
                    prop_FallbackCubemap = TrackProperty("_FallbackCubemap", properties);
                    materialEditor.ShaderProperty(prop_LightingColorMode, languages.speak("prop_LightingColorMode"));
                    materialEditor.ShaderProperty(prop_LightingDirectionMode, languages.speak("prop_LightingDirectionMode"));
                    EditorGUI.indentLevel++;
                    if (prop_LightingDirectionMode.floatValue == 1) // forced directional
                    {
                        materialEditor.ShaderProperty(prop_ForcedLightDirection, languages.speak("prop_ForcedLightDirection"));
                    } else if (prop_LightingDirectionMode.floatValue == 2 || prop_LightingDirectionMode.floatValue == 3) // view direction
                    {
                        materialEditor.ShaderProperty(prop_ViewDirectionOffsetX, languages.speak("prop_ViewDirectionOffsetX"));
                        materialEditor.ShaderProperty(prop_ViewDirectionOffsetY, languages.speak("prop_ViewDirectionOffsetY"));
                    }
                    EditorGUI.indentLevel--;
                    materialEditor.ShaderProperty(prop_LightingSource, languages.speak("prop_LightingSource"));
                    materialEditor.ShaderProperty(prop_IndirectAlbedo, languages.speak("prop_IndirectAlbedo"));
                    materialEditor.ShaderProperty(prop_IndirectDiffuse, languages.speak("prop_IndirectDiffuse"));
                    materialEditor.ShaderProperty(prop_DirectDiffuse, languages.speak("prop_DirectDiffuse"));
                    materialEditor.ShaderProperty(prop_DirectionalAmbience, languages.speak("prop_DirectionalAmbience"));
                    materialEditor.ShaderProperty(prop_IndirectAdditive, languages.speak("prop_IndirectAdditive"));
                    materialEditor.ShaderProperty(prop_IndirectOverride, languages.speak("prop_IndirectOverride"));
                    materialEditor.ShaderProperty(prop_IndirectFallbackMode, languages.speak("prop_IndirectFallbackMode"));
                    materialEditor.ShaderProperty(prop_FallbackCubemap, languages.speak("prop_FallbackCubemap"));
                });
                sub_tab_intensity.process(() => {
                    prop_DirectIntensity = TrackProperty("_DirectIntensity", properties);
                    prop_IndirectIntensity = TrackProperty("_IndirectIntensity", properties);
                    prop_VertexIntensity = TrackProperty("_VertexIntensity", properties);
                    prop_AdditiveIntensity = TrackProperty("_AdditiveIntensity", properties);
                    prop_BakedDirectIntensity = TrackProperty("_BakedDirectIntensity", properties);
                    prop_BakedIndirectIntensity = TrackProperty("_BakedIndirectIntensity", properties);
                    materialEditor.ShaderProperty(prop_DirectIntensity, languages.speak("prop_DirectIntensity"));
                    materialEditor.ShaderProperty(prop_IndirectIntensity, languages.speak("prop_IndirectIntensity"));
                    materialEditor.ShaderProperty(prop_VertexIntensity, languages.speak("prop_VertexIntensity"));
                    materialEditor.ShaderProperty(prop_AdditiveIntensity, languages.speak("prop_AdditiveIntensity"));
                    materialEditor.ShaderProperty(prop_BakedDirectIntensity, languages.speak("prop_BakedDirectIntensity"));
                    materialEditor.ShaderProperty(prop_BakedIndirectIntensity, languages.speak("prop_BakedIndirectIntensity"));
                });
                sub_tab_attenuation.process(() => {
                    prop_AttenuationOverride = TrackProperty("_AttenuationOverride", properties);
                    prop_AttenuationShaded = TrackProperty("_AttenuationShaded", properties);
                    prop_AttenuationManual = TrackProperty("_AttenuationManual", properties);
                    prop_AttenuationMin = TrackProperty("_AttenuationMin", properties);
                    prop_AttenuationMax = TrackProperty("_AttenuationMax", properties);
                    prop_AttenuationMultiplier = TrackProperty("_AttenuationMultiplier", properties);
                    prop_AttenuationBoost = TrackProperty("_AttenuationBoost", properties);
                    materialEditor.ShaderProperty(prop_AttenuationOverride, languages.speak("prop_AttenuationOverride"));
                    Components.start_dynamic_disable(prop_AttenuationOverride.floatValue == 0, configs);
                    EditorGUI.indentLevel++;
                    materialEditor.ShaderProperty(prop_AttenuationManual, languages.speak("prop_AttenuationManual"));
                    EditorGUI.indentLevel--;
                    Components.end_dynamic_disable(prop_AttenuationOverride.floatValue == 0, configs);
                    materialEditor.ShaderProperty(prop_AttenuationMin, languages.speak("prop_AttenuationMin"));
                    materialEditor.ShaderProperty(prop_AttenuationMax, languages.speak("prop_AttenuationMax"));
                    materialEditor.ShaderProperty(prop_AttenuationMultiplier, languages.speak("prop_AttenuationMultiplier"));
                    materialEditor.ShaderProperty(prop_AttenuationBoost, languages.speak("prop_AttenuationBoost"));
                    materialEditor.ShaderProperty(prop_AttenuationShaded, languages.speak("prop_AttenuationShaded"));
                });
                sub_tab_light_limiting.process(() => {
                    prop_EnableBaseLightLimit = TrackProperty("_EnableBaseLightLimit", properties);
                    prop_BaseLightMin = TrackProperty("_BaseLightMin", properties);
                    prop_BaseLightMax = TrackProperty("_BaseLightMax", properties);
                    prop_EnableAddLightLimit = TrackProperty("_EnableAddLightLimit", properties);
                    prop_AddLightMin = TrackProperty("_AddLightMin", properties);
                    prop_AddLightMax = TrackProperty("_AddLightMax", properties);
                    prop_GreyscaleLighting = TrackProperty("_GreyscaleLighting", properties);
                    prop_ForceLightColor = TrackProperty("_ForceLightColor", properties);
                    prop_ForcedLightColor = TrackProperty("_ForcedLightColor", properties);
                    materialEditor.ShaderProperty(prop_EnableBaseLightLimit, languages.speak("prop_EnableBaseLightLimit"));
                    Components.start_dynamic_disable(!prop_EnableBaseLightLimit.floatValue.Equals(1), configs);
                    EditorGUI.indentLevel++;
                    materialEditor.ShaderProperty(prop_BaseLightMin, languages.speak("prop_BaseLightMin"));
                    materialEditor.ShaderProperty(prop_BaseLightMax, languages.speak("prop_BaseLightMax"));
                    EditorGUI.indentLevel--;
                    Components.end_dynamic_disable(!prop_EnableBaseLightLimit.floatValue.Equals(1), configs);
                    materialEditor.ShaderProperty(prop_EnableAddLightLimit, languages.speak("prop_EnableAddLightLimit"));
                    Components.start_dynamic_disable(!prop_EnableAddLightLimit.floatValue.Equals(1), configs);
                    EditorGUI.indentLevel++;
                    materialEditor.ShaderProperty(prop_AddLightMin, languages.speak("prop_AddLightMin"));
                    materialEditor.ShaderProperty(prop_AddLightMax, languages.speak("prop_AddLightMax"));
                    EditorGUI.indentLevel--;
                    Components.end_dynamic_disable(!prop_EnableAddLightLimit.floatValue.Equals(1), configs);
                    materialEditor.ShaderProperty(prop_GreyscaleLighting, languages.speak("prop_GreyscaleLighting"));
                    materialEditor.ShaderProperty(prop_ForceLightColor, languages.speak("prop_ForceLightColor"));
                    Components.start_dynamic_disable(!prop_ForceLightColor.floatValue.Equals(1), configs);
                    EditorGUI.indentLevel++;
                    materialEditor.ShaderProperty(prop_ForcedLightColor, languages.speak("prop_ForcedLightColor"));
                    EditorGUI.indentLevel--;
                    Components.end_dynamic_disable(!prop_ForceLightColor.floatValue.Equals(1), configs);
                });
                sub_tab_emission.process(() => {
                    prop_ToggleEmission = TrackProperty("_ToggleEmission", properties);
                    prop_EmissionColor = TrackProperty("_EmissionColor", properties);
                    prop_EmissionMap = TrackProperty("_EmissionMap", properties);
                    prop_UseAlbedoAsEmission = TrackProperty("_UseAlbedoAsEmission", properties);
                    prop_EmissionStrength = TrackProperty("_EmissionStrength", properties);
                    materialEditor.ShaderProperty(prop_ToggleEmission, languages.speak("prop_ToggleEmission"));
                    Components.start_dynamic_disable(!prop_ToggleEmission.floatValue.Equals(1), configs);
                    materialEditor.ShaderProperty(prop_EmissionMap, languages.speak("prop_EmissionMap"));
                    materialEditor.ShaderProperty(prop_EmissionColor, languages.speak("prop_EmissionColor"));
                    materialEditor.ShaderProperty(prop_UseAlbedoAsEmission, languages.speak("prop_UseAlbedoAsEmission"));
                    materialEditor.ShaderProperty(prop_EmissionStrength, languages.speak("prop_EmissionStrength"));
                    Components.end_dynamic_disable(!prop_ToggleEmission.floatValue.Equals(1), configs);
                });
                Components.end_foldout();
            });
            // shading tab
            tab_shading.process(() => {
                Components.start_foldout();
                prop_AnimeMode = TrackProperty("_AnimeMode", properties);
                prop_RampMode = TrackProperty("_RampMode", properties);
                prop_Ramp = TrackProperty("_Ramp", properties);
                prop_RampColor = TrackProperty("_RampColor", properties);
                prop_RampOffset = TrackProperty("_RampOffset", properties);
                prop_RampShadows = TrackProperty("_RampShadows", properties);
                prop_RampOcclusionOffset = TrackProperty("_RampOcclusionOffset", properties);
                prop_RampMin = TrackProperty("_RampMin", properties);
                prop_RampProceduralShift = TrackProperty("_RampProceduralShift", properties);
                prop_RampProceduralToony = TrackProperty("_RampProceduralToony", properties);
                prop_RampNormalIntensity = TrackProperty("_RampNormalIntensity", properties);
                prop_RampIndex = TrackProperty("_RampIndex", properties);
                prop_RampTotal = TrackProperty("_RampTotal", properties);
                prop_CelMode = TrackProperty("_CelMode", properties);
                prop_CelThreshold = TrackProperty("_CelThreshold", properties);
                prop_CelFeather = TrackProperty("_CelFeather", properties);
                prop_CelCastShadowFeather = TrackProperty("_CelCastShadowFeather", properties);
                prop_CelCastShadowPower = TrackProperty("_CelCastShadowPower", properties);
                prop_CelShadowTint = TrackProperty("_CelShadowTint", properties);
                prop_CelLitTint = TrackProperty("_CelLitTint", properties);
                prop_CelSmoothGradientPower = TrackProperty("_CelSmoothGradientPower", properties);
                prop_CelSmoothOcclusionStrength = TrackProperty("_CelSmoothOcclusionStrength", properties);
                prop_NPRDiffMin = TrackProperty("_NPRDiffMin", properties);
                prop_NPRDiffMax = TrackProperty("_NPRDiffMax", properties);
                prop_NPRLitColor = TrackProperty("_NPRLitColor", properties);
                prop_NPRShadowColor = TrackProperty("_NPRShadowColor", properties);
                prop_NPRSpecularMask = TrackProperty("_NPRSpecularMask", properties);
                prop_NPRForwardSpecular = TrackProperty("_NPRForwardSpecular", properties);
                prop_NPRForwardSpecularRange = TrackProperty("_NPRForwardSpecularRange", properties);
                prop_NPRForwardSpecularMultiplier = TrackProperty("_NPRForwardSpecularMultiplier", properties);
                prop_NPRForwardSpecularColor = TrackProperty("_NPRForwardSpecularColor", properties);
                prop_NPRBlinn = TrackProperty("_NPRBlinn", properties);
                prop_NPRBlinnPower = TrackProperty("_NPRBlinnPower", properties);
                prop_NPRBlinnMin = TrackProperty("_NPRBlinnMin", properties);
                prop_NPRBlinnMax = TrackProperty("_NPRBlinnMax", properties);
                prop_NPRBlinnColor = TrackProperty("_NPRBlinnColor", properties);
                prop_NPRBlinnMultiplier = TrackProperty("_NPRBlinnMultiplier", properties);
                prop_NPRSSS = TrackProperty("_NPRSSS", properties);
                prop_NPRSSSExp = TrackProperty("_NPRSSSExp", properties);
                prop_NPRSSSRef = TrackProperty("_NPRSSSRef", properties);
                prop_NPRSSSMin = TrackProperty("_NPRSSSMin", properties);
                prop_NPRSSSMax = TrackProperty("_NPRSSSMax", properties);
                prop_NPRSSSShadows = TrackProperty("_NPRSSSShadows", properties);
                prop_NPRSSSColor = TrackProperty("_NPRSSSColor", properties);
                prop_NPRRim = TrackProperty("_NPRRim", properties);
                prop_NPRRimExp = TrackProperty("_NPRRimExp", properties);
                prop_NPRRimMin = TrackProperty("_NPRRimMin", properties);
                prop_NPRRimMax = TrackProperty("_NPRRimMax", properties);
                prop_NPRRimColor = TrackProperty("_NPRRimColor", properties);
                prop_PackedMapStyle = TrackProperty("_PackedMapStyle", properties);
                prop_PackedMapOne = TrackProperty("_PackedMapOne", properties);
                prop_PackedMapTwo = TrackProperty("_PackedMapTwo", properties);
                prop_PackedMapThree = TrackProperty("_PackedMapThree", properties);
                prop_PackedLitColor = TrackProperty("_PackedLitColor", properties);
                prop_PackedShadowColor = TrackProperty("_PackedShadowColor", properties);
                prop_PackedShadowSmoothness = TrackProperty("_PackedShadowSmoothness", properties);
                prop_PackedRimLight = TrackProperty("_PackedRimLight", properties);
                prop_PackedRimColor = TrackProperty("_PackedRimColor", properties);
                prop_PackedRimThreshold = TrackProperty("_PackedRimThreshold", properties);
                prop_PackedRimPower = TrackProperty("_PackedRimPower", properties);
                prop_PackedMapMetals = TrackProperty("_PackedMapMetals", properties);
                prop_PackedAmbient = TrackProperty("_PackedAmbient", properties);
                prop_PackedUmaSpecularBoost = TrackProperty("_PackedUmaSpecularBoost", properties);
                prop_PackedUmaMetalDark = TrackProperty("_PackedUmaMetalDark", properties);
                prop_PackedUmaMetalLight = TrackProperty("_PackedUmaMetalLight", properties);
                prop_PackedGGSpecularSize = TrackProperty("_PackedGGSpecularSize", properties);
                prop_PackedGGSpecularIntensity = TrackProperty("_PackedGGSpecularIntensity", properties);
                prop_PackedGGSpecularTint = TrackProperty("_PackedGGSpecularTint", properties);
                prop_PackedGGShadow1Push = TrackProperty("_PackedGGShadow1Push", properties);
                prop_PackedGGShadow1Smoothness = TrackProperty("_PackedGGShadow1Smoothness", properties);
                prop_PackedGGShadow2Push = TrackProperty("_PackedGGShadow2Push", properties);
                prop_PackedGGShadow2Smoothness = TrackProperty("_PackedGGShadow2Smoothness", properties);
                prop_PackedGGShadow1Tint = TrackProperty("_PackedGGShadow1Tint", properties);
                prop_PackedGGShadow2Tint = TrackProperty("_PackedGGShadow2Tint", properties);
                prop_TriBandSmoothness = TrackProperty("_TriBandSmoothness", properties);
                prop_TriBandThreshold = TrackProperty("_TriBandThreshold", properties);
                prop_TriBandShallowWidth = TrackProperty("_TriBandShallowWidth", properties);
                prop_TriBandShadowColor = TrackProperty("_TriBandShadowColor", properties);
                prop_TriBandShallowColor = TrackProperty("_TriBandShallowColor", properties);
                prop_TriBandLitColor = TrackProperty("_TriBandLitColor", properties);
                prop_TriBandPostShadowTint = TrackProperty("_TriBandPostShadowTint", properties);
                prop_TriBandPostShallowTint = TrackProperty("_TriBandPostShallowTint", properties);
                prop_TriBandPostLitTint = TrackProperty("_TriBandPostLitTint", properties);
                prop_TriBandAttenuatedShadows = TrackProperty("_TriBandAttenuatedShadows", properties);
                prop_TriBandIndirectShallow = TrackProperty("_TriBandIndirectShallow", properties);
                prop_SkinLUT = TrackProperty("_SkinLUT", properties);
                prop_SkinShadowColor = TrackProperty("_SkinShadowColor", properties);
                prop_SkinScattering = TrackProperty("_SkinScattering", properties);
                prop_WrapFactor = TrackProperty("_WrapFactor", properties);
                prop_WrapNormalization = TrackProperty("_WrapNormalization", properties);
                prop_WrapColorHigh = TrackProperty("_WrapColorHigh", properties);
                prop_WrapColorLow = TrackProperty("_WrapColorLow", properties);
                materialEditor.ShaderProperty(prop_AnimeMode, languages.speak("prop_AnimeModeNew"));
                int animeMode = (int)prop_AnimeMode.floatValue;
                if (animeMode == 1 || animeMode == 0) // ramp, we show when disabled too now!
                {
                    Components.start_dynamic_disable(animeMode != 1, configs);
                    // shared properties
                    materialEditor.ShaderProperty(prop_RampMode, languages.speak("prop_RampMode"));
                    materialEditor.ShaderProperty(prop_RampNormalIntensity, languages.speak("prop_RampNormalIntensity"));
                    if (prop_RampMode.floatValue == 0) // texture
                    {
                        materialEditor.ShaderProperty(prop_Ramp, languages.speak("prop_Ramp"));
                        materialEditor.ShaderProperty(prop_RampTotal, languages.speak("prop_RampTotal"));
                        EditorGUI.indentLevel++;
                        materialEditor.ShaderProperty(prop_RampIndex, languages.speak("prop_RampIndex"));
                        EditorGUI.indentLevel--;
                        materialEditor.ShaderProperty(prop_RampColor, languages.speak("prop_RampColor"));
                        materialEditor.ShaderProperty(prop_RampMin, languages.speak("prop_RampMin"));
                        materialEditor.ShaderProperty(prop_RampOffset, languages.speak("prop_RampOffset"));
                        materialEditor.ShaderProperty(prop_RampShadows, languages.speak("prop_RampShadows"));
                        materialEditor.ShaderProperty(prop_RampOcclusionOffset, languages.speak("prop_RampOcclusionOffset"));
                    }
                    else // procedural
                    {
                        materialEditor.ShaderProperty(prop_RampProceduralShift, languages.speak("prop_RampProceduralShift"));
                        materialEditor.ShaderProperty(prop_RampProceduralToony, languages.speak("prop_RampProceduralToony"));
                    }
                    Components.end_dynamic_disable(animeMode != 1, configs);
                }
                else if (animeMode == 2) // cel
                {
                    materialEditor.ShaderProperty(prop_CelMode, languages.speak("prop_CelMode"));
                    if (prop_CelMode.floatValue == 2) // smooth
                    {
                        EditorGUI.indentLevel++;
                        materialEditor.ShaderProperty(prop_CelSmoothGradientPower, languages.speak("prop_CelSmoothGradientPower"));
                        materialEditor.ShaderProperty(prop_CelSmoothOcclusionStrength, languages.speak("prop_CelSmoothOcclusionStrength"));
                        EditorGUI.indentLevel--;
                    }
                    materialEditor.ShaderProperty(prop_CelThreshold, languages.speak("prop_CelThreshold"));
                    materialEditor.ShaderProperty(prop_CelFeather, languages.speak("prop_CelFeather"));
                    materialEditor.ShaderProperty(prop_CelCastShadowFeather, languages.speak("prop_CelCastShadowFeather"));
                    materialEditor.ShaderProperty(prop_CelCastShadowPower, languages.speak("prop_CelCastShadowPower"));
                    materialEditor.ShaderProperty(prop_CelShadowTint, languages.speak("prop_CelShadowTint"));
                    materialEditor.ShaderProperty(prop_CelLitTint, languages.speak("prop_CelLitTint"));
                }
                else if (animeMode == 3) // npr
                {
                    materialEditor.ShaderProperty(prop_NPRSpecularMask, languages.speak("prop_NPRSpecularMask"));
                    materialEditor.ShaderProperty(prop_NPRDiffMin, languages.speak("prop_NPRDiffMin"));
                    materialEditor.ShaderProperty(prop_NPRDiffMax, languages.speak("prop_NPRDiffMax"));
                    materialEditor.ShaderProperty(prop_NPRLitColor, languages.speak("prop_NPRLitColor"));
                    materialEditor.ShaderProperty(prop_NPRShadowColor, languages.speak("prop_NPRShadowColor"));
                    // forward specular
                    materialEditor.ShaderProperty(prop_NPRForwardSpecular, languages.speak("prop_NPRForwardSpecular"));
                    Components.start_dynamic_disable(prop_NPRForwardSpecular.floatValue == 0, configs);
                    EditorGUI.indentLevel++;
                    materialEditor.ShaderProperty(prop_NPRForwardSpecularMultiplier, languages.speak("prop_NPRForwardSpecularMultiplier"));
                    materialEditor.ShaderProperty(prop_NPRForwardSpecularRange, languages.speak("prop_NPRForwardSpecularRange"));
                    materialEditor.ShaderProperty(prop_NPRForwardSpecularColor, languages.speak("prop_NPRForwardSpecularColor"));
                    EditorGUI.indentLevel--;
                    Components.end_dynamic_disable(prop_NPRForwardSpecular.floatValue == 0, configs);
                    // blinn
                    materialEditor.ShaderProperty(prop_NPRBlinn, languages.speak("prop_NPRBlinn"));
                    Components.start_dynamic_disable(prop_NPRBlinn.floatValue == 0, configs);
                    EditorGUI.indentLevel++;
                    materialEditor.ShaderProperty(prop_NPRBlinnPower, languages.speak("prop_NPRBlinnPower"));
                    materialEditor.ShaderProperty(prop_NPRBlinnMin, languages.speak("prop_NPRBlinnMin"));
                    materialEditor.ShaderProperty(prop_NPRBlinnMultiplier, languages.speak("prop_NPRBlinnMultiplier"));
                    materialEditor.ShaderProperty(prop_NPRBlinnMax, languages.speak("prop_NPRBlinnMax"));
                    materialEditor.ShaderProperty(prop_NPRBlinnColor, languages.speak("prop_NPRBlinnColor"));
                    EditorGUI.indentLevel--;
                    Components.end_dynamic_disable(prop_NPRBlinn.floatValue == 0, configs);
                    // sss
                    materialEditor.ShaderProperty(prop_NPRSSS, languages.speak("prop_NPRSSS"));
                    Components.start_dynamic_disable(prop_NPRSSS.floatValue == 0, configs);
                    EditorGUI.indentLevel++;
                    materialEditor.ShaderProperty(prop_NPRSSSExp, languages.speak("prop_NPRSSSExp"));
                    materialEditor.ShaderProperty(prop_NPRSSSRef, languages.speak("prop_NPRSSSRef"));
                    materialEditor.ShaderProperty(prop_NPRSSSMin, languages.speak("prop_NPRSSSMin"));
                    materialEditor.ShaderProperty(prop_NPRSSSMax, languages.speak("prop_NPRSSSMax"));
                    materialEditor.ShaderProperty(prop_NPRSSSShadows, languages.speak("prop_NPRSSSShadows"));
                    materialEditor.ShaderProperty(prop_NPRSSSColor, languages.speak("prop_NPRSSSColor"));
                    EditorGUI.indentLevel--;
                    Components.end_dynamic_disable(prop_NPRSSS.floatValue == 0, configs);
                    // rim
                    materialEditor.ShaderProperty(prop_NPRRim, languages.speak("prop_NPRRim"));
                    Components.start_dynamic_disable(prop_NPRRim.floatValue == 0, configs);
                    EditorGUI.indentLevel++;
                    materialEditor.ShaderProperty(prop_NPRRimExp, languages.speak("prop_NPRRimExp"));
                    materialEditor.ShaderProperty(prop_NPRRimMin, languages.speak("prop_NPRRimMin"));
                    materialEditor.ShaderProperty(prop_NPRRimMax, languages.speak("prop_NPRRimMax"));
                    materialEditor.ShaderProperty(prop_NPRRimColor, languages.speak("prop_NPRRimColor"));
                    EditorGUI.indentLevel--;
                    Components.end_dynamic_disable(prop_NPRRim.floatValue == 0, configs);
                }
                else if (animeMode == 4) // packed
                {
                    materialEditor.TexturePropertySingleLine(new GUIContent(languages.speak("prop_PackedMapOne")), prop_PackedMapOne);
                    materialEditor.TexturePropertySingleLine(new GUIContent(languages.speak("prop_PackedMapTwo")), prop_PackedMapTwo);
                    materialEditor.TexturePropertySingleLine(new GUIContent(languages.speak("prop_PackedMapThree")), prop_PackedMapThree);
                    materialEditor.ShaderProperty(prop_PackedMapStyle, languages.speak("prop_PackedMapStyle"));
                    int packedStyle = (int)prop_PackedMapStyle.floatValue;
                    if (packedStyle == 1) // uma
                    {
                        EditorGUI.indentLevel++;
                        materialEditor.ShaderProperty(prop_PackedUmaSpecularBoost, languages.speak("prop_PackedUmaSpecularBoost"));
                        materialEditor.ShaderProperty(prop_PackedUmaMetalDark, languages.speak("prop_PackedUmaMetalDark"));
                        materialEditor.ShaderProperty(prop_PackedUmaMetalLight, languages.speak("prop_PackedUmaMetalLight"));
                        EditorGUI.indentLevel--;
                    }
                    else if (packedStyle == 2) // guilty gear
                    {
                        EditorGUI.indentLevel++;
                        materialEditor.ShaderProperty(prop_PackedGGSpecularSize, languages.speak("prop_PackedGGSpecularSize"));
                        materialEditor.ShaderProperty(prop_PackedGGSpecularIntensity, languages.speak("prop_PackedGGSpecularIntensity"));
                        materialEditor.ShaderProperty(prop_PackedGGSpecularTint, languages.speak("prop_PackedGGSpecularTint"));
                        materialEditor.ShaderProperty(prop_PackedGGShadow1Push, languages.speak("prop_PackedGGShadow1Push"));
                        materialEditor.ShaderProperty(prop_PackedGGShadow1Smoothness, languages.speak("prop_PackedGGShadow1Smoothness"));
                        materialEditor.ShaderProperty(prop_PackedGGShadow2Push, languages.speak("prop_PackedGGShadow2Push"));
                        materialEditor.ShaderProperty(prop_PackedGGShadow2Smoothness, languages.speak("prop_PackedGGShadow2Smoothness"));
                        materialEditor.ShaderProperty(prop_PackedGGShadow1Tint, languages.speak("prop_PackedGGShadow1Tint"));
                        materialEditor.ShaderProperty(prop_PackedGGShadow2Tint, languages.speak("prop_PackedGGShadow2Tint"));
                        EditorGUI.indentLevel--;
                    }
                    materialEditor.ShaderProperty(prop_PackedMapMetals, languages.speak("prop_PackedMapMetals"));
                    materialEditor.ShaderProperty(prop_PackedShadowSmoothness, languages.speak("prop_PackedShadowSmoothness"));
                    materialEditor.ShaderProperty(prop_PackedLitColor, languages.speak("prop_PackedLitColor"));
                    materialEditor.ShaderProperty(prop_PackedShadowColor, languages.speak("prop_PackedShadowColor"));
                    materialEditor.ShaderProperty(prop_PackedRimLight, languages.speak("prop_PackedRimLight"));
                    Components.start_dynamic_disable(prop_PackedRimLight.floatValue == 0, configs);
                    EditorGUI.indentLevel++;
                    materialEditor.ShaderProperty(prop_PackedRimColor, languages.speak("prop_PackedRimColor"));
                    materialEditor.ShaderProperty(prop_PackedRimThreshold, languages.speak("prop_PackedRimThreshold"));
                    materialEditor.ShaderProperty(prop_PackedRimPower, languages.speak("prop_PackedRimPower"));
                    EditorGUI.indentLevel--;
                    Components.end_dynamic_disable(prop_PackedRimLight.floatValue == 0, configs);
                    materialEditor.ShaderProperty(prop_PackedAmbient, languages.speak("prop_PackedAmbient"));
                }
                else if (animeMode == 5) // triband
                {
                    materialEditor.ShaderProperty(prop_TriBandSmoothness, languages.speak("prop_TriBandSmoothness"));
                    materialEditor.ShaderProperty(prop_TriBandThreshold, languages.speak("prop_TriBandThreshold"));
                    materialEditor.ShaderProperty(prop_TriBandShallowWidth, languages.speak("prop_TriBandShallowWidth"));
                    materialEditor.ShaderProperty(prop_TriBandShadowColor, languages.speak("prop_TriBandShadowColor"));
                    materialEditor.ShaderProperty(prop_TriBandShallowColor, languages.speak("prop_TriBandShallowColor"));
                    materialEditor.ShaderProperty(prop_TriBandLitColor, languages.speak("prop_TriBandLitColor"));
                    materialEditor.ShaderProperty(prop_TriBandPostShadowTint, languages.speak("prop_TriBandPostShadowTint"));
                    materialEditor.ShaderProperty(prop_TriBandPostShallowTint, languages.speak("prop_TriBandPostShallowTint"));
                    materialEditor.ShaderProperty(prop_TriBandPostLitTint, languages.speak("prop_TriBandPostLitTint"));
                    materialEditor.ShaderProperty(prop_TriBandAttenuatedShadows, languages.speak("prop_TriBandAttenuatedShadows"));
                    materialEditor.ShaderProperty(prop_TriBandIndirectShallow, languages.speak("prop_TriBandIndirectShallow"));
                }
                else if (animeMode == 6) // skin
                {
                    materialEditor.ShaderProperty(prop_SkinLUT, languages.speak("prop_SkinLUT"));
                    materialEditor.ShaderProperty(prop_SkinScattering, languages.speak("prop_SkinScattering"));
                    materialEditor.ShaderProperty(prop_SkinShadowColor, languages.speak("prop_SkinShadowColor"));
                }
                else if (animeMode == 7) // wrapped
                {
                    materialEditor.ShaderProperty(prop_WrapFactor, languages.speak("prop_WrapFactor"));
                    materialEditor.ShaderProperty(prop_WrapNormalization, languages.speak("prop_WrapNormalization"));
                    materialEditor.ShaderProperty(prop_WrapColorHigh, languages.speak("prop_WrapColorHigh"));
                    materialEditor.ShaderProperty(prop_WrapColorLow, languages.speak("prop_WrapColorLow"));
                }
                Components.end_foldout();
            });
            // anime tab
            tab_anime.process(() => {
                Components.start_foldout();
                prop_ToggleAnimeExtras = TrackProperty("_ToggleAnimeExtras", properties);
                materialEditor.ShaderProperty(prop_ToggleAnimeExtras, languages.speak("prop_ToggleAnimeExtras"));
                Components.start_dynamic_disable(!prop_ToggleAnimeExtras.floatValue.Equals(1), configs);
                sub_tab_ambient_gradient.process(() => {
                    prop_ToggleAmbientGradient = TrackProperty("_ToggleAmbientGradient", properties);
                    prop_AnimeOcclusionToShadow = TrackProperty("_AnimeOcclusionToShadow", properties);
                    prop_AmbientUp = TrackProperty("_AmbientUp", properties);
                    prop_AmbientSkyThreshold = TrackProperty("_AmbientSkyThreshold", properties);
                    prop_AmbientDown = TrackProperty("_AmbientDown", properties);
                    prop_AmbientGroundThreshold = TrackProperty("_AmbientGroundThreshold", properties);
                    prop_AmbientIntensity = TrackProperty("_AmbientIntensity", properties);
                    materialEditor.ShaderProperty(prop_ToggleAmbientGradient, languages.speak("prop_ToggleAmbientGradient"));
                    Components.start_dynamic_disable(!prop_ToggleAmbientGradient.floatValue.Equals(1), configs);
                    materialEditor.ShaderProperty(prop_AmbientIntensity, languages.speak("prop_AmbientIntensity"));
                    materialEditor.ShaderProperty(prop_AnimeOcclusionToShadow, languages.speak("prop_AnimeOcclusionToShadow"));
                    materialEditor.ShaderProperty(prop_AmbientUp, languages.speak("prop_AmbientUp"));
                    materialEditor.ShaderProperty(prop_AmbientSkyThreshold, languages.speak("prop_AmbientSkyThreshold"));
                    materialEditor.ShaderProperty(prop_AmbientDown, languages.speak("prop_AmbientDown"));
                    materialEditor.ShaderProperty(prop_AmbientGroundThreshold, languages.speak("prop_AmbientGroundThreshold"));
                    Components.end_dynamic_disable(!prop_ToggleAmbientGradient.floatValue.Equals(1), configs);
                });
                sub_tab_manual_normals.process(() => {
                    prop_ToggleManualNormals = TrackProperty("_ToggleManualNormals", properties);
                    prop_ManualNormalPreview = TrackProperty("_ManualNormalPreview", properties);
                    prop_ManualNormalOffset = TrackProperty("_ManualNormalOffset", properties);
                    prop_ManualNormalScale = TrackProperty("_ManualNormalScale", properties);
                    prop_ManualApplication = TrackProperty("_ManualApplication", properties);
                    prop_ManualNormalSharpness = TrackProperty("_ManualNormalSharpness", properties);
                    materialEditor.ShaderProperty(prop_ToggleManualNormals, languages.speak("prop_ToggleManualNormals"));
                    Components.start_dynamic_disable(!prop_ToggleManualNormals.floatValue.Equals(1), configs);
                    materialEditor.ShaderProperty(prop_ManualNormalPreview, languages.speak("prop_ManualNormalPreview"));
                    Components.Vector3Property(materialEditor, prop_ManualNormalOffset, languages.speak("prop_ManualNormalOffset"));
                    Components.Vector3Property(materialEditor, prop_ManualNormalScale, languages.speak("prop_ManualNormalScale"));
                    Components.Vector3Property(materialEditor, prop_ManualApplication, languages.speak("prop_ManualApplication"));
                    materialEditor.ShaderProperty(prop_ManualNormalSharpness, languages.speak("prop_ManualNormalSharpness"));
                    Components.end_dynamic_disable(!prop_ToggleManualNormals.floatValue.Equals(1), configs);
                });
                sub_tab_sdf_shadow.process(() => {
                    prop_ToggleSDFShadow = TrackProperty("_ToggleSDFShadow", properties);
                    prop_SDFMode = TrackProperty("_SDFMode", properties);
                    prop_SDFLocalForward = TrackProperty("_SDFLocalForward", properties);
                    prop_SDFLocalRight = TrackProperty("_SDFLocalRight", properties);
                    prop_SDFShadowTexture = TrackProperty("_SDFShadowTexture", properties);
                    prop_SDFShadowThreshold = TrackProperty("_SDFShadowThreshold", properties);
                    prop_SDFShadowSoftness = TrackProperty("_SDFShadowSoftness", properties);
                    prop_SDFShadowSoftnessLow = TrackProperty("_SDFShadowSoftnessLow", properties);
                    materialEditor.ShaderProperty(prop_ToggleSDFShadow, languages.speak("prop_ToggleSDFShadow"));
                    Components.start_dynamic_disable(!prop_ToggleSDFShadow.floatValue.Equals(1), configs);
                    materialEditor.ShaderProperty(prop_SDFMode, languages.speak("prop_SDFMode"));
                    Components.Vector3Property(materialEditor, prop_SDFLocalForward, languages.speak("prop_SDFLocalForward"));
                    Components.Vector3Property(materialEditor, prop_SDFLocalRight, languages.speak("prop_SDFLocalRight"));
                    materialEditor.ShaderProperty(prop_SDFShadowTexture, languages.speak("prop_SDFShadowTexture"));
                    materialEditor.ShaderProperty(prop_SDFShadowThreshold, languages.speak("prop_SDFShadowThreshold"));
                    materialEditor.ShaderProperty(prop_SDFShadowSoftness, languages.speak("prop_SDFShadowSoftness"));
                    materialEditor.ShaderProperty(prop_SDFShadowSoftnessLow, languages.speak("prop_SDFShadowSoftnessLow"));
                    Components.end_dynamic_disable(!prop_ToggleSDFShadow.floatValue.Equals(1), configs);
                });
                sub_tab_stocking.process(() => {
                    prop_ToggleStockings = TrackProperty("_ToggleStockings", properties);
                    prop_StockingsMap = TrackProperty("_StockingsMap", properties);
                    prop_StockingsPower = TrackProperty("_StockingsPower", properties);
                    prop_StockingsDarkWidth = TrackProperty("_StockingsDarkWidth", properties);
                    prop_StockingsLightedWidth = TrackProperty("_StockingsLightedWidth", properties);
                    prop_StockingsLightedIntensity = TrackProperty("_StockingsLightedIntensity", properties);
                    prop_StockingsRoughness = TrackProperty("_StockingsRoughness", properties);
                    prop_StockingsColor = TrackProperty("_StockingsColor", properties);
                    prop_StockingsColorDark = TrackProperty("_StockingsColorDark", properties);
                    materialEditor.ShaderProperty(prop_ToggleStockings, languages.speak("prop_ToggleStockings"));
                    Components.start_dynamic_disable(!prop_ToggleStockings.floatValue.Equals(1), configs);
                    materialEditor.ShaderProperty(prop_StockingsMap, languages.speak("prop_StockingsMap"));
                    materialEditor.ShaderProperty(prop_StockingsPower, languages.speak("prop_StockingsPower"));
                    materialEditor.ShaderProperty(prop_StockingsRoughness, languages.speak("prop_StockingsRoughness"));
                    materialEditor.ShaderProperty(prop_StockingsLightedWidth, languages.speak("prop_StockingsLightedWidth"));
                    materialEditor.ShaderProperty(prop_StockingsLightedIntensity, languages.speak("prop_StockingsLightedIntensity"));
                    materialEditor.ShaderProperty(prop_StockingsDarkWidth, languages.speak("prop_StockingsDarkWidth"));
                    materialEditor.ShaderProperty(prop_StockingsColor, languages.speak("prop_StockingsColor"));
                    materialEditor.ShaderProperty(prop_StockingsColorDark, languages.speak("prop_StockingsColorDark"));
                    Components.end_dynamic_disable(!prop_ToggleStockings.floatValue.Equals(1), configs);
                });
                sub_tab_eye_parallax.process(() => {
                    prop_ToggleEyeParallax = TrackProperty("_ToggleEyeParallax", properties);
                    prop_EyeParallaxIrisTex = TrackProperty("_EyeParallaxIrisTex", properties);
                    prop_EyeParallaxEyeMaskTex = TrackProperty("_EyeParallaxEyeMaskTex", properties);
                    prop_EyeParallaxStrength = TrackProperty("_EyeParallaxStrength", properties);
                    prop_EyeParallaxClamp = TrackProperty("_EyeParallaxClamp", properties);
                    prop_ToggleEyeParallaxBreathing = TrackProperty("_ToggleEyeParallaxBreathing", properties);
                    prop_EyeParallaxBreathStrength = TrackProperty("_EyeParallaxBreathStrength", properties);
                    prop_EyeParallaxBreathSpeed = TrackProperty("_EyeParallaxBreathSpeed", properties);
                    materialEditor.ShaderProperty(prop_ToggleEyeParallax, languages.speak("prop_ToggleEyeParallax"));
                    Components.start_dynamic_disable(!prop_ToggleEyeParallax.floatValue.Equals(1), configs);
                    materialEditor.ShaderProperty(prop_EyeParallaxIrisTex, languages.speak("prop_EyeParallaxIrisTex"));
                    materialEditor.ShaderProperty(prop_EyeParallaxEyeMaskTex, languages.speak("prop_EyeParallaxEyeMaskTex"));
                    materialEditor.ShaderProperty(prop_EyeParallaxStrength, languages.speak("prop_EyeParallaxStrength"));
                    materialEditor.ShaderProperty(prop_EyeParallaxClamp, languages.speak("prop_EyeParallaxClamp"));
                    materialEditor.ShaderProperty(prop_ToggleEyeParallaxBreathing, languages.speak("prop_ToggleEyeParallaxBreathing"));
                    Components.start_dynamic_disable(!prop_ToggleEyeParallaxBreathing.floatValue.Equals(1), configs);
                    EditorGUI.indentLevel++;
                    materialEditor.ShaderProperty(prop_EyeParallaxBreathStrength, languages.speak("prop_EyeParallaxBreathStrength"));
                    materialEditor.ShaderProperty(prop_EyeParallaxBreathSpeed, languages.speak("prop_EyeParallaxBreathSpeed"));
                    EditorGUI.indentLevel--;
                    Components.end_dynamic_disable(!prop_ToggleEyeParallaxBreathing.floatValue.Equals(1), configs);
                    Components.end_dynamic_disable(!prop_ToggleEyeParallax.floatValue.Equals(1), configs);
                });
                sub_tab_translucent_hair.process(() => {
                    prop_ToggleHairTransparency = TrackProperty("_ToggleHairTransparency", properties);
                    prop_HairHeadForward = TrackProperty("_HairHeadForward", properties);
                    prop_HairHeadUp = TrackProperty("_HairHeadUp", properties);
                    prop_HairHeadRight = TrackProperty("_HairHeadRight", properties);
                    prop_HairBlendAlpha = TrackProperty("_HairBlendAlpha", properties);
                    prop_HairTransparencyStrength = TrackProperty("_HairTransparencyStrength", properties);
                    prop_HairHeadMaskMode = TrackProperty("_HairHeadMaskMode", properties);
                    prop_HairSDFPreview = TrackProperty("_HairSDFPreview", properties);
                    prop_HairHeadCenter = TrackProperty("_HairHeadCenter", properties);
                    prop_HairSDFScale = TrackProperty("_HairSDFScale", properties);
                    prop_HairSDFSoftness = TrackProperty("_HairSDFSoftness", properties);
                    prop_HairSDFBlend = TrackProperty("_HairSDFBlend", properties);
                    prop_HairDistanceFalloffStart = TrackProperty("_HairDistanceFalloffStart", properties);
                    prop_HairDistanceFalloffEnd = TrackProperty("_HairDistanceFalloffEnd", properties);
                    prop_HairDistanceFalloffStrength = TrackProperty("_HairDistanceFalloffStrength", properties);
                    prop_HairMaskTex = TrackProperty("_HairMaskTex", properties);
                    prop_HairMaskStrength = TrackProperty("_HairMaskStrength", properties);
                    prop_HairExtremeAngleGuard = TrackProperty("_HairExtremeAngleGuard", properties);
                    prop_HairAngleFadeStart = TrackProperty("_HairAngleFadeStart", properties);
                    prop_HairAngleFadeEnd = TrackProperty("_HairAngleFadeEnd", properties);
                    prop_HairAngleGuardStrength = TrackProperty("_HairAngleGuardStrength", properties);
                    materialEditor.ShaderProperty(prop_ToggleHairTransparency, languages.speak("prop_ToggleHairTransparency"));
                    Components.start_dynamic_disable(!prop_ToggleHairTransparency.floatValue.Equals(1), configs);
                    Components.Vector3Property(materialEditor, prop_HairHeadForward, languages.speak("prop_HairHeadForward"));
                    Components.Vector3Property(materialEditor, prop_HairHeadUp, languages.speak("prop_HairHeadUp"));
                    Components.Vector3Property(materialEditor, prop_HairHeadRight, languages.speak("prop_HairHeadRight"));
                    materialEditor.ShaderProperty(prop_HairBlendAlpha, languages.speak("prop_HairBlendAlpha"));
                    materialEditor.ShaderProperty(prop_HairTransparencyStrength, languages.speak("prop_HairTransparencyStrength"));
                    materialEditor.ShaderProperty(prop_HairHeadMaskMode, languages.speak("prop_HairHeadMaskMode"));
                    EditorGUI.indentLevel++;
                    int maskMode = (int)prop_HairHeadMaskMode.floatValue;
                    if (maskMode == 1) // sdf volume
                    {
                        materialEditor.ShaderProperty(prop_HairSDFPreview, languages.speak("prop_HairSDFPreview"));
                        Components.Vector3Property(materialEditor, prop_HairHeadCenter, languages.speak("prop_HairHeadCenter"));
                        Components.Vector3Property(materialEditor, prop_HairSDFScale, languages.speak("prop_HairSDFScale"));
                        materialEditor.ShaderProperty(prop_HairSDFSoftness, languages.speak("prop_HairSDFSoftness"));
                        materialEditor.ShaderProperty(prop_HairSDFBlend, languages.speak("prop_HairSDFBlend"));
                    }
                    else if (maskMode == 2) // distance
                    {
                        materialEditor.ShaderProperty(prop_HairDistanceFalloffStart, languages.speak("prop_HairDistanceFalloffStart"));
                        materialEditor.ShaderProperty(prop_HairDistanceFalloffEnd, languages.speak("prop_HairDistanceFalloffEnd"));
                        materialEditor.ShaderProperty(prop_HairDistanceFalloffStrength, languages.speak("prop_HairDistanceFalloffStrength"));
                    }
                    else if (maskMode == 3) // texture masking
                    {
                        materialEditor.ShaderProperty(prop_HairMaskTex, languages.speak("prop_HairMaskTex"));
                        materialEditor.ShaderProperty(prop_HairMaskStrength, languages.speak("prop_HairMaskStrength"));
                    }
                    EditorGUI.indentLevel--;
                    materialEditor.ShaderProperty(prop_HairExtremeAngleGuard, languages.speak("prop_HairExtremeAngleGuard"));
                    Components.start_dynamic_disable(!prop_HairExtremeAngleGuard.floatValue.Equals(1), configs);
                    EditorGUI.indentLevel++;
                    materialEditor.ShaderProperty(prop_HairAngleFadeStart, languages.speak("prop_HairAngleFadeStart"));
                    materialEditor.ShaderProperty(prop_HairAngleFadeEnd, languages.speak("prop_HairAngleFadeEnd"));
                    materialEditor.ShaderProperty(prop_HairAngleGuardStrength, languages.speak("prop_HairAngleGuardStrength"));
                    EditorGUI.indentLevel--;
                    Components.end_dynamic_disable(!prop_HairExtremeAngleGuard.floatValue.Equals(1), configs);
                    Components.end_dynamic_disable(!prop_ToggleHairTransparency.floatValue.Equals(1), configs);
                });
                sub_tab_expression_map.process(() => {
                    prop_ToggleExpressionMap = TrackProperty("_ToggleExpressionMap", properties);
                    prop_ExpressionMap = TrackProperty("_ExpressionMap", properties);
                    prop_ExCheekColor = TrackProperty("_ExCheekColor", properties);
                    prop_ExCheekIntensity = TrackProperty("_ExCheekIntensity", properties);
                    prop_ExShyColor = TrackProperty("_ExShyColor", properties);
                    prop_ExShyIntensity = TrackProperty("_ExShyIntensity", properties);
                    prop_ExShadowColor = TrackProperty("_ExShadowColor", properties);
                    prop_ExShadowIntensity = TrackProperty("_ExShadowIntensity", properties);
                    materialEditor.ShaderProperty(prop_ToggleExpressionMap, languages.speak("prop_ToggleExpressionMap"));
                    Components.start_dynamic_disable(!prop_ToggleExpressionMap.floatValue.Equals(1), configs);
                    materialEditor.ShaderProperty(prop_ExpressionMap, languages.speak("prop_ExpressionMap"));
                    materialEditor.ShaderProperty(prop_ExCheekIntensity, languages.speak("prop_ExCheekIntensity"));
                    EditorGUI.indentLevel++;
                    materialEditor.ShaderProperty(prop_ExCheekColor, languages.speak("prop_ExCheekColor"));
                    EditorGUI.indentLevel--;
                    materialEditor.ShaderProperty(prop_ExShyIntensity, languages.speak("prop_ExShyIntensity"));
                    EditorGUI.indentLevel++;
                    materialEditor.ShaderProperty(prop_ExShyColor, languages.speak("prop_ExShyColor"));
                    EditorGUI.indentLevel--;
                    materialEditor.ShaderProperty(prop_ExShadowIntensity, languages.speak("prop_ExShadowIntensity"));
                    EditorGUI.indentLevel++;
                    materialEditor.ShaderProperty(prop_ExShadowColor, languages.speak("prop_ExShadowColor"));
                    EditorGUI.indentLevel--;
                    Components.end_dynamic_disable(!prop_ToggleExpressionMap.floatValue.Equals(1), configs);
                });
                sub_tab_face_map.process(() => {
                    prop_ToggleFaceMap = TrackProperty("_ToggleFaceMap", properties);
                    prop_FaceHeadForward = TrackProperty("_FaceHeadForward", properties);
                    prop_FaceMap = TrackProperty("_FaceMap", properties);
                    prop_ToggleNoseLine = TrackProperty("_ToggleNoseLine", properties);
                    prop_NoseLinePower = TrackProperty("_NoseLinePower", properties);
                    prop_NoseLineColor = TrackProperty("_NoseLineColor", properties);
                    prop_ToggleEyeShadow = TrackProperty("_ToggleEyeShadow", properties);
                    prop_ExEyeColor = TrackProperty("_ExEyeColor", properties);
                    prop_EyeShadowIntensity = TrackProperty("_EyeShadowIntensity", properties);
                    prop_ToggleLipOutline = TrackProperty("_ToggleLipOutline", properties);
                    prop_LipOutlineColor = TrackProperty("_LipOutlineColor", properties);
                    prop_LipOutlineIntensity = TrackProperty("_LipOutlineIntensity", properties);
                    materialEditor.ShaderProperty(prop_ToggleFaceMap, languages.speak("prop_ToggleFaceMap"));
                    Components.start_dynamic_disable(!prop_ToggleFaceMap.floatValue.Equals(1), configs);
                    Components.Vector3Property(materialEditor, prop_FaceHeadForward, languages.speak("prop_FaceHeadForward"));
                    materialEditor.ShaderProperty(prop_FaceMap, languages.speak("prop_FaceMap"));
                    materialEditor.ShaderProperty(prop_ToggleNoseLine, languages.speak("prop_ToggleNoseLine"));
                    Components.start_dynamic_disable(!prop_ToggleNoseLine.floatValue.Equals(1), configs);
                    EditorGUI.indentLevel++;
                    materialEditor.ShaderProperty(prop_NoseLinePower, languages.speak("prop_NoseLinePower"));
                    materialEditor.ShaderProperty(prop_NoseLineColor, languages.speak("prop_NoseLineColor"));
                    EditorGUI.indentLevel--;
                    Components.end_dynamic_disable(!prop_ToggleNoseLine.floatValue.Equals(1), configs);
                    materialEditor.ShaderProperty(prop_ToggleEyeShadow, languages.speak("prop_ToggleEyeShadow"));
                    Components.start_dynamic_disable(!prop_ToggleEyeShadow.floatValue.Equals(1), configs);
                    EditorGUI.indentLevel++;
                    materialEditor.ShaderProperty(prop_ExEyeColor, languages.speak("prop_ExEyeColor"));
                    materialEditor.ShaderProperty(prop_EyeShadowIntensity, languages.speak("prop_EyeShadowIntensity"));
                    EditorGUI.indentLevel--;
                    Components.end_dynamic_disable(!prop_ToggleEyeShadow.floatValue.Equals(1), configs);
                    materialEditor.ShaderProperty(prop_ToggleLipOutline, languages.speak("prop_ToggleLipOutline"));
                    Components.start_dynamic_disable(!prop_ToggleLipOutline.floatValue.Equals(1), configs);
                    EditorGUI.indentLevel++;
                    materialEditor.ShaderProperty(prop_LipOutlineColor, languages.speak("prop_LipOutlineColor"));
                    materialEditor.ShaderProperty(prop_LipOutlineIntensity, languages.speak("prop_LipOutlineIntensity"));
                    EditorGUI.indentLevel--;
                    Components.end_dynamic_disable(!prop_ToggleLipOutline.floatValue.Equals(1), configs);
                    Components.end_dynamic_disable(!prop_ToggleFaceMap.floatValue.Equals(1), configs);
                });
                sub_tab_gradient.process(() => {
                    prop_ToggleAnimeGradient = TrackProperty("_ToggleAnimeGradient", properties);
                    prop_AnimeGradientMode = TrackProperty("_AnimeGradientMode", properties);
                    prop_AnimeGradientDirection = TrackProperty("_AnimeGradientDirection", properties);
                    prop_AnimeGradientColourA = TrackProperty("_AnimeGradientColourA", properties);
                    prop_AnimeGradientColourB = TrackProperty("_AnimeGradientColourB", properties);
                    prop_AnimeGradientOffset = TrackProperty("_AnimeGradientOffset", properties);
                    prop_AnimeGradientMultiplier = TrackProperty("_AnimeGradientMultiplier", properties);
                    materialEditor.ShaderProperty(prop_ToggleAnimeGradient, languages.speak("prop_ToggleAnimeGradient"));
                    Components.start_dynamic_disable(!prop_ToggleAnimeGradient.floatValue.Equals(1), configs);
                    materialEditor.ShaderProperty(prop_AnimeGradientMode, languages.speak("prop_AnimeGradientMode"));
                    Components.Vector3Property(materialEditor, prop_AnimeGradientDirection, languages.speak("prop_AnimeGradientDirection"));
                    materialEditor.ShaderProperty(prop_AnimeGradientOffset, languages.speak("prop_AnimeGradientOffset"));
                    materialEditor.ShaderProperty(prop_AnimeGradientMultiplier, languages.speak("prop_AnimeGradientMultiplier"));
                    materialEditor.ShaderProperty(prop_AnimeGradientColourA, languages.speak("prop_AnimeGradientColourA"));
                    materialEditor.ShaderProperty(prop_AnimeGradientColourB, languages.speak("prop_AnimeGradientColourB"));
                    Components.end_dynamic_disable(!prop_ToggleAnimeGradient.floatValue.Equals(1), configs);
                });
                sub_tab_toon_highlights.process(() => {
                    prop_ToggleSpecularToon = TrackProperty("_ToggleSpecularToon", properties);
                    prop_SpecularToonShininess = TrackProperty("_SpecularToonShininess", properties);
                    prop_SpecularToonRoughness = TrackProperty("_SpecularToonRoughness", properties);
                    prop_SpecularToonSharpness = TrackProperty("_SpecularToonSharpness", properties);
                    prop_SpecularToonIntensity = TrackProperty("_SpecularToonIntensity", properties);
                    prop_SpecularToonThreshold = TrackProperty("_SpecularToonThreshold", properties);
                    prop_SpecularToonColor = TrackProperty("_SpecularToonColor", properties);
                    prop_SpecularToonUseLighting = TrackProperty("_SpecularToonUseLighting", properties);
                    materialEditor.ShaderProperty(prop_ToggleSpecularToon, languages.speak("prop_ToggleSpecularToon"));
                    Components.start_dynamic_disable(!prop_ToggleSpecularToon.floatValue.Equals(1), configs);
                    materialEditor.ShaderProperty(prop_SpecularToonUseLighting, languages.speak("prop_SpecularToonUseLighting"));
                    materialEditor.ShaderProperty(prop_SpecularToonShininess, languages.speak("prop_SpecularToonShininess"));
                    materialEditor.ShaderProperty(prop_SpecularToonRoughness, languages.speak("prop_SpecularToonRoughness"));
                    materialEditor.ShaderProperty(prop_SpecularToonSharpness, languages.speak("prop_SpecularToonSharpness"));
                    materialEditor.ShaderProperty(prop_SpecularToonIntensity, languages.speak("prop_SpecularToonIntensity"));
                    materialEditor.ShaderProperty(prop_SpecularToonThreshold, languages.speak("prop_SpecularToonThreshold"));
                    materialEditor.ShaderProperty(prop_SpecularToonColor, languages.speak("prop_SpecularToonColor"));
                    Components.end_dynamic_disable(!prop_ToggleSpecularToon.floatValue.Equals(1), configs);
                });
                sub_tab_angel_rings.process(() => {
                    prop_AngelRingMode = TrackProperty("_AngelRingMode", properties);
                    prop_AngelRingSharpness = TrackProperty("_AngelRingSharpness", properties);
                    prop_AngelRingThreshold = TrackProperty("_AngelRingThreshold", properties);
                    prop_AngelRingSoftness = TrackProperty("_AngelRingSoftness", properties);
                    prop_AngelRing1Position = TrackProperty("_AngelRing1Position", properties);
                    prop_AngelRing1Width = TrackProperty("_AngelRing1Width", properties);
                    prop_AngelRing1Color = TrackProperty("_AngelRing1Color", properties);
                    prop_UseSecondaryRing = TrackProperty("_UseSecondaryRing", properties);
                    prop_AngelRing2Position = TrackProperty("_AngelRing2Position", properties);
                    prop_AngelRing2Width = TrackProperty("_AngelRing2Width", properties);
                    prop_AngelRing2Color = TrackProperty("_AngelRing2Color", properties);
                    prop_UseTertiaryRing = TrackProperty("_UseTertiaryRing", properties);
                    prop_AngelRing3Position = TrackProperty("_AngelRing3Position", properties);
                    prop_AngelRing3Width = TrackProperty("_AngelRing3Width", properties);
                    prop_AngelRing3Color = TrackProperty("_AngelRing3Color", properties);
                    prop_AngelRingHeightDirection = TrackProperty("_AngelRingHeightDirection", properties);
                    prop_AngelRingHeightScale = TrackProperty("_AngelRingHeightScale", properties);
                    prop_AngelRingHeightOffset = TrackProperty("_AngelRingHeightOffset", properties);
                    prop_AngelRingBlendMode = TrackProperty("_AngelRingBlendMode", properties);
                    prop_AngelRingManualOffset = TrackProperty("_AngelRingManualOffset", properties);
                    prop_AngelRingManualScale = TrackProperty("_AngelRingManualScale", properties);
                    prop_AngelRingBreakup = TrackProperty("_AngelRingBreakup", properties);
                    prop_AngelRingBreakupDensity = TrackProperty("_AngelRingBreakupDensity", properties);
                    prop_AngelRingBreakupWidthMin = TrackProperty("_AngelRingBreakupWidthMin", properties);
                    prop_AngelRingBreakupWidthMax = TrackProperty("_AngelRingBreakupWidthMax", properties);
                    prop_AngelRingBreakupSoftness = TrackProperty("_AngelRingBreakupSoftness", properties);
                    prop_AngelRingBreakupHeight = TrackProperty("_AngelRingBreakupHeight", properties);
                    prop_AngelRingUseLighting = TrackProperty("_AngelRingUseLighting", properties);
                    materialEditor.ShaderProperty(prop_AngelRingMode, languages.speak("prop_AngelRingMode"));
                    Components.start_dynamic_disable(prop_AngelRingMode.floatValue == 0, configs);
                    materialEditor.ShaderProperty(prop_AngelRingBlendMode, languages.speak("prop_AngelRingBlendMode"));
                    materialEditor.ShaderProperty(prop_AngelRingSharpness, languages.speak("prop_AngelRingSharpness"));
                    materialEditor.ShaderProperty(prop_AngelRingThreshold, languages.speak("prop_AngelRingThreshold"));
                    materialEditor.ShaderProperty(prop_AngelRingSoftness, languages.speak("prop_AngelRingSoftness"));
                    Components.Vector3Property(materialEditor, prop_AngelRingHeightDirection, languages.speak("prop_AngelRingHeightDirection"));
                    materialEditor.ShaderProperty(prop_AngelRingHeightScale, languages.speak("prop_AngelRingHeightScale"));
                    materialEditor.ShaderProperty(prop_AngelRingHeightOffset, languages.speak("prop_AngelRingHeightOffset"));
                    materialEditor.ShaderProperty(prop_AngelRingManualOffset, languages.speak("prop_AngelRingManualOffset"));
                    materialEditor.ShaderProperty(prop_AngelRingManualScale, languages.speak("prop_AngelRingManualScale"));
                    EditorGUILayout.LabelField(languages.speak("header_angel_ring_one"), EditorStyles.boldLabel);
                    EditorGUI.indentLevel++;
                    materialEditor.ShaderProperty(prop_AngelRing1Position, languages.speak("prop_AngelRing1Position"));
                    materialEditor.ShaderProperty(prop_AngelRing1Width, languages.speak("prop_AngelRing1Width"));
                    materialEditor.ShaderProperty(prop_AngelRing1Color, languages.speak("prop_AngelRing1Color"));
                    EditorGUI.indentLevel--;
                    EditorGUILayout.LabelField(languages.speak("header_angel_ring_two"), EditorStyles.boldLabel);
                    EditorGUI.indentLevel++;
                    materialEditor.ShaderProperty(prop_UseSecondaryRing, languages.speak("prop_UseSecondaryRing"));
                    Components.start_dynamic_disable(!prop_UseSecondaryRing.floatValue.Equals(1), configs);
                    materialEditor.ShaderProperty(prop_AngelRing2Position, languages.speak("prop_AngelRing2Position"));
                    materialEditor.ShaderProperty(prop_AngelRing2Width, languages.speak("prop_AngelRing2Width"));
                    materialEditor.ShaderProperty(prop_AngelRing2Color, languages.speak("prop_AngelRing2Color"));
                    Components.end_dynamic_disable(!prop_UseSecondaryRing.floatValue.Equals(1), configs);
                    EditorGUI.indentLevel--;
                    EditorGUILayout.LabelField(languages.speak("header_angel_ring_three"), EditorStyles.boldLabel);
                    EditorGUI.indentLevel++;
                    materialEditor.ShaderProperty(prop_UseTertiaryRing, languages.speak("prop_UseTertiaryRing"));
                    Components.start_dynamic_disable(!prop_UseTertiaryRing.floatValue.Equals(1), configs);
                    materialEditor.ShaderProperty(prop_AngelRing3Position, languages.speak("prop_AngelRing3Position"));
                    materialEditor.ShaderProperty(prop_AngelRing3Width, languages.speak("prop_AngelRing3Width"));
                    materialEditor.ShaderProperty(prop_AngelRing3Color, languages.speak("prop_AngelRing3Color"));
                    Components.end_dynamic_disable(!prop_UseTertiaryRing.floatValue.Equals(1), configs);
                    EditorGUI.indentLevel--;
                    EditorGUILayout.LabelField(languages.speak("header_angel_ring_breakup"), EditorStyles.boldLabel);
                    EditorGUI.indentLevel++;
                    Components.start_dynamic_disable(prop_AngelRingBreakup.floatValue == 0, configs);
                    materialEditor.ShaderProperty(prop_AngelRingBreakup, languages.speak("prop_AngelRingBreakup"));
                    materialEditor.ShaderProperty(prop_AngelRingBreakupDensity, languages.speak("prop_AngelRingBreakupDensity"));
                    materialEditor.ShaderProperty(prop_AngelRingBreakupWidthMin, languages.speak("prop_AngelRingBreakupWidthMin"));
                    materialEditor.ShaderProperty(prop_AngelRingBreakupWidthMax, languages.speak("prop_AngelRingBreakupWidthMax"));
                    materialEditor.ShaderProperty(prop_AngelRingBreakupSoftness, languages.speak("prop_AngelRingBreakupSoftness"));
                    materialEditor.ShaderProperty(prop_AngelRingBreakupHeight, languages.speak("prop_AngelRingBreakupHeight"));
                    Components.end_dynamic_disable(prop_AngelRingBreakup.floatValue == 0, configs);
                    EditorGUI.indentLevel--;
                    materialEditor.ShaderProperty(prop_AngelRingUseLighting, languages.speak("prop_AngelRingUseLighting"));
                    Components.end_dynamic_disable(prop_AngelRingMode.floatValue == 0, configs);
                });
                Components.end_dynamic_disable(!prop_ToggleAnimeExtras.floatValue.Equals(1), configs);
                Components.end_foldout();
            });
            // specular tab
            tab_specular.process(() => {
                Components.start_foldout();
                prop_ToggleSpecular = TrackProperty("_ToggleSpecular", properties);
                prop_ToggleVertexSpecular = TrackProperty("_ToggleVertexSpecular", properties);
                prop_SpecularMode = TrackProperty("_SpecularMode", properties);
                prop_SpecularEnergyMode = TrackProperty("_SpecularEnergyMode", properties);
                prop_SpecularEnergyMin = TrackProperty("_SpecularEnergyMin", properties);
                prop_SpecularEnergyMax = TrackProperty("_SpecularEnergyMax", properties);
                prop_SpecularEnergy = TrackProperty("_SpecularEnergy", properties);
                prop_MSSO = TrackProperty("_MSSO", properties);
                prop_Metallic = TrackProperty("_Metallic", properties);
                prop_Glossiness = TrackProperty("_Glossiness", properties);
                prop_Occlusion = TrackProperty("_Occlusion", properties);
                prop_SpecularIntensity = TrackProperty("_SpecularIntensity", properties);
                prop_Specular = TrackProperty("_Specular", properties);
                prop_SpecularTintTexture = TrackProperty("_SpecularTintTexture", properties);
                prop_SpecularTint = TrackProperty("_SpecularTint", properties);
                prop_ReplaceSpecular = TrackProperty("_ReplaceSpecular", properties);
                prop_PreserveShadows = TrackProperty("_PreserveShadows", properties);
                prop_TangentMap = TrackProperty("_TangentMap", properties);
                prop_Anisotropy = TrackProperty("_Anisotropy", properties);
                materialEditor.ShaderProperty(prop_ToggleSpecular, languages.speak("prop_ToggleSpecular"));
                Components.start_dynamic_disable(!prop_ToggleSpecular.floatValue.Equals(1), configs);
                materialEditor.ShaderProperty(prop_ToggleVertexSpecular, languages.speak("prop_ToggleVertexSpecular"));
                materialEditor.ShaderProperty(prop_SpecularMode, languages.speak("prop_SpecularMode"));
                if (prop_SpecularMode.floatValue != 0) // anistrophic setitngs
                {
                    EditorGUI.indentLevel++;
                    materialEditor.TexturePropertySingleLine(new GUIContent(languages.speak("prop_TangentMap")), prop_TangentMap);
                    materialEditor.ShaderProperty(prop_Anisotropy, languages.speak("prop_Anisotropy"));
                    EditorGUI.indentLevel--;
                }
                materialEditor.ShaderProperty(prop_SpecularEnergyMode, languages.speak("prop_SpecularEnergyMode"));
                EditorGUI.indentLevel++;
                materialEditor.ShaderProperty(prop_SpecularEnergyMin, languages.speak("prop_SpecularEnergyMin"));
                materialEditor.ShaderProperty(prop_SpecularEnergyMax, languages.speak("prop_SpecularEnergyMax"));
                if (prop_SpecularEnergyMode.floatValue == 3)
                {
                    materialEditor.ShaderProperty(prop_SpecularEnergy, languages.speak("prop_SpecularEnergy"));
                }
                EditorGUI.indentLevel--;
                materialEditor.ShaderProperty(prop_MSSO, languages.speak("prop_MSSO"));
                materialEditor.ShaderProperty(prop_Metallic, languages.speak("prop_Metallic"));
                materialEditor.ShaderProperty(prop_Glossiness, languages.speak("prop_Glossiness"));
                materialEditor.ShaderProperty(prop_Occlusion, languages.speak("prop_Occlusion"));
                materialEditor.ShaderProperty(prop_SpecularIntensity, languages.speak("prop_SpecularIntensity"));
                materialEditor.ShaderProperty(prop_Specular, languages.speak("prop_Specular"));
                materialEditor.TexturePropertySingleLine(new GUIContent(languages.speak("prop_SpecularTintTexture")), prop_SpecularTintTexture);
                materialEditor.ShaderProperty(prop_SpecularTint, languages.speak("prop_SpecularTint"));
                materialEditor.ShaderProperty(prop_ReplaceSpecular, languages.speak("prop_ReplaceSpecular"));
                materialEditor.ShaderProperty(prop_PreserveShadows, languages.speak("prop_PreserveShadows"));
                Components.end_dynamic_disable(!prop_ToggleSpecular.floatValue.Equals(1), configs);
                Components.end_foldout();
            });
            // stylise tab
            tab_stylise.process(() => {
                Components.start_foldout();
                sub_tab_rim_lighting.process(() => {
                    prop_RimMode = TrackProperty("_RimMode", properties);
                    prop_RimColor = TrackProperty("_RimColor", properties);
                    prop_RimWidth = TrackProperty("_RimWidth", properties);
                    prop_RimIntensity = TrackProperty("_RimIntensity", properties);
                    prop_RimLightBased = TrackProperty("_RimLightBased", properties);
                    prop_DepthRimColor = TrackProperty("_DepthRimColor", properties);
                    prop_DepthRimWidth = TrackProperty("_DepthRimWidth", properties);
                    prop_DepthRimThreshold = TrackProperty("_DepthRimThreshold", properties);
                    prop_DepthRimSharpness = TrackProperty("_DepthRimSharpness", properties);
                    prop_DepthRimBlendMode = TrackProperty("_DepthRimBlendMode", properties);
                    prop_OffsetRimColor = TrackProperty("_OffsetRimColor", properties);
                    prop_OffsetRimWidth = TrackProperty("_OffsetRimWidth", properties);
                    prop_OffsetRimHardness = TrackProperty("_OffsetRimHardness", properties);
                    prop_OffsetRimLightBased = TrackProperty("_OffsetRimLightBased", properties);
                    prop_OffsetRimBlendMode = TrackProperty("_OffsetRimBlendMode", properties);
                    materialEditor.ShaderProperty(prop_RimMode, languages.speak("prop_RimMode"));
                    int rimMode = (int)prop_RimMode.floatValue;
                    if (rimMode == 1 || rimMode == 0) // fresnel (default to)
                    {
                        Components.start_dynamic_disable(rimMode == 0, configs);
                        materialEditor.ShaderProperty(prop_RimColor, languages.speak("prop_RimColor"));
                        materialEditor.ShaderProperty(prop_RimWidth, languages.speak("prop_RimWidth"));
                        materialEditor.ShaderProperty(prop_RimIntensity, languages.speak("prop_RimIntensity"));
                        materialEditor.ShaderProperty(prop_RimLightBased, languages.speak("prop_RimLightBased"));
                        Components.end_dynamic_disable(rimMode == 0, configs);
                    }
                    else if (rimMode == 2) // depth
                    {
                        materialEditor.ShaderProperty(prop_DepthRimColor, languages.speak("prop_DepthRimColor"));
                        materialEditor.ShaderProperty(prop_DepthRimWidth, languages.speak("prop_DepthRimWidth"));
                        materialEditor.ShaderProperty(prop_DepthRimThreshold, languages.speak("prop_DepthRimThreshold"));
                        materialEditor.ShaderProperty(prop_DepthRimSharpness, languages.speak("prop_DepthRimSharpness"));
                        materialEditor.ShaderProperty(prop_DepthRimBlendMode, languages.speak("prop_DepthRimBlendMode"));
                        GUIStyle wrappedStyle = new GUIStyle(EditorStyles.label);
                        wrappedStyle.wordWrap = true;
                        GUILayout.Label(theme.language_manager.speak("render_queue_notice"), wrappedStyle);
                    }
                    else if (rimMode == 3) // normal
                    {
                        materialEditor.ShaderProperty(prop_OffsetRimColor, languages.speak("prop_OffsetRimColor"));
                        materialEditor.ShaderProperty(prop_OffsetRimWidth, languages.speak("prop_OffsetRimWidth"));
                        materialEditor.ShaderProperty(prop_OffsetRimHardness, languages.speak("prop_OffsetRimHardness"));
                        materialEditor.ShaderProperty(prop_OffsetRimLightBased, languages.speak("prop_OffsetRimLightBased"));
                        materialEditor.ShaderProperty(prop_OffsetRimBlendMode, languages.speak("prop_OffsetRimBlendMode"));
                        GUIStyle wrappedStyle = new GUIStyle(EditorStyles.label);
                        wrappedStyle.wordWrap = true;
                        GUILayout.Label(theme.language_manager.speak("render_queue_notice"), wrappedStyle);
                    }
                });
                sub_tab_clear_coat.process(() => {
                    prop_ToggleClearcoat = TrackProperty("_ToggleClearcoat", properties);
                    prop_ClearcoatStrength = TrackProperty("_ClearcoatStrength", properties);
                    prop_ClearcoatReflectionStrength = TrackProperty("_ClearcoatReflectionStrength", properties);
                    prop_ClearcoatMap = TrackProperty("_ClearcoatMap", properties);
                    prop_ClearcoatRoughness = TrackProperty("_ClearcoatRoughness", properties);
                    prop_ClearcoatColor = TrackProperty("_ClearcoatColor", properties);
                    materialEditor.ShaderProperty(prop_ToggleClearcoat, languages.speak("prop_ToggleClearcoat"));
                    Components.start_dynamic_disable(!prop_ToggleClearcoat.floatValue.Equals(1), configs);
                    materialEditor.ShaderProperty(prop_ClearcoatStrength, languages.speak("prop_ClearcoatStrength"));
                    materialEditor.ShaderProperty(prop_ClearcoatReflectionStrength, languages.speak("prop_ClearcoatReflectionStrength"));
                    materialEditor.ShaderProperty(prop_ClearcoatMap, languages.speak("prop_ClearcoatMap"));
                    materialEditor.ShaderProperty(prop_ClearcoatRoughness, languages.speak("prop_ClearcoatRoughness"));
                    materialEditor.ShaderProperty(prop_ClearcoatColor, languages.speak("prop_ClearcoatColor"));
                    Components.end_dynamic_disable(!prop_ToggleClearcoat.floatValue.Equals(1), configs);
                });
                sub_tab_matcap.process(() => {
                    prop_ToggleMatcap = TrackProperty("_ToggleMatcap", properties);
                    prop_MatcapTex = TrackProperty("_MatcapTex", properties);
                    prop_MatcapTint = TrackProperty("_MatcapTint", properties);
                    prop_MatcapIntensity = TrackProperty("_MatcapIntensity", properties);
                    prop_MatcapBlendMode = TrackProperty("_MatcapBlendMode", properties);
                    prop_MatcapMask = TrackProperty("_MatcapMask", properties);
                    prop_MatcapSmoothnessEnabled = TrackProperty("_MatcapSmoothnessEnabled", properties);
                    prop_MatcapSmoothness = TrackProperty("_MatcapSmoothness", properties);
                    materialEditor.ShaderProperty(prop_ToggleMatcap, languages.speak("prop_ToggleMatcap"));
                    Components.start_dynamic_disable(!prop_ToggleMatcap.floatValue.Equals(1), configs);
                    materialEditor.ShaderProperty(prop_MatcapTex, languages.speak("prop_MatcapTex"));
                    materialEditor.ShaderProperty(prop_MatcapMask, languages.speak("prop_MatcapMask"));
                    materialEditor.ShaderProperty(prop_MatcapIntensity, languages.speak("prop_MatcapIntensity"));
                    materialEditor.ShaderProperty(prop_MatcapTint, languages.speak("prop_MatcapTint"));
                    materialEditor.ShaderProperty(prop_MatcapBlendMode, languages.speak("prop_MatcapBlendMode"));
                    materialEditor.ShaderProperty(prop_MatcapSmoothnessEnabled, languages.speak("prop_MatcapSmoothnessEnabled"));
                    Components.start_dynamic_disable(!prop_MatcapSmoothnessEnabled.floatValue.Equals(1), configs);
                    EditorGUI.indentLevel++;
                    materialEditor.ShaderProperty(prop_MatcapSmoothness, languages.speak("prop_MatcapSmoothness"));
                    EditorGUI.indentLevel--;
                    Components.end_dynamic_disable(!prop_MatcapSmoothnessEnabled.floatValue.Equals(1), configs);
                    Components.end_dynamic_disable(!prop_ToggleMatcap.floatValue.Equals(1), configs);
                });
                sub_tab_cubemap.process(() => {
                    prop_ToggleCubemap = TrackProperty("_ToggleCubemap", properties);
                    prop_CubemapTex = TrackProperty("_CubemapTex", properties);
                    prop_CubemapTint = TrackProperty("_CubemapTint", properties);
                    prop_CubemapIntensity = TrackProperty("_CubemapIntensity", properties);
                    prop_CubemapBlendMode = TrackProperty("_CubemapBlendMode", properties);
                    materialEditor.ShaderProperty(prop_ToggleCubemap, languages.speak("prop_ToggleCubemap"));
                    Components.start_dynamic_disable(!prop_ToggleCubemap.floatValue.Equals(1), configs);
                    materialEditor.ShaderProperty(prop_CubemapTex, languages.speak("prop_CubemapTex"));
                    materialEditor.ShaderProperty(prop_CubemapIntensity, languages.speak("prop_CubemapIntensity"));
                    materialEditor.ShaderProperty(prop_CubemapTint, languages.speak("prop_CubemapTint"));
                    materialEditor.ShaderProperty(prop_CubemapBlendMode, languages.speak("prop_CubemapBlendMode"));
                    Components.end_dynamic_disable(!prop_ToggleCubemap.floatValue.Equals(1), configs);
                });
                sub_tab_parallax.process(() => {
                    prop_ToggleParallax = TrackProperty("_ToggleParallax", properties);
                    prop_ParallaxMode = TrackProperty("_ParallaxMode", properties);
                    prop_ParallaxMap = TrackProperty("_ParallaxMap", properties);
                    prop_ParallaxStrength = TrackProperty("_ParallaxStrength", properties);
                    prop_ParallaxSteps = TrackProperty("_ParallaxSteps", properties);
                    prop_ParallaxBlend = TrackProperty("_ParallaxBlend", properties);
                    prop_InteriorCubemap = TrackProperty("_InteriorCubemap", properties);
                    prop_InteriorColor = TrackProperty("_InteriorColor", properties);
                    prop_InteriorTiling = TrackProperty("_InteriorTiling", properties);
                    prop_ParallaxLayer1 = TrackProperty("_ParallaxLayer1", properties);
                    prop_ParallaxLayer2 = TrackProperty("_ParallaxLayer2", properties);
                    prop_ParallaxLayer3 = TrackProperty("_ParallaxLayer3", properties);
                    prop_ParallaxLayerDepth1 = TrackProperty("_ParallaxLayerDepth1", properties);
                    prop_ParallaxLayerDepth2 = TrackProperty("_ParallaxLayerDepth2", properties);
                    prop_ParallaxLayerDepth3 = TrackProperty("_ParallaxLayerDepth3", properties);
                    prop_ParallaxStack = TrackProperty("_ParallaxStack", properties);
                    prop_ParallaxBlendWeight = TrackProperty("_ParallaxBlendWeight", properties);
                    prop_ParallaxTile = TrackProperty("_ParallaxTile", properties);
                    materialEditor.ShaderProperty(prop_ToggleParallax, languages.speak("prop_ToggleParallax"));
                    Components.start_dynamic_disable(!prop_ToggleParallax.floatValue.Equals(1), configs);
                    materialEditor.ShaderProperty(prop_ParallaxMode, languages.speak("prop_ParallaxMode"));
                    int parallaxMode = (int)prop_ParallaxMode.floatValue;
                    materialEditor.ShaderProperty(prop_ParallaxMap, languages.speak("prop_ParallaxMap"));
                    materialEditor.ShaderProperty(prop_ParallaxStrength, languages.speak("prop_ParallaxStrength"));
                    materialEditor.ShaderProperty(prop_ParallaxSteps, languages.speak("prop_ParallaxSteps"));
                    materialEditor.ShaderProperty(prop_ParallaxBlend, languages.speak("prop_ParallaxBlend"));
                    if (parallaxMode == 3) {
                        materialEditor.ShaderProperty(prop_InteriorCubemap, languages.speak("prop_InteriorCubemap"));
                        materialEditor.ShaderProperty(prop_InteriorColor, languages.speak("prop_InteriorColor"));
                        materialEditor.ShaderProperty(prop_InteriorTiling, languages.speak("prop_InteriorTiling"));
                    }
                    if (parallaxMode == 2) {
                        materialEditor.ShaderProperty(prop_ParallaxLayer1, languages.speak("prop_ParallaxLayer1"));
                        materialEditor.ShaderProperty(prop_ParallaxLayer2, languages.speak("prop_ParallaxLayer2"));
                        materialEditor.ShaderProperty(prop_ParallaxLayer3, languages.speak("prop_ParallaxLayer3"));
                        materialEditor.ShaderProperty(prop_ParallaxLayerDepth1, languages.speak("prop_ParallaxLayerDepth1"));
                        materialEditor.ShaderProperty(prop_ParallaxLayerDepth2, languages.speak("prop_ParallaxLayerDepth2"));
                        materialEditor.ShaderProperty(prop_ParallaxLayerDepth3, languages.speak("prop_ParallaxLayerDepth3"));
                        materialEditor.ShaderProperty(prop_ParallaxStack, languages.speak("prop_ParallaxStack"));
                        materialEditor.ShaderProperty(prop_ParallaxBlendWeight, languages.speak("prop_ParallaxBlendWeight"));
                        materialEditor.ShaderProperty(prop_ParallaxTile, languages.speak("prop_ParallaxTile"));
                    }
                    Components.end_dynamic_disable(!prop_ToggleParallax.floatValue.Equals(1), configs);
                });
                sub_tab_subsurface.process(() => {
                    prop_ToggleSSS = TrackProperty("_ToggleSSS", properties);
                    prop_SSSColor = TrackProperty("_SSSColor", properties);
                    prop_SSSStrength = TrackProperty("_SSSStrength", properties);
                    prop_SSSPower = TrackProperty("_SSSPower", properties);
                    prop_SSSDistortion = TrackProperty("_SSSDistortion", properties);
                    prop_SSSThicknessMap = TrackProperty("_SSSThicknessMap", properties);
                    prop_SSSThickness = TrackProperty("_SSSThickness", properties);
                    materialEditor.ShaderProperty(prop_ToggleSSS, languages.speak("prop_ToggleSSS"));
                    Components.start_dynamic_disable(!prop_ToggleSSS.floatValue.Equals(1), configs);
                    materialEditor.ShaderProperty(prop_SSSThicknessMap, languages.speak("prop_SSSThicknessMap"));
                    materialEditor.ShaderProperty(prop_SSSThickness, languages.speak("prop_SSSThickness"));
                    materialEditor.ShaderProperty(prop_SSSStrength, languages.speak("prop_SSSStrength"));
                    materialEditor.ShaderProperty(prop_SSSPower, languages.speak("prop_SSSPower"));
                    materialEditor.ShaderProperty(prop_SSSDistortion, languages.speak("prop_SSSDistortion"));
                    materialEditor.ShaderProperty(prop_SSSColor, languages.speak("prop_SSSColor"));
                    Components.end_dynamic_disable(!prop_ToggleSSS.floatValue.Equals(1), configs);
                });
                sub_tab_detail_map.process(() => {
                    prop_ToggleDetail = TrackProperty("_ToggleDetail", properties);
                    prop_DetailAlbedoMap = TrackProperty("_DetailAlbedoMap", properties);
                    prop_DetailNormalMap = TrackProperty("_DetailNormalMap", properties);
                    prop_DetailTiling = TrackProperty("_DetailTiling", properties);
                    prop_DetailNormalStrength = TrackProperty("_DetailNormalStrength", properties);
                    materialEditor.ShaderProperty(prop_ToggleDetail, languages.speak("prop_ToggleDetail"));
                    Components.start_dynamic_disable(!prop_ToggleDetail.floatValue.Equals(1), configs);
                    materialEditor.ShaderProperty(prop_DetailAlbedoMap, languages.speak("prop_DetailAlbedoMap"));
                    materialEditor.ShaderProperty(prop_DetailNormalMap, languages.speak("prop_DetailNormalMap"));
                    materialEditor.ShaderProperty(prop_DetailTiling, languages.speak("prop_DetailTiling"));
                    materialEditor.ShaderProperty(prop_DetailNormalStrength, languages.speak("prop_DetailNormalStrength"));
                    Components.end_dynamic_disable(!prop_ToggleDetail.floatValue.Equals(1), configs);
                });
                sub_tab_shadow_map.process(() => {
                    prop_ToggleShadowMap = TrackProperty("_ToggleShadowMap", properties);
                    prop_ShadowMap = TrackProperty("_ShadowMap", properties);
                    prop_ShadowMapIntensity = TrackProperty("_ShadowMapIntensity", properties);
                    materialEditor.ShaderProperty(prop_ToggleShadowMap, languages.speak("prop_ToggleShadowMap"));
                    Components.start_dynamic_disable(!prop_ToggleShadowMap.floatValue.Equals(1), configs);
                    materialEditor.ShaderProperty(prop_ShadowMap, languages.speak("prop_ShadowMap"));
                    materialEditor.ShaderProperty(prop_ShadowMapIntensity, languages.speak("prop_ShadowMapIntensity"));
                    Components.end_dynamic_disable(!prop_ToggleShadowMap.floatValue.Equals(1), configs);
                });
                Components.end_foldout();
            });
            // stickers tab
            tab_stickers.process(() => {
                Components.start_foldout();
                prop_ToggleDecals = TrackProperty("_ToggleDecals", properties);
                prop_DecalStage = TrackProperty("_DecalStage", properties);
                materialEditor.ShaderProperty(prop_ToggleDecals, languages.speak("prop_ToggleDecals"));
                Components.start_dynamic_disable(!prop_ToggleDecals.floatValue.Equals(1), configs);
                materialEditor.ShaderProperty(prop_DecalStage, languages.speak("prop_DecalLighting_NEW"));
                sub_tab_decal1_settings.process(() => {
                    prop_Decal1Enable = TrackProperty("_Decal1Enable", properties);
                    prop_Decal1Tex = TrackProperty("_Decal1Tex", properties);
                    prop_Decal1Tint = TrackProperty("_Decal1Tint", properties);
                    prop_Decal1BlendMode = TrackProperty("_Decal1BlendMode", properties);
                    prop_Decal1Space = TrackProperty("_Decal1Space", properties);
                    prop_Decal1Behavior = TrackProperty("_Decal1Behavior", properties);
                    prop_Decal1Position = TrackProperty("_Decal1Position", properties);
                    prop_Decal1Scale = TrackProperty("_Decal1Scale", properties);
                    prop_Decal1Rotation = TrackProperty("_Decal1Rotation", properties);
                    prop_Decal1TriplanarPosition = TrackProperty("_Decal1TriplanarPosition", properties);
                    prop_Decal1TriplanarScale = TrackProperty("_Decal1TriplanarScale", properties);
                    prop_Decal1TriplanarRotation = TrackProperty("_Decal1TriplanarRotation", properties);
                    prop_Decal1TriplanarSharpness = TrackProperty("_Decal1TriplanarSharpness", properties);
                    prop_Decal1Repeat = TrackProperty("_Decal1Repeat", properties);
                    prop_Decal1Scroll = TrackProperty("_Decal1Scroll", properties);
                    materialEditor.ShaderProperty(prop_Decal1Enable, languages.speak("prop_Decal1Enable"));
                    Components.start_dynamic_disable(!prop_Decal1Enable.floatValue.Equals(1), configs);
                    materialEditor.ShaderProperty(prop_Decal1Tex, languages.speak("prop_Decal1Tex"));
                    materialEditor.ShaderProperty(prop_Decal1Tint, languages.speak("prop_Decal1Tint"));
                    materialEditor.ShaderProperty(prop_Decal1BlendMode, languages.speak("prop_Decal1BlendMode"));
                    materialEditor.ShaderProperty(prop_Decal1Behavior, languages.speak("prop_Decal1Behavior"));
                    materialEditor.ShaderProperty(prop_Decal1Space, languages.speak("prop_Decal1Space"));
                    EditorGUI.indentLevel++;
                    int decal1Space = (int)prop_Decal1Space.floatValue;
                    if (decal1Space == 0) // uv
                    {
                        Components.Vector2Property(materialEditor, prop_Decal1Position, languages.speak("prop_Decal1Position"));
                        Components.Vector2Property(materialEditor, prop_Decal1Scale, languages.speak("prop_Decal1Scale"));
                        materialEditor.ShaderProperty(prop_Decal1Rotation, languages.speak("prop_Decal1Rotation"));
                    }
                    else if (decal1Space == 1) // triplanar
                    {
                        Components.Vector3Property(materialEditor, prop_Decal1TriplanarPosition, languages.speak("prop_Decal1TriplanarPosition"));
                        materialEditor.ShaderProperty(prop_Decal1TriplanarScale, languages.speak("prop_Decal1TriplanarScale"));
                        Components.Vector3Property(materialEditor, prop_Decal1TriplanarRotation, languages.speak("prop_Decal1TriplanarRotation"));
                        materialEditor.ShaderProperty(prop_Decal1TriplanarSharpness, languages.speak("prop_Decal1TriplanarSharpness"));
                    }
                    else if (decal1Space == 2) // screen
                    {
                        Components.Vector2Property(materialEditor, prop_Decal1Position, languages.speak("prop_Decal1Position"));
                        Components.Vector2Property(materialEditor, prop_Decal1Scale, languages.speak("prop_Decal1Scale"));
                        materialEditor.ShaderProperty(prop_Decal1Rotation, languages.speak("prop_Decal1Rotation"));
                    }
                    EditorGUI.indentLevel--;
                    materialEditor.ShaderProperty(prop_Decal1Repeat, languages.speak("prop_Decal1Repeat"));
                    Components.Vector2Property(materialEditor, prop_Decal1Scroll, languages.speak("prop_Decal1Scroll"));
                    Components.end_dynamic_disable(!prop_Decal1Enable.floatValue.Equals(1), configs);
                });
                sub_tab_decal1_effects.process(() => {
                    prop_Decal1Enable = TrackProperty("_Decal1Enable", properties);
                    prop_Decal1HueShift = TrackProperty("_Decal1HueShift", properties);
                    prop_Decal1AutoCycleHue = TrackProperty("_Decal1AutoCycleHue", properties);
                    prop_Decal1CycleSpeed = TrackProperty("_Decal1CycleSpeed", properties);
                    prop_Decal1Spritesheet = TrackProperty("_Decal1Spritesheet", properties);
                    prop_Decal1SheetCols = TrackProperty("_Decal1SheetCols", properties);
                    prop_Decal1SheetRows = TrackProperty("_Decal1SheetRows", properties);
                    prop_Decal1SheetFPS = TrackProperty("_Decal1SheetFPS", properties);
                    prop_Decal1SheetSlider = TrackProperty("_Decal1SheetSlider", properties);
                    prop_Decal1SpecialEffect = TrackProperty("_Decal1SpecialEffect", properties);
                    prop_Decal1DistortionControls = TrackProperty("_Decal1DistortionControls", properties);
                    prop_Decal1DistortionSpeed = TrackProperty("_Decal1DistortionSpeed", properties);
                    prop_Decal1GlitchControls = TrackProperty("_Decal1GlitchControls", properties);
                    Components.start_dynamic_disable(!prop_Decal1Enable.floatValue.Equals(1), configs);
                    materialEditor.ShaderProperty(prop_Decal1HueShift, languages.speak("prop_Decal1HueShift"));
                    materialEditor.ShaderProperty(prop_Decal1AutoCycleHue, languages.speak("prop_Decal1AutoCycleHue"));
                    Components.start_dynamic_disable(!prop_Decal1AutoCycleHue.floatValue.Equals(1), configs);
                    EditorGUI.indentLevel++;
                    materialEditor.ShaderProperty(prop_Decal1CycleSpeed, languages.speak("prop_Decal1CycleSpeed"));
                    EditorGUI.indentLevel--;
                    Components.end_dynamic_disable(!prop_Decal1AutoCycleHue.floatValue.Equals(1), configs);
                    materialEditor.ShaderProperty(prop_Decal1Spritesheet, languages.speak("prop_Decal1Spritesheet"));
                    Components.start_dynamic_disable(!prop_Decal1Spritesheet.floatValue.Equals(1), configs);
                    EditorGUI.indentLevel++;
                    materialEditor.ShaderProperty(prop_Decal1SheetCols, languages.speak("prop_Decal1SheetCols"));
                    materialEditor.ShaderProperty(prop_Decal1SheetRows, languages.speak("prop_Decal1SheetRows"));
                    materialEditor.ShaderProperty(prop_Decal1SheetFPS, languages.speak("prop_Decal1SheetFPS"));
                    materialEditor.ShaderProperty(prop_Decal1SheetSlider, languages.speak("prop_Decal1SheetSlider"));
                    EditorGUI.indentLevel--;
                    Components.end_dynamic_disable(!prop_Decal1Spritesheet.floatValue.Equals(1), configs);
                    materialEditor.ShaderProperty(prop_Decal1SpecialEffect, languages.speak("prop_Decal1SpecialEffect"));
                    int decal1Effect = (int)prop_Decal1SpecialEffect.floatValue;
                    if (decal1Effect == 1)
                    {
                        EditorGUI.indentLevel++;
                        materialEditor.ShaderProperty(prop_Decal1DistortionControls, languages.speak("prop_Decal1DistortionControls"));
                        materialEditor.ShaderProperty(prop_Decal1DistortionSpeed, languages.speak("prop_Decal1DistortionSpeed"));
                        EditorGUI.indentLevel--;
                    }
                    else if (decal1Effect == 2)
                    {
                        EditorGUI.indentLevel++;
                        materialEditor.ShaderProperty(prop_Decal1GlitchControls, languages.speak("prop_Decal1GlitchControls"));
                        EditorGUI.indentLevel--;
                    }
                    Components.end_dynamic_disable(!prop_Decal1Enable.floatValue.Equals(1), configs);
                });
                sub_tab_decal2_settings.process(() => {
                    prop_Decal2Enable = TrackProperty("_Decal2Enable", properties);
                    prop_Decal2Tex = TrackProperty("_Decal2Tex", properties);
                    prop_Decal2Tint = TrackProperty("_Decal2Tint", properties);
                    prop_Decal2BlendMode = TrackProperty("_Decal2BlendMode", properties);
                    prop_Decal2Space = TrackProperty("_Decal2Space", properties);
                    prop_Decal2Behavior = TrackProperty("_Decal2Behavior", properties);
                    prop_Decal2Position = TrackProperty("_Decal2Position", properties);
                    prop_Decal2Scale = TrackProperty("_Decal2Scale", properties);
                    prop_Decal2Rotation = TrackProperty("_Decal2Rotation", properties);
                    prop_Decal2TriplanarPosition = TrackProperty("_Decal2TriplanarPosition", properties);
                    prop_Decal2TriplanarScale = TrackProperty("_Decal2TriplanarScale", properties);
                    prop_Decal2TriplanarRotation = TrackProperty("_Decal2TriplanarRotation", properties);
                    prop_Decal2TriplanarSharpness = TrackProperty("_Decal2TriplanarSharpness", properties);
                    prop_Decal2Repeat = TrackProperty("_Decal2Repeat", properties);
                    prop_Decal2Scroll = TrackProperty("_Decal2Scroll", properties);
                    materialEditor.ShaderProperty(prop_Decal2Enable, languages.speak("prop_Decal2Enable"));
                    Components.start_dynamic_disable(!prop_Decal2Enable.floatValue.Equals(1), configs);
                    materialEditor.ShaderProperty(prop_Decal2Tex, languages.speak("prop_Decal2Tex"));
                    materialEditor.ShaderProperty(prop_Decal2Tint, languages.speak("prop_Decal2Tint"));
                    materialEditor.ShaderProperty(prop_Decal2BlendMode, languages.speak("prop_Decal2BlendMode"));
                    materialEditor.ShaderProperty(prop_Decal2Behavior, languages.speak("prop_Decal2Behavior"));
                    materialEditor.ShaderProperty(prop_Decal2Space, languages.speak("prop_Decal2Space"));
                    EditorGUI.indentLevel++;
                    int decal2Space = (int)prop_Decal2Space.floatValue;
                    if (decal2Space == 0) // uv
                    {
                        Components.Vector2Property(materialEditor, prop_Decal2Position, languages.speak("prop_Decal2Position"));
                        Components.Vector2Property(materialEditor, prop_Decal2Scale, languages.speak("prop_Decal2Scale"));
                        materialEditor.ShaderProperty(prop_Decal2Rotation, languages.speak("prop_Decal2Rotation"));
                    }
                    else if (decal2Space == 1) // triplanar
                    {
                        Components.Vector3Property(materialEditor, prop_Decal2TriplanarPosition, languages.speak("prop_Decal2TriplanarPosition"));
                        materialEditor.ShaderProperty(prop_Decal2TriplanarScale, languages.speak("prop_Decal2TriplanarScale"));
                        Components.Vector3Property(materialEditor, prop_Decal2TriplanarRotation, languages.speak("prop_Decal2TriplanarRotation"));
                        materialEditor.ShaderProperty(prop_Decal2TriplanarSharpness, languages.speak("prop_Decal2TriplanarSharpness"));
                    }
                    else if (decal2Space == 2) // screen
                    {
                        Components.Vector2Property(materialEditor, prop_Decal2Position, languages.speak("prop_Decal2Position"));
                        Components.Vector2Property(materialEditor, prop_Decal2Scale, languages.speak("prop_Decal2Scale"));
                        materialEditor.ShaderProperty(prop_Decal2Rotation, languages.speak("prop_Decal2Rotation"));
                    }
                    EditorGUI.indentLevel--;
                    materialEditor.ShaderProperty(prop_Decal2Repeat, languages.speak("prop_Decal2Repeat"));
                    Components.Vector2Property(materialEditor, prop_Decal2Scroll, languages.speak("prop_Decal2Scroll"));
                    Components.end_dynamic_disable(!prop_Decal2Enable.floatValue.Equals(1), configs);
                });
                sub_tab_decal2_effects.process(() => {
                    prop_Decal2Enable = TrackProperty("_Decal2Enable", properties);
                    prop_Decal2HueShift = TrackProperty("_Decal2HueShift", properties);
                    prop_Decal2AutoCycleHue = TrackProperty("_Decal2AutoCycleHue", properties);
                    prop_Decal2CycleSpeed = TrackProperty("_Decal2CycleSpeed", properties);
                    prop_Decal2Spritesheet = TrackProperty("_Decal2Spritesheet", properties);
                    prop_Decal2SheetCols = TrackProperty("_Decal2SheetCols", properties);
                    prop_Decal2SheetRows = TrackProperty("_Decal2SheetRows", properties);
                    prop_Decal2SheetFPS = TrackProperty("_Decal2SheetFPS", properties);
                    prop_Decal2SheetSlider = TrackProperty("_Decal2SheetSlider", properties);
                    prop_Decal2SpecialEffect = TrackProperty("_Decal2SpecialEffect", properties);
                    prop_Decal2DistortionControls = TrackProperty("_Decal2DistortionControls", properties);
                    prop_Decal2DistortionSpeed = TrackProperty("_Decal2DistortionSpeed", properties);
                    prop_Decal2GlitchControls = TrackProperty("_Decal2GlitchControls", properties);
                    Components.start_dynamic_disable(!prop_Decal2Enable.floatValue.Equals(1), configs);
                    materialEditor.ShaderProperty(prop_Decal2HueShift, languages.speak("prop_Decal2HueShift"));
                    materialEditor.ShaderProperty(prop_Decal2AutoCycleHue, languages.speak("prop_Decal2AutoCycleHue"));
                    Components.start_dynamic_disable(!prop_Decal2AutoCycleHue.floatValue.Equals(1), configs);
                    EditorGUI.indentLevel++;
                    materialEditor.ShaderProperty(prop_Decal2CycleSpeed, languages.speak("prop_Decal2CycleSpeed"));
                    EditorGUI.indentLevel--;
                    Components.end_dynamic_disable(!prop_Decal2AutoCycleHue.floatValue.Equals(1), configs);
                    materialEditor.ShaderProperty(prop_Decal2Spritesheet, languages.speak("prop_Decal2Spritesheet"));
                    Components.start_dynamic_disable(!prop_Decal2Spritesheet.floatValue.Equals(1), configs);
                    EditorGUI.indentLevel++;
                    materialEditor.ShaderProperty(prop_Decal2SheetCols, languages.speak("prop_Decal2SheetCols"));
                    materialEditor.ShaderProperty(prop_Decal2SheetRows, languages.speak("prop_Decal2SheetRows"));
                    materialEditor.ShaderProperty(prop_Decal2SheetFPS, languages.speak("prop_Decal2SheetFPS"));
                    materialEditor.ShaderProperty(prop_Decal2SheetSlider, languages.speak("prop_Decal2SheetSlider"));
                    EditorGUI.indentLevel--;
                    Components.end_dynamic_disable(!prop_Decal2Spritesheet.floatValue.Equals(1), configs);
                    materialEditor.ShaderProperty(prop_Decal2SpecialEffect, languages.speak("prop_Decal2SpecialEffect"));
                    int decal2Effect = (int)prop_Decal2SpecialEffect.floatValue;
                    if (decal2Effect == 1)
                    {
                        EditorGUI.indentLevel++;
                        materialEditor.ShaderProperty(prop_Decal2DistortionControls, languages.speak("prop_Decal2DistortionControls"));
                        materialEditor.ShaderProperty(prop_Decal2DistortionSpeed, languages.speak("prop_Decal2DistortionSpeed"));
                        EditorGUI.indentLevel--;
                    }
                    else if (decal2Effect == 2)
                    {
                        EditorGUI.indentLevel++;
                        materialEditor.ShaderProperty(prop_Decal2GlitchControls, languages.speak("prop_Decal2GlitchControls"));
                        EditorGUI.indentLevel--;
                    }
                    Components.end_dynamic_disable(!prop_Decal2Enable.floatValue.Equals(1), configs);
                });
                Components.end_dynamic_disable(!prop_ToggleDecals.floatValue.Equals(1), configs);
                Components.end_foldout();
            });
            // effects tab
            tab_effects.process(() => {
                Components.start_foldout();
                sub_tab_dissolve.process(() => {
                    prop_ToggleDissolve = TrackProperty("_ToggleDissolve", properties);
                    prop_DissolveProgress = TrackProperty("_DissolveProgress", properties);
                    prop_DissolveType = TrackProperty("_DissolveType", properties);
                    prop_DissolveEdgeColor = TrackProperty("_DissolveEdgeColor", properties);
                    prop_DissolveEdgeWidth = TrackProperty("_DissolveEdgeWidth", properties);
                    prop_DissolveEdgeMode = TrackProperty("_DissolveEdgeMode", properties);
                    prop_DissolveEdgeSharpness = TrackProperty("_DissolveEdgeSharpness", properties);
                    prop_DissolveNoiseTex = TrackProperty("_DissolveNoiseTex", properties);
                    prop_DissolveNoiseScale = TrackProperty("_DissolveNoiseScale", properties);
                    prop_DissolveDirection = TrackProperty("_DissolveDirection", properties);
                    prop_DissolveDirectionSpace = TrackProperty("_DissolveDirectionSpace", properties);
                    prop_DissolveDirectionBounds = TrackProperty("_DissolveDirectionBounds", properties);
                    prop_DissolveVoxelDensity = TrackProperty("_DissolveVoxelDensity", properties);
                    materialEditor.ShaderProperty(prop_ToggleDissolve, languages.speak("prop_ToggleDissolve"));
                    Components.start_dynamic_disable(!prop_ToggleDissolve.floatValue.Equals(1), configs);
                    materialEditor.ShaderProperty(prop_DissolveType, languages.speak("prop_DissolveType"));
                    EditorGUI.indentLevel++;
                    int dissolveType = (int)prop_DissolveType.floatValue;
                    if (dissolveType == 0) // noise
                    {
                        materialEditor.ShaderProperty(prop_DissolveNoiseTex, languages.speak("prop_DissolveNoiseTex"));
                        materialEditor.ShaderProperty(prop_DissolveNoiseScale, languages.speak("prop_DissolveNoiseScale"));
                    }
                    else if (dissolveType == 1) // directional
                    {
                        Components.Vector3Property(materialEditor, prop_DissolveDirection, languages.speak("prop_DissolveDirection"));
                        materialEditor.ShaderProperty(prop_DissolveDirectionSpace, languages.speak("prop_DissolveDirectionSpace"));
                        materialEditor.ShaderProperty(prop_DissolveDirectionBounds, languages.speak("prop_DissolveDirectionBounds"));
                    }
                    else if (dissolveType == 2) // voxel
                    {
                        materialEditor.ShaderProperty(prop_DissolveVoxelDensity, languages.speak("prop_DissolveVoxelDensity"));
                    }
                    EditorGUI.indentLevel--;
                    materialEditor.ShaderProperty(prop_DissolveProgress, languages.speak("prop_DissolveProgress"));
                    materialEditor.ShaderProperty(prop_DissolveEdgeMode, languages.speak("prop_DissolveEdgeMode"));
                    EditorGUI.indentLevel++;
                    materialEditor.ShaderProperty(prop_DissolveEdgeWidth, languages.speak("prop_DissolveEdgeWidth"));
                    materialEditor.ShaderProperty(prop_DissolveEdgeSharpness, languages.speak("prop_DissolveEdgeSharpness"));
                    materialEditor.ShaderProperty(prop_DissolveEdgeColor, languages.speak("prop_DissolveEdgeColor"));
                    EditorGUI.indentLevel--;
                    Components.end_dynamic_disable(!prop_ToggleDissolve.floatValue.Equals(1), configs);
                });
                sub_tab_pathing.process(() => {
                    prop_TogglePathing = TrackProperty("_TogglePathing", properties);
                    prop_PathingMappingMode = TrackProperty("_PathingMappingMode", properties);
                    prop_PathingMap = TrackProperty("_PathingMap", properties);
                    prop_PathingScale = TrackProperty("_PathingScale", properties);
                    prop_PathingBlendMode = TrackProperty("_PathingBlendMode", properties);
                    prop_PathingColorMode = TrackProperty("_PathingColorMode", properties);
                    prop_PathingTexture = TrackProperty("_PathingTexture", properties);
                    prop_PathingColor = TrackProperty("_PathingColor", properties);
                    prop_PathingColor2 = TrackProperty("_PathingColor2", properties);
                    prop_PathingEmission = TrackProperty("_PathingEmission", properties);
                    prop_PathingType = TrackProperty("_PathingType", properties);
                    prop_PathingSpeed = TrackProperty("_PathingSpeed", properties);
                    prop_PathingWidth = TrackProperty("_PathingWidth", properties);
                    prop_PathingSoftness = TrackProperty("_PathingSoftness", properties);
                    prop_PathingOffset = TrackProperty("_PathingOffset", properties);
                    prop_PathingStart = TrackProperty("_PathingStart", properties);
                    prop_PathingEnd = TrackProperty("_PathingEnd", properties);
                    materialEditor.ShaderProperty(prop_TogglePathing, languages.speak("prop_TogglePathing"));
                    Components.start_dynamic_disable(!prop_TogglePathing.floatValue.Equals(1), configs);
                    materialEditor.ShaderProperty(prop_PathingMappingMode, languages.speak("prop_PathingMappingMode"));
                    materialEditor.ShaderProperty(prop_PathingMap, languages.speak("prop_PathingMap"));
                    materialEditor.ShaderProperty(prop_PathingScale, languages.speak("prop_PathingScale"));
                    materialEditor.ShaderProperty(prop_PathingBlendMode, languages.speak("prop_PathingBlendMode"));
                    materialEditor.ShaderProperty(prop_PathingColorMode, languages.speak("prop_PathingColorMode"));
                    int pathingColorMode = (int)prop_PathingColorMode.floatValue;
                    if (pathingColorMode == 0)
                    {
                        materialEditor.ShaderProperty(prop_PathingColor, languages.speak("prop_PathingColor"));
                    }
                    else if (pathingColorMode == 1)
                    {
                        materialEditor.ShaderProperty(prop_PathingTexture, languages.speak("prop_PathingTexture"));
                    }
                    else if (pathingColorMode == 2)
                    {
                        materialEditor.ShaderProperty(prop_PathingColor, languages.speak("prop_PathingColor"));
                        materialEditor.ShaderProperty(prop_PathingColor2, languages.speak("prop_PathingColor2"));
                    }
                    materialEditor.ShaderProperty(prop_PathingEmission, languages.speak("prop_PathingEmission"));
                    materialEditor.ShaderProperty(prop_PathingType, languages.speak("prop_PathingType"));
                    materialEditor.ShaderProperty(prop_PathingSpeed, languages.speak("prop_PathingSpeed"));
                    materialEditor.ShaderProperty(prop_PathingWidth, languages.speak("prop_PathingWidth"));
                    materialEditor.ShaderProperty(prop_PathingSoftness, languages.speak("prop_PathingSoftness"));
                    materialEditor.ShaderProperty(prop_PathingOffset, languages.speak("prop_PathingOffset"));
                    materialEditor.ShaderProperty(prop_PathingStart, languages.speak("prop_PathingStart"));
                    materialEditor.ShaderProperty(prop_PathingEnd, languages.speak("prop_PathingEnd"));
                    Components.end_dynamic_disable(!prop_TogglePathing.floatValue.Equals(1), configs);
                });
                sub_tab_glitter.process(() => {
                    prop_ToggleGlitter = TrackProperty("_ToggleGlitter", properties);
                    prop_GlitterMode = TrackProperty("_GlitterMode", properties);
                    prop_GlitterNoiseTex = TrackProperty("_GlitterNoiseTex", properties);
                    prop_GlitterMask = TrackProperty("_GlitterMask", properties);
                    prop_GlitterTint = TrackProperty("_GlitterTint", properties);
                    prop_GlitterFrequency = TrackProperty("_GlitterFrequency", properties);
                    prop_GlitterThreshold = TrackProperty("_GlitterThreshold", properties);
                    prop_GlitterSize = TrackProperty("_GlitterSize", properties);
                    prop_GlitterFlickerSpeed = TrackProperty("_GlitterFlickerSpeed", properties);
                    prop_GlitterBrightness = TrackProperty("_GlitterBrightness", properties);
                    prop_GlitterContrast = TrackProperty("_GlitterContrast", properties);
                    prop_ToggleGlitterRainbow = TrackProperty("_ToggleGlitterRainbow", properties);
                    prop_GlitterRainbowSpeed = TrackProperty("_GlitterRainbowSpeed", properties);
                    materialEditor.ShaderProperty(prop_ToggleGlitter, languages.speak("prop_ToggleGlitter"));
                    Components.start_dynamic_disable(!prop_ToggleGlitter.floatValue.Equals(1), configs);
                    materialEditor.ShaderProperty(prop_GlitterMode, languages.speak("prop_GlitterMode"));
                    int glitterMode = (int)prop_GlitterMode.floatValue;
                    if (glitterMode == 1)
                    {
                        materialEditor.ShaderProperty(prop_GlitterNoiseTex, languages.speak("prop_GlitterNoiseTex"));
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
                    Components.start_dynamic_disable(prop_ToggleGlitterRainbow.floatValue.Equals(0), configs);
                    EditorGUI.indentLevel++;
                    materialEditor.ShaderProperty(prop_GlitterRainbowSpeed, languages.speak("prop_GlitterRainbowSpeed"));
                    EditorGUI.indentLevel--;
                    Components.end_dynamic_disable(prop_ToggleGlitterRainbow.floatValue.Equals(0), configs);
                    Components.end_dynamic_disable(!prop_ToggleGlitter.floatValue.Equals(1), configs);
                });
                sub_tab_distance_fading.process(() => {
                    prop_ToggleDistanceFade = TrackProperty("_ToggleDistanceFade", properties);
                    prop_DistanceFadeReference = TrackProperty("_DistanceFadeReference", properties);
                    prop_ToggleNearFade = TrackProperty("_ToggleNearFade", properties);
                    prop_NearFadeMode = TrackProperty("_NearFadeMode", properties);
                    prop_NearFadeDitherScale = TrackProperty("_NearFadeDitherScale", properties);
                    prop_NearFadeStart = TrackProperty("_NearFadeStart", properties);
                    prop_NearFadeEnd = TrackProperty("_NearFadeEnd", properties);
                    prop_ToggleFarFade = TrackProperty("_ToggleFarFade", properties);
                    prop_FarFadeStart = TrackProperty("_FarFadeStart", properties);
                    prop_FarFadeEnd = TrackProperty("_FarFadeEnd", properties);
                    materialEditor.ShaderProperty(prop_ToggleDistanceFade, languages.speak("prop_ToggleDistanceFade"));
                    Components.start_dynamic_disable(!prop_ToggleDistanceFade.floatValue.Equals(1), configs);
                    materialEditor.ShaderProperty(prop_DistanceFadeReference, languages.speak("prop_DistanceFadeReference"));
                    materialEditor.ShaderProperty(prop_ToggleNearFade, languages.speak("prop_ToggleNearFade"));
                    Components.start_dynamic_disable(prop_ToggleNearFade.floatValue.Equals(0), configs);
                    EditorGUI.indentLevel++;
                    materialEditor.ShaderProperty(prop_NearFadeMode, languages.speak("prop_NearFadeMode"));
                    if ((int)prop_NearFadeMode.floatValue == 1)
                    {
                        materialEditor.ShaderProperty(prop_NearFadeDitherScale, languages.speak("prop_NearFadeDitherScale"));
                    }
                    materialEditor.ShaderProperty(prop_NearFadeStart, languages.speak("prop_NearFadeStart"));
                    materialEditor.ShaderProperty(prop_NearFadeEnd, languages.speak("prop_NearFadeEnd"));
                    EditorGUI.indentLevel--;
                    Components.end_dynamic_disable(prop_ToggleNearFade.floatValue.Equals(0), configs);
                    materialEditor.ShaderProperty(prop_ToggleFarFade, languages.speak("prop_ToggleFarFade"));
                    Components.start_dynamic_disable(prop_ToggleFarFade.floatValue.Equals(0), configs);
                    EditorGUI.indentLevel++;
                    materialEditor.ShaderProperty(prop_FarFadeStart, languages.speak("prop_FarFadeStart"));
                    materialEditor.ShaderProperty(prop_FarFadeEnd, languages.speak("prop_FarFadeEnd"));
                    EditorGUI.indentLevel--;
                    Components.end_dynamic_disable(prop_ToggleFarFade.floatValue.Equals(0), configs);
                    Components.end_dynamic_disable(!prop_ToggleDistanceFade.floatValue.Equals(1), configs);
                });
                sub_tab_iridescence.process(() => {
                    prop_ToggleIridescence = TrackProperty("_ToggleIridescence", properties);
                    prop_IridescenceMode = TrackProperty("_IridescenceMode", properties);
                    prop_IridescenceMask = TrackProperty("_IridescenceMask", properties);
                    prop_IridescenceTint = TrackProperty("_IridescenceTint", properties);
                    prop_IridescenceIntensity = TrackProperty("_IridescenceIntensity", properties);
                    prop_IridescenceBlendMode = TrackProperty("_IridescenceBlendMode", properties);
                    prop_IridescenceParallax = TrackProperty("_IridescenceParallax", properties);
                    prop_IridescenceRamp = TrackProperty("_IridescenceRamp", properties);
                    prop_IridescencePower = TrackProperty("_IridescencePower", properties);
                    prop_IridescenceFrequency = TrackProperty("_IridescenceFrequency", properties);
                    materialEditor.ShaderProperty(prop_ToggleIridescence, languages.speak("prop_ToggleIridescence"));
                    Components.start_dynamic_disable(!prop_ToggleIridescence.floatValue.Equals(1), configs);
                    materialEditor.ShaderProperty(prop_IridescenceMode, languages.speak("prop_IridescenceMode"));
                    EditorGUI.indentLevel++;
                    int iridMode = (int)prop_IridescenceMode.floatValue;
                    if (iridMode == 0) // texture mode
                    {
                        materialEditor.ShaderProperty(prop_IridescenceRamp, languages.speak("prop_IridescenceRamp"));
                    }
                    else if (iridMode == 1) // procedural mode
                    {
                        materialEditor.ShaderProperty(prop_IridescenceFrequency, languages.speak("prop_IridescenceFrequency"));
                    }
                    EditorGUI.indentLevel--;
                    materialEditor.ShaderProperty(prop_IridescenceMask, languages.speak("prop_IridescenceMask"));
                    materialEditor.ShaderProperty(prop_IridescenceTint, languages.speak("prop_IridescenceTint"));
                    materialEditor.ShaderProperty(prop_IridescenceIntensity, languages.speak("prop_IridescenceIntensity"));
                    materialEditor.ShaderProperty(prop_IridescenceParallax, languages.speak("prop_IridescenceParallax"));
                    materialEditor.ShaderProperty(prop_IridescencePower, languages.speak("prop_IridescencePower"));
                    materialEditor.ShaderProperty(prop_IridescenceBlendMode, languages.speak("prop_IridescenceBlendMode"));
                    Components.end_dynamic_disable(!prop_ToggleIridescence.floatValue.Equals(1), configs);
                });
                sub_tab_shadow_textures.process(() => {
                    prop_ToggleShadowTexture = TrackProperty("_ToggleShadowTexture", properties);
                    prop_ShadowTextureMappingMode = TrackProperty("_ShadowTextureMappingMode", properties);
                    prop_ShadowTextureBlendMode = TrackProperty("_ShadowTextureBlendMode", properties);
                    prop_ShadowTextureIntensity = TrackProperty("_ShadowTextureIntensity", properties);
                    prop_ShadowTex = TrackProperty("_ShadowTex", properties);
                    prop_ShadowPatternColor = TrackProperty("_ShadowPatternColor", properties);
                    prop_ShadowPatternScale = TrackProperty("_ShadowPatternScale", properties);
                    prop_ShadowPatternTriplanarSharpness = TrackProperty("_ShadowPatternTriplanarSharpness", properties);
                    prop_ShadowPatternTransparency = TrackProperty("_ShadowPatternTransparency", properties);
                    prop_ShadowPatternLightBased = TrackProperty("_ShadowPatternLightBased", properties);
                    prop_ShadowPatternLit = TrackProperty("_ShadowPatternLit", properties);
                    materialEditor.ShaderProperty(prop_ToggleShadowTexture, languages.speak("prop_ToggleShadowTexture"));
                    Components.start_dynamic_disable(!prop_ToggleShadowTexture.floatValue.Equals(1), configs);
                    materialEditor.ShaderProperty(prop_ShadowTextureMappingMode, languages.speak("prop_ShadowTextureMappingMode"));
                    int shadowTexMode = (int)prop_ShadowTextureMappingMode.floatValue;
                    if (shadowTexMode == 2) // triplanar
                    {
                        EditorGUI.indentLevel++;
                        materialEditor.ShaderProperty(prop_ShadowPatternTriplanarSharpness, languages.speak("prop_ShadowPatternTriplanarSharpness"));
                        EditorGUI.indentLevel--;
                    }
                    materialEditor.ShaderProperty(prop_ShadowTextureBlendMode, languages.speak("prop_ShadowTextureBlendMode"));
                    materialEditor.ShaderProperty(prop_ShadowPatternLightBased, languages.speak("prop_ShadowPatternLightBased"));
                    materialEditor.ShaderProperty(prop_ShadowPatternLit, languages.speak("prop_ShadowPatternLit"));
                    materialEditor.ShaderProperty(prop_ShadowTex, languages.speak("prop_ShadowTex"));
                    materialEditor.ShaderProperty(prop_ShadowPatternColor, languages.speak("prop_ShadowPatternColor"));
                    materialEditor.ShaderProperty(prop_ShadowPatternScale, languages.speak("prop_ShadowPatternScale"));
                    materialEditor.ShaderProperty(prop_ShadowTextureIntensity, languages.speak("prop_ShadowTextureIntensity"));
                    materialEditor.ShaderProperty(prop_ShadowPatternTransparency, languages.speak("prop_ShadowPatternTransparency"));
                    Components.end_dynamic_disable(!prop_ToggleShadowTexture.floatValue.Equals(1), configs);
                });
                sub_tab_flatten_model.process(() => {
                    prop_ToggleFlatModel = TrackProperty("_ToggleFlatModel", properties);
                    prop_FlatModeAutoflip = TrackProperty("_FlatModeAutoflip", properties);
                    prop_FlatModel = TrackProperty("_FlatModel", properties);
                    prop_FlatModelDepthCorrection = TrackProperty("_FlatModelDepthCorrection", properties);
                    prop_FlatModelFacing = TrackProperty("_FlatModelFacing", properties);
                    prop_FlatModelLockAxis = TrackProperty("_FlatModelLockAxis", properties);
                    materialEditor.ShaderProperty(prop_ToggleFlatModel, languages.speak("prop_ToggleFlatModel"));
                    Components.start_dynamic_disable(!prop_ToggleFlatModel.floatValue.Equals(1), configs);
                    materialEditor.ShaderProperty(prop_FlatModeAutoflip, languages.speak("prop_FlatModeAutoflip"));
                    materialEditor.ShaderProperty(prop_FlatModelLockAxis, languages.speak("prop_FlatModelLockAxis"));
                    materialEditor.ShaderProperty(prop_FlatModel, languages.speak("prop_FlatModel"));
                    materialEditor.ShaderProperty(prop_FlatModelDepthCorrection, languages.speak("prop_FlatModelDepthCorrection"));
                    materialEditor.ShaderProperty(prop_FlatModelFacing, languages.speak("prop_FlatModelFacing"));
                    Components.end_dynamic_disable(!prop_ToggleFlatModel.floatValue.Equals(1), configs);
                });
                sub_tab_world_aligned.process(() => {
                    prop_ToggleWorldEffect = TrackProperty("_ToggleWorldEffect", properties);
                    prop_WorldEffectBlendMode = TrackProperty("_WorldEffectBlendMode", properties);
                    prop_WorldEffectTex = TrackProperty("_WorldEffectTex", properties);
                    prop_WorldEffectMask = TrackProperty("_WorldEffectMask", properties);
                    prop_WorldEffectColor = TrackProperty("_WorldEffectColor", properties);
                    prop_WorldEffectDirection = TrackProperty("_WorldEffectDirection", properties);
                    prop_WorldEffectScale = TrackProperty("_WorldEffectScale", properties);
                    prop_WorldEffectBlendSharpness = TrackProperty("_WorldEffectBlendSharpness", properties);
                    prop_WorldEffectIntensity = TrackProperty("_WorldEffectIntensity", properties);
                    prop_WorldEffectPosition = TrackProperty("_WorldEffectPosition", properties);
                    prop_WorldEffectRotation = TrackProperty("_WorldEffectRotation", properties);
                    materialEditor.ShaderProperty(prop_ToggleWorldEffect, languages.speak("prop_ToggleWorldEffect"));
                    Components.start_dynamic_disable(!prop_ToggleWorldEffect.floatValue.Equals(1), configs);
                    materialEditor.ShaderProperty(prop_WorldEffectBlendMode, languages.speak("prop_WorldEffectBlendMode"));
                    materialEditor.ShaderProperty(prop_WorldEffectTex, languages.speak("prop_WorldEffectTex"));
                    materialEditor.ShaderProperty(prop_WorldEffectMask, languages.speak("prop_WorldEffectMask"));
                    materialEditor.ShaderProperty(prop_WorldEffectColor, languages.speak("prop_WorldEffectColor"));
                    Components.Vector3Property(materialEditor, prop_WorldEffectDirection, languages.speak("prop_WorldEffectDirection"));
                    materialEditor.ShaderProperty(prop_WorldEffectScale, languages.speak("prop_WorldEffectScale"));
                    materialEditor.ShaderProperty(prop_WorldEffectBlendSharpness, languages.speak("prop_WorldEffectBlendSharpness"));
                    materialEditor.ShaderProperty(prop_WorldEffectIntensity, languages.speak("prop_WorldEffectIntensity"));
                    Components.Vector3Property(materialEditor, prop_WorldEffectPosition, languages.speak("prop_WorldEffectPosition"));
                    Components.Vector3Property(materialEditor, prop_WorldEffectRotation, languages.speak("prop_WorldEffectRotation"));
                    Components.end_dynamic_disable(!prop_ToggleWorldEffect.floatValue.Equals(1), configs);
                });
                sub_tab_vrchat_mirror.process(() => {
                    prop_ToggleMirrorDetection = TrackProperty("_ToggleMirrorDetection", properties);
                    prop_MirrorDetectionMode = TrackProperty("_MirrorDetectionMode", properties);
                    prop_MirrorDetectionTexture = TrackProperty("_MirrorDetectionTexture", properties);
                    materialEditor.ShaderProperty(prop_ToggleMirrorDetection, languages.speak("prop_ToggleMirrorDetection"));
                    Components.start_dynamic_disable(!prop_ToggleMirrorDetection.floatValue.Equals(1), configs);
                    materialEditor.ShaderProperty(prop_MirrorDetectionMode, languages.speak("prop_MirrorDetectionMode"));
                    if ((int)prop_MirrorDetectionMode.floatValue == 0) // texture
                    {
                        materialEditor.ShaderProperty(prop_MirrorDetectionTexture, languages.speak("prop_MirrorDetectionTexture"));
                    }
                    Components.end_dynamic_disable(!prop_ToggleMirrorDetection.floatValue.Equals(1), configs);
                });
                sub_tab_touch_interactions.process(() => {
                    prop_ToggleTouchReactive = TrackProperty("_ToggleTouchReactive", properties);
                    prop_TouchColor = TrackProperty("_TouchColor", properties);
                    prop_TouchRadius = TrackProperty("_TouchRadius", properties);
                    prop_TouchHardness = TrackProperty("_TouchHardness", properties);
                    prop_TouchMode = TrackProperty("_TouchMode", properties);
                    prop_TouchRainbowSpeed = TrackProperty("_TouchRainbowSpeed", properties);
                    prop_TouchRainbowSpread = TrackProperty("_TouchRainbowSpread", properties);
                    materialEditor.ShaderProperty(prop_ToggleTouchReactive, languages.speak("prop_ToggleTouchReactive"));
                    Components.start_dynamic_disable(!prop_ToggleTouchReactive.floatValue.Equals(1), configs);
                    materialEditor.ShaderProperty(prop_TouchColor, languages.speak("prop_TouchColor"));
                    materialEditor.ShaderProperty(prop_TouchRadius, languages.speak("prop_TouchRadius"));
                    materialEditor.ShaderProperty(prop_TouchHardness, languages.speak("prop_TouchHardness"));
                    materialEditor.ShaderProperty(prop_TouchMode, languages.speak("prop_TouchMode"));
                    // rainbow options
                    Components.start_dynamic_disable(!prop_TouchMode.floatValue.Equals(3), configs);
                    EditorGUI.indentLevel++;
                    materialEditor.ShaderProperty(prop_TouchRainbowSpeed, languages.speak("prop_TouchRainbowSpeed"));
                    materialEditor.ShaderProperty(prop_TouchRainbowSpread, languages.speak("prop_TouchRainbowSpread"));
                    EditorGUI.indentLevel--;
                    Components.end_dynamic_disable(!prop_TouchMode.floatValue.Equals(3), configs);
                    Components.end_dynamic_disable(!prop_ToggleTouchReactive.floatValue.Equals(1), configs);
                    GUIStyle wrappedStyle = new GUIStyle(EditorStyles.label);
                    wrappedStyle.wordWrap = true;
                    GUILayout.Label(theme.language_manager.speak("render_queue_notice"), wrappedStyle);
                });
                sub_tab_dither.process(() => {
                    prop_ToggleDither = TrackProperty("_ToggleDither", properties);
                    prop_DitherSpace = TrackProperty("_DitherSpace", properties);
                    prop_DitherAmount = TrackProperty("_DitherAmount", properties);
                    prop_DitherScale = TrackProperty("_DitherScale", properties);
                    materialEditor.ShaderProperty(prop_ToggleDither, languages.speak("prop_ToggleDither"));
                    Components.start_dynamic_disable(!prop_ToggleDither.floatValue.Equals(1), configs);
                    materialEditor.ShaderProperty(prop_DitherSpace, languages.speak("prop_DitherSpace"));
                    materialEditor.ShaderProperty(prop_DitherAmount, languages.speak("prop_DitherAmount"));
                    materialEditor.ShaderProperty(prop_DitherScale, languages.speak("prop_DitherScale"));
                    Components.end_dynamic_disable(!prop_ToggleDither.floatValue.Equals(1), configs);
                });
                sub_tab_ps1.process(() => {
                    prop_TogglePS1 = TrackProperty("_TogglePS1", properties);
                    prop_PS1Rounding = TrackProperty("_PS1Rounding", properties);
                    prop_PS1RoundingPrecision = TrackProperty("_PS1RoundingPrecision", properties);
                    prop_PS1Compression = TrackProperty("_PS1Compression", properties);
                    prop_PS1CompressionPrecision = TrackProperty("_PS1CompressionPrecision", properties);
                    materialEditor.ShaderProperty(prop_TogglePS1, languages.speak("prop_TogglePS1"));
                    Components.start_dynamic_disable(!prop_TogglePS1.floatValue.Equals(1), configs);
                    materialEditor.ShaderProperty(prop_PS1Rounding, languages.speak("prop_PS1Rounding"));
                    Components.start_dynamic_disable(prop_PS1Rounding.floatValue.Equals(0), configs);
                    EditorGUI.indentLevel++;
                    materialEditor.ShaderProperty(prop_PS1RoundingPrecision, languages.speak("prop_PS1RoundingPrecision"));
                    EditorGUI.indentLevel--;
                    Components.end_dynamic_disable(prop_PS1Rounding.floatValue.Equals(0), configs);
                    materialEditor.ShaderProperty(prop_PS1Compression, languages.speak("prop_PS1Compression"));
                    Components.start_dynamic_disable(prop_PS1Compression.floatValue.Equals(0), configs);
                    EditorGUI.indentLevel++;
                    materialEditor.ShaderProperty(prop_PS1CompressionPrecision, languages.speak("prop_PS1CompressionPrecision"));
                    EditorGUI.indentLevel--;
                    Components.end_dynamic_disable(prop_PS1Compression.floatValue.Equals(0), configs);
                    Components.end_dynamic_disable(!prop_TogglePS1.floatValue.Equals(1), configs);
                });
                sub_tab_vertex_distortion.process(() => {
                    prop_ToggleVertexDistortion = TrackProperty("_ToggleVertexDistortion", properties);
                    prop_VertexEffectType = TrackProperty("_VertexEffectType", properties);
                    prop_VertexDistortionMode = TrackProperty("_VertexDistortionMode", properties);
                    prop_VertexGlitchMode = TrackProperty("_VertexGlitchMode", properties);
                    prop_VertexDistortionColorMask = TrackProperty("_VertexDistortionColorMask", properties);
                    prop_VertexDistortionStrength = TrackProperty("_VertexDistortionStrength", properties);
                    prop_VertexDistortionSpeed = TrackProperty("_VertexDistortionSpeed", properties);
                    prop_VertexDistortionFrequency = TrackProperty("_VertexDistortionFrequency", properties);
                    prop_WindStrength = TrackProperty("_WindStrength", properties);
                    prop_WindSpeed = TrackProperty("_WindSpeed", properties);
                    prop_WindScale = TrackProperty("_WindScale", properties);
                    prop_WindDirection = TrackProperty("_WindDirection", properties);
                    prop_WindNoiseTex = TrackProperty("_WindNoiseTex", properties);
                    prop_BreathingStrength = TrackProperty("_BreathingStrength", properties);
                    prop_BreathingSpeed = TrackProperty("_BreathingSpeed", properties);
                    prop_GlitchFrequency = TrackProperty("_GlitchFrequency", properties);
                    materialEditor.ShaderProperty(prop_ToggleVertexDistortion, languages.speak("prop_ToggleVertexDistortion"));
                    Components.start_dynamic_disable(!prop_ToggleVertexDistortion.floatValue.Equals(1), configs);
                    materialEditor.ShaderProperty(prop_VertexEffectType, languages.speak("prop_VertexEffectType"));
                    int effectType = (int)prop_VertexEffectType.floatValue;
                    if (effectType == 0) // distortion
                    {
                        materialEditor.ShaderProperty(prop_VertexDistortionMode, languages.speak("prop_VertexDistortionMode"));
                        materialEditor.ShaderProperty(prop_VertexDistortionColorMask, languages.speak("prop_VertexDistortionColorMask"));
                        int distortMode = (int)prop_VertexDistortionMode.floatValue;
                        if (distortMode == 0 || distortMode == 1) // simple or triplanar
                        {
                            Components.Vector3Property(materialEditor, prop_VertexDistortionStrength, languages.speak("prop_VertexDistortionStrength"));
                            Components.Vector3Property(materialEditor, prop_VertexDistortionSpeed, languages.speak("prop_VertexDistortionSpeed"));
                            Components.Vector3Property(materialEditor, prop_VertexDistortionFrequency, languages.speak("prop_VertexDistortionFrequency"));
                        }
                        else if (distortMode == 2) // wind
                        {
                            materialEditor.ShaderProperty(prop_WindStrength, languages.speak("prop_WindStrength"));
                            materialEditor.ShaderProperty(prop_WindSpeed, languages.speak("prop_WindSpeed"));
                            materialEditor.ShaderProperty(prop_WindScale, languages.speak("prop_WindScale"));
                            Components.Vector3Property(materialEditor, prop_WindDirection, languages.speak("prop_WindDirection"));
                            materialEditor.ShaderProperty(prop_WindNoiseTex, languages.speak("prop_WindNoiseTex"));
                        }
                        else if (distortMode == 3) // breathing
                        {
                            materialEditor.ShaderProperty(prop_BreathingStrength, languages.speak("prop_BreathingStrength"));
                            materialEditor.ShaderProperty(prop_BreathingSpeed, languages.speak("prop_BreathingSpeed"));
                        }
                    }
                    else if (effectType == 1) // glitch
                    {
                        materialEditor.ShaderProperty(prop_VertexGlitchMode, languages.speak("prop_VertexGlitchMode"));
                        materialEditor.ShaderProperty(prop_VertexDistortionColorMask, languages.speak("prop_VertexDistortionColorMask"));
                        Components.Vector3Property(materialEditor, prop_VertexDistortionStrength, languages.speak("prop_VertexDistortionStrength"));
                        Components.Vector3Property(materialEditor, prop_VertexDistortionSpeed, languages.speak("prop_VertexDistortionSpeed"));
                        Components.Vector3Property(materialEditor, prop_VertexDistortionFrequency, languages.speak("prop_VertexDistortionFrequency"));
                        materialEditor.ShaderProperty(prop_GlitchFrequency, languages.speak("prop_GlitchFrequency"));
                    }
                    Components.end_dynamic_disable(!prop_ToggleVertexDistortion.floatValue.Equals(1), configs);
                });
                sub_tab_refraction.process(() => {
                    prop_ToggleRefraction = TrackProperty("_ToggleRefraction", properties);
                    prop_RefractionSourceMode = TrackProperty("_RefractionSourceMode", properties);
                    prop_RefractionTexture = TrackProperty("_RefractionTexture", properties);
                    prop_RefractionMask = TrackProperty("_RefractionMask", properties);
                    prop_RefractionTint = TrackProperty("_RefractionTint", properties);
                    prop_RefractionIOR = TrackProperty("_RefractionIOR", properties);
                    prop_RefractionFresnel = TrackProperty("_RefractionFresnel", properties);
                    prop_RefractionOpacity = TrackProperty("_RefractionOpacity", properties);
                    prop_RefractionSeeThrough = TrackProperty("_RefractionSeeThrough", properties);
                    prop_RefractionMode = TrackProperty("_RefractionMode", properties);
                    prop_RefractionMixStrength = TrackProperty("_RefractionMixStrength", properties);
                    prop_RefractionBlendMode = TrackProperty("_RefractionBlendMode", properties);
                    prop_RefractionGrabpassTint = TrackProperty("_RefractionGrabpassTint", properties);
                    prop_RefractionZoomToggle = TrackProperty("_RefractionZoomToggle", properties);
                    prop_RefractionZoom = TrackProperty("_RefractionZoom", properties);
                    prop_CausticsTex = TrackProperty("_CausticsTex", properties);
                    prop_CausticsColor = TrackProperty("_CausticsColor", properties);
                    prop_CausticsTiling = TrackProperty("_CausticsTiling", properties);
                    prop_CausticsSpeed = TrackProperty("_CausticsSpeed", properties);
                    prop_CausticsIntensity = TrackProperty("_CausticsIntensity", properties);
                    prop_DistortionNoiseTex = TrackProperty("_DistortionNoiseTex", properties);
                    prop_DistortionNoiseTiling = TrackProperty("_DistortionNoiseTiling", properties);
                    prop_DistortionNoiseStrength = TrackProperty("_DistortionNoiseStrength", properties);
                    prop_RefractionDistortionMode = TrackProperty("_RefractionDistortionMode", properties);
                    prop_RefractionCAStrength = TrackProperty("_RefractionCAStrength", properties);
                    prop_RefractionBlurStrength = TrackProperty("_RefractionBlurStrength", properties);
                    prop_RefractionCAUseFresnel = TrackProperty("_RefractionCAUseFresnel", properties);
                    prop_RefractionCAEdgeFade = TrackProperty("_RefractionCAEdgeFade", properties);
                    materialEditor.ShaderProperty(prop_ToggleRefraction, languages.speak("prop_ToggleRefraction"));
                    Components.start_dynamic_disable(!prop_ToggleRefraction.floatValue.Equals(1), configs);
                    materialEditor.ShaderProperty(prop_RefractionSourceMode, languages.speak("prop_RefractionSourceMode"));
                    if ((int)prop_RefractionSourceMode.floatValue == 1) // texture
                    {
                        EditorGUI.indentLevel++;
                        materialEditor.ShaderProperty(prop_RefractionTexture, languages.speak("prop_RefractionTexture"));
                        EditorGUI.indentLevel--;
                    }
                    materialEditor.ShaderProperty(prop_RefractionMask, languages.speak("prop_RefractionMask"));
                    materialEditor.ShaderProperty(prop_RefractionTint, languages.speak("prop_RefractionTint"));
                    materialEditor.ShaderProperty(prop_RefractionIOR, languages.speak("prop_RefractionIOR"));
                    materialEditor.ShaderProperty(prop_RefractionFresnel, languages.speak("prop_RefractionFresnel"));
                    materialEditor.ShaderProperty(prop_RefractionOpacity, languages.speak("prop_RefractionOpacity"));
                    materialEditor.ShaderProperty(prop_RefractionSeeThrough, languages.speak("prop_RefractionSeeThrough"));
                    materialEditor.ShaderProperty(prop_RefractionMode, languages.speak("prop_RefractionMode"));
                    materialEditor.ShaderProperty(prop_RefractionMixStrength, languages.speak("prop_RefractionMixStrength"));
                    materialEditor.ShaderProperty(prop_RefractionBlendMode, languages.speak("prop_RefractionBlendMode"));
                    materialEditor.ShaderProperty(prop_RefractionGrabpassTint, languages.speak("prop_RefractionGrabpassTint"));
                    materialEditor.ShaderProperty(prop_RefractionZoomToggle, languages.speak("prop_RefractionZoomToggle"));
                    Components.start_dynamic_disable(prop_RefractionZoomToggle.floatValue.Equals(0), configs);
                    EditorGUI.indentLevel++;
                    materialEditor.ShaderProperty(prop_RefractionZoom, languages.speak("prop_RefractionZoom"));
                    EditorGUI.indentLevel--;
                    Components.end_dynamic_disable(prop_RefractionZoomToggle.floatValue.Equals(0), configs);
                    materialEditor.ShaderProperty(prop_CausticsTex, languages.speak("prop_CausticsTex"));
                    EditorGUI.indentLevel++;
                    materialEditor.ShaderProperty(prop_CausticsColor, languages.speak("prop_CausticsColor"));
                    materialEditor.ShaderProperty(prop_CausticsTiling, languages.speak("prop_CausticsTiling"));
                    materialEditor.ShaderProperty(prop_CausticsSpeed, languages.speak("prop_CausticsSpeed"));
                    materialEditor.ShaderProperty(prop_CausticsIntensity, languages.speak("prop_CausticsIntensity"));
                    EditorGUI.indentLevel--;
                    materialEditor.ShaderProperty(prop_DistortionNoiseTex, languages.speak("prop_DistortionNoiseTex"));
                    EditorGUI.indentLevel++;
                    materialEditor.ShaderProperty(prop_DistortionNoiseTiling, languages.speak("prop_DistortionNoiseTiling"));
                    materialEditor.ShaderProperty(prop_DistortionNoiseStrength, languages.speak("prop_DistortionNoiseStrength"));
                    EditorGUI.indentLevel--;
                    materialEditor.ShaderProperty(prop_RefractionDistortionMode, languages.speak("prop_RefractionDistortionMode"));
                    EditorGUI.indentLevel++;
                    int refrDistortMode = (int)prop_RefractionDistortionMode.floatValue;
                    if (refrDistortMode == 1) // chromatic aberration
                    {
                        materialEditor.ShaderProperty(prop_RefractionCAStrength, languages.speak("prop_RefractionCAStrength"));
                        materialEditor.ShaderProperty(prop_RefractionCAUseFresnel, languages.speak("prop_RefractionCAUseFresnel"));
                        Components.start_dynamic_disable(prop_RefractionCAUseFresnel.floatValue.Equals(0), configs);
                        materialEditor.ShaderProperty(prop_RefractionCAEdgeFade, languages.speak("prop_RefractionCAEdgeFade"));
                        Components.end_dynamic_disable(prop_RefractionCAUseFresnel.floatValue.Equals(0), configs);
                    }
                    else if (refrDistortMode == 2) // blur
                    {
                        materialEditor.ShaderProperty(prop_RefractionBlurStrength, languages.speak("prop_RefractionBlurStrength"));
                    }
                    EditorGUI.indentLevel--;
                    Components.end_dynamic_disable(!prop_ToggleRefraction.floatValue.Equals(1), configs);
                });
                sub_tab_screenspace_reflection.process(() => {
                    prop_ToggleSSR = TrackProperty("_ToggleSSR", properties);
                    prop_SSRSourceMode = TrackProperty("_SSRSourceMode", properties);
                    prop_SSRTexture = TrackProperty("_SSRTexture", properties);
                    prop_SSRMode = TrackProperty("_SSRMode", properties);
                    prop_SSRMask = TrackProperty("_SSRMask", properties);
                    prop_SSRTint = TrackProperty("_SSRTint", properties);
                    prop_SSRIntensity = TrackProperty("_SSRIntensity", properties);
                    prop_SSRBlendMode = TrackProperty("_SSRBlendMode", properties);
                    prop_SSRFresnelPower = TrackProperty("_SSRFresnelPower", properties);
                    prop_SSRFresnelScale = TrackProperty("_SSRFresnelScale", properties);
                    prop_SSRFresnelBias = TrackProperty("_SSRFresnelBias", properties);
                    prop_SSRCoverage = TrackProperty("_SSRCoverage", properties);
                    prop_SSRParallax = TrackProperty("_SSRParallax", properties);
                    prop_SSRDistortionMap = TrackProperty("_SSRDistortionMap", properties);
                    prop_SSRDistortionStrength = TrackProperty("_SSRDistortionStrength", properties);
                    prop_SSRWorldDistortion = TrackProperty("_SSRWorldDistortion", properties);
                    prop_SSRBlur = TrackProperty("_SSRBlur", properties);
                    prop_SSRMaxSteps = TrackProperty("_SSRMaxSteps", properties);
                    prop_SSRStepSize = TrackProperty("_SSRStepSize", properties);
                    prop_SSREdgeFade = TrackProperty("_SSREdgeFade", properties);
                    prop_SSRCamFade = TrackProperty("_SSRCamFade", properties);
                    prop_SSRCamFadeStart = TrackProperty("_SSRCamFadeStart", properties);
                    prop_SSRCamFadeEnd = TrackProperty("_SSRCamFadeEnd", properties);
                    prop_SSRFlipUV = TrackProperty("_SSRFlipUV", properties);
                    prop_SSRAdaptiveStep = TrackProperty("_SSRAdaptiveStep", properties);
                    prop_SSRThickness = TrackProperty("_SSRThickness", properties);
                    prop_SSROutOfViewMode = TrackProperty("_SSROutOfViewMode", properties);
                    materialEditor.ShaderProperty(prop_ToggleSSR, languages.speak("prop_ToggleSSR"));
                    Components.start_dynamic_disable(!prop_ToggleSSR.floatValue.Equals(1), configs);
                    materialEditor.ShaderProperty(prop_SSRSourceMode, languages.speak("prop_SSRSourceMode"));
                    if ((int)prop_SSRSourceMode.floatValue == 1) // texture
                    {
                        materialEditor.ShaderProperty(prop_SSRTexture, languages.speak("prop_SSRTexture"));
                    }
                    materialEditor.ShaderProperty(prop_SSRMode, languages.speak("prop_SSRMode"));
                    int ssrMode = (int)prop_SSRMode.floatValue;
                    if (ssrMode == 0) // planar
                    {
                        EditorGUI.indentLevel++;
                        materialEditor.ShaderProperty(prop_SSRParallax, languages.speak("prop_SSRParallax"));
                        materialEditor.ShaderProperty(prop_SSRWorldDistortion, languages.speak("prop_SSRWorldDistortion"));
                        materialEditor.ShaderProperty(prop_SSRBlur, languages.speak("prop_SSRBlur"));
                        EditorGUI.indentLevel--;
                    }
                    else if (ssrMode == 1) // raymarched
                    {
                        EditorGUI.indentLevel++;
                        materialEditor.ShaderProperty(prop_SSRMaxSteps, languages.speak("prop_SSRMaxSteps"));
                        materialEditor.ShaderProperty(prop_SSRStepSize, languages.speak("prop_SSRStepSize"));
                        materialEditor.ShaderProperty(prop_SSREdgeFade, languages.speak("prop_SSREdgeFade"));
                        materialEditor.ShaderProperty(prop_SSRAdaptiveStep, languages.speak("prop_SSRAdaptiveStep"));
                        materialEditor.ShaderProperty(prop_SSRThickness, languages.speak("prop_SSRThickness"));
                        materialEditor.ShaderProperty(prop_SSRFlipUV, languages.speak("prop_SSRFlipUV"));
                        materialEditor.ShaderProperty(prop_SSROutOfViewMode, languages.speak("prop_SSROutOfViewMode"));
                        EditorGUI.indentLevel--;
                    }
                    materialEditor.ShaderProperty(prop_SSRMask, languages.speak("prop_SSRMask"));
                    materialEditor.ShaderProperty(prop_SSRTint, languages.speak("prop_SSRTint"));
                    materialEditor.ShaderProperty(prop_SSRIntensity, languages.speak("prop_SSRIntensity"));
                    materialEditor.ShaderProperty(prop_SSRBlendMode, languages.speak("prop_SSRBlendMode"));
                    materialEditor.ShaderProperty(prop_SSRFresnelPower, languages.speak("prop_SSRFresnelPower"));
                    materialEditor.ShaderProperty(prop_SSRFresnelScale, languages.speak("prop_SSRFresnelScale"));
                    materialEditor.ShaderProperty(prop_SSRFresnelBias, languages.speak("prop_SSRFresnelBias"));
                    materialEditor.ShaderProperty(prop_SSRCoverage, languages.speak("prop_SSRCoverage"));
                    materialEditor.ShaderProperty(prop_SSRDistortionStrength, languages.speak("prop_SSRDistortionStrength"));
                    EditorGUI.indentLevel++;
                    materialEditor.ShaderProperty(prop_SSRDistortionMap, languages.speak("prop_SSRDistortionMap"));
                    EditorGUI.indentLevel--;
                    materialEditor.ShaderProperty(prop_SSRCamFade, languages.speak("prop_SSRCamFade"));
                    Components.start_dynamic_disable(prop_SSRCamFade.floatValue.Equals(0), configs);
                    EditorGUI.indentLevel++;
                    materialEditor.ShaderProperty(prop_SSRCamFadeStart, languages.speak("prop_SSRCamFadeStart"));
                    materialEditor.ShaderProperty(prop_SSRCamFadeEnd, languages.speak("prop_SSRCamFadeEnd"));
                    EditorGUI.indentLevel--;
                    Components.end_dynamic_disable(prop_SSRCamFade.floatValue.Equals(0), configs);
                    Components.end_dynamic_disable(!prop_ToggleSSR.floatValue.Equals(1), configs);
                });
                sub_tab_liquid_layer.process(() => {
                    prop_LiquidToggleLiquid = TrackProperty("_LiquidToggleLiquid", properties);
                    prop_LiquidEnabled = TrackProperty("_LiquidEnabled", properties);
                    prop_LiquidFeel = TrackProperty("_LiquidFeel", properties);
                    prop_LiquidLookWatery = TrackProperty("_LiquidLookWatery", properties);
                    prop_LiquidLookViscous = TrackProperty("_LiquidLookViscous", properties);
                    prop_LiquidSpace = TrackProperty("_LiquidSpace", properties);
                    prop_LiquidMapScale = TrackProperty("_LiquidMapScale", properties);
                    prop_LiquidTriplanarSharpness = TrackProperty("_LiquidTriplanarSharpness", properties);
                    prop_LiquidMaskMap = TrackProperty("_LiquidMaskMap", properties);
                    prop_LiquidUseForceMap = TrackProperty("_LiquidUseForceMap", properties);
                    prop_LiquidForceMap = TrackProperty("_LiquidForceMap", properties);
                    prop_LiquidSpecularLit = TrackProperty("_LiquidSpecularLit", properties);
                    prop_LiquidGloss = TrackProperty("_LiquidGloss", properties);
                    prop_LiquidShine = TrackProperty("_LiquidShine", properties);
                    prop_LiquidShineTightness = TrackProperty("_LiquidShineTightness", properties);
                    prop_LiquidShadow = TrackProperty("_LiquidShadow", properties);
                    prop_LiquidRim = TrackProperty("_LiquidRim", properties);
                    prop_LiquidDepth = TrackProperty("_LiquidDepth", properties);
                    prop_LiquidNormalStrength = TrackProperty("_LiquidNormalStrength", properties);
                    prop_LiquidOpacity = TrackProperty("_LiquidOpacity", properties);
                    prop_LiquidDarken = TrackProperty("_LiquidDarken", properties);
                    prop_LiquidManualDirection = TrackProperty("_LiquidManualDirection", properties);
                    prop_LiquidDirectionOne = TrackProperty("_LiquidDirectionOne", properties);
                    prop_LiquidDirectionTwo = TrackProperty("_LiquidDirectionTwo", properties);
                    prop_LiquidLayerOneScale = TrackProperty("_LiquidLayerOneScale", properties);
                    prop_LiquidLayerOneDensity = TrackProperty("_LiquidLayerOneDensity", properties);
                    prop_LiquidLayerOneStretch = TrackProperty("_LiquidLayerOneStretch", properties);
                    prop_LiquidLayerOneSpeed = TrackProperty("_LiquidLayerOneSpeed", properties);
                    prop_LiquidLayerOneRandomness = TrackProperty("_LiquidLayerOneRandomness", properties);
                    prop_LiquidLayerOneSeed = TrackProperty("_LiquidLayerOneSeed", properties);
                    prop_LiquidLayerOneMod = TrackProperty("_LiquidLayerOneMod", properties);
                    prop_LiquidUseLayerTwo = TrackProperty("_LiquidUseLayerTwo", properties);
                    prop_LiquidLayerTwoScale = TrackProperty("_LiquidLayerTwoScale", properties);
                    prop_LiquidLayerTwoDensity = TrackProperty("_LiquidLayerTwoDensity", properties);
                    prop_LiquidLayerTwoStretch = TrackProperty("_LiquidLayerTwoStretch", properties);
                    prop_LiquidLayerTwoSpeed = TrackProperty("_LiquidLayerTwoSpeed", properties);
                    prop_LiquidLayerTwoRandomness = TrackProperty("_LiquidLayerTwoRandomness", properties);
                    prop_LiquidLayerTwoSeed = TrackProperty("_LiquidLayerTwoSeed", properties);
                    prop_LiquidLayerTwoAmount = TrackProperty("_LiquidLayerTwoAmount", properties);
                    prop_LiquidLayerTwoMod = TrackProperty("_LiquidLayerTwoMod", properties);
                    prop_LiquidUseCluster = TrackProperty("_LiquidUseCluster", properties);
                    prop_LiquidClusterScale = TrackProperty("_LiquidClusterScale", properties);
                    prop_LiquidClusterSeed = TrackProperty("_LiquidClusterSeed", properties);
                    prop_LiquidThreshold = TrackProperty("_LiquidThreshold", properties);
                    prop_LiquidSoftness = TrackProperty("_LiquidSoftness", properties);
                    prop_LiquidWateryCoverage = TrackProperty("_LiquidWateryCoverage", properties);
                    prop_LiquidViscousSmooth = TrackProperty("_LiquidViscousSmooth", properties);
                    prop_LiquidViscousThinning = TrackProperty("_LiquidViscousThinning", properties);
                    prop_LiquidViscousThinSeed = TrackProperty("_LiquidViscousThinSeed", properties);
                    prop_LiquidViscousThinScale = TrackProperty("_LiquidViscousThinScale", properties);
                    prop_LiquidSweatUseTint = TrackProperty("_LiquidSweatUseTint", properties);
                    prop_LiquidSweatTintColor = TrackProperty("_LiquidSweatTintColor", properties);
                    prop_LiquidBloodColorFresh = TrackProperty("_LiquidBloodColorFresh", properties);
                    prop_LiquidBloodColorDark = TrackProperty("_LiquidBloodColorDark", properties);
                    prop_LiquidBloodPooling = TrackProperty("_LiquidBloodPooling", properties);
                    prop_LiquidBloodDryingRate = TrackProperty("_LiquidBloodDryingRate", properties);
                    prop_LiquidBloodDryGloss = TrackProperty("_LiquidBloodDryGloss", properties);
                    prop_LiquidOilColor = TrackProperty("_LiquidOilColor", properties);
                    prop_LiquidOilIridescence = TrackProperty("_LiquidOilIridescence", properties);
                    prop_LiquidOilIridescenceScale = TrackProperty("_LiquidOilIridescenceScale", properties);
                    prop_LiquidOilViewBased = TrackProperty("_LiquidOilViewBased", properties);
                    prop_LiquidOilViewBasedCoverage = TrackProperty("_LiquidOilViewBasedCoverage", properties);
                    prop_LiquidIcingColor = TrackProperty("_LiquidIcingColor", properties);
                    prop_LiquidIcingColorVariation = TrackProperty("_LiquidIcingColorVariation", properties);
                    prop_LiquidIcingColorMin = TrackProperty("_LiquidIcingColorMin", properties);
                    prop_LiquidIcingColorMax = TrackProperty("_LiquidIcingColorMax", properties);
                    prop_LiquidIcingColorScale = TrackProperty("_LiquidIcingColorScale", properties);
                    prop_LiquidIcingColorSeed = TrackProperty("_LiquidIcingColorSeed", properties);
                    prop_LiquidWaxColor = TrackProperty("_LiquidWaxColor", properties);
                    prop_LiquidWaxColorVariation = TrackProperty("_LiquidWaxColorVariation", properties);
                    prop_LiquidWaxCoolRate = TrackProperty("_LiquidWaxCoolRate", properties);
                    prop_LiquidSlimeColor = TrackProperty("_LiquidSlimeColor", properties);
                    prop_LiquidSlimeColorShift = TrackProperty("_LiquidSlimeColorShift", properties);
                    prop_LiquidSlimeTranslucency = TrackProperty("_LiquidSlimeTranslucency", properties);
                    prop_LiquidSlimeIridescence = TrackProperty("_LiquidSlimeIridescence", properties);
                    prop_LiquidSlimeStickiness = TrackProperty("_LiquidSlimeStickiness", properties);
                    prop_LiquidMudColor = TrackProperty("_LiquidMudColor", properties);
                    prop_LiquidMudColorDark = TrackProperty("_LiquidMudColorDark", properties);
                    prop_LiquidMudRoughness = TrackProperty("_LiquidMudRoughness", properties);
                    materialEditor.ShaderProperty(prop_LiquidToggleLiquid, languages.speak("prop_LiquidToggleLiquid"));
                    Components.start_dynamic_disable(!prop_LiquidToggleLiquid.floatValue.Equals(1), configs);
                    materialEditor.ShaderProperty(prop_LiquidEnabled, languages.speak("prop_LiquidEnabled"));
                    materialEditor.ShaderProperty(prop_LiquidFeel, languages.speak("prop_LiquidFeel"));
                    int liquidFeel = (int)prop_LiquidFeel.floatValue;
                    if (liquidFeel == 0) // watery
                    {
                        EditorGUI.indentLevel++;
                        materialEditor.ShaderProperty(prop_LiquidLookWatery, languages.speak("prop_LiquidLookWatery"));
                        EditorGUI.indentLevel--;
                    }
                    else if (liquidFeel == 1) // viscous
                    {
                        EditorGUI.indentLevel++;
                        materialEditor.ShaderProperty(prop_LiquidLookViscous, languages.speak("prop_LiquidLookViscous"));
                        EditorGUI.indentLevel--;
                    }
                    materialEditor.ShaderProperty(prop_LiquidSpace, languages.speak("prop_LiquidSpace"));
                    EditorGUI.indentLevel++;
                    materialEditor.ShaderProperty(prop_LiquidMapScale, languages.speak("prop_LiquidMapScale"));
                    if ((int)prop_LiquidSpace.floatValue == 5) // triplanar
                    {
                        materialEditor.ShaderProperty(prop_LiquidTriplanarSharpness, languages.speak("prop_LiquidTriplanarSharpness"));
                    }
                    EditorGUI.indentLevel--;
                    materialEditor.ShaderProperty(prop_LiquidMaskMap, languages.speak("prop_LiquidMaskMap"));
                    materialEditor.ShaderProperty(prop_LiquidUseForceMap, languages.speak("prop_LiquidUseForceMap"));
                    Components.start_dynamic_disable(prop_LiquidUseForceMap.floatValue.Equals(0), configs);
                    EditorGUI.indentLevel++;
                    materialEditor.ShaderProperty(prop_LiquidForceMap, languages.speak("prop_LiquidForceMap"));
                    EditorGUI.indentLevel--;
                    Components.end_dynamic_disable(prop_LiquidUseForceMap.floatValue.Equals(0), configs);
                    materialEditor.ShaderProperty(prop_LiquidSpecularLit, languages.speak("prop_LiquidSpecularLit"));
                    materialEditor.ShaderProperty(prop_LiquidGloss, languages.speak("prop_LiquidGloss"));
                    materialEditor.ShaderProperty(prop_LiquidShine, languages.speak("prop_LiquidShine"));
                    materialEditor.ShaderProperty(prop_LiquidShineTightness, languages.speak("prop_LiquidShineTightness"));
                    materialEditor.ShaderProperty(prop_LiquidShadow, languages.speak("prop_LiquidShadow"));
                    materialEditor.ShaderProperty(prop_LiquidRim, languages.speak("prop_LiquidRim"));
                    materialEditor.ShaderProperty(prop_LiquidDepth, languages.speak("prop_LiquidDepth"));
                    materialEditor.ShaderProperty(prop_LiquidNormalStrength, languages.speak("prop_LiquidNormalStrength"));
                    materialEditor.ShaderProperty(prop_LiquidOpacity, languages.speak("prop_LiquidOpacity"));
                    materialEditor.ShaderProperty(prop_LiquidDarken, languages.speak("prop_LiquidDarken"));
                    materialEditor.ShaderProperty(prop_LiquidManualDirection, languages.speak("prop_LiquidManualDirection"));
                    Components.start_dynamic_disable(prop_LiquidManualDirection.floatValue.Equals(0), configs);
                    EditorGUI.indentLevel++;
                    Components.Vector3Property(materialEditor, prop_LiquidDirectionOne, languages.speak("prop_LiquidDirectionOne"));
                    Components.Vector3Property(materialEditor, prop_LiquidDirectionTwo, languages.speak("prop_LiquidDirectionTwo"));
                    EditorGUI.indentLevel--;
                    Components.end_dynamic_disable(prop_LiquidManualDirection.floatValue.Equals(0), configs);
                    materialEditor.ShaderProperty(prop_LiquidLayerOneScale, languages.speak("prop_LiquidLayerOneScale"));
                    materialEditor.ShaderProperty(prop_LiquidLayerOneDensity, languages.speak("prop_LiquidLayerOneDensity"));
                    materialEditor.ShaderProperty(prop_LiquidLayerOneStretch, languages.speak("prop_LiquidLayerOneStretch"));
                    materialEditor.ShaderProperty(prop_LiquidLayerOneSpeed, languages.speak("prop_LiquidLayerOneSpeed"));
                    materialEditor.ShaderProperty(prop_LiquidLayerOneRandomness, languages.speak("prop_LiquidLayerOneRandomness"));
                    materialEditor.ShaderProperty(prop_LiquidLayerOneSeed, languages.speak("prop_LiquidLayerOneSeed"));
                    materialEditor.ShaderProperty(prop_LiquidLayerOneMod, languages.speak("prop_LiquidLayerOneMod"));
                    materialEditor.ShaderProperty(prop_LiquidUseLayerTwo, languages.speak("prop_LiquidUseLayerTwo"));
                    Components.start_dynamic_disable(prop_LiquidUseLayerTwo.floatValue.Equals(0), configs);
                    EditorGUI.indentLevel++;
                    materialEditor.ShaderProperty(prop_LiquidLayerTwoScale, languages.speak("prop_LiquidLayerTwoScale"));
                    materialEditor.ShaderProperty(prop_LiquidLayerTwoDensity, languages.speak("prop_LiquidLayerTwoDensity"));
                    materialEditor.ShaderProperty(prop_LiquidLayerTwoStretch, languages.speak("prop_LiquidLayerTwoStretch"));
                    materialEditor.ShaderProperty(prop_LiquidLayerTwoSpeed, languages.speak("prop_LiquidLayerTwoSpeed"));
                    materialEditor.ShaderProperty(prop_LiquidLayerTwoRandomness, languages.speak("prop_LiquidLayerTwoRandomness"));
                    materialEditor.ShaderProperty(prop_LiquidLayerTwoSeed, languages.speak("prop_LiquidLayerTwoSeed"));
                    materialEditor.ShaderProperty(prop_LiquidLayerTwoAmount, languages.speak("prop_LiquidLayerTwoAmount"));
                    materialEditor.ShaderProperty(prop_LiquidLayerTwoMod, languages.speak("prop_LiquidLayerTwoMod"));
                    EditorGUI.indentLevel--;
                    Components.end_dynamic_disable(prop_LiquidUseLayerTwo.floatValue.Equals(0), configs);
                    materialEditor.ShaderProperty(prop_LiquidUseCluster, languages.speak("prop_LiquidUseCluster"));
                    materialEditor.ShaderProperty(prop_LiquidClusterScale, languages.speak("prop_LiquidClusterScale"));
                    materialEditor.ShaderProperty(prop_LiquidClusterSeed, languages.speak("prop_LiquidClusterSeed"));
                    materialEditor.ShaderProperty(prop_LiquidThreshold, languages.speak("prop_LiquidThreshold"));
                    materialEditor.ShaderProperty(prop_LiquidSoftness, languages.speak("prop_LiquidSoftness"));
                    if (liquidFeel == 0) // watery
                    {
                        materialEditor.ShaderProperty(prop_LiquidWateryCoverage, languages.speak("prop_LiquidWateryCoverage"));
                        int wateryLook = (int)prop_LiquidLookWatery.floatValue;
                        if (wateryLook == 0) // sweat
                        {
                            materialEditor.ShaderProperty(prop_LiquidSweatUseTint, languages.speak("prop_LiquidSweatUseTint"));
                            Components.start_dynamic_disable(prop_LiquidSweatUseTint.floatValue.Equals(0), configs);
                            EditorGUI.indentLevel++;
                            materialEditor.ShaderProperty(prop_LiquidSweatTintColor, languages.speak("prop_LiquidSweatTintColor"));
                            EditorGUI.indentLevel--;
                            Components.end_dynamic_disable(prop_LiquidSweatUseTint.floatValue.Equals(0), configs);
                        }
                        else if (wateryLook == 1) // blood
                        {
                            materialEditor.ShaderProperty(prop_LiquidBloodColorFresh, languages.speak("prop_LiquidBloodColorFresh"));
                            materialEditor.ShaderProperty(prop_LiquidBloodColorDark, languages.speak("prop_LiquidBloodColorDark"));
                            materialEditor.ShaderProperty(prop_LiquidBloodPooling, languages.speak("prop_LiquidBloodPooling"));
                            materialEditor.ShaderProperty(prop_LiquidBloodDryingRate, languages.speak("prop_LiquidBloodDryingRate"));
                            materialEditor.ShaderProperty(prop_LiquidBloodDryGloss, languages.speak("prop_LiquidBloodDryGloss"));
                        }
                        else if (wateryLook == 2) // oil
                        {
                            materialEditor.ShaderProperty(prop_LiquidOilColor, languages.speak("prop_LiquidOilColor"));
                            materialEditor.ShaderProperty(prop_LiquidOilIridescence, languages.speak("prop_LiquidOilIridescence"));
                            materialEditor.ShaderProperty(prop_LiquidOilIridescenceScale, languages.speak("prop_LiquidOilIridescenceScale"));
                            materialEditor.ShaderProperty(prop_LiquidOilViewBased, languages.speak("prop_LiquidOilViewBased"));
                            Components.start_dynamic_disable(prop_LiquidOilViewBased.floatValue.Equals(0), configs);
                            EditorGUI.indentLevel++;
                            materialEditor.ShaderProperty(prop_LiquidOilViewBasedCoverage, languages.speak("prop_LiquidOilViewBasedCoverage"));
                            EditorGUI.indentLevel--;
                            Components.end_dynamic_disable(prop_LiquidOilViewBased.floatValue.Equals(0), configs);
                        }
                    }
                    else if (liquidFeel == 1) // viscous
                    {
                        materialEditor.ShaderProperty(prop_LiquidViscousSmooth, languages.speak("prop_LiquidViscousSmooth"));
                        materialEditor.ShaderProperty(prop_LiquidViscousThinning, languages.speak("prop_LiquidViscousThinning"));
                        materialEditor.ShaderProperty(prop_LiquidViscousThinSeed, languages.speak("prop_LiquidViscousThinSeed"));
                        materialEditor.ShaderProperty(prop_LiquidViscousThinScale, languages.speak("prop_LiquidViscousThinScale"));
                        int viscousLook = (int)prop_LiquidLookViscous.floatValue;
                        if (viscousLook == 0) // icing
                        {
                            materialEditor.ShaderProperty(prop_LiquidIcingColor, languages.speak("prop_LiquidIcingColor"));
                            materialEditor.ShaderProperty(prop_LiquidIcingColorVariation, languages.speak("prop_LiquidIcingColorVariation"));
                            Components.start_dynamic_disable(prop_LiquidIcingColorVariation.floatValue.Equals(0), configs);
                            EditorGUI.indentLevel++;
                            materialEditor.ShaderProperty(prop_LiquidIcingColorMin, languages.speak("prop_LiquidIcingColorMin"));
                            materialEditor.ShaderProperty(prop_LiquidIcingColorMax, languages.speak("prop_LiquidIcingColorMax"));
                            materialEditor.ShaderProperty(prop_LiquidIcingColorScale, languages.speak("prop_LiquidIcingColorScale"));
                            materialEditor.ShaderProperty(prop_LiquidIcingColorSeed, languages.speak("prop_LiquidIcingColorSeed"));
                            EditorGUI.indentLevel--;
                            Components.end_dynamic_disable(prop_LiquidIcingColorVariation.floatValue.Equals(0), configs);
                        }
                        else if (viscousLook == 1) // slime
                        {
                            materialEditor.ShaderProperty(prop_LiquidSlimeColor, languages.speak("prop_LiquidSlimeColor"));
                            materialEditor.ShaderProperty(prop_LiquidSlimeColorShift, languages.speak("prop_LiquidSlimeColorShift"));
                            materialEditor.ShaderProperty(prop_LiquidSlimeTranslucency, languages.speak("prop_LiquidSlimeTranslucency"));
                            materialEditor.ShaderProperty(prop_LiquidSlimeIridescence, languages.speak("prop_LiquidSlimeIridescence"));
                            materialEditor.ShaderProperty(prop_LiquidSlimeStickiness, languages.speak("prop_LiquidSlimeStickiness"));
                        }
                        else if (viscousLook == 2) // wax
                        {
                            materialEditor.ShaderProperty(prop_LiquidWaxColor, languages.speak("prop_LiquidWaxColor"));
                            materialEditor.ShaderProperty(prop_LiquidWaxColorVariation, languages.speak("prop_LiquidWaxColorVariation"));
                            materialEditor.ShaderProperty(prop_LiquidWaxCoolRate, languages.speak("prop_LiquidWaxCoolRate"));
                        }
                        else if (viscousLook == 3) // mud
                        {
                            materialEditor.ShaderProperty(prop_LiquidMudColor, languages.speak("prop_LiquidMudColor"));
                            materialEditor.ShaderProperty(prop_LiquidMudColorDark, languages.speak("prop_LiquidMudColorDark"));
                            materialEditor.ShaderProperty(prop_LiquidMudRoughness, languages.speak("prop_LiquidMudRoughness"));
                        }
                    }
                    Components.end_dynamic_disable(!prop_LiquidToggleLiquid.floatValue.Equals(1), configs);
                });
                Components.end_foldout();
            });
            // world tab
            tab_world.process(() => {
                Components.start_foldout();
                sub_tab_stochastic.process(() => {
                    prop_StochasticSampling = TrackProperty("_StochasticSampling", properties);
                    prop_StochasticSamplingMode = TrackProperty("_StochasticSamplingMode", properties);
                    prop_StochasticTexture = TrackProperty("_StochasticTexture", properties);
                    prop_StochasticOpacity = TrackProperty("_StochasticOpacity", properties);
                    prop_StochasticBlendMode = TrackProperty("_StochasticBlendMode", properties);
                    prop_StochasticScale = TrackProperty("_StochasticScale", properties);
                    prop_StochasticOffsetX = TrackProperty("_StochasticOffsetX", properties);
                    prop_StochasticOffsetY = TrackProperty("_StochasticOffsetY", properties);
                    prop_StochasticTint = TrackProperty("_StochasticTint", properties);
                    prop_StochasticBlend = TrackProperty("_StochasticBlend", properties);
                    prop_StochasticRotationRange = TrackProperty("_StochasticRotationRange", properties);
                    prop_StochasticPriority = TrackProperty("_StochasticPriority", properties);
                    prop_StochasticContrastStrength = TrackProperty("_StochasticContrastStrength", properties);
                    prop_StochasticContrastThreshold = TrackProperty("_StochasticContrastThreshold", properties);
                    prop_StochasticHeightBlend = TrackProperty("_StochasticHeightBlend", properties);
                    prop_StochasticHeightMap = TrackProperty("_StochasticHeightMap", properties);
                    prop_StochasticHeightStrength = TrackProperty("_StochasticHeightStrength", properties);
                    prop_StochasticMipBias = TrackProperty("_StochasticMipBias", properties);
                    prop_StochasticAlpha = TrackProperty("_StochasticAlpha", properties);
                    prop_StochasticNormals = TrackProperty("_StochasticNormals", properties);
                    materialEditor.ShaderProperty(prop_StochasticSampling, languages.speak("prop_StochasticSampling"));
                    Components.start_dynamic_disable(!prop_StochasticSampling.floatValue.Equals(1), configs);
                    materialEditor.ShaderProperty(prop_StochasticSamplingMode, languages.speak("prop_StochasticSamplingMode"));
                    EditorGUI.indentLevel++;
                    int stochasticMode = (int)prop_StochasticSamplingMode.floatValue;
                    if (stochasticMode == 0)
                    {
                        EditorGUI.indentLevel++;
                        materialEditor.ShaderProperty(prop_StochasticBlend, languages.speak("prop_StochasticBlend"));
                        materialEditor.ShaderProperty(prop_StochasticRotationRange, languages.speak("prop_StochasticRotationRange"));
                        EditorGUI.indentLevel--;
                    }
                    else if (stochasticMode == 1)
                    {
                        EditorGUI.indentLevel++;
                        materialEditor.ShaderProperty(prop_StochasticPriority, languages.speak("prop_StochasticPriority"));
                        materialEditor.ShaderProperty(prop_StochasticContrastStrength, languages.speak("prop_StochasticContrastStrength"));
                        materialEditor.ShaderProperty(prop_StochasticContrastThreshold, languages.speak("prop_StochasticContrastThreshold"));
                        EditorGUI.indentLevel--;
                    }
                    EditorGUI.indentLevel--;
                    materialEditor.ShaderProperty(prop_StochasticTexture, languages.speak("prop_StochasticTexture"));
                    materialEditor.ShaderProperty(prop_StochasticMipBias, languages.speak("prop_StochasticMipBias"));
                    materialEditor.ShaderProperty(prop_StochasticScale, languages.speak("prop_StochasticScale"));
                    materialEditor.ShaderProperty(prop_StochasticOffsetX, languages.speak("prop_StochasticOffsetX"));
                    materialEditor.ShaderProperty(prop_StochasticOffsetY, languages.speak("prop_StochasticOffsetY"));
                    materialEditor.ShaderProperty(prop_StochasticOpacity, languages.speak("prop_StochasticOpacity"));
                    materialEditor.ShaderProperty(prop_StochasticTint, languages.speak("prop_StochasticTint"));
                    materialEditor.ShaderProperty(prop_StochasticBlendMode, languages.speak("prop_StochasticBlendMode"));
                    materialEditor.ShaderProperty(prop_StochasticAlpha, languages.speak("prop_StochasticAlpha"));
                    materialEditor.ShaderProperty(prop_StochasticNormals, languages.speak("prop_StochasticNormals"));
                    materialEditor.ShaderProperty(prop_StochasticHeightBlend, languages.speak("prop_StochasticHeightBlend"));
                    Components.start_dynamic_disable(prop_StochasticHeightBlend.floatValue.Equals(0), configs);
                    EditorGUI.indentLevel++;
                    materialEditor.ShaderProperty(prop_StochasticHeightMap, languages.speak("prop_StochasticHeightMap"));
                    materialEditor.ShaderProperty(prop_StochasticHeightStrength, languages.speak("prop_StochasticHeightStrength"));
                    EditorGUI.indentLevel--;
                    Components.end_dynamic_disable(prop_StochasticHeightBlend.floatValue.Equals(0), configs);
                    Components.end_dynamic_disable(!prop_StochasticSampling.floatValue.Equals(1), configs);
                });
                sub_tab_splatter.process(() => {
                    prop_SplatterMapping = TrackProperty("_SplatterMapping", properties);
                    prop_SplatterMappingMode = TrackProperty("_SplatterMappingMode", properties);
                    prop_SplatterControl = TrackProperty("_SplatterControl", properties);
                    prop_SplatterUseNormals = TrackProperty("_SplatterUseNormals", properties);
                    prop_SplatterAlbedo0 = TrackProperty("_SplatterAlbedo0", properties);
                    prop_SplatterNormal0 = TrackProperty("_SplatterNormal0", properties);
                    prop_SplatterMasks0 = TrackProperty("_SplatterMasks0", properties);
                    prop_SplatterColor0 = TrackProperty("_SplatterColor0", properties);
                    prop_SplatterTiling0 = TrackProperty("_SplatterTiling0", properties);
                    prop_SplatterNormalStrength0 = TrackProperty("_SplatterNormalStrength0", properties);
                    prop_SplatterBlendMode0 = TrackProperty("_SplatterBlendMode0", properties);
                    prop_SplatterAlbedo1 = TrackProperty("_SplatterAlbedo1", properties);
                    prop_SplatterNormal1 = TrackProperty("_SplatterNormal1", properties);
                    prop_SplatterMasks1 = TrackProperty("_SplatterMasks1", properties);
                    prop_SplatterColor1 = TrackProperty("_SplatterColor1", properties);
                    prop_SplatterTiling1 = TrackProperty("_SplatterTiling1", properties);
                    prop_SplatterNormalStrength1 = TrackProperty("_SplatterNormalStrength1", properties);
                    prop_SplatterBlendMode1 = TrackProperty("_SplatterBlendMode1", properties);
                    prop_SplatterCullThreshold = TrackProperty("_SplatterCullThreshold", properties);
                    prop_SplatterBlendSharpness = TrackProperty("_SplatterBlendSharpness", properties);
                    prop_SplatterMipBias = TrackProperty("_SplatterMipBias", properties);
                    prop_SplatterAlphaChannel = TrackProperty("_SplatterAlphaChannel", properties);
                    materialEditor.ShaderProperty(prop_SplatterMapping, languages.speak("prop_SplatterMapping"));
                    Components.start_dynamic_disable(!prop_SplatterMapping.floatValue.Equals(1), configs);
                    materialEditor.ShaderProperty(prop_SplatterMappingMode, languages.speak("prop_SplatterMappingMode"));
                    materialEditor.ShaderProperty(prop_SplatterControl, languages.speak("prop_SplatterControl"));
                    EditorGUILayout.LabelField(languages.speak("header_layer_one"), EditorStyles.boldLabel);
                    EditorGUI.indentLevel++;
                    materialEditor.ShaderProperty(prop_SplatterAlbedo0, languages.speak("prop_SplatterAlbedo0"));
                    materialEditor.ShaderProperty(prop_SplatterNormal0, languages.speak("prop_SplatterNormal0"));
                    materialEditor.ShaderProperty(prop_SplatterMasks0, languages.speak("prop_SplatterMasks0"));
                    materialEditor.ShaderProperty(prop_SplatterColor0, languages.speak("prop_SplatterColor0"));
                    materialEditor.ShaderProperty(prop_SplatterTiling0, languages.speak("prop_SplatterTiling0"));
                    materialEditor.ShaderProperty(prop_SplatterNormalStrength0, languages.speak("prop_SplatterNormalStrength0"));
                    materialEditor.ShaderProperty(prop_SplatterBlendMode0, languages.speak("prop_SplatterBlendMode0"));
                    EditorGUI.indentLevel--;
                    EditorGUILayout.LabelField(languages.speak("header_layer_two"), EditorStyles.boldLabel);
                    EditorGUI.indentLevel++;
                    materialEditor.ShaderProperty(prop_SplatterAlbedo1, languages.speak("prop_SplatterAlbedo1"));
                    materialEditor.ShaderProperty(prop_SplatterNormal1, languages.speak("prop_SplatterNormal1"));
                    materialEditor.ShaderProperty(prop_SplatterMasks1, languages.speak("prop_SplatterMasks1"));
                    materialEditor.ShaderProperty(prop_SplatterColor1, languages.speak("prop_SplatterColor1"));
                    materialEditor.ShaderProperty(prop_SplatterTiling1, languages.speak("prop_SplatterTiling1"));
                    materialEditor.ShaderProperty(prop_SplatterNormalStrength1, languages.speak("prop_SplatterNormalStrength1"));
                    materialEditor.ShaderProperty(prop_SplatterBlendMode1, languages.speak("prop_SplatterBlendMode1"));
                    EditorGUI.indentLevel--;
                    materialEditor.ShaderProperty(prop_SplatterCullThreshold, languages.speak("prop_SplatterCullThreshold"));
                    materialEditor.ShaderProperty(prop_SplatterBlendSharpness, languages.speak("prop_SplatterBlendSharpness"));
                    materialEditor.ShaderProperty(prop_SplatterMipBias, languages.speak("prop_SplatterMipBias"));
                    materialEditor.ShaderProperty(prop_SplatterUseNormals, languages.speak("prop_SplatterUseNormals"));
                    materialEditor.ShaderProperty(prop_SplatterAlphaChannel, languages.speak("prop_SplatterAlphaChannel"));
                    Components.end_dynamic_disable(!prop_SplatterMapping.floatValue.Equals(1), configs);
                });
                sub_tab_bombing.process(() => {
                    prop_BombingTextures = TrackProperty("_BombingTextures", properties);
                    prop_BombingMode = TrackProperty("_BombingMode", properties);
                    prop_BombingBlendMode = TrackProperty("_BombingBlendMode", properties);
                    prop_BombingMappingMode = TrackProperty("_BombingMappingMode", properties);
                    prop_BombingTriplanarSharpness = TrackProperty("_BombingTriplanarSharpness", properties);
                    prop_BombingThreshold = TrackProperty("_BombingThreshold", properties);
                    prop_BombingOpacity = TrackProperty("_BombingOpacity", properties);
                    prop_BombingTex = TrackProperty("_BombingTex", properties);
                    prop_BombingColor = TrackProperty("_BombingColor", properties);
                    prop_BombingTiling = TrackProperty("_BombingTiling", properties);
                    prop_BombingDensity = TrackProperty("_BombingDensity", properties);
                    prop_BombingGlobalScale = TrackProperty("_BombingGlobalScale", properties);
                    prop_BombingJitterAmount = TrackProperty("_BombingJitterAmount", properties);
                    prop_BombingScaleVar = TrackProperty("_BombingScaleVar", properties);
                    prop_BombingRotVar = TrackProperty("_BombingRotVar", properties);
                    prop_BombingHueVar = TrackProperty("_BombingHueVar", properties);
                    prop_BombingSatVar = TrackProperty("_BombingSatVar", properties);
                    prop_BombingValVar = TrackProperty("_BombingValVar", properties);
                    prop_BombingUseNormal = TrackProperty("_BombingUseNormal", properties);
                    prop_BombingNormal = TrackProperty("_BombingNormal", properties);
                    prop_BombingNormalStrength = TrackProperty("_BombingNormalStrength", properties);
                    prop_BombingUseSheet = TrackProperty("_BombingUseSheet", properties);
                    prop_BombingSheetData = TrackProperty("_BombingSheetData", properties);
                    prop_BombingCullDist = TrackProperty("_BombingCullDist", properties);
                    prop_BombingCullFalloff = TrackProperty("_BombingCullFalloff", properties);
                    materialEditor.ShaderProperty(prop_BombingTextures, languages.speak("prop_BombingTextures"));
                    Components.start_dynamic_disable(!prop_BombingTextures.floatValue.Equals(1), configs);
                    materialEditor.ShaderProperty(prop_BombingMode, languages.speak("prop_BombingMode"));
                    materialEditor.ShaderProperty(prop_BombingBlendMode, languages.speak("prop_BombingBlendMode"));
                    materialEditor.ShaderProperty(prop_BombingMappingMode, languages.speak("prop_BombingMappingMode"));
                    Components.start_dynamic_disable(prop_BombingMappingMode.floatValue.Equals(0), configs);
                    materialEditor.ShaderProperty(prop_BombingTriplanarSharpness, languages.speak("prop_BombingTriplanarSharpness"));
                    Components.end_dynamic_disable(prop_BombingMappingMode.floatValue.Equals(0), configs);
                    materialEditor.ShaderProperty(prop_BombingThreshold, languages.speak("prop_BombingThreshold"));
                    materialEditor.ShaderProperty(prop_BombingOpacity, languages.speak("prop_BombingOpacity"));
                    materialEditor.ShaderProperty(prop_BombingTex, languages.speak("prop_BombingTex"));
                    materialEditor.ShaderProperty(prop_BombingColor, languages.speak("prop_BombingColor"));
                    materialEditor.ShaderProperty(prop_BombingTiling, languages.speak("prop_BombingTiling"));
                    materialEditor.ShaderProperty(prop_BombingDensity, languages.speak("prop_BombingDensity"));
                    materialEditor.ShaderProperty(prop_BombingGlobalScale, languages.speak("prop_BombingGlobalScale"));
                    materialEditor.ShaderProperty(prop_BombingJitterAmount, languages.speak("prop_BombingJitterAmount"));
                    EditorGUILayout.LabelField(languages.speak("header_variation"), EditorStyles.boldLabel);
                    EditorGUI.indentLevel++;
                    materialEditor.ShaderProperty(prop_BombingScaleVar, languages.speak("prop_BombingScaleVar"));
                    materialEditor.ShaderProperty(prop_BombingRotVar, languages.speak("prop_BombingRotVar"));
                    materialEditor.ShaderProperty(prop_BombingHueVar, languages.speak("prop_BombingHueVar"));
                    materialEditor.ShaderProperty(prop_BombingSatVar, languages.speak("prop_BombingSatVar"));
                    materialEditor.ShaderProperty(prop_BombingValVar, languages.speak("prop_BombingValVar"));
                    EditorGUI.indentLevel--;
                    materialEditor.ShaderProperty(prop_BombingUseNormal, languages.speak("prop_BombingUseNormal"));
                    Components.start_dynamic_disable(prop_BombingUseNormal.floatValue.Equals(0), configs);
                    EditorGUI.indentLevel++;
                    materialEditor.ShaderProperty(prop_BombingNormal, languages.speak("prop_BombingNormal"));
                    materialEditor.ShaderProperty(prop_BombingNormalStrength, languages.speak("prop_BombingNormalStrength"));
                    EditorGUI.indentLevel--;
                    Components.end_dynamic_disable(prop_BombingUseNormal.floatValue.Equals(0), configs);
                    materialEditor.ShaderProperty(prop_BombingUseSheet, languages.speak("prop_BombingUseSheet"));
                    Components.start_dynamic_disable(prop_BombingUseSheet.floatValue.Equals(0), configs);
                    EditorGUI.indentLevel++;
                    materialEditor.ShaderProperty(prop_BombingSheetData, languages.speak("prop_BombingSheetData"));
                    EditorGUI.indentLevel--;
                    Components.end_dynamic_disable(prop_BombingUseSheet.floatValue.Equals(0), configs);
                    materialEditor.ShaderProperty(prop_BombingCullDist, languages.speak("prop_BombingCullDist"));
                    materialEditor.ShaderProperty(prop_BombingCullFalloff, languages.speak("prop_BombingCullFalloff"));
                    Components.end_dynamic_disable(!prop_BombingTextures.floatValue.Equals(1), configs);
                });
                Components.end_foldout();
            });
            // outline tab
            tab_outline.process(() => {
                Components.start_foldout();
                prop_ToggleLitOutline = TrackProperty("_ToggleLitOutline", properties);
                prop_OutlineLitMix = TrackProperty("_OutlineLitMix", properties);
                prop_OutlineColor = TrackProperty("_OutlineColor", properties);
                prop_OutlineWidth = TrackProperty("_OutlineWidth", properties);
                prop_OutlineVertexColorMask = TrackProperty("_OutlineVertexColorMask", properties);
                prop_OutlineDistanceFade = TrackProperty("_OutlineDistanceFade", properties);
                prop_OutlineFadeStart = TrackProperty("_OutlineFadeStart", properties);
                prop_OutlineFadeEnd = TrackProperty("_OutlineFadeEnd", properties);
                prop_OutlineHueShift = TrackProperty("_OutlineHueShift", properties);
                prop_OutlineHueShiftSpeed = TrackProperty("_OutlineHueShiftSpeed", properties);
                prop_OutlineOpacity = TrackProperty("_OutlineOpacity", properties);
                prop_OutlineSpace = TrackProperty("_OutlineSpace", properties);
                prop_OutlineMode = TrackProperty("_OutlineMode", properties);
                prop_OutlineTexMap = TrackProperty("_OutlineTexMap", properties);
                prop_OutlineTex = TrackProperty("_OutlineTex", properties);
                prop_OutlineTexTiling = TrackProperty("_OutlineTexTiling", properties);
                prop_OutlineTexScroll = TrackProperty("_OutlineTexScroll", properties);
                prop_OutlineOffset = TrackProperty("_OutlineOffset", properties);
                prop_OutlineStyle = TrackProperty("_OutlineStyle", properties);
                prop_OutlineStencilRef = TrackProperty("_OutlineStencilRef", properties);
                prop_OutlineStencilComp = TrackProperty("_OutlineStencilComp", properties);
                prop_OutlineStencilPass = TrackProperty("_OutlineStencilPass", properties);
                prop_OutlineStencilFail = TrackProperty("_OutlineStencilFail", properties);
                prop_OutlineStencilZFail = TrackProperty("_OutlineStencilZFail", properties);
                materialEditor.ShaderProperty(prop_OutlineWidth, languages.speak("prop_OutlineWidth"));
                materialEditor.ShaderProperty(prop_OutlineOpacity, languages.speak("prop_OutlineOpacity"));
                materialEditor.ShaderProperty(prop_OutlineColor, languages.speak("prop_OutlineColor"));
                materialEditor.ShaderProperty(prop_OutlineSpace, languages.speak("prop_OutlineSpace"));
                materialEditor.ShaderProperty(prop_OutlineStyle, languages.speak("prop_OutlineStyle"));
                materialEditor.ShaderProperty(prop_ToggleLitOutline, languages.speak("prop_ToggleLitOutline"));
                Components.start_dynamic_disable(!prop_ToggleLitOutline.floatValue.Equals(1), configs);
                EditorGUI.indentLevel++;
                materialEditor.ShaderProperty(prop_OutlineLitMix, languages.speak("prop_OutlineLitMix"));
                EditorGUI.indentLevel--;
                Components.end_dynamic_disable(!prop_ToggleLitOutline.floatValue.Equals(1), configs);
                materialEditor.ShaderProperty(prop_OutlineMode, languages.speak("prop_OutlineMode"));
                Components.start_dynamic_disable(!prop_OutlineMode.floatValue.Equals(1), configs);
                EditorGUI.indentLevel++;
                materialEditor.ShaderProperty(prop_OutlineTexMap, languages.speak("prop_OutlineTexMap"));
                materialEditor.ShaderProperty(prop_OutlineTex, languages.speak("prop_OutlineTex"));
                materialEditor.ShaderProperty(prop_OutlineTexTiling, languages.speak("prop_OutlineTexTiling"));
                materialEditor.ShaderProperty(prop_OutlineTexScroll, languages.speak("prop_OutlineTexScroll"));
                EditorGUI.indentLevel--;
                Components.end_dynamic_disable(!prop_OutlineMode.floatValue.Equals(1), configs);
                materialEditor.ShaderProperty(prop_OutlineOffset, languages.speak("prop_OutlineOffset"));
                materialEditor.ShaderProperty(prop_OutlineVertexColorMask, languages.speak("prop_OutlineVertexColorMask"));
                materialEditor.ShaderProperty(prop_OutlineDistanceFade, languages.speak("prop_OutlineDistanceFade"));
                Components.start_dynamic_disable(prop_OutlineDistanceFade.floatValue.Equals(0), configs);
                EditorGUI.indentLevel++;
                materialEditor.ShaderProperty(prop_OutlineFadeStart, languages.speak("prop_OutlineFadeStart"));
                materialEditor.ShaderProperty(prop_OutlineFadeEnd, languages.speak("prop_OutlineFadeEnd"));
                EditorGUI.indentLevel--;
                Components.end_dynamic_disable(prop_OutlineDistanceFade.floatValue.Equals(0), configs);
                materialEditor.ShaderProperty(prop_OutlineHueShift, languages.speak("prop_OutlineHueShift"));
                Components.start_dynamic_disable(prop_OutlineHueShift.floatValue.Equals(0), configs);
                EditorGUI.indentLevel++;
                materialEditor.ShaderProperty(prop_OutlineHueShiftSpeed, languages.speak("prop_OutlineHueShiftSpeed"));
                EditorGUI.indentLevel--;
                Components.end_dynamic_disable(prop_OutlineHueShift.floatValue.Equals(0), configs);
                materialEditor.ShaderProperty(prop_OutlineStencilRef, languages.speak("prop_OutlineStencilRef"));
                materialEditor.ShaderProperty(prop_OutlineStencilComp, languages.speak("prop_OutlineStencilComp"));
                materialEditor.ShaderProperty(prop_OutlineStencilPass, languages.speak("prop_OutlineStencilPass"));
                materialEditor.ShaderProperty(prop_OutlineStencilFail, languages.speak("prop_OutlineStencilFail"));
                materialEditor.ShaderProperty(prop_OutlineStencilZFail, languages.speak("prop_OutlineStencilZFail"));
                Components.end_foldout();
            });
            // third party tab
            tab_third_party.process(() => {
                Components.start_foldout();
                sub_tab_audiolink.process(() => {
                    prop_ToggleAudioLink = TrackProperty("_ToggleAudioLink", properties);
                    prop_AudioLinkFallback = TrackProperty("_AudioLinkFallback", properties);
                    prop_AudioLinkMode = TrackProperty("_AudioLinkMode", properties);
                    prop_AudioLinkSmoothLevel = TrackProperty("_AudioLinkSmoothLevel", properties);
                    prop_AudioLinkEmissionBand = TrackProperty("_AudioLinkEmissionBand", properties);
                    prop_AudioLinkEmissionStrength = TrackProperty("_AudioLinkEmissionStrength", properties);
                    prop_AudioLinkEmissionRange = TrackProperty("_AudioLinkEmissionRange", properties);
                    prop_AudioLinkRimBand = TrackProperty("_AudioLinkRimBand", properties);
                    prop_AudioLinkRimStrength = TrackProperty("_AudioLinkRimStrength", properties);
                    prop_AudioLinkRimRange = TrackProperty("_AudioLinkRimRange", properties);
                    prop_AudioLinkHueShiftBand = TrackProperty("_AudioLinkHueShiftBand", properties);
                    prop_AudioLinkHueShiftStrength = TrackProperty("_AudioLinkHueShiftStrength", properties);
                    prop_AudioLinkHueShiftRange = TrackProperty("_AudioLinkHueShiftRange", properties);
                    prop_AudioLinkDecalHueBand = TrackProperty("_AudioLinkDecalHueBand", properties);
                    prop_AudioLinkDecalHueStrength = TrackProperty("_AudioLinkDecalHueStrength", properties);
                    prop_AudioLinkDecalHueRange = TrackProperty("_AudioLinkDecalHueRange", properties);
                    prop_AudioLinkDecalEmissionBand = TrackProperty("_AudioLinkDecalEmissionBand", properties);
                    prop_AudioLinkDecalEmissionStrength = TrackProperty("_AudioLinkDecalEmissionStrength", properties);
                    prop_AudioLinkDecalEmissionRange = TrackProperty("_AudioLinkDecalEmissionRange", properties);
                    prop_AudioLinkDecalOpacityBand = TrackProperty("_AudioLinkDecalOpacityBand", properties);
                    prop_AudioLinkDecalOpacityStrength = TrackProperty("_AudioLinkDecalOpacityStrength", properties);
                    prop_AudioLinkDecalOpacityRange = TrackProperty("_AudioLinkDecalOpacityRange", properties);
                    prop_AudioLinkVertexBand = TrackProperty("_AudioLinkVertexBand", properties);
                    prop_AudioLinkVertexStrength = TrackProperty("_AudioLinkVertexStrength", properties);
                    prop_AudioLinkVertexRange = TrackProperty("_AudioLinkVertexRange", properties);
                    prop_AudioLinkOutlineBand = TrackProperty("_AudioLinkOutlineBand", properties);
                    prop_AudioLinkOutlineStrength = TrackProperty("_AudioLinkOutlineStrength", properties);
                    prop_AudioLinkOutlineRange = TrackProperty("_AudioLinkOutlineRange", properties);
                    prop_AudioLinkMatcapBand = TrackProperty("_AudioLinkMatcapBand", properties);
                    prop_AudioLinkMatcapStrength = TrackProperty("_AudioLinkMatcapStrength", properties);
                    prop_AudioLinkMatcapRange = TrackProperty("_AudioLinkMatcapRange", properties);
                    prop_AudioLinkPathingBand = TrackProperty("_AudioLinkPathingBand", properties);
                    prop_AudioLinkPathingStrength = TrackProperty("_AudioLinkPathingStrength", properties);
                    prop_AudioLinkPathingRange = TrackProperty("_AudioLinkPathingRange", properties);
                    prop_AudioLinkGlitterBand = TrackProperty("_AudioLinkGlitterBand", properties);
                    prop_AudioLinkGlitterStrength = TrackProperty("_AudioLinkGlitterStrength", properties);
                    prop_AudioLinkGlitterRange = TrackProperty("_AudioLinkGlitterRange", properties);
                    prop_AudioLinkIridescenceBand = TrackProperty("_AudioLinkIridescenceBand", properties);
                    prop_AudioLinkIridescenceStrength = TrackProperty("_AudioLinkIridescenceStrength", properties);
                    prop_AudioLinkIridescenceRange = TrackProperty("_AudioLinkIridescenceRange", properties);
                    materialEditor.ShaderProperty(prop_ToggleAudioLink, languages.speak("prop_ToggleAudioLink"));
                    Components.start_dynamic_disable(!prop_ToggleAudioLink.floatValue.Equals(1), configs);
                    materialEditor.ShaderProperty(prop_AudioLinkFallback, languages.speak("prop_AudioLinkFallback"));
                    materialEditor.ShaderProperty(prop_AudioLinkMode, languages.speak("prop_AudioLinkMode"));
                    Components.start_dynamic_disable(!prop_AudioLinkMode.floatValue.Equals(1), configs);
                    materialEditor.ShaderProperty(prop_AudioLinkSmoothLevel, languages.speak("prop_AudioLinkSmoothLevel"));
                    Components.end_dynamic_disable(!prop_AudioLinkMode.floatValue.Equals(1), configs);
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
                });
                sub_tab_superplug.process(() => {
                });
                sub_tab_ltcgi.process(() => {
                    prop_ToggleLTCGI = TrackProperty("_ToggleLTCGI", properties);
                    materialEditor.ShaderProperty(prop_ToggleLTCGI, languages.speak("prop_ToggleLTCGI"));
                });
                Components.end_foldout();
            });
            #endregion // Backlace
            config_menu?.draw();
            presets_menu?.draw();
            premonition_menu?.draw();
            debug_menu?.draw(materialEditor, properties);
            license_menu?.draw();
            update?.draw();
            announcement?.draw();
            docs?.draw();
            socials_menu?.draw();
            footer?.draw();
            if (EditorGUI.EndChangeCheck())
            {
                cushion?.Update(targetMat);
                beauty_blender?.Update(targetMat);
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