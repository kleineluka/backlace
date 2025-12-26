#if UNITY_EDITOR

// imports
using System;
using System.IO;
using UnityEditor;
using UnityEngine;
using System.Collections.Generic;

// Depends.cs is dedicated towards helper and utility functions..
namespace Luka.Backlace
{

    // languages
    public class Languages
    {

        // storing constant variables
        public static readonly string language_store = "Languages";
        public static readonly string language_default = "English";

        // info about the language + store the translations
        private string language;
        private Dictionary<string, string> localised;
        private Dictionary<string, string> localised_fallback;

        // event for auto-indexing search terms
        public Action<string> on_speak_event;

        // constructor
        public Languages(string language)
        {
            this.language = language;
            load();
            // if the current language can't be loaded, try the default
            if (localised == null)
            {
                this.language = language_default;
                load();
            }
        }

        // load
        private void load()
        {
            try
            {
                // load the language file
                string language_path = Project.project_path + "/" + language_store + "/" + language;
                TextAsset json = Resources.Load<TextAsset>(language_path);
                Localisation_JsonData data = JsonUtility.FromJson<Localisation_JsonData>(json.text);
                localised = new Dictionary<string, string>();
                foreach (var entry in data.entries)
                {
                    localised[entry.key] = entry.value;
                }
                // also load the fallback language
                if (language != language_default)
                {
                    string fallback_path = Project.project_path + "/" + language_store + "/" + language_default;
                    TextAsset fallback_json = Resources.Load<TextAsset>(fallback_path);
                    Localisation_JsonData fallback_data = JsonUtility.FromJson<Localisation_JsonData>(fallback_json.text);
                    localised_fallback = new Dictionary<string, string>();
                    foreach (var entry in fallback_data.entries)
                    {
                        localised_fallback[entry.key] = entry.value;
                    }
                }
                else
                {
                    localised_fallback = null; // no fallback needed for default
                }
            }
            catch (Exception)
            {
                localised = null;
            }
        }

        // speak that language
        public string speak(string key, params object[] args)
        {
            string result = key;
            if (localised != null && localised.TryGetValue(key, out string value))
            {
                result = string.Format(value, args);
            }
            else if (localised_fallback != null && localised_fallback.TryGetValue(key, out string fallback_value))
            {
                result = string.Format(fallback_value, args);
            }
            // notify listeners (used for search indexing)
            on_speak_event?.Invoke(result);
            return result;
        }

    }

    // logging
    public class Pretty
    {

        // basic configuration
        private static readonly string log_format = "%project% @ %time% >> [%colour_start%%kind%%colour_end%] %message%";

        // log kinds
        public struct LogKind
        {
            public static readonly LogKind Info = new LogKind("Info", "#FFFFFF");
            public static readonly LogKind Warning = new LogKind("Warning", "#FFA500");
            public static readonly LogKind Error = new LogKind("Error", "#FF0000");
            public static readonly LogKind Debug = new LogKind("Debug", "#00FFFF");

            public string Name { get; }
            public string HexColor { get; }

            private LogKind(string name, string hexColor)
            {
                Name = name;
                HexColor = hexColor;
            }

        }

        // format a message
        private static string format(string message, string kind)
        {
            return log_format
                .Replace("%project%", Project.project_name)
                .Replace("%time%", DateTime.Now.ToString("HH:mm:ss"))
                .Replace("%colour_start%", $"<color={LogKind.Info.HexColor}>")
                .Replace("%kind%", kind)
                .Replace("%colour_end%", "</color>")
                .Replace("%message%", message);
        }

        // log a message
        public static void print(string message, LogKind kind)
        {
            string formatted_message = format(message, kind.Name);
            switch (kind.Name)
            {
                case "Info":
                    Debug.Log(formatted_message);
                    break;
                case "Warning":
                    Debug.LogWarning(formatted_message);
                    break;
                case "Error":
                    Debug.LogError(formatted_message);
                    break;
                case "Debug":
                    // only print debug messages in developer mode
                    if (Project.enable_debug) Debug.Log(formatted_message);
                    break;
                default:
                    Debug.Log(formatted_message);
                    break;
            }
        }

        // because i can't default logkind to null for whatever reason
        public static void print(string message)
        {
            print(message, LogKind.Info);
        }

    }

    // keep track of versions in semantic format
    public class Version
    {

        int major = 0;
        int minor = 0;
        int patch = 0;

        public Version(string version)
        {
            string[] version_split = version.Split('.');
            if (version_split.Length > 0) major = int.Parse(version_split[0]);
            if (version_split.Length > 1) minor = int.Parse(version_split[1]);
            if (version_split.Length > 2) patch = int.Parse(version_split[2]);
        }

        public bool is_newer_than(Version version)
        {
            if (major == version.major && minor == version.minor && patch == version.patch) return true; // current version is same
            if (major > version.major) return true;
            if (major == version.major && minor > version.minor) return true;
            if (major == version.major && minor == version.minor && patch > version.patch) return true;
            return false;
        }

        public string print()
        {
            return $"{major}.{minor}.{patch}";
        }

    }

    // configuration
    public class Config
    {

        // malleable properties
        public Config_JsonData json_data;
        public bool config_loaded = false;

        // constant properties
        private static readonly string config_active = "Active_Config";
        private static readonly string config_default = "Default_Config";
        private static readonly string config_storage = "Data";

        // constructor
        public Config()
        {
            populate();
        }

        // populate the config
        public void populate()
        {
            read();
            if (!config_loaded)
            { // basic safety check
                reset();
                read();
            }
        }

        private bool write(Config_JsonData data)
        {
            string active_config_path = Path.Combine(Project.project_path, config_storage, config_active);
            TextAsset active_config = Resources.Load<TextAsset>(active_config_path);
            string active_disk_path = Path.GetFullPath(AssetDatabase.GetAssetPath(active_config));
            string json_string = JsonUtility.ToJson(data, true);
            try
            {
                File.WriteAllText(active_disk_path, json_string);
                AssetDatabase.Refresh();
                return true;
            }
            catch (Exception e)
            {
                Pretty.print($"Failed to save configuration: {e.Message}", Pretty.LogKind.Error);
                return false;
            }
        }

