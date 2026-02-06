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
        private static Tab sub_tab_stickers = null;
        private static Tab sub_tab_post_processing = null;
        private static Tab sub_tab_uv_sets = null;
        private static Tab sub_tab_legacy_mode = null;
        // lighting
        private static Tab tab_lighting = null;
        private static Tab sub_tab_lighting_model = null;
        private static Tab sub_tab_emission = null;
        private static Tab sub_tab_light_limiting = null;
        // specular
        private static Tab tab_specular = null;
        private static Tab sub_tab_pbr_specular = null;
        private static Tab sub_tab_stylised_specular = null;
        // shading
        private static Tab tab_shading = null;
        // anime
        private static Tab tab_anime = null;
        private static Tab sub_tab_ambient_gradient = null;
        private static Tab sub_tab_sdf_shadow = null;
        private static Tab sub_tab_stocking = null;
        private static Tab sub_tab_eye_parallax = null;
        private static Tab sub_tab_translucent_hair = null;
        private static Tab sub_tab_hair_masking = null;
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
            if (sub_tab_emission != null) { sub_tab_emission.is_expanded = false; sub_tab_emission.is_active = false; }
            if (sub_tab_light_limiting != null) { sub_tab_light_limiting.is_expanded = false; sub_tab_light_limiting.is_active = false; }
            if (tab_specular != null) { tab_specular.is_expanded = false; tab_specular.is_active = false; }
            if (sub_tab_pbr_specular != null) { sub_tab_pbr_specular.is_expanded = false; sub_tab_pbr_specular.is_active = false; }
            if (sub_tab_stylised_specular != null) { sub_tab_stylised_specular.is_expanded = false; sub_tab_stylised_specular.is_active = false; }
            if (tab_shading != null) { tab_shading.is_expanded = false; tab_shading.is_active = false; }
            if (tab_anime != null) { tab_anime.is_expanded = false; tab_anime.is_active = false; }
            if (sub_tab_ambient_gradient != null) { sub_tab_ambient_gradient.is_expanded = false; sub_tab_ambient_gradient.is_active = false; }
            if (sub_tab_sdf_shadow != null) { sub_tab_sdf_shadow.is_expanded = false; sub_tab_sdf_shadow.is_active = false; }
            if (sub_tab_stocking != null) { sub_tab_stocking.is_expanded = false; sub_tab_stocking.is_active = false; }
            if (sub_tab_eye_parallax != null) { sub_tab_eye_parallax.is_expanded = false; sub_tab_eye_parallax.is_active = false; }
            if (sub_tab_translucent_hair != null) { sub_tab_translucent_hair.is_expanded = false; sub_tab_translucent_hair.is_active = false; }
            if (sub_tab_hair_masking != null) { sub_tab_hair_masking.is_expanded = false; sub_tab_hair_masking.is_active = false; }
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
            tab_specular = null;
            sub_tab_pbr_specular = null;
            sub_tab_stylised_specular = null;
            sub_tab_emission = null;
            sub_tab_light_limiting = null;
            tab_shading = null;
            tab_anime = null;
            sub_tab_ambient_gradient = null;
            sub_tab_sdf_shadow = null;
            sub_tab_stocking = null;
            sub_tab_eye_parallax = null;
            sub_tab_translucent_hair = null;
            sub_tab_hair_masking = null;
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
            tab_shading = new Tab(ref targetMat, ref theme, (int)Tab.tab_sizes.Primary, 2, languages.speak("tab_shading"));
            tab_anime = new Tab(ref targetMat, ref theme, (int)Tab.tab_sizes.Primary, 3, languages.speak("tab_anime"));
            sub_tab_ambient_gradient = new Tab(ref targetMat, ref theme, (int)Tab.tab_sizes.Sub, 0, languages.speak("sub_tab_ambient_gradient"), null, "_ToggleAmbientGradient");
            sub_tab_sdf_shadow = new Tab(ref targetMat, ref theme, (int)Tab.tab_sizes.Sub, 1, languages.speak("sub_tab_sdf_shadow"), null, "_ToggleSDFShadow");
            sub_tab_stocking = new Tab(ref targetMat, ref theme, (int)Tab.tab_sizes.Sub, 2, languages.speak("sub_tab_stocking"), null, "_ToggleStocking");
            sub_tab_eye_parallax = new Tab(ref targetMat, ref theme, (int)Tab.tab_sizes.Sub, 3, languages.speak("sub_tab_eye_parallax"), null, "_ToggleEyeParallax");
            sub_tab_translucent_hair = new Tab(ref targetMat, ref theme, (int)Tab.tab_sizes.Sub, 4, languages.speak("sub_tab_translucent_hair"), null, "_ToggleTranslucentHair");
            sub_tab_hair_masking = new Tab(ref targetMat, ref theme, (int)Tab.tab_sizes.Sub, 5, languages.speak("sub_tab_hair_masking"), null, "_ToggleHairMasking");
            sub_tab_expression_map = new Tab(ref targetMat, ref theme, (int)Tab.tab_sizes.Sub, 6, languages.speak("sub_tab_expression_map"), null, "_ToggleExpressionMap");
            sub_tab_face_map = new Tab(ref targetMat, ref theme, (int)Tab.tab_sizes.Sub, 7, languages.speak("sub_tab_face_map"), null, "_ToggleFaceMap");
            sub_tab_gradient = new Tab(ref targetMat, ref theme, (int)Tab.tab_sizes.Sub, 8, languages.speak("sub_tab_gradient"), null, "_ToggleGradient");
            sub_tab_toon_highlights = new Tab(ref targetMat, ref theme, (int)Tab.tab_sizes.Sub, 9, languages.speak("sub_tab_toon_highlights"), null, "_ToggleToonHighlights");
            sub_tab_angel_rings = new Tab(ref targetMat, ref theme, (int)Tab.tab_sizes.Sub, 10, languages.speak("sub_tab_angel_rings"), null, "_ToggleAngelRings");
            tab_specular = new Tab(ref targetMat, ref theme, (int)Tab.tab_sizes.Primary, 4, languages.speak("tab_specular"));
            sub_tab_pbr_specular = new Tab(ref targetMat, ref theme, (int)Tab.tab_sizes.Sub, 0, languages.speak("sub_tab_pbr_specular"));
            sub_tab_stylised_specular = new Tab(ref targetMat, ref theme, (int)Tab.tab_sizes.Sub, 1, languages.speak("sub_tab_stylised_specular"));
            sub_tab_emission = new Tab(ref targetMat, ref theme, (int)Tab.tab_sizes.Sub, 3, languages.speak("sub_tab_emission"), null, "_ToggleEmission");
            sub_tab_light_limiting = new Tab(ref targetMat, ref theme, (int)Tab.tab_sizes.Sub, 4, languages.speak("sub_tab_light_limiting"));
            tab_stylise = new Tab(ref targetMat, ref theme, (int)Tab.tab_sizes.Primary, 5, languages.speak("tab_stylise"));
            sub_tab_rim_lighting = new Tab(ref targetMat, ref theme, (int)Tab.tab_sizes.Sub, 0, languages.speak("sub_tab_rim_lighting"), null, "_RimMode");
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
            tab_world = new Tab(ref targetMat, ref theme, (int)Tab.tab_sizes.Primary, 8, languages.speak("tab_world"),  Project.shader_variants[3]);
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

        private void DrawUI(MaterialEditor materialEditor, MaterialProperty[] properties)
        {
            Material targetMat = materialEditor.target as Material;
            // fetch properties
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
            prop_ColorGradingMode = FindProperty("_ColorGradingMode", properties);
            prop_ColorGradingLUT = FindProperty("_ColorGradingLUT", properties);
            prop_ColorGradingIntensity = FindProperty("_ColorGradingIntensity", properties);
            prop_GTShadows = FindProperty("_GTShadows", properties);
            prop_GTHighlights = FindProperty("_GTHighlights", properties);
            prop_LCWLift = FindProperty("_LCWLift", properties);
            prop_LCWGamma = FindProperty("_LCWGamma", properties);
            prop_LCWGain = FindProperty("_LCWGain", properties);
            prop_BlackAndWhite = FindProperty("_BlackAndWhite", properties);
            prop_Brightness = FindProperty("_Brightness", properties);

            EditorGUI.BeginChangeCheck();
            header.draw();
            if (is_compact) {
                compact_notice.draw();
                GUILayout.Space(4);
            }
            search_bar.draw(ref theme);
            #region Backlace
            // main tab
            tab_main.process(() => {
                Components.start_foldout();
                sub_tab_rendering.process(() => {
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
                    materialEditor.LightmapEmissionProperty();
                });
                sub_tab_main_textures.process(() => {
                    prop_MainTex = FindProperty("_MainTex", properties);
                    prop_Color = FindProperty("_Color", properties);
                    prop_Cutoff = FindProperty("_Cutoff", properties);
                    prop_UseBump = FindProperty("_UseBump", properties);
                    prop_BumpMap = FindProperty("_BumpMap", properties);
                    prop_BumpScale = FindProperty("_BumpScale", properties);
                    prop_BumpFromAlbedo = FindProperty("_BumpFromAlbedo", properties);
                    prop_BumpFromAlbedoOffset = FindProperty("_BumpFromAlbedoOffset", properties);
                    prop_Alpha = FindProperty("_Alpha", properties);
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
                    prop_UseTextureStitching = FindProperty("_UseTextureStitching", properties);
                    prop_StitchTex = FindProperty("_StitchTex", properties);
                    prop_StitchAxis = FindProperty("_StitchAxis", properties);
                    prop_StitchOffset = FindProperty("_StitchOffset", properties);
                    materialEditor.ShaderProperty(prop_UseTextureStitching, languages.speak("prop_UseTextureStitching"));
                    Components.start_dynamic_disable(!prop_UseTextureStitching.floatValue.Equals(1), configs);
                    EditorGUI.indentLevel++;
                    materialEditor.TexturePropertySingleLine(new GUIContent(languages.speak("prop_StitchTex")), prop_StitchTex);
                    int currentAxis = (int)prop_StitchAxis.floatValue;
                    int newAxis = EditorGUILayout.Popup(languages.speak("prop_StitchAxis"), currentAxis, new string[] { "X Axis", "Y Axis", "Z Axis" });
                    if (newAxis != currentAxis) prop_StitchAxis.floatValue = newAxis;
                    materialEditor.ShaderProperty(prop_StitchOffset, languages.speak("prop_StitchOffset"));
                    EditorGUI.indentLevel--;
                    Components.end_dynamic_disable(!prop_UseTextureStitching.floatValue.Equals(1), configs);
                });
                sub_tab_uv_manipulation.process(() => {
                    prop_UVOffsetX = FindProperty("_UV_Offset_X", properties);
                    prop_UVOffsetY = FindProperty("_UV_Offset_Y", properties);
                    prop_UVScaleX = FindProperty("_UV_Scale_X", properties);
                    prop_UVScaleY = FindProperty("_UV_Scale_Y", properties);
                    prop_UVRotation = FindProperty("_UV_Rotation", properties);
                    prop_UVScrollXSpeed = FindProperty("_UV_Scroll_X_Speed", properties);
                    prop_UVScrollYSpeed = FindProperty("_UV_Scroll_Y_Speed", properties);
                    materialEditor.ShaderProperty(prop_UVOffsetX, languages.speak("prop_UV_Offset_X"));
                    materialEditor.ShaderProperty(prop_UVOffsetY, languages.speak("prop_UV_Offset_Y"));
                    materialEditor.ShaderProperty(prop_UVScaleX, languages.speak("prop_UV_Scale_X"));
                    materialEditor.ShaderProperty(prop_UVScaleY, languages.speak("prop_UV_Scale_Y"));
                    materialEditor.ShaderProperty(prop_UVRotation, languages.speak("prop_UV_Rotation"));
                    materialEditor.ShaderProperty(prop_UVScrollXSpeed, languages.speak("prop_UV_Scroll_X_Speed"));
                    materialEditor.ShaderProperty(prop_UVScrollYSpeed, languages.speak("prop_UV_Scroll_Y_Speed"));
                });
                sub_tab_uv_effects.process(() => {
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
                    prop_VertexManipulationPosition = FindProperty("_VertexManipulationPosition", properties);
                    prop_VertexManipulationScale = FindProperty("_VertexManipulationScale", properties);
                    materialEditor.ShaderProperty(prop_VertexManipulationPosition, languages.speak("prop_VertexManipulationPosition"));
                    materialEditor.ShaderProperty(prop_VertexManipulationScale, languages.speak("prop_VertexManipulationScale"));
                });
                sub_tab_post_processing.process(() => {
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
                    prop_StitchTex_UV = FindProperty("_StitchTex_UV", properties);
                    prop_SDFShadowTexture_UV = FindProperty("_SDFShadowTexture_UV", properties);
                    prop_StockingsMap_UV = FindProperty("_StockingsMap_UV", properties);
                    prop_EyeParallaxIrisTex_UV = FindProperty("_EyeParallaxIrisTex_UV", properties);
                    prop_EyeParallaxEyeMaskTex_UV = FindProperty("_EyeParallaxEyeMaskTex_UV", properties);
                    prop_HairMaskTex_UV = FindProperty("_HairMaskTex_UV", properties);
                    prop_ExpressionMap_UV = FindProperty("_ExpressionMap_UV", properties);
                    prop_FaceMap_UV = FindProperty("_FaceMap_UV", properties);
                    prop_NPRSpecularMask_UV = FindProperty("_NPRSpecularMask_UV", properties);
                    prop_PackedMapOne_UV = FindProperty("_PackedMapOne_UV", properties);
                    prop_PackedMapTwo_UV = FindProperty("_PackedMapTwo_UV", properties);
                    prop_PackedMapThree_UV = FindProperty("_PackedMapThree_UV", properties);
                    prop_SkinLUT_UV = FindProperty("_SkinLUT_UV", properties);
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
                });
                Components.end_foldout();
            });
            // lighting tab
            tab_lighting.process(() => {
                Components.start_foldout();
                sub_tab_lighting_model.process(() => {
                });
                sub_tab_emission.process(() => {
                });
                sub_tab_light_limiting.process(() => {
                });
                Components.end_foldout();
            });
            // shading tab
            tab_shading.process(() => {
            });
            // anime tab
            tab_anime.process(() => {
                Components.start_foldout();
                sub_tab_ambient_gradient.process(() => {
                });
                sub_tab_sdf_shadow.process(() => {
                });
                sub_tab_stocking.process(() => {
                });
                sub_tab_eye_parallax.process(() => {
                });
                sub_tab_translucent_hair.process(() => {
                });
                sub_tab_hair_masking.process(() => {
                });
                sub_tab_expression_map.process(() => {
                });
                sub_tab_face_map.process(() => {
                });
                sub_tab_gradient.process(() => {
                });
                sub_tab_toon_highlights.process(() => {
                });
                sub_tab_angel_rings.process(() => {
                });
                Components.end_foldout();
            });
            // specular tab
            tab_specular.process(() => {
                Components.start_foldout();
                sub_tab_pbr_specular.process(() => {
                });
                sub_tab_stylised_specular.process(() => {
                });
                sub_tab_emission.process(() => {
                });
                sub_tab_light_limiting.process(() => {
                });
                Components.end_foldout();
            });
            // stylise tab
            tab_stylise.process(() => {
                Components.start_foldout();
                sub_tab_rim_lighting.process(() => {
                });
                sub_tab_clear_coat.process(() => {
                });
                sub_tab_matcap.process(() => {
                });
                sub_tab_cubemap.process(() => {
                });
                sub_tab_parallax.process(() => {
                });
                sub_tab_subsurface.process(() => {
                });
                sub_tab_detail_map.process(() => {
                });
                sub_tab_shadow_map.process(() => {
                });
                Components.end_foldout();
            });
            // stickers tab
            tab_stickers.process(() => {
                Components.start_foldout();
                sub_tab_decal1_settings.process(() => {
                });
                sub_tab_decal1_effects.process(() => {
                });
                sub_tab_decal2_settings.process(() => {
                });
                sub_tab_decal2_effects.process(() => {
                });
                Components.end_foldout();
            });
            // effects tab
            tab_effects.process(() => {
                Components.start_foldout();
                sub_tab_dissolve.process(() => {
                });
                sub_tab_pathing.process(() => {
                });
                sub_tab_glitter.process(() => {
                });
                sub_tab_distance_fading.process(() => {
                });
                sub_tab_iridescence.process(() => {
                });
                sub_tab_shadow_textures.process(() => {
                });
                sub_tab_flatten_model.process(() => {
                });
                sub_tab_world_aligned.process(() => {
                });
                sub_tab_vrchat_mirror.process(() => {
                });
                sub_tab_touch_interactions.process(() => {
                });
                sub_tab_dither.process(() => {
                });
                sub_tab_ps1.process(() => {
                });
                sub_tab_vertex_distortion.process(() => {
                });
                sub_tab_refraction.process(() => {
                });
                sub_tab_screenspace_reflection.process(() => {
                });
                Components.end_foldout();
            });
            // world tab
            tab_world.process(() => {
                Components.start_foldout();
                sub_tab_stochastic.process(() => {
                });
                sub_tab_splatter.process(() => {
                });
                sub_tab_bombing.process(() => {
                });
                Components.end_foldout();
            });
            // outline tab
            tab_outline.process(() => {
            });
            // third party tab
            tab_third_party.process(() => {
                Components.start_foldout();
                sub_tab_audiolink.process(() => {
                });
                sub_tab_superplug.process(() => {
                });
                sub_tab_ltcgi.process(() => {
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