#if UNITY_EDITOR
#pragma warning disable CS0414

using UnityEngine;
using UnityEditor;
using System;
using System.IO;
using System.Text;
using System.Collections.Generic;
using System.Text.RegularExpressions;

// Helpers.cs contains utility functions for the pre-processor
namespace Luka.Backlace.Premonition
{

    // functions for generating shader names based on different naming schemes
    public static class Naming
    {
        private static readonly System.Random random = new System.Random();

        // generate a random string of given length, using upper and lowercase letters
        public static string get_random_name(int length)
        {
            const string chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz";
            var stringBuilder = new StringBuilder(length);
            for (int i = 0; i < length; i++)
            {
                stringBuilder.Append(chars[random.Next(chars.Length)]);
            }
            return "_Locked_" + stringBuilder.ToString();
        }

        // generate a simple name based on the current unix timestamp
        public static string get_timestamp_name()
        {
            long timestamp = DateTimeOffset.UtcNow.ToUnixTimeSeconds();
            return "_Locked_" + timestamp.ToString();
        }

        // get the locked shader name based on the selected naming scheme
        public static string get_compact_name(ShaderNameType shaderNameType, string customShaderName, int randomNameLength)
        {
            string lockedShaderName;
            switch (shaderNameType)
            {
                case ShaderNameType.Custom:
                    lockedShaderName = customShaderName;
                    break;
                case ShaderNameType.Random:
                    lockedShaderName = get_random_name(randomNameLength);
                    break;
                case ShaderNameType.Timestamp:
                default:
                    lockedShaderName = get_timestamp_name();
                    break;
            }
            return lockedShaderName;
        }
    }

    // for leaving debug output and comments in the generated shader
    public class Markers
    {
        // add a comment block to the start of the shader with pre-processor info
        public static ShaderParts add_processor_info(ProcessorSettings settings, Material sourceMaterial, string[] activeKeywords, ShaderParts shaderParts)
        {
            if (!settings.addMarker || shaderParts == null) return shaderParts;
            var commentBlockBuilder = new StringBuilder();
            commentBlockBuilder.AppendLine("// ------------- PREMONITIONS -------------");
            commentBlockBuilder.AppendLine($"// Source Material: {(sourceMaterial != null ? sourceMaterial.name : "Unknown")}");
            commentBlockBuilder.AppendLine($"// Source Shader: {(sourceMaterial != null && sourceMaterial.shader != null ? sourceMaterial.shader.name : "Unknown")}");
            commentBlockBuilder.AppendLine($"// Generated On: {DateTime.Now.ToString("yyyy-MM-dd HH:mm:ss")}");
            commentBlockBuilder.AppendLine($"// Premonition Version: {settings.VERSION}");
            if (settings.addDebug) {
                commentBlockBuilder.AppendLine("// Debugging On, Premonitions Settings:");
                commentBlockBuilder.AppendLine($"// - addCompilerComments: {settings.addCompilerComments}");
                commentBlockBuilder.AppendLine($"// - removeShaderComments: {settings.removeShaderComments}");
                commentBlockBuilder.AppendLine($"// - optimizeWhitespace: {settings.optimizeWhitespace}");
                commentBlockBuilder.AppendLine($"// - removeEmptyLines: {settings.removeEmptyLines}");
                commentBlockBuilder.AppendLine($"// - removePropertyAttributes: {settings.removePropertyAttributes}");
                commentBlockBuilder.AppendLine($"// - randomiseGrabpass: {settings.randomiseGrabpass}");
                commentBlockBuilder.AppendLine($"// - hideShaderName: {settings.hideShaderName}");
                commentBlockBuilder.AppendLine($"// - trackErrors: {settings.trackErrors}");
                commentBlockBuilder.AppendLine($"// - addMarker: {settings.addMarker}");
                commentBlockBuilder.AppendLine($"// - skipMarked: {settings.skipMarked}");
                commentBlockBuilder.AppendLine($"// - naiveGrabpassDetection: {settings.naiveGrabpassDetection}");
                commentBlockBuilder.AppendLine($"// - customShaderName: '{settings.customShaderName}'");
                commentBlockBuilder.AppendLine($"// - compactShaderFolder: '{settings.compactShaderFolder}'");
                commentBlockBuilder.AppendLine($"// - randomNameLength: {settings.randomNameLength}");
                commentBlockBuilder.AppendLine($"// - ignoreIncludes: {(settings.ignoreIncludes.Count > 0 ? string.Join(", ", settings.ignoreIncludes) : "None")}");
                commentBlockBuilder.AppendLine($"// - ignoreKeywords: {(settings.ignoreKeywords.Count > 0 ? string.Join(", ", settings.ignoreKeywords) : "None")}");
            }
            commentBlockBuilder.AppendLine("// Baked-In Keywords:");
            if (activeKeywords != null && activeKeywords.Length > 0)
            {
                foreach (string keyword in activeKeywords)
                {
                    commentBlockBuilder.AppendLine($"// - {keyword}");
                }
            }
            else
            {
                commentBlockBuilder.AppendLine("//  - None");
            }
            commentBlockBuilder.AppendLine("// -----------------------------------------");
            shaderParts.PrePassContent = commentBlockBuilder.ToString() + shaderParts.PrePassContent;
            return shaderParts;
        }

        // check if the shader code has the premonitions marker
        public static bool is_marked(string shaderCode)
        {
            return shaderCode.Contains("// ------------- PREMONITIONS -------------");
        }
    }

