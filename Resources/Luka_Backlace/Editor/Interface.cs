#if UNITY_EDITOR

// imports
using System.IO;
using UnityEditor;
using UnityEngine;

// Interface.cs is the actual shader GUI that is displayed..
namespace Luka.Backlace
{

    // the material editor interface
    public class Interface : ShaderGUI
    {

        private static bool loaded = false;
        private static bool preview_loaded = false;
        private static bool is_preview = false;
        private static Config configs = null;
        private static Languages languages = null;
        private static Theme theme = null;
        private static Header header = null;
        private static Announcement announcement = null;
        private static Update update = null;
        private static Docs docs = null;
        private static SocialsMenu socials_menu = null;
        private static Metadata meta = null;
        private static Tab config_tab = null;
        private static Tab license_tab = null;
        private static ConfigMenu config_menu = null;
        private static LicenseMenu license_menu = null;
        
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
        private static Tab sub_tab_diffuse = null;
        private static Tab sub_tab_specular = null;
        private static Tab sub_tab_emission = null;
        private static Tab sub_tab_light_limiting = null;
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
        private static Tab sub_tab_audiolink = null;
        private static Tab sub_tab_glitter = null;
        private static Tab sub_tab_distance_fading = null;
        private static Tab sub_tab_iridescence = null;
        private static Tab sub_tab_shadow_textures = null;
        private static Tab sub_tab_flatten_model = null;
        private static Tab sub_tab_world_aligned = null;
        private static Tab sub_tab_vrchat_mirror = null;
        private static Tab sub_tab_touch_interactions = null;
        private static Tab sub_tab_vertex_distortion = null;
        private static Tab sub_tab_refraction = null;
        private static Tab sub_tab_screenspace_reflection = null;
        // outline
        private static Tab tab_outline = null;
        #endregion // Tabs

        #region Properties
        // rendering properties
        private MaterialProperty prop_SrcBlend = null;
        private MaterialProperty prop_DstBlend = null;
        private MaterialProperty prop_ZWrite = null;
        private MaterialProperty prop_Cull = null;
        private MaterialProperty prop_StencilID = null;
        private MaterialProperty prop_StencilComp = null;
        private MaterialProperty prop_StencilOp = null;
        private MaterialProperty prop_BlendMode = null;
        // texture properties
        private MaterialProperty prop_MainTex = null;
        private MaterialProperty prop_Color = null;
        private MaterialProperty prop_Cutoff = null;
        private MaterialProperty prop_BumpMap = null;
        private MaterialProperty prop_BumpScale = null;
        private MaterialProperty prop_Alpha = null;
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
        private MaterialProperty prop_ToggleToonLighting = null;
        private MaterialProperty prop_ToonMode = null;
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
        private MaterialProperty prop_ToggleAnimeAmbientGradient = null;
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
        private MaterialProperty prop_SpecularTintTexture = null;
        private MaterialProperty prop_SpecularTint = null;
        private MaterialProperty prop_TangentMap = null;
        private MaterialProperty prop_Anisotropy = null;
        private MaterialProperty prop_ReplaceSpecular = null;
        private MaterialProperty prop_HighlightRamp = null;
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
        private MaterialProperty prop_ThicknessMap = null;
        private MaterialProperty prop_SSSColor = null;
        private MaterialProperty prop_SSSStrength = null;
        private MaterialProperty prop_SSSDistortion = null;
        private MaterialProperty prop_SSSSpread = null;
        private MaterialProperty prop_SSSBaseColorMix = null;
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
        private MaterialProperty prop_UVCount = null;
        private MaterialProperty prop_UV1Index = null;
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
        #endregion // Properties

        // unload the interface (ex. on shader change)
        public static void unload()
        {
            loaded = false;
            preview_loaded = false;
            is_preview = false;
            configs = null;
            languages = null;
            theme = null;
            header = null;
            announcement = null;
            update = null;
            docs = null;
            socials_menu = null;
            meta = null;
            config_tab = null;
            license_tab = null;
            config_menu = null;
            license_menu = null;
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
            sub_tab_diffuse = null;
            sub_tab_specular = null;
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
            sub_tab_audiolink = null;
            sub_tab_glitter = null;
            sub_tab_distance_fading = null;
            sub_tab_iridescence = null;
            sub_tab_shadow_textures = null;
            sub_tab_flatten_model = null;
            sub_tab_world_aligned = null;
            sub_tab_vrchat_mirror = null;
            sub_tab_touch_interactions = null;
            sub_tab_vertex_distortion = null;
            sub_tab_refraction = null;
            sub_tab_screenspace_reflection = null;
            tab_outline = null;
            #endregion // Tabs
        }

