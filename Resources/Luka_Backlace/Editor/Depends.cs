#if UNITY_EDITOR
#define LUKA_DEVELOPER_MODE

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
            if (localised != null && localised.TryGetValue(key, out string value))
            {
                return string.Format(value, args);
            }
            else if (localised_fallback != null && localised_fallback.TryGetValue(key, out string fallback_value))
            {
                return string.Format(fallback_value, args);
            }
            return key;
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
            #if LUKA_DEVELOPER_MODE
                Pretty.print("Developer mode is active, skipping metadata fetch...", Pretty.LogKind.Info);
                full_metadata = null;
                metadata_loaded = false;
                return;
            #endif
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
                new VersionEntry { Name = Project.project_name, Version = Project.version.print() }
            };
            metadata_loaded = true;
        }

    }

    // unity can be a brat, but i can be brattier
    public class Bratty
    {

        public static string GetFullPathFromResource(string resourcePath) 
        {
            UnityEngine.Object asset = Resources.Load(resourcePath);
            if (asset == null)
            {
                Pretty.print($"Resource at path '{resourcePath}' not found.", Pretty.LogKind.Error);
                return null;
            }
            // get the full asset path from that
            string assetPath = AssetDatabase.GetAssetPath(asset);
            if (string.IsNullOrEmpty(assetPath))
            {
                Pretty.print($"Could not determine asset path for resource '{resourcePath}'.", Pretty.LogKind.Error);
                return null;
            }
            string fullPath = Path.GetFullPath(assetPath);
            return fullPath;
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

        public BeautyBlender(Material mat)
        {
            if (!mat.HasProperty("_BlendMode")) return;
            _currentBlendMode = mat.GetInt("_BlendMode");
            Apply(mat);
        }

        public void Update(Material mat)
        {
            if (!mat.HasProperty("_BlendMode")) return;
            int newBlendMode = mat.GetInt("_BlendMode");
            if (newBlendMode != _currentBlendMode)
            {
                _currentBlendMode = newBlendMode;
                Apply(mat);
            }
        }

        private void Apply(Material mat)
        {
            // Expected blend enum: 0=Opaque, 1=Cutout, 2=Fade, 3=Transparent, 4=Premultiply
            switch (_currentBlendMode)
            {
                case 0: // opaque
                    mat.SetOverrideTag("RenderType", "Opaque");
                    mat.SetInt("_SrcBlend", (int)UnityEngine.Rendering.BlendMode.One);
                    mat.SetInt("_DstBlend", (int)UnityEngine.Rendering.BlendMode.Zero);
                    mat.SetInt("_ZWrite", 1);
                    mat.renderQueue = (int)UnityEngine.Rendering.RenderQueue.Geometry;
                    break;
                case 1: // cutout
                    mat.SetOverrideTag("RenderType", "TransparentCutout");
                    mat.SetInt("_SrcBlend", (int)UnityEngine.Rendering.BlendMode.One);
                    mat.SetInt("_DstBlend", (int)UnityEngine.Rendering.BlendMode.Zero);
                    mat.SetInt("_ZWrite", 1);
                    mat.renderQueue = (int)UnityEngine.Rendering.RenderQueue.AlphaTest;
                    break;
                case 2: // fade (standard alpha blending)
                    mat.SetOverrideTag("RenderType", "Transparent");
                    mat.SetInt("_SrcBlend", (int)UnityEngine.Rendering.BlendMode.SrcAlpha);
                    mat.SetInt("_DstBlend", (int)UnityEngine.Rendering.BlendMode.OneMinusSrcAlpha);
                    mat.SetInt("_ZWrite", 0);
                    mat.renderQueue = (int)UnityEngine.Rendering.RenderQueue.Transparent;
                    break;
                case 3: // transparent (additive transparency)
                    mat.SetOverrideTag("RenderType", "Transparent");
                    mat.SetInt("_SrcBlend", (int)UnityEngine.Rendering.BlendMode.SrcAlpha);
                    mat.SetInt("_DstBlend", (int)UnityEngine.Rendering.BlendMode.One);
                    mat.SetInt("_ZWrite", 0);
                    mat.renderQueue = (int)UnityEngine.Rendering.RenderQueue.Transparent;
                    break;
                case 4: // premultiply (premultiplied alpha)
                    mat.SetOverrideTag("RenderType", "Transparent");
                    mat.SetInt("_SrcBlend", (int)UnityEngine.Rendering.BlendMode.One);
                    mat.SetInt("_DstBlend", (int)UnityEngine.Rendering.BlendMode.OneMinusSrcAlpha);
                    mat.SetInt("_ZWrite", 0);
                    mat.renderQueue = (int)UnityEngine.Rendering.RenderQueue.Transparent;
                    break;
            }
        }
    }

    // personal preset manager
    public class Bags
    {   
        private static readonly string preset_extension = ".dazzlepreset";
        private static readonly string project_preset_path = Project.project_path + "/Presets";
        private static readonly string user_preset_path = project_preset_path + "/User";
        public Languages language_manager = null;
        public List<Material> projectPresets;
        public List<Material> userPresets;

        public Bags(ref Languages language)
        {
            language_manager = language;
            LoadPresets();
        }

        public void LoadPresets()
        {
            projectPresets = LoadMaterialsFromPath(project_preset_path);
            userPresets = LoadMaterialsFromPath(user_preset_path);
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
            if (!Directory.Exists(user_preset_path))
            {
                Directory.CreateDirectory(user_preset_path);
                AssetDatabase.Refresh();
            }
            string path = Path.Combine(user_preset_path, presetName + preset_extension);
            if (File.Exists(path))
            {
                if (!EditorUtility.DisplayDialog(language_manager.speak("preset_overwrite_prompt_title"),
                    language_manager.speak("preset_overwrite_prompt", presetName),
                    language_manager.speak("preset_overwrite_prompt_yes"), language_manager.speak("preset_overwrite_prompt_no")))
                {
                    return false;
                }
            }
            Material newPreset = new Material(sourceMaterial);
            try
            {
                AssetDatabase.CreateAsset(newPreset, path);
                AssetDatabase.SaveAssets();
                AssetDatabase.Refresh();
                Pretty.print($"Saved preset '{presetName}' successfully.", Pretty.LogKind.Info);
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
            string path = Path.Combine(user_preset_path, presetName + preset_extension);
            if (!File.Exists(path))
            {
                Pretty.print($"Preset '{presetName}' not found at path: {path}", Pretty.LogKind.Warning);
                return false;
            }
            if (AssetDatabase.DeleteAsset(path))
            {
                Pretty.print($"Deleted preset '{presetName}' successfully.", Pretty.LogKind.Info);
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
            Shader shader = source.shader;
            for (int i = 0; i < ShaderUtil.GetPropertyCount(shader); i++)
            {
                string propertyName = ShaderUtil.GetPropertyName(shader, i);
                ShaderUtil.ShaderPropertyType type = ShaderUtil.GetPropertyType(shader, i);
                switch (type)
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
                        dest.SetTexture(propertyName, source.GetTexture(propertyName));
                        dest.SetTextureOffset(propertyName, source.GetTextureOffset(propertyName));
                        dest.SetTextureScale(propertyName, source.GetTextureScale(propertyName));
                        break;
                }
            }
        }

        private List<Material> LoadMaterialsFromPath(string path)
        {
            string assetPath = Bratty.GetFullPathFromResource(path);
            List<Material> materials = new List<Material>();
            if (!Directory.Exists(assetPath))
            {
                if (assetPath != Bratty.GetFullPathFromResource(user_preset_path))
                {
                    Pretty.print($"Preset directory not found: {assetPath}", Pretty.LogKind.Warning);
                }
                return materials;
            }
            string[] filePaths = Directory.GetFiles(assetPath);
            foreach (string filePath in filePaths)
            {
                if (filePath.EndsWith(preset_extension))
                {
                    string relativePath = filePath;
                    int assetsIndex = relativePath.IndexOf("Assets");
                    if (assetsIndex != -1)
                    {
                        relativePath = relativePath.Substring(assetsIndex);
                    }
                    relativePath = relativePath.Replace('\\', '/');
                    Material mat = AssetDatabase.LoadAssetAtPath<Material>(relativePath);
                    if (mat != null)
                    {
                        materials.Add(mat);
                    }
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

}

# endif // UNITY_EDITOR