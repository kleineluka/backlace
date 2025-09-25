#if UNITY_EDITOR

// Cache.cs prevents reloading assets used between multiple materials
namespace Luka.Backlace
{
    public static class CacheManager
    {
        public static Metadata meta = null;
        public static Languages languages = null;
        public static Config configs = null;
        public static Theme theme = null;
        public static SocialsMenu socials_menu = null;
        public static bool _initialised = false;

        public static void init_cache()
        {
            if (_initialised) return;
            Pretty.print("Initializing shared UI cache...", Pretty.LogKind.Debug);
            configs = new Config();
            languages = new Languages(configs.json_data.@interface.language);
            meta = new Metadata();
            theme = new Theme(ref configs, ref languages, ref meta);
            socials_menu = new SocialsMenu(ref theme);
            _initialised = true;
        }

        public static void clear_cache()
        {
            if (!_initialised) return;
            Pretty.print("Clearing shared UI cache...", Pretty.LogKind.Debug);
            meta = null;
            languages = null;
            configs = null;
            theme = null;
            socials_menu = null;
            _initialised = false;
        }
    }
}
#endif // UNITY_EDITOR