        // load (/reload) the interface (ex. on language change)
        public void load(ref Material targetMat)
        {
            configs = new Config();
            languages = new Languages(configs.json_data.@interface.language);
            meta = new Metadata();
            theme = new Theme(ref configs, ref languages, ref meta);
            license_tab = new Tab(ref targetMat, ref theme, (int)Tab.tab_sizes.Primary, 0, languages.speak("tab_license"));
            config_tab = new Tab(ref targetMat, ref theme, (int)Tab.tab_sizes.Primary, 1, languages.speak("tab_config"));
            config_menu = new ConfigMenu(ref theme, ref languages, ref configs, ref config_tab);
            license_menu = new LicenseMenu(ref theme, ref languages, ref license_tab);
            header = new Header(ref theme);
            announcement = new Announcement(ref theme);
            update = new Update(ref theme);
            docs = new Docs(ref theme);
            socials_menu = new SocialsMenu(ref theme);
            #region Tabs
            tab_main = new Tab(ref targetMat, ref theme, (int)Tab.tab_sizes.Primary, 0, languages.speak("tab_main"));
            sub_tab_rendering = new Tab(ref targetMat, ref theme, (int)Tab.tab_sizes.Sub, 0, languages.speak("sub_tab_rendering"));
            sub_tab_textures = new Tab(ref targetMat, ref theme, (int)Tab.tab_sizes.Sub, 1, languages.speak("sub_tab_textures"));
            sub_tab_uv_manipulation = new Tab(ref targetMat, ref theme, (int)Tab.tab_sizes.Sub, 2, languages.speak("sub_tab_uv_manipulation"));
            sub_tab_uv_effects = new Tab(ref targetMat, ref theme, (int)Tab.tab_sizes.Sub, 3, languages.speak("sub_tab_uv_effects"));
            sub_tab_vertex_manipulation = new Tab(ref targetMat, ref theme, (int)Tab.tab_sizes.Sub, 4, languages.speak("sub_tab_vertex_manipulation"));
            sub_tab_decal_one = new Tab(ref targetMat, ref theme, (int)Tab.tab_sizes.Sub, 5, languages.speak("sub_tab_decal_one"));
            sub_tab_decal_two = new Tab(ref targetMat, ref theme, (int)Tab.tab_sizes.Sub, 6, languages.speak("sub_tab_decal_two"));
            sub_tab_post_processing = new Tab(ref targetMat, ref theme, (int)Tab.tab_sizes.Sub, 7, languages.speak("sub_tab_post_processing"));
            sub_tab_uv_sets = new Tab(ref targetMat, ref theme, (int)Tab.tab_sizes.Sub, 8, languages.speak("sub_tab_uv_sets"));
            tab_lighting = new Tab(ref targetMat, ref theme, (int)Tab.tab_sizes.Primary, 1, languages.speak("tab_lighting"));
            sub_tab_lighting_model = new Tab(ref targetMat, ref theme, (int)Tab.tab_sizes.Sub, 0, languages.speak("sub_tab_lighting_model"));
            sub_tab_diffuse = new Tab(ref targetMat, ref theme, (int)Tab.tab_sizes.Sub, 1, languages.speak("sub_tab_diffuse"));
            sub_tab_specular = new Tab(ref targetMat, ref theme, (int)Tab.tab_sizes.Sub, 2, languages.speak("sub_tab_specular"));
            sub_tab_emission = new Tab(ref targetMat, ref theme, (int)Tab.tab_sizes.Sub, 3, languages.speak("sub_tab_emission"));
            sub_tab_light_limiting = new Tab(ref targetMat, ref theme, (int)Tab.tab_sizes.Sub, 4, languages.speak("sub_tab_light_limiting"));
            tab_shading = new Tab(ref targetMat, ref theme, (int)Tab.tab_sizes.Primary, 2, languages.speak("tab_shading"));
            sub_tab_rim_lighting = new Tab(ref targetMat, ref theme, (int)Tab.tab_sizes.Sub, 0, languages.speak("sub_tab_rim_lighting"));
            sub_tab_depth_rim = new Tab(ref targetMat, ref theme, (int)Tab.tab_sizes.Sub, 1, languages.speak("sub_tab_depth_rim"));
            sub_tab_clear_coat = new Tab(ref targetMat, ref theme, (int)Tab.tab_sizes.Sub, 2, languages.speak("sub_tab_clear_coat"));
            sub_tab_matcap = new Tab(ref targetMat, ref theme, (int)Tab.tab_sizes.Sub, 3, languages.speak("sub_tab_matcap"));
            sub_tab_cubemap = new Tab(ref targetMat, ref theme, (int)Tab.tab_sizes.Sub, 4, languages.speak("sub_tab_cubemap"));
            sub_tab_parallax = new Tab(ref targetMat, ref theme, (int)Tab.tab_sizes.Sub, 5, languages.speak("sub_tab_parallax"));
            sub_tab_subsurface = new Tab(ref targetMat, ref theme, (int)Tab.tab_sizes.Sub, 6, languages.speak("sub_tab_subsurface"));
            sub_tab_detail_map = new Tab(ref targetMat, ref theme, (int)Tab.tab_sizes.Sub, 7, languages.speak("sub_tab_detail_map"));
            sub_tab_shadow_map = new Tab(ref targetMat, ref theme, (int)Tab.tab_sizes.Sub, 8, languages.speak("sub_tab_shadow_map"));
            tab_effects = new Tab(ref targetMat, ref theme, (int)Tab.tab_sizes.Primary, 3, languages.speak("tab_effects"));
            sub_tab_dissolve = new Tab(ref targetMat, ref theme, (int)Tab.tab_sizes.Sub, 0, languages.speak("sub_tab_dissolve"));
            sub_tab_pathing = new Tab(ref targetMat, ref theme, (int)Tab.tab_sizes.Sub, 1, languages.speak("sub_tab_pathing"));
            sub_tab_audiolink = new Tab(ref targetMat, ref theme, (int)Tab.tab_sizes.Sub, 2, languages.speak("sub_tab_audiolink"));
            sub_tab_glitter = new Tab(ref targetMat, ref theme, (int)Tab.tab_sizes.Sub, 3, languages.speak("sub_tab_glitter"));
            sub_tab_distance_fading = new Tab(ref targetMat, ref theme, (int)Tab.tab_sizes.Sub, 4, languages.speak("sub_tab_distance_fading"));
            sub_tab_iridescence = new Tab(ref targetMat, ref theme, (int)Tab.tab_sizes.Sub, 5, languages.speak("sub_tab_iridescence"));
            sub_tab_shadow_textures = new Tab(ref targetMat, ref theme, (int)Tab.tab_sizes.Sub, 6, languages.speak("sub_tab_shadow_textures"));
            sub_tab_flatten_model = new Tab(ref targetMat, ref theme, (int)Tab.tab_sizes.Sub, 7, languages.speak("sub_tab_flatten_model"));
            sub_tab_world_aligned = new Tab(ref targetMat, ref theme, (int)Tab.tab_sizes.Sub, 8, languages.speak("sub_tab_world_aligned"));
            sub_tab_vrchat_mirror = new Tab(ref targetMat, ref theme, (int)Tab.tab_sizes.Sub, 9, languages.speak("sub_tab_vrchat_mirror"));
            sub_tab_touch_interactions = new Tab(ref targetMat, ref theme, (int)Tab.tab_sizes.Sub, 10, languages.speak("sub_tab_touch_interactions"));
            sub_tab_vertex_distortion = new Tab(ref targetMat, ref theme, (int)Tab.tab_sizes.Sub, 11, languages.speak("sub_tab_vertex_distortion"));
            sub_tab_refraction = new Tab(ref targetMat, ref theme, (int)Tab.tab_sizes.Sub, 12, languages.speak("sub_tab_refraction"));
            sub_tab_screenspace_reflection = new Tab(ref targetMat, ref theme, (int)Tab.tab_sizes.Sub, 13, languages.speak("sub_tab_screenspace_reflection"));
            tab_outline = new Tab(ref targetMat, ref theme, (int)Tab.tab_sizes.Primary, 4, languages.speak("tab_outline"));
            #endregion // Tabs
            loaded = true;
        }

