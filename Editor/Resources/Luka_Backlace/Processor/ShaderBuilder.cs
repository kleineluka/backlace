#if UNITY_EDITOR
#pragma warning disable CS0414

using UnityEngine;
using UnityEditor;
using System;
using System.IO;
using System.Text;
using System.Collections.Generic;

// ShaderBuilder.cs takes a shader and adds all its includes inline
namespace Luka.Backlace.Premonition
{

    public static class ShaderBuilder 
    {

        // get the path of an include directive line, or null if not found
        private static string extract_include_path(string includeLine)
        {
            int firstQuote = includeLine.IndexOf('"') + 1;
            int lastQuote = includeLine.LastIndexOf('"');
            if (firstQuote == 0 || lastQuote == -1 || lastQuote <= firstQuote) {
                return null;
            }
            return includeLine.Substring(firstQuote, lastQuote - firstQuote);
        }

        // search for the include file in the project, return the path if found, otherwise null
        private static string find_include_file(string includeFileName, string searchDirectory)
        {
            // check relative to current file first
            string relativePath = Path.GetFullPath(Path.Combine(searchDirectory, includeFileName));
            if(File.Exists(relativePath))
            {
                if (relativePath.StartsWith(Application.dataPath))
                {
                    return "Assets" + relativePath.Substring(Application.dataPath.Length).Replace('\\', '/');
                }
                Uri projectUri = new Uri(Directory.GetCurrentDirectory() + Path.DirectorySeparatorChar);
                Uri fileUri = new Uri(relativePath);
                return projectUri.MakeRelativeUri(fileUri).ToString();
            }
            // then search the whole project
            string[] guids = AssetDatabase.FindAssets(Path.GetFileNameWithoutExtension(includeFileName));
            foreach (var guid in guids)
            {
                string path = AssetDatabase.GUIDToAssetPath(guid);
                if (Path.GetFileName(path).Equals(includeFileName, System.StringComparison.OrdinalIgnoreCase))
                {
                    return path;
                }
            }
            return null;
        }

        // recursively process includes, keeping track of already processed files to avoid circular includes
        private static string process_include_recursive(string filePath, HashSet<string> processedInThisChain, ProcessorSettings settings)
        {
            // first, check for circular includes
            string absolutePath = Path.GetFullPath(filePath);
            if (processedInThisChain.Contains(absolutePath))
            {
                if (settings.addCompilerComments) {
                    return $"// PREMONITIONS: Skipped circular include for {Path.GetFileName(filePath)}\n";
                } else {
                    return "";
                }
            }
            processedInThisChain.Add(absolutePath);
            var stringBuilder = new StringBuilder();
            string fileDirectory = Path.GetDirectoryName(filePath);
            string[] lines = File.ReadAllLines(filePath);
            // process each line
            foreach (var line in lines)
            {
                string trimmedLine = line.Trim();
                if (trimmedLine.StartsWith("#include"))
                {
                    string includePath = extract_include_path(trimmedLine);
                    if (string.IsNullOrEmpty(includePath))
                    {
                        stringBuilder.AppendLine(line);
                        continue;
                    }
                    // if it's a default include we want to ignore, just copy the line as is
                    if (settings.ignoreIncludes.Contains(includePath))
                    {
                        stringBuilder.AppendLine(line);
                        continue;
                    }
                    // find the include file
                    string includeAssetPath = find_include_file(includePath, fileDirectory);
                    // if found, process it recursively
                    if (!string.IsNullOrEmpty(includeAssetPath))
                    {
                        if(settings.addCompilerComments) stringBuilder.AppendLine($"// PREMONITIONS: Inlining content from {includePath}\n// ----------------------------------------");
                        stringBuilder.Append(process_include_recursive(includeAssetPath, processedInThisChain, settings));
                        if(settings.addCompilerComments) stringBuilder.AppendLine($"// ----------------------------------------\n// PREMONITIONS: End of inlined {includePath}");
                    }
                    else
                    {
                        // if not found, just copy the line as is and add a comment
                        stringBuilder.AppendLine(line);
                        if(settings.trackErrors) stringBuilder.AppendLine($"// PREMONITIONS ERROR: Could not find include file '{includePath}'");
                    }
                }
                else
                {
                    stringBuilder.AppendLine(line);
                }
            }
            return stringBuilder.ToString();
        }

        // wrapper to start the recursive processing of includes
        public static string build_single_shader(string sourceShaderPath, ProcessorSettings settings)
        {
            var finalShaderCode = new StringBuilder();
            if (settings.addCompilerComments) finalShaderCode.AppendLine($"// PREMONITIONS: Processing shader from {sourceShaderPath}");
            string sourceDirectory = Path.GetDirectoryName(sourceShaderPath);
            string[] lines = File.ReadAllLines(sourceShaderPath);
            // process each line
            foreach (var line in lines)
            {
                // optimising white space is optional, but might help a tiny bit with file size (?)
                string trimmedLine = (settings.optimizeWhitespace) ? line.Trim() : line;
                if (trimmedLine.StartsWith("#include"))
                {
                    string includePath = extract_include_path(trimmedLine);
                    // if no path found, just copy the line as is
                    if (string.IsNullOrEmpty(includePath))
                    {
                        finalShaderCode.AppendLine(line);
                        continue;
                    }
                    // if it's a default include we want to ignore, just copy the line as is
                    if (settings.ignoreIncludes.Contains(includePath))
                    {
                        finalShaderCode.AppendLine(line);
                        continue;
                    }
                    // find the include file
                    string includeAssetPath = find_include_file(includePath, sourceDirectory);
                    if (!string.IsNullOrEmpty(includeAssetPath))
                    {
                        // if found, process it recursively
                        if(settings.addCompilerComments) finalShaderCode.AppendLine($"// PREMONITIONS: Inlining content from {includePath}\n// ----------------------------------------");
                        string inlinedContent = process_include_recursive(includeAssetPath, new HashSet<string>(), settings);
                        finalShaderCode.Append(inlinedContent);
                        if(settings.addCompilerComments) finalShaderCode.AppendLine($"// ----------------------------------------\n// PREMONITIONS: End of inlined {includePath}");
                    }
                    else
                    {
                        // if not found, just copy the line as is and add a comment
                        finalShaderCode.AppendLine(line);
                        if(settings.trackErrors) finalShaderCode.AppendLine($"// PREMONITIONS ERROR: Could not find include file '{includePath}'");
                    }
                }
                else
                {
                    finalShaderCode.AppendLine(line);
                }
            }
            return finalShaderCode.ToString();
        }
    }

}
#endif // UNITY_EDITOR