        public void read()
        {
            string config_path = Project.project_path + "/" + config_storage + "/" + config_active;
            TextAsset config_text = Resources.Load<TextAsset>(config_path);
            json_data = JsonUtility.FromJson<Config_JsonData>(config_text.text);
            config_loaded = (json_data != null);
        }

        public bool save()
        {
            if (json_data != null)
            {
                if (!write(json_data)) return false;
                config_loaded = true;
                return true;
            }
            else
            {
                Pretty.print("Config data is null, cannot save.", Pretty.LogKind.Error);
                return false;
            }
        }

        public bool reset()
        {
            string default_path = Project.project_path + "/" + config_storage + "/" + config_default;
            TextAsset default_text = Resources.Load<TextAsset>(default_path);
            if (default_text != null)
            {
                json_data = JsonUtility.FromJson<Config_JsonData>(default_text.text);
                write(json_data);
                config_loaded = true;
                return true;
            }
            else
            {
                Pretty.print("Default config not found, creating a new one.", Pretty.LogKind.Error);
                json_data = new Config_JsonData();
                return false;
            }
        }

    }

    // metadata
    public class Metadata
    {

        // malleable properties
        public FullMetadata full_metadata;
        public bool metadata_loaded = false;

        // constant properties
        private static readonly string metadata_path = "https://luka.moe/api/unity/shared.json";
        private static readonly string metadata_agent = "Luka/UnityEditor/" + Project.project_name + "/" + Project.version.print();

        // constructor
        public Metadata()
        {
            fetch();
            if (!metadata_loaded)
            {
                reset();
                fallback();
            }
        }

        // fetch
        private void fetch()
        {
            if (Project.enable_debug) 
            {
                Pretty.print("Developer mode is active, skipping metadata fetch...", Pretty.LogKind.Info);
                full_metadata = null;
                metadata_loaded = false;
                return;
            }
            try
            {
                using (var wc = new System.Net.WebClient())
                {
                    wc.Headers.Add("user-agent", metadata_agent);
                    string string_file = wc.DownloadString(metadata_path);
                    if (!string.IsNullOrEmpty(string_file))
                    {
                        full_metadata = JsonUtility.FromJson<FullMetadata>(string_file);
                        metadata_loaded = true;
                    }
                    else
                    {
                        Pretty.print("Failed to fetch metadata, response was empty. Defaulting to fallback..", Pretty.LogKind.Error);
                        full_metadata = null;
                        metadata_loaded = false;
                    }
                }
            }
            catch (Exception ex)
            {
                Pretty.print($"Error fetching metadata: {ex.Message}", Pretty.LogKind.Error);
                full_metadata = null;
                metadata_loaded = false;
            }
        }

        // reset
        private void reset()
        {
            // reset the metadata
            full_metadata = new FullMetadata();
            metadata_loaded = false;
        }

        // default
        private void fallback()
        {
            full_metadata = new FullMetadata();
            full_metadata.Announcement = new AnnouncementData
            {
                Header = "",
                Message = "",
                Active = false
            };
            full_metadata.Socials = new List<SocialLink>
            {
                new SocialLink(Name: "Gumroad", Hover: "My Gumroad Shop!", Link: "https://luka.moe/go/gumroad"),
                new SocialLink(Name: "Booth", Hover: "Booth.jp Store :)", Link: "https://luka.moe/go/booth"),
                new SocialLink(Name: "Jinxxy", Hover: "My Jinxxy", Link: "https://luka.moe/go/jinxxy"),
                new SocialLink(Name: "Payhip", Hover: "My Payhip Store", Link: "https://luka.moe/go/payhip"),
                new SocialLink(Name: "Website", Hover: "My Very Own Website!", Link: "https://luka.moe/"),
                new SocialLink(Name: "Discord", Hover: "Wanna Reach Out To Me?", Link: "https://luka.moe/contact"),
                new SocialLink(Name: "Github", Hover: "My Open Source Projects <3", Link: "https://luka.moe/go/github"),
            };
            full_metadata.Versions = new List<VersionEntry>
            {
                new VersionEntry { Name = Project.project_name, Version = Project.version.print(), Changelog = "" }
            };
            metadata_loaded = true;
        }

    }

    // unity can be a brat, but i can be brattier
    public class Bratty
    {

        public static string GetFullPathFromResource(string resourcePath)
        {
            resourcePath = resourcePath.Replace('\\', '/');
            string[] guids = AssetDatabase.FindAssets($"t:DefaultAsset {Path.GetFileName(resourcePath)}");
            foreach (string guid in guids)
            {
                string assetPath = AssetDatabase.GUIDToAssetPath(guid);
                if (assetPath.Contains("/Resources/") && assetPath.EndsWith(resourcePath))
                {
                    return Path.GetFullPath(assetPath);
                }
            }
            var asset = Resources.Load(resourcePath);
            if (asset != null)
            {
                string assetPath = AssetDatabase.GetAssetPath(asset);
                if (!string.IsNullOrEmpty(assetPath))
                {
                    return Path.GetFullPath(assetPath);
                }
            }
            Pretty.print($"Could not find a valid full path for resource '{resourcePath}'.", Pretty.LogKind.Warning);
            return null;
        }

