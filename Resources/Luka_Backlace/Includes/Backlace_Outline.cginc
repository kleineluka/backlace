#ifndef BACKLACE_OUTLINE_CGINC
#define BACKLACE_OUTLINE_CGINC

// defines
#pragma vertex vert
#pragma fragment frag

// keywords that need alpha support in the outline
#pragma shader_feature_local _ _BACKLACE_DISSOLVE
#pragma shader_feature_local _ _BACKLACE_VERTEX_DISTORTION
#pragma shader_feature_local _ _BACKLACE_FLAT_MODEL
#pragma shader_feature_local _ _BACKLACE_VRCHAT_MIRROR
#pragma shader_feature_local _ _BACKLACE_DITHER
#pragma shader_feature_local _ _BLENDMODE_CUTOUT

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

UNITY_DECLARE_TEX2D(_MainTex);
float4 _MainTex_ST;
float _Cutoff;
float _MainTex_UV;

// Vertex manipulation
float3 _VertexManipulationPosition;
float3 _VertexManipulationScale;

// data structures
struct appdata
{
    float4 vertex : POSITION;
    float3 normal : NORMAL;
    float2 uv : TEXCOORD0;
    fixed4 color : COLOR;
};

struct v2f
{
    float4 pos : SV_POSITION;
    float3 worldPos : TEXCOORD0;
    float2 uv : TEXCOORD1;
    float4 screenPos : TEXCOORD2;
    float4 vertex : TEXCOORD3;
    float3 normal : TEXCOORD4;
};

// outline vertex shader
v2f vert(appdata v)
{
    v2f o;
    // apply vertex modifications
    v.vertex.xyz *= _VertexManipulationScale;
    v.vertex.xyz += _VertexManipulationPosition;
    #if defined(_BACKLACE_VERTEX_DISTORTION)
        DistortVertex(v.vertex);
    #endif // _BACKLACE_VERTEX_DISTORTION
    // calculate boilerplate stuff
    o.vertex = v.vertex;
    o.normal = v.normal;
    o.uv = v.uv;
    float4 worldPos = mul(unity_ObjectToWorld, v.vertex);
    float3 worldNormal = UnityObjectToWorldNormal(v.normal);
    // optionally, flatten the model
    #if defined(_BACKLACE_FLAT_MODEL)
        float4 finalClipPos;
        float3 finalWorldPos;
        float3 finalWorldNormal;
        FlattenModel(v.vertex, v.normal, finalClipPos, finalWorldPos, finalWorldNormal);
        worldPos.xyz = finalWorldPos;
        worldNormal = finalWorldNormal;
    #endif
    // outline extrusion logic
    float mask = lerp(1.0, v.color.r, _OutlineVertexColorMask);
    float4 viewPos = mul(UNITY_MATRIX_V, worldPos);
    float3 viewNormal = mul((float3x3)UNITY_MATRIX_V, worldNormal);
    viewNormal = normalize(viewNormal);
    viewPos.xyz += viewNormal * _OutlineWidth * mask * viewPos.w;
    o.pos = mul(UNITY_MATRIX_P, viewPos);
    o.worldPos = worldPos.xyz;
    o.screenPos = ComputeScreenPos(o.pos); // for dithering
    return o;
}

// outline fragment shader
fixed4 frag(v2f i) : SV_Target
{
    float baseAlpha = UNITY_SAMPLE_TEX2D(_MainTex, i.uv).a;
    // handle cutout blending for the outline
    #if defined(_BLENDMODE_CUTOUT)
        float4 mainTex = UNITY_SAMPLE_TEX2D(_MainTex, i.uv);
        clip(mainTex.a - _Cutoff);
    #endif // _BLENDMODE_CUTOUT
    // handle dissolve effect on the outline
    #if defined(_BACKLACE_DISSOLVE)
        float3 worldNormal = UnityObjectToWorldNormal(i.normal);
        float dissolveMapValue = GetDissolveMapValue(i.worldPos, i.vertex.xyz, worldNormal);
        clip(dissolveMapValue - _DissolveProgress);
    #endif
    // mirror effect support for the outline
    #if defined(_BACKLACE_VRCHAT_MIRROR)
        if ((_MirrorDetectionMode == 1 && IsInMirrorView()) || (_MirrorDetectionMode == 2 && !IsInMirrorView()))
        {
            clip(-1);
        }
    #endif // _BACKLACE_VRCHAT_MIRROR
    // handle dithering
    #if defined(_BACKLACE_DITHER)
        float ditheredAlpha = lerp(baseAlpha, 0.0, _DitherAmount);
        float pattern = 1.0 - GetTiltedCheckerboardPattern(i.screenPos.xy / i.screenPos.w * _ScreenParams.xy, _DitherScale);
        clip(ditheredAlpha - pattern);
    #endif // _BACKLACE_DITHER
    // finally, draw the outline
    fixed4 finalColor = _OutlineColor;
    if (_OutlineHueShift == 1)
    {
        float3 rainbow = Sinebow(_Time.y * _OutlineHueShiftSpeed);
        finalColor.rgb = rainbow;
    }
    if (_OutlineDistanceFade == 1)
    {
        float dist = distance(i.worldPos, GetCameraPos());
        float fadeFactor = 1.0 - smoothstep(_OutlineFadeStart, _OutlineFadeEnd, dist);
        finalColor.a *= saturate(fadeFactor);
    }
    finalColor.a *= _OutlineOpacity;
    finalColor.a *= _Alpha;
    finalColor.a *= baseAlpha;
    clip(finalColor.a - 0.001);
    return finalColor;
}

#endif // BACKLACE_OUTLINE_CGINC