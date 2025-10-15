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
        public static Version version = new Version("1.0.0");
        public static readonly Version version_dazzle = new Version("3.0.0"); // just internally
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
            new ShaderVariant("Default", "", Color.clear),
            new ShaderVariant("Outline", "Outline", new Color(1.0f, 0.75f, 0.8f)),
            new ShaderVariant("Grabpass", "Grabpass", new Color(0.77f, 0.93f, 0.77f))
        };
        public static readonly List<ShaderCapability> shader_capabilities = new List<ShaderCapability>
        { 
            new ShaderCapability("Depth", "depth_popup_info", new Color(0.9f, 0.9f, 0.9f)),
        };
        public static readonly List<Footer.Segment> footer_parts = new List<Footer.Segment>
        {
            new Footer.Segment("footer_madewith"),
            new Footer.Segment("footer_dazzle", "https://luka.moe/god/github/dazzle"),
            new Footer.Segment("footer_premonition", "https://luka.moe/god/github/premonition"),
            new Footer.Segment("footer_and"),
            new Footer.Segment("footer_backlace", "https://luka.moe/god/github/backlace"),
            new Footer.Segment("footer_heart"),
        };
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