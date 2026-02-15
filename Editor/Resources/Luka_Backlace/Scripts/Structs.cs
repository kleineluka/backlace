#if UNITY_EDITOR
#pragma warning disable CS0414

// imports
using System;
using System.Collections.Generic;
using UnityEngine; 

// Structures.cs is dedicated towards data structures and classes.. (mostly for JSON)
namespace Luka.Backlace
{

    // language file entry
    [System.Serializable]
    public class LocalisationEntry
    {
        public string key;
        public string value;
    }

    // language file support
    [System.Serializable]
    public class Localisation_JsonData
    {
        public LocalisationEntry[] entries;
    }


    // a specific scheme (text, tab)
    [System.Serializable]
    public class SchemeIndex
    {
        public string name;
        public List<string> colors;
    }

    // a collection of schemes (text, tab)
    [System.Serializable]
    public class SchemeCollection
    {
        public List<SchemeIndex> schemelist;
    }

    // interface configuration
    [System.Serializable]
    public class InterfaceConfig
    {
        public string tab_theme;
        public string text_theme;
        public string ui_size;
        public string language;
        public bool show_updates;
        public bool show_announcements;
        public bool grey_unused;
        public bool show_status_badges;
        public bool expand_searches;
        public bool check_updates;
        public bool optimise_presets;
        public bool info_badges;
        public string reset_mode;
        public bool preset_ignore;
    }

    [System.Serializable]
    public class Config_JsonData
    {
        public InterfaceConfig @interface;
    }

    // metadata stuffs
    [System.Serializable]
    public class AnnouncementData
    {
        public string Header;
        public string Message;
        public bool Active;
    }

    [System.Serializable]
    public class VersionEntry
    {
        public string Name;
        public string Version;
        public string Changelog;
    }

    [System.Serializable]
    public class SocialLink
    {
        public string Name;
        public string Hover;
        public string Link;
        public SocialLink() {}
        public SocialLink (string Name, string Hover, string Link) {
            this.Name = Name;
            this.Hover = Hover;
            this.Link = Link;
        }
    }

    [System.Serializable]
    public class FullMetadata
    {
        public AnnouncementData Announcement;
        public List<VersionEntry> Versions;
        public List<SocialLink> Socials;
    }

    [System.Serializable]
    public struct BadgeMetadata
    {
        public string Text;
        public Color Color;
        public GUIStyle Style;
        public Action OnClick;
    }

    [System.Serializable]
    public class CustomBadge
    {
        public string PropertyName;
        public Dictionary<float, string> ValueToLabel;
        public Dictionary<float, Color> ValueToColor;
        public Color DefaultColor;
        public Action<float> OnClick;

        public CustomBadge(string propertyName, Dictionary<float, string> valueToLabel, Color? defaultColor = null, Dictionary<float, Color> valueToColor = null, Action<float> onClick = null)
        {
            PropertyName = propertyName;
            ValueToLabel = valueToLabel;
            ValueToColor = valueToColor;
            DefaultColor = defaultColor ?? new Color(0.6f, 0.6f, 0.8f);
            OnClick = onClick;
        }

        public string GetLabel(Material material)
        {
            if (material == null || !material.HasProperty(PropertyName)) return null;
            float value = material.GetFloat(PropertyName);
            return ValueToLabel.TryGetValue(value, out string label) ? label : null;
        }

        public Color GetColor(Material material)
        {
            if (material == null || !material.HasProperty(PropertyName) || ValueToColor == null) return DefaultColor;
            float value = material.GetFloat(PropertyName);
            return ValueToColor.TryGetValue(value, out Color color) ? color : DefaultColor;
        }
    }

    [System.Serializable]
    public enum DependencyType
    {
        Folder,
        Package,
        Either
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