        public static string GetAssetPathFromResource(string resourcePath)
        {
            resourcePath = resourcePath.Replace('\\', '/');
            string[] guids = AssetDatabase.FindAssets($"t:DefaultAsset {Path.GetFileName(resourcePath)}");
            foreach (string guid in guids)
            {
                string assetPath = AssetDatabase.GUIDToAssetPath(guid);
                if (assetPath.Contains("/Resources/") && assetPath.EndsWith(resourcePath))
                {
                    return assetPath;
                }
            }
            var asset = Resources.Load(resourcePath);
            if (asset != null)
            {
                string assetPath = AssetDatabase.GetAssetPath(asset);
                if (!string.IsNullOrEmpty(assetPath))
                {
                    return assetPath;
                }
            }
            Pretty.print($"Could not find a valid asset path for resource '{resourcePath}'.", Pretty.LogKind.Warning);
            return null;
        }

    }

    // you fall on a cushion, your shader falls back to others
    public class Cushion
    {
        private int _currentFallback;
        private int _currentBlendMode;

        public Cushion(Material mat)
        {
            if (!mat.HasProperty("_VRCFallback") || !mat.HasProperty("_BlendMode")) return;
            _currentFallback = mat.GetInt("_VRCFallback");
            _currentBlendMode = mat.GetInt("_BlendMode");
            SetTag(mat);
        }

        public void Update(Material mat)
        {
            if (!mat.HasProperty("_VRCFallback") || !mat.HasProperty("_BlendMode")) return;
            int newFallback = mat.GetInt("_VRCFallback");
            int newBlendMode = mat.GetInt("_BlendMode");
            if (newFallback != _currentFallback || newBlendMode != _currentBlendMode)
            {
                _currentFallback = newFallback;
                _currentBlendMode = newBlendMode;
                SetTag(mat);
            }
        }

        private void SetTag(Material mat)
        {
            string fallbackTag = "";
            // Expected fallback enum: Toon=0, DoubleSided=1, Unlit=2, Particle=3, Matcap=4, Sprite=5, Hidden=6
            switch (_currentFallback)
            {
                case 0: fallbackTag = "Toon"; break;
                case 1: fallbackTag = "DoubleSided"; break;
                case 2: fallbackTag = "Unlit"; break;
                case 3: fallbackTag = "Particle"; break;
                case 4: fallbackTag = "Matcap"; break;
                case 5: fallbackTag = "Sprite"; break;
                case 6: fallbackTag = "Hidden"; break;
                default: break;
            }
            if (_currentFallback != 6) // Not "Hidden"
            {
                // _BlendMode enum: Cutout=0, Fade=1, Transparent=2, Premultiply=3
                switch (_currentBlendMode)
                {
                    case 1: // cutout
                        fallbackTag += "Cutout";
                        break;
                    case 2: // fade
                        fallbackTag += "Fade";
                        break;
                    case 3: // transparent
                    case 4: // premultiply
                        fallbackTag += "Transparent";
                        break;
                    // case 0 (Opaque)
                    default: break;
                }
            }
            mat.SetOverrideTag("VRCFallback", fallbackTag);
        }
    }

    // handle blend modes and render modes
    public class BeautyBlender
    {
        private int _currentBlendMode;
        private bool _isOverrideQueue;
        private bool _isOverrideBaseBlend;
        private bool _isOverrideAddBlend;
        private bool _isOverrideZWrite;

        public BeautyBlender(Material mat)
        {
            if (!mat.HasProperty("_BlendMode")) return;
            _currentBlendMode = mat.GetInt("_BlendMode");
            _isOverrideQueue = mat.GetFloat("_OverrideRenderQueue") == 1.0f;
            _isOverrideBaseBlend = mat.GetFloat("_OverrideBaseBlend") == 1.0f;
            _isOverrideAddBlend = mat.GetFloat("_OverrideAddBlend") == 1.0f;
            _isOverrideZWrite = mat.GetFloat("_OverrideZWrite") == 1.0f;
            Apply(mat);
        }

        public void Update(Material mat)
        {
            if (!mat.HasProperty("_BlendMode")) return;
            int newBlendMode = mat.GetInt("_BlendMode");
            bool newOverrideQueue = mat.GetFloat("_OverrideRenderQueue") == 1.0f;
            bool newOverrideBaseBlend = mat.GetFloat("_OverrideBaseBlend") == 1.0f;
            bool newOverrideAddBlend = mat.GetFloat("_OverrideAddBlend") == 1.0f;
            bool newOverrideZWrite = mat.GetFloat("_OverrideZWrite") == 1.0f;
            if (newBlendMode != _currentBlendMode || newOverrideQueue != _isOverrideQueue ||
                newOverrideBaseBlend != _isOverrideBaseBlend || newOverrideAddBlend != _isOverrideAddBlend ||
                newOverrideZWrite != _isOverrideZWrite)
            {
                _currentBlendMode = newBlendMode;
                _isOverrideQueue = newOverrideQueue;
                _isOverrideBaseBlend = newOverrideBaseBlend;
                _isOverrideAddBlend = newOverrideAddBlend;
                _isOverrideZWrite = newOverrideZWrite;
                Apply(mat);
            }
        }

        // make life easier
        private static void SetBlendModeKeyword(Material mat, string keywordToEnable)
        {
            mat.DisableKeyword("_BLENDMODE_CUTOUT");
            mat.DisableKeyword("_BLENDMODE_FADE");
            mat.DisableKeyword("_BLENDMODE_TRANSPARENT");
            mat.DisableKeyword("_BLENDMODE_PREMULTIPLY");
            if (!string.IsNullOrEmpty(keywordToEnable))
            {
                mat.EnableKeyword(keywordToEnable);
            }
        }

