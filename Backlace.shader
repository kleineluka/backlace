Shader "luka/indev/backlace"
{

    Properties
    {
        // RENDERING SETTINGS
        [Space(35)]
        [Header(Rendering Settings)]
        [Space(10)]
        _SrcBlend ("Src Blend", Float) = 1.0
        _DstBlend ("Dst Blend", Float) = 0.0
        _ZWrite ("ZWrite", Float) = 1.0
        [Enum(UnityEngine.Rendering.CullMode)] _Cull ("Cull Mode", Int) = 2
        _Mode ("Blend mode", Int) = 0
        [IntRange] _StencilID ("Stencil ID (0-255)", Range(0, 255)) = 0
        [Enum(UnityEngine.Rendering.CompareFunction)] _StencilComp ("Stencil Comparison", Int) = 0
        [Enum(UnityEngine.Rendering.StencilOp)] _StencilOp ("Stencil Operation", Int) = 0

        // MAIN MAPS AND ALPHA
        [Space(35)]
        [Header(Main Maps and Alpha)]
        [Space(10)]
        _MainTex ("Main texture", 2D) = "white" { }
        _Color ("Albedo color", Color) = (1, 1, 1, 1)
        _Cutoff ("Alpha Cutoff", Range(0, 1)) = 0.5
        _BumpMap ("Normal map", 2D) = "bump" { }
        _BumpScale ("Normal map scale", Float) = 1

        // EMISSION
        [Space(35)]
        [Header(Emission)]
        [Space(10)]
        [Toggle(_BACKLACE_EMISSION)] _ToggleEmission ("Enable Emission", Float) = 0.0
        [HDR] _EmissionColor ("Emission Color", Color) = (0, 0, 0, 1)
        _EmissionMap ("Emission Map (Mask)", 2D) = "black" { }
        [IntRange] _UseAlbedoAsEmission ("Use Albedo for Emission", Range(0, 1)) = 0.0
        _EmissionStrength ("Emission Strength", Float) = 1.0

        // LIGHT LIMITING
        [Space(35)]
        [Header(Light Limiting)]
        [Space(10)]
        [IntRange] _EnableBaseLightLimit ("Enable Base Pass Limit", Range(0, 1)) = 0.0
        _BaseLightMin ("Base Light Min", Float) = 0.0
        _BaseLightMax ("Base Light Max", Float) = 2.0
        [IntRange] _EnableAddLightLimit ("Enable Add Pass Limit", Range(0, 1)) = 0.0
        _AddLightMin ("Add Light Min", Float) = 0.0
        _AddLightMax ("Add Light Max", Float) = 2.0
        _GreyscaleLighting ("Greyscale Lighting", Range(0, 1)) = 0.0
        _ForceLightColor ("Force Light Color", Range(0, 1)) = 0.0
        _ForcedLightColor ("Forced Light Color", Color) = (1, 1, 1, 1)

        // LIGHTING MODELS
        [Space(35)]
        [Header(Lighting Model)]
        [Space(10)]
        [Enum(Backlace, 0, Poiyomi Custom, 1, OpenLit, 2, Standard, 3, Mochie, 4)] _LightingColorMode ("Light Color Mode", Int) = 0
        [Enum(Backlace, 0, Forced World Direction, 1, View Direction, 2)] _LightingDirectionMode ("Light Direction Mode", Int) = 0
        _ForcedLightDirection ("Forced Light Direction", Vector) = (0.0, 1.0, 0.0, 0.0)
        _ViewDirectionOffsetX ("View Direction Offset X", Float) = 0.0
        _ViewDirectionOffsetY ("View Direction Offset Y", Float) = 0.0

        // TOON LIGHTING
        [Space(35)]
        [Header(Toon Lighting)]
        [Space(10)]
        _DirectLightMode ("Direct Light Mode", Float) = 0.0
        _Ramp ("Toon Ramp", 2D) = "white" { }
        _RampColor ("Ramp Color", Color) = (1, 1, 1, 1)
        _RampOffset ("Ramp Offset", Range(-1, 1)) = 0
        _ShadowIntensity ("Shadow intensity", Range(0, 1)) = 0.6
        _OcclusionOffsetIntensity ("Occlusion Offset Intensity", Range(0, 1)) = 0
        _RampMin ("Ramp Min", Color) = (0.003921569, 0.003921569, 0.003921569, 0.003921569)
        [Enum(Disabled, 0, Raw Light, 1, Tuned Light, 2, Ramp Based, 3)] _TintMaskSource ("Tint Mask Source", Int) = 0
        [HDR] _LitTint ("Lit Area Tint", Color) = (1, 1, 1, 0.75)
        _LitThreshold ("Lit Coverage", Range(0, 1)) = 0.6
        [HDR] _ShadowTint ("Shadow Area Tint", Color) = (1, 1, 1, 0.75)
        _ShadowThreshold ("Shadow Coverage", Range(0, 1)) = 0.4

        // SPECULAR
        [Space(35)]
        [Header(Specular)]
        [Space(10)]
        [Toggle(_BACKLACE_SPECULAR)] _ToggleSpecular ("Enable Specular", Float) = 0.0
        [Toggle(_BACKLACE_VERTEX_SPECULAR)] _ToggleVertexSpecular ("Enable Vertex Specular", Float) = 0.0
        _MSSO ("MSSO", 2D) = "white" { }
        _Metallic ("Metallic", Range(0, 1)) = 0
        _Glossiness ("Glossiness", Range(0, 1)) = 0
        _Occlusion ("Occlusion", Range(0, 1)) = 1
        _Specular ("Specular", Range(0, 1)) = 0.5
        _SpecularTintTexture ("Specular Tint Texture", 2D) = "white" { }
        _SpecularTint ("Specular Tint", Color) = (1, 1, 1, 1)
        _SpecularMode ("Specular Mode", Float) = -1
        _TangentMap ("Tangent Map", 2D) = "white" { }
        _Anisotropy ("Ansotropy", Range(-1, 1)) = 0
        _ReplaceSpecular ("Replace Specular", Float) = 0
        _HighlightRamp ("Highlight Ramp", 2D) = "white" { }
        _HighlightRampColor ("Highlight Color", Color) = (1, 1, 1, 1)
        _HighlightIntensity ("Highlight Intensity", Float) = 1.0
        _HighlightRampOffset ("Highlight Ramp Offset", Range(-1, 1)) = 0.0

        // RIM LIGHTING
        [Space(35)]
        [Header(Rim Lighting)]
        [Space(10)]
        [Toggle(_BACKLACE_RIMLIGHT)] _ToggleRimlight ("Enable Rim Lighting", Float) = 0.0
        [HDR] _RimColor ("Rim Color", Color) = (1, 1, 1, 1)
        _RimWidth ("Rim Width", Range(20, 0.1)) = 2.5
        _RimIntensity ("Rim Intensity", Float) = 1.0
        [IntRange] _RimLightBased ("Light-Based Rim", Range(0, 1)) = 0.0

        // CLEARCOAT
        [Space(35)]
        [Header(Clear Coat)]
        [Space(10)]
        [Toggle(_BACKLACE_CLEARCOAT)] _ToggleClearcoat ("Enable Clear Coat", Float) = 0.0
        _ClearcoatStrength ("Strength", Range(0, 1)) = 1.0
        [NoScaleOffset] _ClearcoatMap ("Strength Map (R)", 2D) = "white" { }
        _ClearcoatRoughness ("Roughness", Range(0, 1)) = 0.1

        // INDIRECT LIGHTING
        [Space(35)]
        [Header(Indirect Lighting)]
        [Space(10)]
        _IndirectFallbackMode ("Indirect Fallback Mode", Float) = 0.0
        _IndirectOverride ("Indirect Override", Float) = 0.0
        _FallbackCubemap ("Fallback Cubemap", Cube) = "" { }

        // UV SETTINGS
        [Space(35)]
        [Header(UV Settings)]
        [Space(10)]
        _UVCount ("UV Count", Float) = 0.0
        _UV1Index ("UV1 Index", Float) = 0.0
        _MainTex_UV ("Main texture UV set", Float) = 0
        _BumpMap_UV ("Bump map UV set", Float) = 0
        _MSSO_UV ("MSSO UV set", Float) = 0
        _SpecularTintTexture_UV ("Specular Tint UV Set", Float) = 0
        _TangentMap_UV ("Tangent Map UV", Float) = 0
        _EmissionMap_UV ("Emission Map UV Set", Float) = 0
        _ClearcoatMap_UV ("Clear Coat Map UV Set", Float) = 0

        // DO NOT CHANGE
        [Space(35)]
        [Header(Do Not Change)]
        [Space(10)]
        [NonModifiableTextureData][NoScaleOffset] _DFG ("DFG Lut", 2D) = "black" { }
        [NonModifiableTextureData][NoScaleOffset] _DFGType ("Lighing Type", Float) = 0
        _StencilSection ("Stencil Section Display", Int) = 0
    }

    SubShader
    {

        // Rendering Settings
        Blend [_SrcBlend] [_DstBlend]
        ZWrite [_ZWrite]
        Cull [_Cull]
        Stencil
        {
            Ref [_StencilID]
            Comp [_StencilComp]
            Pass [_StencilOp]
        }

        // Forward Base Pass
        Pass
        {  
            Tags { "LightMode" = "ForwardBase" }
            CGPROGRAM
            #ifndef UNITY_PASS_FORWARDBASE
                #define UNITY_PASS_FORWARDBASE
            #endif // UNITY_PASS_FORWARDBASE
            #include "Resources/Luka_Backlace/Includes/Backlace_Forward.cginc"
            ENDCG
        }
          
        // Forward Add Pass
        Pass
        {
            Tags { "LightMode" = "ForwardAdd" }
            Blend [_SrcBlend] One // make it, well, *additive
            Fog { Color(0, 0, 0, 0) } // additive should have black fog
            ZWrite Off
            CGPROGRAM
            #ifndef UNITY_PASS_FORWARDADD
                #define UNITY_PASS_FORWARDADD
            #endif // UNITY_PASS_FORWARDADD
            #include "Resources/Luka_Backlace/Includes/Backlace_Forward.cginc"
            ENDCG
        }

        // Shadow Pass
        Pass
        {
            Tags { "LightMode" = "ShadowCaster" }
            ZWrite On 
            ZTest LEqual
            CGPROGRAM
            #ifndef UNITY_PASS_SHADOWCASTER
                #define UNITY_PASS_SHADOWCASTER
            #endif // UNITY_PASS_SHADOWCASTER
            #include "Resources/Luka_Backlace/Includes/Backlace_Shadow.cginc"
            ENDCG
        }
        
        // Meta Pass
        Pass
        {
            Tags { "LightMode" = "Meta" }
            Cull Off
            CGPROGRAM
            #ifndef UNITY_PASS_META
                #define UNITY_PASS_META
            #endif // UNITY_PASS_META
            #include "Resources/Luka_Backlace/Includes/Backlace_Meta.cginc"
            ENDCG
        }

    }

}