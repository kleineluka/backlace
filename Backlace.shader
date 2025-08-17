Shader "luka/indev/backlace"
{

    Properties
    {
        _SrcBlend ("Src Blend", Float) = 1.0
        _DstBlend ("Dst Blend", Float) = 0.0
        _ZWrite ("ZWrite", Float) = 1.0
        [Enum(UnityEngine.Rendering.CullMode)] _Cull ("Cull Mode", Int) = 2
        _Mode ("Blend mode", Int) = 0
        [IntRange] _StencilID ("Stencil ID (0-255)", Range(0, 255)) = 0
        [Enum(UnityEngine.Rendering.CompareFunction)] _StencilComp ("Stencil Comparison", Int) = 0
        [Enum(UnityEngine.Rendering.StencilOp)] _StencilOp ("Stencil Operation", Int) = 0
        _StencilSection ("Stencil Section Display", Int) = 0
        _DirectLightMode ("Direct Light Mode", Float) = 0.0
        _UVCount ("UV Count", Float) = 0.0
        _UV1Index ("UV1 Index", Float) = 0.0
        _MainTex ("Main texture", 2D) = "white" { }
        _Color ("Albedo color", Color) = (1, 1, 1, 1)
        _BumpMap ("Normal map", 2D) = "bump" { }
        _BumpScale ("Normal map scale", Float) = 1
        _Cutoff ("Alpha Cutoff", Range(0, 1)) = 0.5
        _Occlusion ("Occlusion", Range(0, 1)) = 1
        _MSSO ("MSSO", 2D) = "white" { }
        _MainTex_UV ("Main texture UV set", Float) = 0
        _BumpMap_UV ("Bump map UV set", Float) = 0
        _MSSO_UV ("MSSO UV set", Float) = 0
        _Ramp ("Toon Ramp", 2D) = "white" { }
        _RampOffset ("Ramp Offset", Range(-1, 1)) = 0
        _ShadowIntensity ("Shadow intensity", Range(0, 1)) = 0.6
        _OcclusionOffsetIntensity ("Occlusion Offset Intensity", Range(0, 1)) = 0
        _RampMin ("Ramp Min", Color) = (0.003921569, 0.003921569, 0.003921569, 0.003921569)
        _RampColor ("Ramp Color", Color) = (1, 1, 1, 1)
        _Metallic ("Metallic", Range(0, 1)) = 0
        _Glossiness ("Glossiness", Range(0, 1)) = 0
        _Specular ("Specular", Range(0, 1)) = 0.5
        _SpecularTintTexture ("Specular Tint Texture", 2D) = "white" { }
        _SpecularTint ("Specular Tint", Color) = (1, 1, 1, 1)
        _ReplaceSpecular ("Replace Specular", Float) = 0
        _SpecularMode ("Specular Mode", Float) = -1
        _SpecularTintTexture_UV ("Specular Tint UV Set", Float) = 0
        [NonModifiableTextureData][NoScaleOffset] _DFG ("DFG Lut", 2D) = "black" { }
        [NonModifiableTextureData][NoScaleOffset] _DFGType ("Lighing Type", Float) = 0
        _EnableSpecular ("Enable Specular", Float) = 0.0
        _TangentMap ("Tangent Map", 2D) = "white" { }
        _Anisotropy ("Ansotropy", Range(-1, 1)) = 0
        _TangentMap_UV ("Tangent Map UV", Float) = 0
        _IndirectFallbackMode ("Indirect Fallback Mode", Float) = 0.0
        _IndirectOverride ("Indirect Override", Float) = 0.0
        _FallbackCubemap ("Fallback Cubemap", Cube) = "" { }
    }

    SubShader
    {

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
            #pragma target 5.0
            #pragma vertex Vertex
            #pragma fragment Fragment
            #pragma multi_compile_fwdbase
            #pragma multi_compile_fog
            #pragma multi_compile _ VERTEXLIGHT_ON
            #pragma multi_compile_instancing

            #ifndef UNITY_PASS_FORWARDBASE
                #define UNITY_PASS_FORWARDBASE
            #endif

            #pragma shader_feature_local _ _ALPHATEST_ON _ALPHAMODULATE_ON _ALPHABLEND_ON _ALPHAPREMULTIPLY_ON

            #include "UnityCG.cginc"
            #include "UnityLightingCommon.cginc"
            #include "UnityStandardUtils.cginc"
            #include "AutoLight.cginc"

            struct VertexData
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float2 uv1 : TEXCOORD1;
                float2 uv2 : TEXCOORD2;
                float2 uv3 : TEXCOORD3;
                float3 normal : NORMAL;
                float4 tangentDir : TANGENT;
                
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct FragmentData
            {
                float4 pos : SV_POSITION;
                float3 normal : NORMAL;
                float4 tangentDir : TANGENT;
                float2 uv : TEXCOORD0;
                float2 uv1 : TEXCOORD1;
                float2 uv2 : TEXCOORD2;
                float2 uv3 : TEXCOORD3;
                float3 worldPos : TEXCOORD4;
                float4 vertex : TEXCOORD5;
                
                UNITY_SHADOW_COORDS(6)
                UNITY_FOG_COORDS(7)
                
                #if defined(LIGHTMAP_ON)
                    float2 lightmapUV : TEXCOORD8;
                #endif
                #if defined(DYNAMICLIGHTMAP_ON)
                    float2 dynamicLightmapUV : TEXCOORD9;
                #endif
                
                UNITY_VERTEX_OUTPUT_STEREO
            };

            #include "Resources/Luka_Backlace/Includes/Backlace_Base.cginc"

            ENDCG
        }
          
        // ...
        Pass
        {
            Tags { "LightMode" = "ForwardAdd" }
            ENDCG
        }

        // ...
        Pass
        {
            Tags { "LightMode" = "ShadowCaster" }
            ENDCG
        }
        
        // ...
        Pass
        {
            Tags { "LightMode" = "Meta" }
            ENDCG
        }

    }

}