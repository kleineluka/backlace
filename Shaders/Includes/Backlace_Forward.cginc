#ifndef BACKLACE_FORWARD_CGINC
#define BACKLACE_FORWARD_CGINC

// [ ♡ ] ────────────────────── [ ♡ ]
//
//        Compiler Directives
//
// [ ♡ ] ────────────────────── [ ♡ ]


// shared keywords
#include "./Backlace_Keywords.cginc"

// manually defined pragmas
#ifdef BACKLACE_LEGACY_MODE
    #pragma target 3.0
    #undef _BACKLACE_AUDIOLINK
    #undef _BACKLACE_LTCGI
#else // BACKLACE_LEGACY_MODE
    #pragma target 5.0
#endif // BACKLACE_LEGACY_MODE

// shader passes
#pragma vertex Vertex
//#pragma geometry Geometry
#pragma fragment Fragment

// branch between forward base and forward add passes
#if defined(UNITY_PASS_FORWARDBASE)
    #pragma multi_compile_fwdbase
    #pragma multi_compile _ VERTEXLIGHT_ON
#elif defined(UNITY_PASS_FORWARDADD)
    #pragma multi_compile_fwdadd_fullshadows
#endif // UNITY_PASS_FORWARDBASE
#pragma multi_compile_fog
#pragma multi_compile_instancing


// [ ♡ ] ────────────────────── [ ♡ ]
//
//      Includes & Integrations
//
// [ ♡ ] ────────────────────── [ ♡ ]


// unity includes
#include "UnityCG.cginc"
#include "UnityLightingCommon.cginc"
#include "UnityStandardUtils.cginc"
#include "AutoLight.cginc"

// optional audiolink integration
#if defined(_BACKLACE_AUDIOLINK)
    #include "./Backlace_AudioLink.cginc"
#endif // _BACKLACE_AUDIOLINK

// optional ltcgi integration
#if defined(_BACKLACE_LTCGI)
    #include "./Backlace_LTCGI.cginc"
#endif // _BACKLACE_LTCGI


// [ ♡ ] ────────────────────── [ ♡ ]
//
//           Data Structs
//
// [ ♡ ] ────────────────────── [ ♡ ]


struct VertexData
{
    float4 vertex : POSITION;
    float2 uv : TEXCOORD0;
    float2 uv1 : TEXCOORD1;
    float2 uv2 : TEXCOORD2;
    float2 uv3 : TEXCOORD3;
    float3 normal : NORMAL;
    float4 tangentDir : TANGENT;
    #if defined(_BACKLACE_VERTEX_DISTORTION)
        fixed4 color : COLOR;
    #endif // _BACKLACE_VERTEX_DISTORTION
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
        float2 lightmapUV : TEXCOORD9;
    #endif // LIGHTMAP_ON
    #if defined(DYNAMICLIGHTMAP_ON)
        float2 dynamicLightmapUV : TEXCOORD10;
    #endif // DYNAMICLIGHTMAP_ON
    #if defined(_BACKLACE_MATCAP)
        float2 matcapUV : TEXCOORD11;
    #endif // _BACKLACE_MATCAP
    float3 worldObjectCenter : TEXCOORD12;
    float4 scrPos : TEXCOORD13;
    UNITY_VERTEX_OUTPUT_STEREO
};

struct Unity_GlossyEnvironmentData
{
    half roughness; // this is perceptualRoughness but compatability
    half3 reflUVW;
};


// [ ♡ ] ────────────────────── [ ♡ ]
//
//         Backlace Magic~
//
// [ ♡ ] ────────────────────── [ ♡ ]


#include "./Backlace_Properties.cginc"
#include "./Backlace_Universal.cginc"
#include "./Backlace_Lighting.cginc"
#include "./Backlace_Effects.cginc"
#include "./Backlace_Shading.cginc"
#include "./Backlace_Fragment.cginc"
// #include "./Backlace_Geometry.cginc"
#include "./Backlace_Vertex.cginc"


#endif // BACKLACE_FORWARD_CGINC