    // WARNING: regex heavy..........
    public static class Cleaner
    {
        // remove all comments from shader code
        public static string remove_comments(string code)
        {
            var re = @"(@(?:""[^""]*"")+|""(?:[^""\\]|\\.)*""|'(?:[^'\\]|\\.)*')|//.*|/\*(?s:.*?)\*/";
            return Regex.Replace(code, re, "$1");
        }

        // trim excess whitespace from shader code
        public static string optimise_whitespace(string code)
        {
            // replace multiple spaces with a single space
            code = Regex.Replace(code, @"[ \t]+", " ");
            // replace multiple newlines with a single newline
            code = Regex.Replace(code, @"(\r\n|\r|\n)+", "\n");
            // trim leading and trailing whitespace from each line
            var lines = code.Split(new[] { "\r\n", "\r", "\n" }, StringSplitOptions.None);
            for (int i = 0; i < lines.Length; i++)
            {
                lines[i] = lines[i].Trim();
            }
            // rejoin lines
            code = string.Join("\n", lines);
            // trim leading and trailing whitespace from the entire code
            code = code.Trim();
            return code;
        }

        // remove all empty/whitespace-only lines from shader code
        public static string remove_empty_lines(string code)
        {
            return System.Text.RegularExpressions.Regex.Replace(code, @"^\s*$\r?\n", string.Empty, System.Text.RegularExpressions.RegexOptions.Multiline);
        }

        // function to remove all the [Header(whatever goes here)] attributes from the shader code in properties block
        public static string remove_header_attributes(string code)
        {
            return Regex.Replace(code, @"\[Header\((.*?)\)\]", string.Empty);
        }

        // function to remove all the [Space(whatever goes here)] attributes from the shader code in properties block
        public static string remove_space_attributes(string code)
        {
            return Regex.Replace(code, @"\[Space\((.*?)\)\]", string.Empty);
        }

        // generate a random name for each GrabPass block in the shader code
        public static string randomise_grabpass_names(string shaderCode, ProcessorSettings settings)
        {
            var nameMap = new Dictionary<string, string>();
            int currentIndex = 0;
            // first pass: find all GrabPass names and create a map of old->new names.
            while (currentIndex < shaderCode.Length)
            {
                int grabPassIndex = shaderCode.IndexOf("GrabPass", currentIndex);
                if (grabPassIndex == -1) break;
                int openBraceIndex = shaderCode.IndexOf('{', grabPassIndex);
                if (openBraceIndex == -1)
                {
                    currentIndex = grabPassIndex + "GrabPass".Length;
                    continue;
                }
                int closeBraceIndex = ShaderParser.find_matching_brace(shaderCode, openBraceIndex);
                if (closeBraceIndex == -1)
                {
                    currentIndex = openBraceIndex + 1;
                    continue;
                }
                string grabPassBlock = shaderCode.Substring(grabPassIndex, closeBraceIndex - grabPassIndex + 1);
                string blockContent = grabPassBlock.Substring(grabPassBlock.IndexOf('{') + 1, grabPassBlock.LastIndexOf('}') - grabPassBlock.IndexOf('{') - 1);
                string contentWithoutTags = blockContent;
                int tagsIndex = contentWithoutTags.IndexOf("Tags");
                if (tagsIndex != -1)
                {
                    int tagsOpenBrace = contentWithoutTags.IndexOf('{', tagsIndex);
                    if (tagsOpenBrace != -1)
                    {
                        int tagsCloseBrace = ShaderParser.find_matching_brace(contentWithoutTags, tagsOpenBrace);
                        if (tagsCloseBrace != -1)
                        {
                            contentWithoutTags = contentWithoutTags.Remove(tagsIndex, tagsCloseBrace - tagsIndex + 1);
                        }
                    }
                }
                var nameMatch = System.Text.RegularExpressions.Regex.Match(contentWithoutTags, @"""([^""]+)""");
                if (nameMatch.Success)
                {
                    string oldName = nameMatch.Groups[1].Value;
                    if (!nameMap.ContainsKey(oldName))
                    {
                        string newName = Naming.get_random_name(settings.randomNameLength).Replace("_Locked_", "GP_");
                        nameMap[oldName] = newName;
                    }
                }
                currentIndex = closeBraceIndex + 1;
            }
            // second pass: apply the name changes throughout the entire shader code.
            string result = shaderCode;
            foreach (var pair in nameMap)
            {
                string oldName = pair.Key;
                string newName = pair.Value;
                if (settings.naiveGrabpassDetection) {
                    result = result.Replace(oldName, newName);
                } else {
                    result = Regex.Replace(result, $@"\b{Regex.Escape(oldName)}\b", newName);
                    result = Regex.Replace(result, $@"\b{Regex.Escape(oldName)}_ST\b", newName + "_ST");
                    result = Regex.Replace(result, $@"\b{Regex.Escape(oldName)}_TexelSize\b", newName + "_TexelSize");
                }
            }
            return result;
        }

        // find the shader name and update it based on settings
        public static string rename_shader(string shaderCode, string nameToAppend, bool hide)
        {
            return Regex.Replace(shaderCode, @"(Shader\s+"")([^""]+)""", (match) => {
                string originalName = match.Groups[2].Value;
                string newName = (hide ? "Hidden/" : "") + originalName + nameToAppend;
                return $"{match.Groups[1].Value}{newName}\"";
            });
        }
        
    }

}
#endif // UNITY_EDITOR