        private void Apply(Material mat)
        {
            int renderQueue;
            string renderType;
            switch (_currentBlendMode)
            {
                case 0: // opaque
                    if (!_isOverrideBaseBlend) {
                        mat.SetInt("_SrcBlend", (int)UnityEngine.Rendering.BlendMode.One);
                        mat.SetInt("_DstBlend", (int)UnityEngine.Rendering.BlendMode.Zero);
                        mat.SetInt("_BlendOp", (int)UnityEngine.Rendering.BlendOp.Add);
                    }
                    if (!_isOverrideAddBlend) {
                        mat.SetInt("_AddSrcBlend", (int)UnityEngine.Rendering.BlendMode.One);
                        mat.SetInt("_AddDstBlend", (int)UnityEngine.Rendering.BlendMode.One);
                        mat.SetInt("_AddBlendOp", (int)UnityEngine.Rendering.BlendOp.Add);
                    }
                    if (!_isOverrideZWrite) mat.SetInt("_ZWrite", 1);
                    renderQueue = (int)UnityEngine.Rendering.RenderQueue.Geometry;
                    renderType = "Opaque";
                    SetBlendModeKeyword(mat, null);
                    break;
                case 1: // cutout
                    if (!_isOverrideBaseBlend) {
                        mat.SetInt("_SrcBlend", (int)UnityEngine.Rendering.BlendMode.One);
                        mat.SetInt("_DstBlend", (int)UnityEngine.Rendering.BlendMode.Zero);
                        mat.SetInt("_BlendOp", (int)UnityEngine.Rendering.BlendOp.Add);
                    }
                    if (!_isOverrideAddBlend) {
                        mat.SetInt("_AddSrcBlend", (int)UnityEngine.Rendering.BlendMode.One);
                        mat.SetInt("_AddDstBlend", (int)UnityEngine.Rendering.BlendMode.One);
                        mat.SetInt("_AddBlendOp", (int)UnityEngine.Rendering.BlendOp.Add);
                    }
                    if (!_isOverrideZWrite) mat.SetInt("_ZWrite", 1);
                    renderQueue = (int)UnityEngine.Rendering.RenderQueue.AlphaTest;
                    renderType = "TransparentCutout";
                    SetBlendModeKeyword(mat, "_BLENDMODE_CUTOUT");
                    break;
                case 2: // fade
                    if (!_isOverrideBaseBlend) {
                        mat.SetInt("_SrcBlend", (int)UnityEngine.Rendering.BlendMode.SrcAlpha);
                        mat.SetInt("_DstBlend", (int)UnityEngine.Rendering.BlendMode.OneMinusSrcAlpha);
                        mat.SetInt("_BlendOp", (int)UnityEngine.Rendering.BlendOp.Add);
                    }
                    if (!_isOverrideAddBlend) {
                        mat.SetInt("_AddSrcBlend", (int)UnityEngine.Rendering.BlendMode.One);
                        mat.SetInt("_AddDstBlend", (int)UnityEngine.Rendering.BlendMode.One);
                        mat.SetInt("_AddBlendOp", (int)UnityEngine.Rendering.BlendOp.Add);
                    }
                    if (!_isOverrideZWrite) mat.SetInt("_ZWrite", 0);
                    renderQueue = (int)UnityEngine.Rendering.RenderQueue.Transparent;
                    renderType = "Transparent";
                    SetBlendModeKeyword(mat, "_BLENDMODE_FADE");
                    break;
                case 3: // opaque fade
                    if (!_isOverrideBaseBlend) {
                        mat.SetInt("_SrcBlend", (int)UnityEngine.Rendering.BlendMode.SrcAlpha);
                        mat.SetInt("_DstBlend", (int)UnityEngine.Rendering.BlendMode.OneMinusSrcAlpha);
                        mat.SetInt("_BlendOp", (int)UnityEngine.Rendering.BlendOp.Add);
                    }
                    if (!_isOverrideAddBlend) {
                        mat.SetInt("_AddSrcBlend", (int)UnityEngine.Rendering.BlendMode.One);
                        mat.SetInt("_AddDstBlend", (int)UnityEngine.Rendering.BlendMode.One);
                        mat.SetInt("_AddBlendOp", (int)UnityEngine.Rendering.BlendOp.Add);
                    }
                    if (!_isOverrideZWrite) mat.SetInt("_ZWrite", 1);
                    renderQueue = (int)UnityEngine.Rendering.RenderQueue.AlphaTest;
                    renderType = "Transparent";
                    SetBlendModeKeyword(mat, "_BLENDMODE_FADE");
                    break;
                case 4: // transparent
                     if (!_isOverrideBaseBlend) {
                        mat.SetInt("_SrcBlend", (int)UnityEngine.Rendering.BlendMode.SrcAlpha);
                        mat.SetInt("_DstBlend", (int)UnityEngine.Rendering.BlendMode.OneMinusSrcAlpha);
                        mat.SetInt("_BlendOp", (int)UnityEngine.Rendering.BlendOp.Add);
                    }
                    if (!_isOverrideAddBlend) {
                        mat.SetInt("_AddSrcBlend", (int)UnityEngine.Rendering.BlendMode.One);
                        mat.SetInt("_AddDstBlend", (int)UnityEngine.Rendering.BlendMode.One);
                        mat.SetInt("_AddBlendOp", (int)UnityEngine.Rendering.BlendOp.Add);
                    }
                    if (!_isOverrideZWrite) mat.SetInt("_ZWrite", 0);
                    renderQueue = (int)UnityEngine.Rendering.RenderQueue.Transparent;
                    renderType = "Transparent";
                    SetBlendModeKeyword(mat, "_BLENDMODE_TRANSPARENT");
                    break;
                case 5: // premultiply
                    if (!_isOverrideBaseBlend) {
                        mat.SetInt("_SrcBlend", (int)UnityEngine.Rendering.BlendMode.One);
                        mat.SetInt("_DstBlend", (int)UnityEngine.Rendering.BlendMode.OneMinusSrcAlpha);
                        mat.SetInt("_BlendOp", (int)UnityEngine.Rendering.BlendOp.Add);
                    }
                    if (!_isOverrideAddBlend) {
                        mat.SetInt("_AddSrcBlend", (int)UnityEngine.Rendering.BlendMode.One);
                        mat.SetInt("_AddDstBlend", (int)UnityEngine.Rendering.BlendMode.One);
                        mat.SetInt("_AddBlendOp", (int)UnityEngine.Rendering.BlendOp.Add);
                    }
                    if (!_isOverrideZWrite) mat.SetInt("_ZWrite", 0);
                    renderQueue = (int)UnityEngine.Rendering.RenderQueue.Transparent;
                    renderType = "Transparent";
                    SetBlendModeKeyword(mat, "_BLENDMODE_PREMULTIPLY");
                    break;
                case 6: // additive
                    if (!_isOverrideBaseBlend) {
                        mat.SetInt("_SrcBlend", (int)UnityEngine.Rendering.BlendMode.One);
                        mat.SetInt("_DstBlend", (int)UnityEngine.Rendering.BlendMode.One);
                        mat.SetInt("_BlendOp", (int)UnityEngine.Rendering.BlendOp.Add);
                    }
                    if (!_isOverrideAddBlend) {
                        mat.SetInt("_AddSrcBlend", (int)UnityEngine.Rendering.BlendMode.One);
                        mat.SetInt("_AddDstBlend", (int)UnityEngine.Rendering.BlendMode.One);
                        mat.SetInt("_AddBlendOp", (int)UnityEngine.Rendering.BlendOp.Add);
                    }
                    if (!_isOverrideZWrite) mat.SetInt("_ZWrite", 0);
                    renderQueue = (int)UnityEngine.Rendering.RenderQueue.Transparent;
                    renderType = "Transparent";
                    SetBlendModeKeyword(mat, "_BLENDMODE_FADE");
                    break;
                case 7: // soft additive
                    if (!_isOverrideBaseBlend) {
                        mat.SetInt("_SrcBlend", (int)UnityEngine.Rendering.BlendMode.OneMinusDstColor);
                        mat.SetInt("_DstBlend", (int)UnityEngine.Rendering.BlendMode.One);
                        mat.SetInt("_BlendOp", (int)UnityEngine.Rendering.BlendOp.Add);
                    }
                    if (!_isOverrideAddBlend) {
                        mat.SetInt("_AddSrcBlend", (int)UnityEngine.Rendering.BlendMode.One);
                        mat.SetInt("_AddDstBlend", (int)UnityEngine.Rendering.BlendMode.One);
                        mat.SetInt("_AddBlendOp", (int)UnityEngine.Rendering.BlendOp.Add);
                    }
                    if (!_isOverrideZWrite) mat.SetInt("_ZWrite", 0);
                    renderQueue = (int)UnityEngine.Rendering.RenderQueue.Transparent;
                    renderType = "Transparent";
                    SetBlendModeKeyword(mat, "_BLENDMODE_FADE");
                    break;
                case 8: // multiplicative
                    if (!_isOverrideBaseBlend) {
                        mat.SetInt("_SrcBlend", (int)UnityEngine.Rendering.BlendMode.DstColor);
                        mat.SetInt("_DstBlend", (int)UnityEngine.Rendering.BlendMode.Zero);
                        mat.SetInt("_BlendOp", (int)UnityEngine.Rendering.BlendOp.Add);
                    }
                    if (!_isOverrideAddBlend) {
                        mat.SetInt("_AddSrcBlend", (int)UnityEngine.Rendering.BlendMode.One);
                        mat.SetInt("_AddDstBlend", (int)UnityEngine.Rendering.BlendMode.One);
                        mat.SetInt("_AddBlendOp", (int)UnityEngine.Rendering.BlendOp.Add);
                    }
                    if (!_isOverrideZWrite) mat.SetInt("_ZWrite", 0);
                    renderQueue = (int)UnityEngine.Rendering.RenderQueue.Transparent;
                    renderType = "Transparent";
                    SetBlendModeKeyword(mat, "_BLENDMODE_FADE");
                    break;
                case 9: // 2x multiplicative 
                    if (!_isOverrideBaseBlend) {
                        mat.SetInt("_SrcBlend", (int)UnityEngine.Rendering.BlendMode.DstColor);
                        mat.SetInt("_DstBlend", (int)UnityEngine.Rendering.BlendMode.SrcColor);
                        mat.SetInt("_BlendOp", (int)UnityEngine.Rendering.BlendOp.Add);
                    }
                    if (!_isOverrideAddBlend) {
                        mat.SetInt("_AddSrcBlend", (int)UnityEngine.Rendering.BlendMode.One);
                        mat.SetInt("_AddDstBlend", (int)UnityEngine.Rendering.BlendMode.One);
                        mat.SetInt("_AddBlendOp", (int)UnityEngine.Rendering.BlendOp.Add);
                    }
                    if (!_isOverrideZWrite) mat.SetInt("_ZWrite", 0);
                    renderQueue = (int)UnityEngine.Rendering.RenderQueue.Transparent;
                    renderType = "Transparent";
                    SetBlendModeKeyword(mat, "_BLENDMODE_FADE");
                    break;
                default: // fallback to opaque
                    if (!_isOverrideBaseBlend) {
                        mat.SetInt("_SrcBlend", (int)UnityEngine.Rendering.BlendMode.One);
                        mat.SetInt("_DstBlend", (int)UnityEngine.Rendering.BlendMode.Zero);
                        mat.SetInt("_BlendOp", (int)UnityEngine.Rendering.BlendOp.Add);
                    }
                    if (!_isOverrideAddBlend) {
                        mat.SetInt("_AddSrcBlend", (int)UnityEngine.Rendering.BlendMode.One);
                        mat.SetInt("_AddDstBlend", (int)UnityEngine.Rendering.BlendMode.One);
                        mat.SetInt("_AddBlendOp", (int)UnityEngine.Rendering.BlendOp.Add);
                    }
                    if (!_isOverrideZWrite) mat.SetInt("_ZWrite", 1);
                    renderQueue = (int)UnityEngine.Rendering.RenderQueue.Geometry;
                    renderType = "Opaque";
                    SetBlendModeKeyword(mat, null);
                    break;
            }
            // finally apply the tags and render queue
            mat.SetOverrideTag("RenderType", renderType);
            if (!_isOverrideQueue)
            {
                mat.renderQueue = renderQueue;
            }
        }
    }

