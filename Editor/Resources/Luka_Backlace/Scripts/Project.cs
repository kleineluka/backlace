#if UNITY_EDITOR

using System.Collections.Generic;
using UnityEngine; 

// Project.cs is dedicated towards project information and metadata.
namespace Luka.Backlace
{

    // information about this specific project
    public class Project
    {
        public static readonly string project_name = "Backlace";
        public static readonly string project_path = "Luka_Backlace";
        public static readonly string project_license = "/Licenses/Backlace";
        public static Version version = new Version("3.0.0");
        public static readonly Version version_dazzle = new Version("5.0.0"); // just internally
        public static readonly string project_docs = "https://luka.moe/docs/backlace";
        public static readonly bool has_license = true; // if the project has a license file, or if you wanna show it
        public static readonly bool has_docs = true; // if the project has documentation, or if you wanna show it
        public static readonly bool shader_has_fallback = true; // if the shader uses a vrchat fallback shader that needs to be set in the inspector
        public static readonly bool shader_has_blendmodes = true; // if the shader has blendmodes that need to be set in the inspector
        public static readonly bool shader_has_variants = true; // if the shader has variants that need to be set in the inspector
        public static readonly bool has_banner = true; // if the ui should use a banner image instead of just text
        public static readonly string banner_image = "Images/Backlace_Logo"; // where that banner image is located
        public static readonly List<ShaderVariant> shader_variants = new List<ShaderVariant>
        {
            // smol
            new ShaderVariant("Small", "small/vanilla", new Color(0.6f, 0.8f, 1.0f), "luka/backlace/small/vanilla"),
            new ShaderVariant("Small Outline", "small/outline", new Color(0.6f, 0.7f, 0.9f), "luka/backlace/small/outline"),
            // default
            new ShaderVariant("Default", "default/vanilla", new Color(0.8f, 0.8f, 1.0f), "luka/backlace/default/vanilla"),
            new ShaderVariant("Default Outline", "default/outline", new Color(1.0f, 0.75f, 0.8f), "luka/backlace/default/outline"),
            new ShaderVariant("Default World", "default/world", new Color(0.7f, 0.9f, 0.7f), "luka/backlace/default/world"),
            new ShaderVariant("Default World Outline", "default/worldoutline", new Color(0.9f, 0.4f, 0.3f), "luka/backlace/default/worldoutline"),
            // full
            new ShaderVariant("Full", "full/vanilla", new Color(0.9f, 0.8f, 1.0f), "luka/backlace/full/vanilla"),
            new ShaderVariant("Full Outline", "full/outline", new Color(1.0f, 0.6f, 0.9f), "luka/backlace/full/outline"),
            new ShaderVariant("Full Grabpass", "full/grabpass", new Color(0.6f, 0.9f, 0.6f), "luka/backlace/full/grabpass"),
            new ShaderVariant("Full Grabpass Outline", "full/grabpassoutline", new Color(0.8f, 0.9f, 0.5f), "luka/backlace/full/grabpassoutline"),
            new ShaderVariant("Full World", "full/world", new Color(0.5f, 0.8f, 0.6f), "luka/backlace/full/world"),
            new ShaderVariant("Full World Outline", "full/worldoutline", new Color(0.8f, 0.3f, 0.2f), "luka/backlace/full/worldoutline"),
            new ShaderVariant("Full World Grabpass", "full/worldgrabpass", new Color(0.4f, 0.7f, 0.5f), "luka/backlace/full/worldgrabpass"),
            new ShaderVariant("Full World Grabpass Outline", "full/worldgrabpassoutline", new Color(0.7f, 0.2f, 0.1f), "luka/backlace/full/worldgrabpassoutline"),
        };
        public static readonly List<string> outline_variants = new List<string> { shader_variants[1].Token, shader_variants[3].Token, shader_variants[5].Token, shader_variants[7].Token, shader_variants[9].Token, shader_variants[11].Token, shader_variants[13].Token };
        public static readonly List<string> world_variants = new List<string> { shader_variants[4].Token, shader_variants[5].Token, shader_variants[10].Token, shader_variants[11].Token, shader_variants[12].Token, shader_variants[13].Token };
        public static readonly List<string> grabpass_variants = new List<string> { shader_variants[6].Token, shader_variants[7].Token, shader_variants[12].Token, shader_variants[13].Token };
        public static readonly List<ShaderCapability> shader_capabilities = new List<ShaderCapability>
        { 
            new ShaderCapability("Depth", "depth_popup_info", new Color(0.9f, 0.9f, 0.9f)),
        };
        public static readonly List<Footer.Segment> footer_parts = new List<Footer.Segment>
        {
            new Footer.Segment("footer_madewith"),
            new Footer.Segment("footer_backlace", "https://luka.moe/god/github/backlace"),
            new Footer.Segment("footer_heart"),
        };
        public static readonly List<Dependency> dependencies = new List<Dependency>
        {
            new Dependency("LTCGI", DependencyType.Package, folderPath: "", packageName: "at.pimaker.ltcgi", infoUrl: "https://github.com/PiMaker/ltcgi"),
            new Dependency("SPS", DependencyType.Package, folderPath: "", packageName: "com.vrcfury.vrcfury", infoUrl: "https://github.com/VRCFury/VRCFury"),
        };
        public static readonly List<string> preset_ignore = new List<string>
        {
            "_MainTex"
        };
        public static readonly DependencyManager dependency_manager = new DependencyManager(dependencies);
        public static readonly List<CustomBadge> lighting_mode_badges = new List<CustomBadge>
        {
            new CustomBadge("_LightingColorMode", new Dictionary<float, string> {
                { 0f, "custom_badge_backlace" },
                { 1f, "custom_badge_poi" },
                { 2f, "custom_badge_openlit" },
                { 3f, "custom_badge_standard" },
                { 4f, "custom_badge_mochie" }
            }, new Color(0.8f, 0.6f, 0.7f))
        };
        public static readonly List<CustomBadge> parallax_mode_badges = new List<CustomBadge>
        {
            new CustomBadge("_ParallaxMode", new Dictionary<float, string> {
                { 0f, "custom_badge_fast_uv" },
                { 1f, "custom_badge_fancy_uv" },
                { 2f, "custom_badge_layered" },
                { 3f, "custom_badge_interior" }
            }, new Color(0.6f, 0.7f, 0.9f))
        };
        public static readonly List<CustomBadge> iridescence_mode_badges = new List<CustomBadge>
        {
            new CustomBadge("_IridescenceMode", new Dictionary<float, string> {
                { 0f, "custom_badge_texture" },
                { 1f, "custom_badge_procedural" }
            }, new Color(0.8f, 0.6f, 0.9f))
        };
        public static readonly List<CustomBadge> glitter_mode_badges = new List<CustomBadge>
        {
            new CustomBadge("_GlitterMode", new Dictionary<float, string> {
                { 0f, "custom_badge_procedural" },
                { 1f, "custom_badge_texture" }
            }, new Color(0.9f, 0.85f, 0.6f))
        };
        public static readonly List<CustomBadge> dissolve_mode_badges = new List<CustomBadge>
        {
            new CustomBadge("_DissolveType", new Dictionary<float, string> {
                { 0f, "custom_badge_noise" },
                { 1f, "custom_badge_directional" },
                { 2f, "custom_badge_voxel" }
            }, new Color(0.9f, 0.65f, 0.6f))
        };
        public static readonly List<CustomBadge> distortion_mode_badges = new List<CustomBadge>
        {
            new CustomBadge("_VertexEffectType", new Dictionary<float, string> {
                { 0f, "custom_badge_distortion" },
                { 1f, "custom_badge_glitch" },
            }, new Color(0.6f, 0.9f, 0.8f))
        };
        public static readonly List<CustomBadge> anime_mode_badges = new List<CustomBadge>
        {
            new CustomBadge("_AnimeMode", new Dictionary<float, string> {
                { 1f, "custom_badge_ramp" },
                { 2f, "custom_badge_halftone" },
                { 3f, "custom_badge_hifi" },
                { 4f, "custom_badge_skin" },
                { 5f, "custom_badge_wrapped" },
            }, new Color(0.8f, 0.2f, 0.3f))
        };
        public static readonly List<CustomBadge> blend_mode_badges = new List<CustomBadge>
        {
            new CustomBadge("_BlendMode", new Dictionary<float, string> {
                { 0f, "custom_badge_opaque" },
                { 1f, "custom_badge_cutout" },
                { 2f, "custom_badge_fade" },
                { 3f, "custom_badge_opaquefade" },
                { 4f, "custom_badge_transparent" },
                { 5f, "custom_badge_premultiply" },
                { 6f, "custom_badge_additive" },
                { 7f, "custom_badge_softadditive" },
                { 8f, "custom_badge_multiplicative" },
                { 9f, "custom_badge_2multiplicative" }
            }, new Color(0.2f, 0.1f, 0.8f))
        };
        public static readonly bool enable_debug = true;
        public static readonly string debug_tag = "_Liquid";
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