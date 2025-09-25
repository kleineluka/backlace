#if UNITY_EDITOR
#pragma warning disable CS0414

using UnityEngine;
using UnityEditor;
using System;
using System.IO;
using System.Text;
using System.Collections.Generic;

// Structs.cs contains shared data structures for the pre-processor
namespace Luka.Backlace.Premonition
{

    // using premonition processor will return this object
    public class CompactResultData
    {
        public CompactResult Result { get; set; }
        public string ShaderName { get; set; }
        public string ShaderPath { get; set; }
    }

    // possible results of the compacting operation
    public enum CompactResult
    {
        Success,
        AlreadyLocked,
        ErrorInliningIncludes,
        ErrorSplittingShader,
        InvalidMaterial,
        InvalidShader,
        ShaderNotFound,
        MaterialNotFound
    }

    // different types of shader naming schemes
    public enum ShaderNameType
    {
        Timestamp = 0,
        Random = 1,
        Custom = 2
    }

    // settings to share between components of the pre-processor
    public class ProcessorSettings
    {
        public string VERSION = "1.0.0";
        public ShaderNameType shaderNameType = ShaderNameType.Timestamp;
        public bool addCompilerComments = true;
        public bool removeShaderComments = true;
        public bool optimizeWhitespace = true;
        public bool removeEmptyLines = true;
        public bool removePropertyAttributes = true;
        public bool randomiseGrabpass = true;
        public bool hideShaderName = true;
        public bool trackErrors = true;
        public bool addMarker = true;
        public bool addDebug = false;
        public bool skipMarked = true;
        public bool bakeDefines = true;
        public bool naiveGrabpassDetection = false;
        public string customShaderName = "_CompactCustomNameExample";
        public string compactShaderFolder = "CompactShaders";
        public int randomNameLength = 8;
        public List<string> ignoreIncludes = new List<string>();
        public List<string> ignoreKeywords = new List<string>();
        public ProcessorSettings() 
        { 
            // default ignored includes
            ignoreIncludes.Add("UnityCG.cginc");
            ignoreIncludes.Add("AutoLight.cginc");
            ignoreIncludes.Add("Lighting.cginc");
            ignoreIncludes.Add("HLSLSupport.cginc");
            ignoreIncludes.Add("UnityShaderVariables.cginc");
            ignoreIncludes.Add("TerrainEngine.cginc");
            // default ignored keywords
            //ignoreKeywords.Add("_"); // For shader_feature_local
            ignoreKeywords.Add("VERTEXLIGHT_ON");
            ignoreKeywords.Add("FOG_LINEAR");
            ignoreKeywords.Add("FOG_EXP");
            ignoreKeywords.Add("FOG_EXP2");
        }
    }

    // container for various parts of a shader
    public class ShaderParts
    {
        public string PrePassContent { get; set; }
        public List<string> Passes { get; set; }
        public string PostPassContent { get; set; }

        public ShaderParts()
        {
            PrePassContent = "";
            Passes = new List<string>();
            PostPassContent = "";
        }
    }

}
#endif // UNITY_EDITOR