    // personal preset manager
    public class Bags
    {   
        private static readonly string preset_extension = ".asset";
        private static readonly string project_preset_path = Project.project_path + "/Presets";
        private static readonly string user_preset_path = project_preset_path + "/User";
        private string asset_preset_path = null; // for unity assets, tba
        private string asset_user_path = null; // for unity assets, tba
        private string real_preset_path = null; // for working with directories, tba
        private string real_user_path = null; // for working with directories, tba
        public Languages language_manager = null;
        public List<Material> projectPresets;
        public List<Material> userPresets;

        public Bags(ref Languages language)
        {
            language_manager = language;
            LoadPaths();
            LoadPresets();
        }

        public void LoadPaths() {
            // the real path matters most
            asset_preset_path = Bratty.GetAssetPathFromResource(project_preset_path);
            real_preset_path = Bratty.GetFullPathFromResource(project_preset_path);
            // user path is optional, but we just add /User to the end of both
            asset_user_path = Path.Combine(asset_preset_path, "User");
            real_user_path = Path.Combine(real_preset_path, "User");
        }

        public void LoadPresets()
        {
            projectPresets = LoadMaterialsFromPath(real_preset_path, SearchOption.AllDirectories);
            userPresets = LoadMaterialsFromPath(real_user_path, SearchOption.TopDirectoryOnly);
        }

