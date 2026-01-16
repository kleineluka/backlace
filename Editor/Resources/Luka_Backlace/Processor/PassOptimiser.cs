#if UNITY_EDITOR
#pragma warning disable CS0414

using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Text.RegularExpressions;

// PassOptimiser.cs contains functions to optimise individual shader passes (ex. removing unused keywords)
namespace Luka.Backlace.Premonition
{
    public static class PassOptimiser
    {
        
        // bake the active shader keywords into #define directives, removing all other shader_feature/multi_compile pragmas
        public static string bake_defines(string passCode, string[] activeKeywords, ProcessorSettings settings)
        {
            // avoid duplicates + quick lookups thru hashsets
            var processedLines = new List<string>();
            var definesToAdd = new HashSet<string>();
            var activeKeywordsSet = new HashSet<string>(activeKeywords);
            var blacklistSet = new HashSet<string>(settings.ignoreKeywords);
            // go through each line
            string[] lines = passCode.Split(new[] { "\r\n", "\r", "\n" }, System.StringSplitOptions.None);
            foreach (var line in lines)
            {
                // we only want shader_feature and multi_compile pragmas (WITH a space after multi_compile)
                string trimmedLine = line.Trim();
                if (trimmedLine.StartsWith("#pragma shader_feature") || trimmedLine.StartsWith("#pragma multi_compile "))
                {
                    // grab all keywords from this line
                    var keywordsOnLine = Regex.Matches(trimmedLine, @"\b[A-Z0-9_]+\b")
                                              .Cast<Match>()
                                              .Select(m => m.Value)
                                              .ToList();
                    // ignore the "pragma" and "shader_feature"/"multi_compile" parts of the line
                    keywordsOnLine.Remove("pragma");
                    keywordsOnLine.Remove("shader_feature");
                    keywordsOnLine.Remove("multi_compile");
                    // skip if blacklisted keywords were found
                    bool isBlacklisted = keywordsOnLine.Any(k => blacklistSet.Contains(k));
                    if (isBlacklisted)
                    {
                        processedLines.Add(line);
                    }
                    else
                    {
                        // find the active keyword on this line...
                        foreach (var keyword in keywordsOnLine)
                        {
                            if (activeKeywordsSet.Contains(keyword))
                            {
                                // ...and we turn them into #define directives.
                                definesToAdd.Add($"#define {keyword}");
                            }
                        }
                    }
                }
                else
                {
                    // keep all other lines as they are
                    processedLines.Add(line);
                }
            }
            var finalPassBuilder = new StringBuilder();
            bool definesInjected = false; // only do this once per pass
            foreach (var processedLine in processedLines)
            {
                finalPassBuilder.AppendLine(processedLine);
                // inject them into the first CGPROGRAM/HLSLPROGRAM block we find
                if (!definesInjected && (processedLine.Trim().ToUpper() == "CGPROGRAM" || processedLine.Trim().ToUpper() == "HLSLPROGRAM"))
                {
                    definesInjected = true;
                    if (definesToAdd.Any())
                    {
                        if(settings.addCompilerComments) finalPassBuilder.AppendLine("// --- Premonitions: Baked Keywords ---");
                        foreach (var def in definesToAdd.OrderBy(d => d))
                        {
                            finalPassBuilder.AppendLine($"{def}");
                        }
                        if(settings.addCompilerComments) finalPassBuilder.AppendLine("// ------------------------------------");
                    }
                }
            }
            return finalPassBuilder.ToString();
        }
    }

}
#endif // UNITY_EDITOR