        // per-shader ui here
        public override void OnGUI(MaterialEditor materialEditor, MaterialProperty[] properties)
        {
            Material targetMat = materialEditor.target as Material;
            // load global
            if (!loaded) load(ref targetMat);
            EditorGUI.BeginChangeCheck();
            header.draw();
            update.draw();
            #region Backlace
            tab_main.draw();
            if (tab_main.is_expanded) {
                Components.start_foldout();
                sub_tab_rendering.draw();
                if (sub_tab_rendering.is_expanded) {
                    // main - rendering
                    prop_BlendMode = FindProperty("_BlendMode", properties);
                    prop_SrcBlend = FindProperty("_SrcBlend", properties);
                    prop_DstBlend = FindProperty("_DstBlend", properties);
                    prop_ZWrite = FindProperty("_ZWrite", properties);
                    prop_Cull = FindProperty("_Cull", properties);
                    prop_StencilID = FindProperty("_StencilID", properties);
                    prop_StencilComp = FindProperty("_StencilComp", properties);
                    prop_StencilOp = FindProperty("_StencilOp", properties);
                    materialEditor.ShaderProperty(prop_BlendMode, languages.speak("prop_BlendMode"));
                    materialEditor.ShaderProperty(prop_SrcBlend, languages.speak("prop_SrcBlend"));
                    materialEditor.ShaderProperty(prop_DstBlend, languages.speak("prop_DstBlend"));
                    materialEditor.ShaderProperty(prop_ZWrite, languages.speak("prop_ZWrite"));
                    materialEditor.ShaderProperty(prop_Cull, languages.speak("prop_Cull"));
                    materialEditor.ShaderProperty(prop_StencilID, languages.speak("prop_StencilID"));
                    materialEditor.ShaderProperty(prop_StencilComp, languages.speak("prop_StencilComp"));
                    materialEditor.ShaderProperty(prop_StencilOp, languages.speak("prop_StencilOp"));     
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
                    materialEditor.ShaderProperty(prop_Cutoff, languages.speak("prop_Cutoff"));
                    materialEditor.ShaderProperty(prop_BumpMap, languages.speak("prop_BumpMap"));
                    materialEditor.ShaderProperty(prop_BumpScale, languages.speak("prop_BumpScale"));
                    materialEditor.ShaderProperty(prop_Alpha, languages.speak("prop_Alpha"));
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
                    materialEditor.ShaderProperty(prop_UV_Rotation, languages.speak("prop_UV_Rotation"));
                    materialEditor.ShaderProperty(prop_UV_Scroll_X_Speed, languages.speak("prop_UV_Scroll_X_Speed"));
                    materialEditor.ShaderProperty(prop_UV_Scroll_Y_Speed, languages.speak("prop_UV_Scroll_Y_Speed"));
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
                    materialEditor.ShaderProperty(prop_UVTriplanarMapping, languages.speak("prop_UVTriplanarMapping"));
                    materialEditor.ShaderProperty(prop_UVTriplanarPosition, languages.speak("prop_UVTriplanarPosition"));
                    materialEditor.ShaderProperty(prop_UVTriplanarScale, languages.speak("prop_UVTriplanarScale"));
                    materialEditor.ShaderProperty(prop_UVTriplanarRotation, languages.speak("prop_UVTriplanarRotation"));
                    materialEditor.ShaderProperty(prop_UVTriplanarSharpness, languages.speak("prop_UVTriplanarSharpness"));
                    materialEditor.ShaderProperty(prop_UVScreenspaceMapping, languages.speak("prop_UVScreenspaceMapping"));
                    materialEditor.ShaderProperty(prop_UVScreenspaceTiling, languages.speak("prop_UVScreenspaceTiling"));
                    materialEditor.ShaderProperty(prop_UVFlipbook, languages.speak("prop_UVFlipbook"));
                    materialEditor.ShaderProperty(prop_UVFlipbookRows, languages.speak("prop_UVFlipbookRows"));
                    materialEditor.ShaderProperty(prop_UVFlipbookColumns, languages.speak("prop_UVFlipbookColumns"));
                    materialEditor.ShaderProperty(prop_UVFlipbookFrames, languages.speak("prop_UVFlipbookFrames"));
                    materialEditor.ShaderProperty(prop_UVFlipbookFPS, languages.speak("prop_UVFlipbookFPS"));
                    materialEditor.ShaderProperty(prop_UVFlipbookScrub, languages.speak("prop_UVFlipbookScrub"));
                    materialEditor.ShaderProperty(prop_UVFlowmap, languages.speak("prop_UVFlowmap"));
                    materialEditor.ShaderProperty(prop_UVFlowmapTex, languages.speak("prop_UVFlowmapTex"));
                    materialEditor.ShaderProperty(prop_UVFlowmapStrength, languages.speak("prop_UVFlowmapStrength"));
                    materialEditor.ShaderProperty(prop_UVFlowmapSpeed, languages.speak("prop_UVFlowmapSpeed"));
                    materialEditor.ShaderProperty(prop_UVFlowmapDistortion, languages.speak("prop_UVFlowmapDistortion"));
                }
                sub_tab_vertex_manipulation.draw();
                if (sub_tab_vertex_manipulation.is_expanded) {
                    // main - vertex manipulation
                    prop_VertexManipulationPosition = FindProperty("_VertexManipulationPosition", properties);
                    prop_VertexManipulationScale = FindProperty("_VertexManipulationScale", properties);
                    materialEditor.ShaderProperty(prop_VertexManipulationPosition, languages.speak("prop_VertexManipulationPosition"));
                    materialEditor.ShaderProperty(prop_VertexManipulationScale, languages.speak("prop_VertexManipulationScale"));
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
                    materialEditor.ShaderProperty(prop_Decal1Enable, languages.speak("prop_Decal1Enable"));
                    Components.start_dynamic_disable(!prop_Decal1Enable.floatValue.Equals(1), configs);
                    materialEditor.ShaderProperty(prop_Decal1Tex, languages.speak("prop_Decal1Tex"));
                    materialEditor.ShaderProperty(prop_Decal1Tint, languages.speak("prop_Decal1Tint"));
                    materialEditor.ShaderProperty(prop_Decal1BlendMode, languages.speak("prop_Decal1BlendMode"));
                    materialEditor.ShaderProperty(prop_Decal1IsTriplanar, languages.speak("prop_Decal1IsTriplanar"));
                    materialEditor.ShaderProperty(prop_Decal1Position, languages.speak("prop_Decal1Position"));
                    materialEditor.ShaderProperty(prop_Decal1Scale, languages.speak("prop_Decal1Scale"));
                    materialEditor.ShaderProperty(prop_Decal1Rotation, languages.speak("prop_Decal1Rotation"));
                    materialEditor.ShaderProperty(prop_Decal1TriplanarPosition, languages.speak("prop_Decal1TriplanarPosition"));
                    materialEditor.ShaderProperty(prop_Decal1TriplanarScale, languages.speak("prop_Decal1TriplanarScale"));
                    materialEditor.ShaderProperty(prop_Decal1TriplanarRotation, languages.speak("prop_Decal1TriplanarRotation"));
                    materialEditor.ShaderProperty(prop_Decal1TriplanarSharpness, languages.speak("prop_Decal1TriplanarSharpness"));
                    materialEditor.ShaderProperty(prop_Decal1Repeat, languages.speak("prop_Decal1Repeat"));
                    materialEditor.ShaderProperty(prop_Decal1Scroll, languages.speak("prop_Decal1Scroll"));
                    materialEditor.ShaderProperty(prop_Decal1HueShift, languages.speak("prop_Decal1HueShift"));
                    materialEditor.ShaderProperty(prop_Decal1AutoCycleHue, languages.speak("prop_Decal1AutoCycleHue"));
                    materialEditor.ShaderProperty(prop_Decal1CycleSpeed, languages.speak("prop_Decal1CycleSpeed"));
                    Components.end_dynamic_disable(!prop_Decal1Enable.floatValue.Equals(1), configs);
                }
                sub_tab_decal_two.draw();
                if (sub_tab_decal_two.is_expanded) {
                    // main - decal two
                }
                sub_tab_post_processing.draw();
                if (sub_tab_post_processing.is_expanded) {
                    // main - post processing
                }
                sub_tab_uv_sets.draw();
                if (sub_tab_uv_sets.is_expanded) {
                    // main - uv sets
                }
                Components.end_foldout();
            }
            tab_lighting.draw();
            if (tab_lighting.is_expanded) {
                Components.start_foldout();
                sub_tab_lighting_model.draw();
                if (sub_tab_lighting_model.is_expanded) {
                    // lighting - lighting model
                }
                sub_tab_diffuse.draw();
                if (sub_tab_diffuse.is_expanded) {
                    // lighting - diffuse
                }
                sub_tab_specular.draw();
                if (sub_tab_specular.is_expanded) {
                    // lighting - specular
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
                    materialEditor.ShaderProperty(prop_EmissionColor, languages.speak("prop_EmissionColor"));
                    materialEditor.ShaderProperty(prop_EmissionMap, languages.speak("prop_EmissionMap"));
                    materialEditor.ShaderProperty(prop_UseAlbedoAsEmission, languages.speak("prop_UseAlbedoAsEmission"));
                    materialEditor.ShaderProperty(prop_EmissionStrength, languages.speak("prop_EmissionStrength"));
                }
                sub_tab_light_limiting.draw();
                if (sub_tab_light_limiting.is_expanded) {
                    // lighting - light limiting
                }
                Components.end_foldout();
            }
            tab_shading.draw();
            if (tab_shading.is_expanded) {
                Components.start_foldout();
                sub_tab_rim_lighting.draw();
                if (sub_tab_rim_lighting.is_expanded) {
                    // shading - rim lighting
                }
                sub_tab_depth_rim.draw();
                if (sub_tab_depth_rim.is_expanded) {
                    // shading - depth rim
                }
                sub_tab_clear_coat.draw();
                if (sub_tab_clear_coat.is_expanded) {
                    // shading - clear coat
                }
                sub_tab_matcap.draw();
                if (sub_tab_matcap.is_expanded) {
                    // shading - matcap
                }
                sub_tab_cubemap.draw();
                if (sub_tab_cubemap.is_expanded) {
                    // shading - cubemap
                }
                sub_tab_parallax.draw();
                if (sub_tab_parallax.is_expanded) {
                    // shading - parallax
                }
                sub_tab_subsurface.draw();
                if (sub_tab_subsurface.is_expanded) {
                    // shading - subsurface
                }
                sub_tab_detail_map.draw();
                if (sub_tab_detail_map.is_expanded) {
                    // shading - detail map
                }
                sub_tab_shadow_map.draw();
                if (sub_tab_shadow_map.is_expanded) {
                    // shading - shadow map
                }
                Components.end_foldout();
            }
            tab_effects.draw();
            if (tab_effects.is_expanded) {
                Components.start_foldout();
                sub_tab_dissolve.draw();
                if (sub_tab_dissolve.is_expanded) {
                    // effects - dissolve
                }
                sub_tab_pathing.draw();
                if (sub_tab_pathing.is_expanded) {
                    // effects - pathing
                }
                sub_tab_audiolink.draw();
                if (sub_tab_audiolink.is_expanded) {
                    // effects - audiolink
                }
                sub_tab_glitter.draw();
                if (sub_tab_glitter.is_expanded) {
                    // effects - glitter
                }
                sub_tab_distance_fading.draw();
                if (sub_tab_distance_fading.is_expanded) {
                    // effects - distance fading
                }
                sub_tab_iridescence.draw();
                if (sub_tab_iridescence.is_expanded) {
                    // effects - iridescence
                }
                sub_tab_shadow_textures.draw();
                if (sub_tab_shadow_textures.is_expanded) {
                    // effects - shadow textures
                }
                sub_tab_flatten_model.draw();
                if (sub_tab_flatten_model.is_expanded) {
                    // effects - flatten model
                }
                sub_tab_world_aligned.draw();
                if (sub_tab_world_aligned.is_expanded) {
                    // effects - world aligned
                }
                sub_tab_vrchat_mirror.draw();
                if (sub_tab_vrchat_mirror.is_expanded) {
                    // effects - vrchat mirror
                }
                sub_tab_touch_interactions.draw();
                if (sub_tab_touch_interactions.is_expanded) {
                    // effects - touch interactions
                }
                sub_tab_vertex_distortion.draw();
                if (sub_tab_vertex_distortion.is_expanded) {
                    // effects - vertex distortion
                }
                sub_tab_refraction.draw();
                if (sub_tab_refraction.is_expanded) {
                    // effects - refraction
                }
                sub_tab_screenspace_reflection.draw();
                if (sub_tab_screenspace_reflection.is_expanded) {
                    // effects - screenspace reflection
                }
                Components.end_foldout();
            }
            tab_outline.draw();
            if (tab_outline.is_expanded) {
                Components.start_foldout();
                // outline
                Components.end_foldout();
            }
            #endregion // Backlace
            license_menu.draw();
            config_menu.draw();
            announcement.draw();
            docs.draw();
            socials_menu.draw();
            EditorGUI.EndChangeCheck();
        }

    }

}
#endif // UNITY_EDITOR