        public static void ApplyPreset(Material preset, Material targetMaterial)
        {
            if (preset == null || targetMaterial == null)
            {
                Pretty.print("Preset or target material is null. Cannot apply.", Pretty.LogKind.Error);
                return;
            }
            Undo.RecordObject(targetMaterial, "Apply Dazzle Preset '" + preset.name + "'");
            // copy all shader properties
            CopyMaterialProperties(preset, targetMaterial);
            targetMaterial.shaderKeywords = preset.shaderKeywords;
            targetMaterial.renderQueue = preset.renderQueue;
            // trigger logic from beautyblender and cushion if needed
            if (Project.shader_has_blendmodes) new BeautyBlender(targetMaterial);
            if (Project.shader_has_fallback) new Cushion(targetMaterial);
            EditorUtility.SetDirty(targetMaterial);
        }

        public bool SavePreset(Material sourceMaterial, string presetName)
        {
            if (sourceMaterial == null || string.IsNullOrEmpty(presetName))
            {
                Pretty.print("Source material is null or preset name is empty.", Pretty.LogKind.Error);
                return false;
            }
            if (!Directory.Exists(real_user_path))
            {
                Directory.CreateDirectory(real_user_path);
                AssetDatabase.Refresh();
            }
            string finalAssetPath = Path.Combine(asset_user_path, presetName + preset_extension);
            string finalRealPath = Path.Combine(real_user_path, presetName + preset_extension);
            if (File.Exists(finalRealPath))
            {
                if (!EditorUtility.DisplayDialog(language_manager.speak("preset_title"),
                    language_manager.speak("preset_overwrite_prompt", presetName),
                    language_manager.speak("preset_overwrite_prompt_yes"), language_manager.speak("preset_overwrite_prompt_no")))
                {
                    return false;
                }
                AssetDatabase.DeleteAsset(finalAssetPath);
            }
            Material newPreset = new Material(sourceMaterial);
            try
            {
                string tempAssetPath = Path.Combine(asset_user_path, presetName + ".asset");
                AssetDatabase.CreateAsset(newPreset, tempAssetPath);
                AssetDatabase.SaveAssets(); 
                AssetDatabase.MoveAsset(tempAssetPath, finalAssetPath);
                AssetDatabase.Refresh();
                Pretty.print($"Saved preset '{presetName}' successfully.", Pretty.LogKind.Debug);
                LoadPresets();
                return true;
            }
            catch (Exception e)
            {
                Pretty.print($"Failed to save preset: {e.Message}", Pretty.LogKind.Error);
                return false;
            }
        }

        public bool DeletePreset(string presetName)
        {
            if (string.IsNullOrEmpty(presetName))
            {
                Pretty.print("Preset name is empty.", Pretty.LogKind.Error);
                return false;
            }
            string realPath = Path.Combine(real_user_path, presetName + preset_extension);
            string assetPath = Path.Combine(asset_user_path, presetName + preset_extension);
            if (!File.Exists(realPath))
            {
                Pretty.print($"Preset '{presetName}' not found at path: {realPath}", Pretty.LogKind.Warning);
                return false;
            }
            if (AssetDatabase.DeleteAsset(assetPath))
            {
                Pretty.print($"Deleted preset '{presetName}' successfully.", Pretty.LogKind.Debug);
                LoadPresets(); 
                return true;
            }
            else
            {
                Pretty.print($"Failed to delete preset '{presetName}'.", Pretty.LogKind.Error);
                return false;
            }
        }
        
        private static void CopyMaterialProperties(Material source, Material dest)
        {
            dest.shader = source.shader;
            int propertyCount = ShaderUtil.GetPropertyCount(source.shader);
            for (int i = 0; i < propertyCount; i++)
            {
                string propertyName = ShaderUtil.GetPropertyName(source.shader, i);
                if (dest.HasProperty(propertyName))
                {
                    switch (ShaderUtil.GetPropertyType(source.shader, i))
                    {
                        case ShaderUtil.ShaderPropertyType.Color:
                            dest.SetColor(propertyName, source.GetColor(propertyName));
                            break;
                        case ShaderUtil.ShaderPropertyType.Vector:
                            dest.SetVector(propertyName, source.GetVector(propertyName));
                            break;
                        case ShaderUtil.ShaderPropertyType.Float:
                        case ShaderUtil.ShaderPropertyType.Range:
                            dest.SetFloat(propertyName, source.GetFloat(propertyName));
                            break;
                        case ShaderUtil.ShaderPropertyType.TexEnv:
                            Texture texture = source.GetTexture(propertyName);
                            Vector2 offset = source.GetTextureOffset(propertyName);
                            Vector2 scale = source.GetTextureScale(propertyName);
                            dest.SetTexture(propertyName, texture);
                            dest.SetTextureOffset(propertyName, offset);
                            dest.SetTextureScale(propertyName, scale);
                            break;
                    }
                }
            }
        }

