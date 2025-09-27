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
        public static Header header = null;
        public static Announcement announcement = null;
        public static Update update = null;
        public static Docs docs = null;
        public static Footer footer = null;
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
            header = new Header(ref theme);
            announcement = new Announcement(ref theme);
            update = new Update(ref theme);
            docs = new Docs(ref theme);
            footer = new Footer(ref theme, Project.footer_parts);
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
            header = null;
            announcement = null;
            update = null;
            docs = null;
            footer = null;
            _initialised = false;
        }
    }
}
#endif // UNITY_EDITOR