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