        private List<Material> LoadMaterialsFromPath(string path, SearchOption searchOption)
        {
            List<Material> materials = new List<Material>();
            if (!Directory.Exists(path))
            {
                if (path != real_user_path)
                {
                    Pretty.print($"Preset directory not found: {path}", Pretty.LogKind.Warning);
                }
                return materials;
            }
            string[] presetFiles = Directory.GetFiles(path, $"*{preset_extension}", searchOption);
            foreach (string filePath in presetFiles)
            {
                // ignore user presets in the main preset folder
                if (path != real_user_path && filePath.StartsWith(real_user_path))
                {
                    continue;
                }
                string assetPath = "Assets" + filePath.Substring(Application.dataPath.Length).Replace('\\', '/');
                Material preset = AssetDatabase.LoadAssetAtPath<Material>(assetPath);
                if (preset != null)
                {
                    materials.Add(preset);
                }
            }
            return materials;
        }

    }

    // prefab spawner
    public class Prefabulous
    {
        private static readonly string prefab_path = Project.project_path + "/Prefabs";
        public List<GameObject> prefabs;

        public Prefabulous()
        {
            LoadPrefabs();
        }

        public void LoadPrefabs()
        {
            prefabs = LoadPrefabsFromPath(prefab_path);
        }

        public void SpawnPrefab(GameObject prefab)
        {
            if (prefab == null)
            {
                Pretty.print("Prefab is null. Cannot spawn.", Pretty.LogKind.Error);
                return;
            }
            GameObject instance = PrefabUtility.InstantiatePrefab(prefab) as GameObject;
            string baseName = prefab.name;
            string newName = baseName;
            int counter = 1;
            while (GameObject.Find(newName) != null)
            {
                newName = $"{baseName} ({counter++})";
            }
            instance.name = newName;
            PrefabUtility.UnpackPrefabInstance(instance, PrefabUnpackMode.Completely, InteractionMode.AutomatedAction);
            Undo.RegisterCreatedObjectUndo(instance, "Spawn Prefab " + instance.name);
            Pretty.print($"Spawned and unpacked '{instance.name}' into the scene.", Pretty.LogKind.Info);
        }

        private List<GameObject> LoadPrefabsFromPath(string path)
        {
            string assetPath = Bratty.GetFullPathFromResource(path);
            List<GameObject> loadedPrefabs = new List<GameObject>();
            if (!Directory.Exists(assetPath))
            {
                // not necessarily an error, shader just doesn't use prefabs
                return loadedPrefabs;
            }
            string[] filePaths = Directory.GetFiles(assetPath, "*.prefab");
            foreach (string filePath in filePaths)
            {
                string relativePath = filePath;
                int assetsIndex = relativePath.IndexOf("Assets");
                if (assetsIndex != -1)
                {
                    relativePath = relativePath.Substring(assetsIndex);
                }
                relativePath = relativePath.Replace('\\', '/');
                GameObject prefab = AssetDatabase.LoadAssetAtPath<GameObject>(relativePath);
                if (prefab != null)
                {
                    loadedPrefabs.Add(prefab);
                }
            }
            return loadedPrefabs;
        }
    }

    // shader variants
    public class ShaderVariant
    {
        public string Name { get; private set; }
        public string Token { get; private set; }
        public Color Color { get; private set; }
        public string ShaderPath { get; set; } // optional, can kinda be autodetected

        public ShaderVariant(string name, string token, Color color, string shaderPath = null)
        {
            Name = name;
            Token = token;
            Color = color;
            ShaderPath = shaderPath;
        }

        public static List<ShaderVariant> DetectCapabilities(ref Material mat) 
        {
            var detectedCapabilities = new List<ShaderVariant>();
            if (mat == null || mat.shader == null)
            {
                return detectedCapabilities; // how?
            }
            string shaderName = mat.shader.name.ToLower();
            string[] nameParts = shaderName.Split('/');
            string lastPart = nameParts[nameParts.Length - 1];
            foreach (ShaderVariant variant in Project.shader_variants)
            {
                if (lastPart.Contains(variant.Token.ToLower()))
                {
                    detectedCapabilities.Add(new ShaderVariant(variant.Name, variant.Token, variant.Color));
                }
            }
            return detectedCapabilities;
        }

    }

    // shader capabilities
    public class ShaderCapability
    {

        public string Name { get; private set; }
        public string Definition { get; private set; } // should be a language file name, ex. "depth_popup_info"
        public Color Color { get; private set; }

        public ShaderCapability(string name, string definition, Color color)
        {
            Name = name;
            Definition = definition;
            Color = color;
        }

        public string GetDefinition(ref Languages language_manager)
        {
            if (language_manager != null && !string.IsNullOrEmpty(Definition))
            {
                return language_manager.speak(Definition);
            }
            return Definition;
        }

    }

    // fuzzy search helper for typo friendly matching ;) dw i gotcha
    public static class FuzzySearch
    {
        // computes the Levenshtein distance between two strings
        public static int LevenshteinDistance(string a, string b)
        {
            if (string.IsNullOrEmpty(a)) return b?.Length ?? 0;
            if (string.IsNullOrEmpty(b)) return a.Length;
            int[,] d = new int[a.Length + 1, b.Length + 1];
            for (int i = 0; i <= a.Length; i++) d[i, 0] = i;
            for (int j = 0; j <= b.Length; j++) d[0, j] = j;
            for (int i = 1; i <= a.Length; i++)
            {
                for (int j = 1; j <= b.Length; j++)
                {
                    int cost = (a[i - 1] == b[j - 1]) ? 0 : 1;
                    d[i, j] = Math.Min(Math.Min(
                        d[i - 1, j] + 1,
                        d[i, j - 1] + 1),
                        d[i - 1, j - 1] + cost);
                }
            }
            return d[a.Length, b.Length];
        }

