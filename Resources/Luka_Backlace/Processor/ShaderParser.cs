#if UNITY_EDITOR
#pragma warning disable CS0414

using UnityEngine;
using UnityEditor;
using System;
using System.IO;
using System.Text;
using System.Collections.Generic;
using System.Text.RegularExpressions;

// ShaderParser.cs contains functions to parse shader code into parts (pre-pass, pass, post-pass)
namespace Luka.Backlace.Premonition
{

    public static class ShaderParser
    {

        // find the matching closing brace for a given opening brace index
        public static int find_matching_brace(string code, int startIndex)
        {
            if (startIndex < 0 || code[startIndex] != '{') return -1;

            int braceCount = 1;
            for (int i = startIndex + 1; i < code.Length; i++)
            {
                if (code[i] == '{')
                {
                    braceCount++;
                }
                else if (code[i] == '}')
                {
                    braceCount--;
                }

                if (braceCount == 0)
                {
                    return i;
                }
            }
            return -1; // not found :(
        }

        // split shader code into pre-pass, passes, and post-pass sections
        public static ShaderParts split_shader_parts(string shaderCode)
        {
            var parts = new ShaderParts();
            // find the SubShader block first
            var subShaderMatch = Regex.Match(shaderCode, @"\bSubShader\b");
            if (!subShaderMatch.Success)
            {
                parts.PrePassContent = shaderCode;
                return parts;
            }
            // find the braces for the SubShader block
            int subShaderBraceOpen = shaderCode.IndexOf('{', subShaderMatch.Index);
            if (subShaderBraceOpen == -1)
            {
                parts.PrePassContent = shaderCode;
                return parts;
            }
            // find the matching closing brace for the SubShader block
            int subShaderBraceClose = find_matching_brace(shaderCode, subShaderBraceOpen);
            if (subShaderBraceClose == -1)
            {
                parts.PrePassContent = shaderCode;
                return parts;
            }
            // now we have the full SubShader block, we can search for Pass blocks within it
            string subShaderContent = shaderCode.Substring(subShaderBraceOpen + 1, subShaderBraceClose - subShaderBraceOpen - 1);
            int searchIndex = 0;
            int lastPassEnd = 0;
            // look for "Pass" keywords
            while (searchIndex < subShaderContent.Length)
            {
                var passMatch = Regex.Match(subShaderContent.Substring(searchIndex), @"\bPass\b");
                if (!passMatch.Success) break;
                int passStartIndexInSubstring = searchIndex + passMatch.Index;
                // Check if the "Pass" keyword is actually followed by an opening brace
                int checkIndex = passStartIndexInSubstring + passMatch.Length;
                while (checkIndex < subShaderContent.Length && char.IsWhiteSpace(subShaderContent[checkIndex]))
                {
                    checkIndex++;
                }
                // If we reach the end of the substring or the next character isn't an opening brace, it's not a real pass
                if (checkIndex >= subShaderContent.Length || subShaderContent[checkIndex] != '{')
                {
                    searchIndex = passStartIndexInSubstring + passMatch.Length;
                    continue;
                }
                // found a valid Pass block, now find its matching closing brace
                int passBraceOpen = checkIndex;
                int passBraceClose = find_matching_brace(subShaderContent, passBraceOpen);
                if (passBraceClose != -1)
                {
                    if (parts.Passes.Count == 0)
                    {
                        string subShaderHeader = subShaderContent.Substring(0, passStartIndexInSubstring);
                        parts.PrePassContent = shaderCode.Substring(0, subShaderBraceOpen + 1) + subShaderHeader;
                    }
                    // extract the full Pass block
                    string passBlock = subShaderContent.Substring(passStartIndexInSubstring, passBraceClose - passStartIndexInSubstring + 1);
                    parts.Passes.Add(passBlock);
                    // update indices for next search
                    lastPassEnd = passBraceClose + 1;
                    searchIndex = lastPassEnd;
                }
                else
                {
                    searchIndex = passStartIndexInSubstring + passMatch.Length;
                }
            }
            // everything after the last pass is post-pass content
            if (parts.Passes.Count == 0)
            {
                parts.PrePassContent = shaderCode;
            }
            else
            {
                string subShaderFooter = subShaderContent.Substring(lastPassEnd);
                parts.PostPassContent = subShaderFooter + shaderCode.Substring(subShaderBraceClose);
            }
            return parts;
        }
    }

}
#endif // UNITY_EDITOR