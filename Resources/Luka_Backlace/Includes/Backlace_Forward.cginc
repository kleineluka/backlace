#ifndef BACKLACE_FORWARD_CGINC
#define BACKLACE_FORWARD_CGINC

// keywords
#include "./Backlace_Keywords.cginc"

// compiler directives
#pragma target 5.0
#pragma vertex Vertex
//#pragma geometry Geometry
#pragma fragment Fragment
#pragma multi_compile_fog
#pragma multi_compile_instancing

// branch between forward base and forward add passes
#if defined(UNITY_PASS_FORWARDBASE)
    #pragma multi_compile_fwdbase
    #pragma multi_compile _ VERTEXLIGHT_ON
#elif defined(UNITY_PASS_FORWARDADD)
    #pragma multi_compile_fwdadd_fullshadows
#endif // UNITY_PASS_FORWARDBASE

// unity includes
#include "UnityCG.cginc"
#include "UnityLightingCommon.cginc"
#include "UnityStandardUtils.cginc"
#include "AutoLight.cginc"

// optional audiolink integration
#if defined(_BACKLACE_AUDIOLINK)
    #include "./Backlace_AudioLink.cginc"
#endif // _BACKLACE_AUDIOLINK

// data structures
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
    #endif // LIGHTMAP_ON
    #if defined(DYNAMICLIGHTMAP_ON)
        float2 dynamicLightmapUV : TEXCOORD9;
    #endif // DYNAMICLIGHTMAP_ON
    #if defined(_BACKLACE_MATCAP)
        float2 matcapUV : TEXCOORD10;
    #endif // _BACKLACE_MATCAP
    float3 worldObjectCenter : TEXCOORD11;
    float4 scrPos : TEXCOORD12; // for grab pass
    #if defined(_BACKLACE_AUDIOLINK)
        float4 alChannel1 : TEXCOORD13; // x=emission, y=rim, z=hueShift, w=matcap
        float4 alChannel2 : TEXCOORD14; // x=pathing, y=glitter, z=iridescence, w=decalHue
        float2 alChannel3 : TEXCOORD15; // x=decalEmission, y=decalOpacity
    #endif // _BACKLACE_AUDIOLINK
    #if defined(_BACKLACE_PS1)
        float4 affineUV : TEXCOORD16;
    #endif // _BACKLACE_PS1
    UNITY_VERTEX_OUTPUT_STEREO
};

struct Unity_GlossyEnvironmentData
{
    half roughness; // this is perceptualRoughness but compatability
    half3 reflUVW;
};

// backlace includes
#include "./Backlace_Properties.cginc"
#include "./Backlace_Universal.cginc"
#include "./Backlace_Lighting.cginc"
#include "./Backlace_Effects.cginc"
#include "./Backlace_Shading.cginc"
#include "./Backlace_Fragment.cginc"
// #include "./Backlace_Geometry.cginc"
#include "./Backlace_Vertex.cginc"

#endif // BACKLACE_FORWARD_CGINC