        // performs a fuzzy match between text and query with an optional max distance
        public static bool FuzzyMatch(string text, string query, int maxDistance = -1)
        {
            if (string.IsNullOrEmpty(query)) return true;
            if (string.IsNullOrEmpty(text)) return false;
            text = text.ToLower();
            query = query.ToLower();
            if (text.Contains(query)) return true;
            if (maxDistance < 0) maxDistance = Math.Max(1, query.Length / 4);
            string[] words = text.Split(new[] { ' ', '_', '-' }, StringSplitOptions.RemoveEmptyEntries);
            foreach (string word in words)
            {
                if (word.Length >= query.Length - maxDistance && word.Length <= query.Length + maxDistance)
                {
                    if (LevenshteinDistance(word, query) <= maxDistance) return true;
                }
                if (word.Length > query.Length)
                {
                    for (int i = 0; i <= word.Length - query.Length; i++)
                    {
                        string sub = word.Substring(i, query.Length);
                        if (LevenshteinDistance(sub, query) <= maxDistance) return true;
                    }
                }
            }
            // check substrings of the entire text as a last resort
            if (text.Length >= query.Length)
            {
                for (int i = 0; i <= text.Length - query.Length; i++)
                {
                    string sub = text.Substring(i, query.Length);
                    if (LevenshteinDistance(sub, query) <= maxDistance) return true;
                }
            }
            return false;
        }

        // checks if any keyword in the collection matches the query
        public static bool MatchesAny(IEnumerable<string> keywords, string query)
        {
            foreach (string keyword in keywords)
            {
                if (FuzzyMatch(keyword, query)) return true;
            }
            return false;
        }
    }

    // a dependency that can be checked for installation
    public class Dependency
    {
        public string Name { get; private set; }
        public string FolderPath { get; private set; }
        public string PackageName { get; private set; }
        public DependencyType Type { get; private set; }
        public bool IsInstalled { get; private set; }
        public string InfoUrl { get; private set; }
        public bool FolderDetected { get; private set; }
        public bool PackageDetected { get; private set; }
        public string DetectedFolderPath { get; private set; }

        public Dependency(string name, DependencyType type, string folderPath = null, string packageName = null, string infoUrl = null)
        {
            Name = name;
            Type = type;
            FolderPath = folderPath;
            PackageName = packageName;
            InfoUrl = infoUrl;
            IsInstalled = false;
            FolderDetected = false;
            PackageDetected = false;
            DetectedFolderPath = null;
            Check();
        }

        public bool Check()
        {
            FolderDetected = CheckFolder();
            PackageDetected = CheckPackage();
            IsInstalled = Type switch
            {
                DependencyType.Folder => FolderDetected,
                DependencyType.Package => PackageDetected,
                DependencyType.Either => FolderDetected || PackageDetected,
                _ => false
            };
            return IsInstalled;
        }

        public string GetDetectionInfo()
        {
            if (!IsInstalled) return null;
            List<string> detectedVia = new List<string>();
            if (FolderDetected && !string.IsNullOrEmpty(DetectedFolderPath)) 
            {
                detectedVia.Add("[Folder] " + DetectedFolderPath);
            }
            if (PackageDetected)
            {
                detectedVia.Add("[Package] " + PackageName);
            }
            return string.Join("\n", detectedVia);
        }

        private bool CheckFolder()
        {
            if (string.IsNullOrEmpty(FolderPath)) return false;
            string fullPath = Bratty.GetFullPathFromResource(FolderPath);
            if (!string.IsNullOrEmpty(fullPath) && Directory.Exists(fullPath))
            {
                DetectedFolderPath = fullPath;
                return true;
            }
            string assetsPath = Path.Combine(Application.dataPath, FolderPath);
            if (Directory.Exists(assetsPath))
            {
                DetectedFolderPath = assetsPath;
                return true;
            }
            return false;
        }

        private bool CheckPackage()
        {
            if (string.IsNullOrEmpty(PackageName)) return false;
            var listRequest = UnityEditor.PackageManager.Client.List(true, true);
            while (!listRequest.IsCompleted) { }
            if (listRequest.Status == UnityEditor.PackageManager.StatusCode.Success)
            {
                foreach (var package in listRequest.Result)
                {
                    if (package.name == PackageName) return true;
                }
            }
            return false;
        }
    }

    // manage all dependencies for a project
    public class DependencyManager
    {
        public List<Dependency> Dependencies { get; private set; }

        public DependencyManager(List<Dependency> dependencies)
        {
            Dependencies = dependencies ?? new List<Dependency>();
        }

        public void CheckAll()
        {
            foreach (var dep in Dependencies) dep.Check();
        }

        public List<Dependency> GetMissing()
        {
            List<Dependency> missing = new List<Dependency>();
            foreach (var dep in Dependencies)
            {
                if (!dep.IsInstalled) missing.Add(dep);
            }
            return missing;
        }

        public List<Dependency> GetInstalled()
        {
            List<Dependency> installed = new List<Dependency>();
            foreach (var dep in Dependencies)
            {
                if (dep.IsInstalled) installed.Add(dep);
            }
            return installed;
        }

        public Dependency Get(string name)
        {
            foreach (var dep in Dependencies)
            {
                if (dep.Name == name) return dep;
            }
            return null;
        }

        public bool IsInstalled(string name)
        {
            var dep = Get(name);
            return dep != null && dep.IsInstalled;
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