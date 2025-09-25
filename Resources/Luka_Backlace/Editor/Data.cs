#if UNITY_EDITOR

using System.Collections.Generic;
using UnityEngine;

// Data.cs stores metadata and language to prevent reloading across materials.
namespace Luka.Backlace
{
    public static class DataManager
    {
        // shared data 
        private static Metadata _metadata;
        public static Metadata Metadata => _metadata ?? (_metadata = new Metadata());
        private static Dictionary<string, Languages> _languageCache = new Dictionary<string, Languages>();
        public static Languages get_languages(string language)
        {
            if (string.IsNullOrEmpty(language)) language = Languages.language_default;
            if (!_languageCache.ContainsKey(language))
            {
                _languageCache[language] = new Languages(language);
            }
            return _languageCache[language];
        }

        // shared configurations
        private static Config _configs;
        public static Config Configs => _configs ?? (_configs = new Config());
        private static Theme _theme;
        public static Theme Theme
        {
            get
            {
                if (_theme == null)
                {
                    var currentLanguage = get_languages(Configs.json_data.@interface.language);
                    var metadata = Metadata; // ensure metadata is loaded
                    _theme = new Theme(ref _configs, ref currentLanguage, ref metadata);
                }
                return _theme;
            }
        }

        // shared ui components
        private static Header _header;
        public static Header Header => _header ?? (_header = new Header(ref _theme));
        private static Announcement _announcement;
        public static Announcement Announcement => _announcement ?? (_announcement = new Announcement(ref _theme));
        private static Update _update;
        public static Update Update => _update ?? (_update = new Update(ref _theme));
        private static Docs _docs;
        public static Docs Docs => _docs ?? (_docs = new Docs(ref _theme));
        private static SocialsMenu _socialsMenu;
        public static SocialsMenu SocialsMenu => _socialsMenu ?? (_socialsMenu = new SocialsMenu(ref _theme));
        private static Footer _footer;
        public static Footer Footer => _footer ?? (_footer = new Footer(ref _theme, Project.footer_parts));
        private static Bags _bags;
        public static Bags Bags
        {
            get
            {
                if (_bags == null)
                {
                    var currentLanguage = get_languages(Configs.json_data.@interface.language);
                    _bags = new Bags(ref currentLanguage);
                }
                return _bags;
            }
        }

        // invalidate all caches (ex. on shader change)
        public static void invalidate_caches()
        {
            Pretty.print("Invalidating all editor data manager caches.", Pretty.LogKind.Debug);
            _languageCache.Clear();
            _metadata = null;
            _configs = null;
            _theme = null;
            _header = null;
            _announcement = null;
            _update = null;
            _docs = null;
            _socialsMenu = null;
            _footer = null;
            _bags = null;
        }
    }
}   
#endif // UNITY_EDITOR