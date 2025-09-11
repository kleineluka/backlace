#ifndef BACKLACE_OUTLINE_CGINC
#define BACKLACE_OUTLINE_CGINC

// defines
#pragma vertex vert
#pragma fragment frag

// keywords
#pragma shader_feature_local _ _BACKLACE_DISSOLVE
#pragma shader_feature_local _ _BACKLACE_VERTEX_DISTORTION

// dissolve support for the outline
#if defined(_BACKLACE_DISSOLVE)
    float _DissolveProgress;
    UNITY_DECLARE_TEX2D(_DissolveNoiseTex);
    float _DissolveNoiseScale;
    int _DissolveType;
    float4 _DissolveDirection;
    int _DissolveDirectionSpace;
    float _DissolveDirectionBounds;
    float _DissolveVoxelDensity;
#endif

// vertex manipulation
float3 _VertexManipulationPosition;
float3 _VertexManipulationScale;

// includes
#include "UnityCG.cginc"
#include "./Backlace_Universal.cginc"
#include "./Backlace_Effects.cginc"

// properties
float _Alpha;
float4 _OutlineColor;
float _OutlineWidth;
int _OutlineVertexColorMask;
int _OutlineDistanceFade;
float _OutlineFadeStart;
float _OutlineFadeEnd;
float _OutlineHueShiftSpeed;
int _OutlineHueShift;
float _OutlineOpacity;

// data structures
struct appdata
{
    float4 vertex : POSITION;
    float3 normal : NORMAL;
    fixed4 color : COLOR;
};

struct v2f
{
    float4 pos : SV_POSITION;
    float3 worldPos : TEXCOORD0;
    // dissolve support for the outline
    #if defined(_BACKLACE_DISSOLVE)
        float4 vertex : TEXCOORD1;
        float3 normal : TEXCOORD2;
    #endif // _BACKLACE_DISSOLVE
};

// vertex shader
v2f vert(appdata v)
{
    v2f o;
    // vertex effects from forward passes
    v.vertex.xyz *= _VertexManipulationScale;
    v.vertex.xyz += _VertexManipulationPosition;
    #if defined(_BACKLACE_VERTEX_DISTORTION)
        DistortVertex(v.vertex);
    #endif // _BACKLACE_VERTEX_DISTORTION
    float mask = lerp(1.0, v.color.r, _OutlineVertexColorMask);
    float4 worldPos = mul(unity_ObjectToWorld, v.vertex);
    float3 worldNormal = UnityObjectToWorldNormal(v.normal);
    float4 viewPos = mul(UNITY_MATRIX_V, worldPos);
    float3 viewNormal = mul((float3x3)UNITY_MATRIX_V, worldNormal);
    viewNormal = normalize(viewNormal);
    viewPos.xyz += viewNormal * _OutlineWidth * mask * viewPos.w;
    o.pos = mul(UNITY_MATRIX_P, viewPos);
    o.worldPos = worldPos.xyz;
    // dissolve support for the outline
    #if defined(_BACKLACE_DISSOLVE)
        o.vertex = v.vertex;
        o.normal = v.normal;
    #endif // _BACKLACE_DISSOLVE
    return o;
}

// fragment shader
fixed4 frag(v2f i) : SV_Target
{
    #if defined(_BACKLACE_DISSOLVE)
        float3 worldNormal = UnityObjectToWorldNormal(i.normal);
        float dissolveMapValue = GetDissolveMapValue(i.worldPos, i.vertex.xyz, worldNormal);
        clip(dissolveMapValue - _DissolveProgress);
    #endif // _BACKLACE_DISSOLVE
    fixed4 finalColor = _OutlineColor;
    [branch] if (_OutlineHueShift > 0.5)
    {
        float3 rainbow = Sinebow(_Time.y * _OutlineHueShiftSpeed);
        finalColor.rgb = rainbow;
    }
    [branch] if (_OutlineDistanceFade == 1)
    {
        float dist = distance(i.worldPos, GetCameraPos());
        float fadeFactor = 1.0 - smoothstep(_OutlineFadeStart, _OutlineFadeEnd, dist);
        finalColor.a *= saturate(fadeFactor);
    }
    finalColor.a *= _OutlineOpacity;
    finalColor.a *= _Alpha;
    // dissolve support for the outline
    clip(finalColor.a - 0.001);
    return finalColor;
}

#endif // BACKLACE_OUTLINE_CGINC