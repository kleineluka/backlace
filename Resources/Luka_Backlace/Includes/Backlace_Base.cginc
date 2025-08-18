#ifndef BACKLACE_FORWARDBASE_CGINC
#define BACKLACE_FORWARDBASE_CGINC

// compiler directives
#pragma target 5.0
#pragma vertex Vertex
#pragma fragment Fragment
#pragma multi_compile_fwdbase
#pragma multi_compile_fog
#pragma multi_compile _ VERTEXLIGHT_ON
#pragma multi_compile_instancing

// current pass
#ifndef UNITY_PASS_FORWARDBASE
    #define UNITY_PASS_FORWARDBASE
#endif // UNITY_PASS_FORWARDBASE

// keywords
#pragma shader_feature_local _ _ALPHATEST_ON _ALPHAMODULATE_ON _ALPHABLEND_ON _ALPHAPREMULTIPLY_ON
#include "./Backlace_Keywords.cginc"

// unity includes
#include "UnityCG.cginc"
#include "UnityLightingCommon.cginc"
#include "UnityStandardUtils.cginc"
#include "AutoLight.cginc"

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
    UNITY_VERTEX_OUTPUT_STEREO
};

// backlace includes
#include "./Backlace_Properties.cginc"
#include "./Backlace_Universal.cginc"
#include "./Backlace_Lighting.cginc"
#include "./Backlace_Forward.cginc"
#include "./Backlace_Vertex.cginc"
#include "./Backlace_Fragment.cginc"

#endif // BACKLACE_FORWARDBASE_CGINC