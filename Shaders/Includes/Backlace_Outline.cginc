#ifndef BACKLACE_OUTLINE_CGINC
#define BACKLACE_OUTLINE_CGINC


// [ ♡ ] ────────────────────── [ ♡ ]
//
//           Legacy Mode
//
// [ ♡ ] ────────────────────── [ ♡ ]


#include "./Backlace_Legacy.cginc" // toggle inside here!


// [ ♡ ] ────────────────────── [ ♡ ]
//
//        Compiler Directives
//
// [ ♡ ] ────────────────────── [ ♡ ]


// compiler directives
#ifdef BACKLACE_LEGACY_MODE
    #pragma target 3.0
    #undef _BACKLACE_AUDIOLINK
    #undef _BACKLACE_LTCGI
#else // BACKLACE_LEGACY_MODE
    #pragma target 5.0
#endif // BACKLACE_LEGACY_MODE

// defines
#pragma vertex vert
#pragma fragment frag

// keywords that need alpha support in the outline
#pragma shader_feature_local _ _BACKLACE_DISSOLVE
#pragma shader_feature_local _ _BACKLACE_VERTEX_DISTORTION
// #pragma shader_feature_local _ _BACKLACE_FLAT_MODEL
#pragma shader_feature_local _ _BACKLACE_VRCHAT_MIRROR
#pragma shader_feature_local _ _BACKLACE_AUDIOLINK
#pragma shader_feature_local _ _BLENDMODE_CUTOUT
#pragma shader_feature_local _ _BACKLACE_LIT_OUTLINE

// includes
#include "UnityCG.cginc"
#if defined(_BACKLACE_AUDIOLINK)
    #include "./Backlace_AudioLink.cginc"
#endif // _BACKLACE_AUDIOLINK
#include "./Backlace_Universal.cginc"
#include "./Backlace_Effects.cginc"


// [ ♡ ] ────────────────────── [ ♡ ]
//
//            Properties
//
// [ ♡ ] ────────────────────── [ ♡ ]


int _OutlineSpace;
float _OutlineWidth;
int _OutlineVertexColorMask;
int _OutlineDistanceFade;
float _OutlineFadeStart;
float _OutlineFadeEnd;
float _OutlineHueShiftSpeed;
int _OutlineHueShift;
float _OutlineOpacity;
int _OutlineMode;
int _OutlineTexMap;
UNITY_DECLARE_TEX2D_NOSAMPLER(_OutlineTex);
float2 _OutlineTexTiling;
float2 _OutlineTexScroll;
float4 _OutlineColor;
float3 _OutlineOffset;
int _OutlineStyle;


// [ ♡ ] ────────────────────── [ ♡ ]
//
//         Data Structures
//
// [ ♡ ] ────────────────────── [ ♡ ]


// data structures
struct appdata
{
    float4 vertex : POSITION;
    float3 normal : NORMAL;
    float2 uv : TEXCOORD0;
    fixed4 color : COLOR;
};


// [ ♡ ] ────────────────────── [ ♡ ]
//
//          Outline Lighting
//
// [ ♡ ] ────────────────────── [ ♡ ]
#if defined(_BACKLACE_LIT_OUTLINE)
    float _OutlineLitMix;
    #include "UnityLightingCommon.cginc"
    #include "UnityStandardUtils.cginc"
    #include "AutoLight.cginc"
    struct FragmentData
    {
        float4 pos : SV_POSITION;
        float3 normal : NORMAL;
        float4 tangentDir : TANGENT;
        float2 uv : TEXCOORD0;
        float4 screenPos : TEXCOORD2;
        float3 worldPos : TEXCOORD4;
        UNITY_SHADOW_COORDS(6)
        #if defined(LIGHTMAP_ON)
            float2 lightmapUV : TEXCOORD8;
        #endif
        #if defined(DYNAMICLIGHTMAP_ON)
            float2 dynamicLightmapUV : TEXCOORD9;
        #endif
        float4 vertex : TEXCOORD3;
    };
    #include "./Backlace_Properties.cginc"
    #include "./Backlace_Lighting.cginc"
    #include "./Backlace_Shading.cginc" // For GetGeometryVectors 
#else // _BACKLACE_LIT_OUTLINE
    UNITY_DECLARE_TEX2D(_MainTex);
    float4 _MainTex_ST;
    float _Cutoff;
    float _MainTex_UV;
    float _Alpha;
    float3 _VertexManipulationPosition;
    float3 _VertexManipulationScale;
    struct FragmentData
    {
        float4 pos : SV_POSITION;
        float3 worldPos : TEXCOORD0;
        float2 uv : TEXCOORD1;
        float4 screenPos : TEXCOORD2;
        float4 vertex : TEXCOORD3;
        float3 normal : TEXCOORD4;
    };
#endif // _BACKLACE_LIT_OUTLINE


// [ ♡ ] ────────────────────── [ ♡ ]
//
//           Vertex Shader
//
// [ ♡ ] ────────────────────── [ ♡ ]


FragmentData vert(appdata v)
{
    FragmentData o;
    // apply vertex modifications
    #if defined(_BACKLACE_AUDIOLINK)
        Divine al_data = CalculateDivine();
        v.vertex.xyz *= _VertexManipulationScale * al_data.vertexScale; // scale
    #else // _BACKLACE_AUDIOLINK
        v.vertex.xyz *= _VertexManipulationScale; // scale
    #endif // _BACKLACE_AUDIOLINK
    v.vertex.xyz += _VertexManipulationPosition;
    v.vertex.xyz += _OutlineOffset;
    #if defined(_BACKLACE_VERTEX_DISTORTION)
        ApplyVertexDistortion(v.vertex, mul(unity_ObjectToWorld, v.vertex).xyz, v.color);
    #endif // _BACKLACE_VERTEX_DISTORTION
    // calculate boilerplate stuff
    o.vertex = v.vertex;
    o.normal = v.normal;
    o.uv = v.uv;
    float4 worldPos = mul(unity_ObjectToWorld, v.vertex);
    float3 worldNormal = UnityObjectToWorldNormal(v.normal);
    if (_OutlineStyle == 1) // silhouette
    {
        worldNormal.rgb = (v.color.rgb - 0.5) * 2.0;
    }
    // optionally, flatten the model
    #if defined(BACKLACE_CAPABILITIES_HIGH)
        if (_ToggleFlatModel == 1)
        {
            float4 finalClipPos;
            float3 finalWorldPos;
            float3 finalWorldNormal;
            FlattenModel(v.vertex, v.normal, finalClipPos, finalWorldPos, finalWorldNormal);
            worldPos.xyz = finalWorldPos;
            worldNormal = finalWorldNormal;
        }
    #endif // BACKLACE_CAPABILITIES_HIGH
    // outline extrusion logic
    float mask = lerp(1.0, v.color.r, _OutlineVertexColorMask);
    if (_OutlineSpace == 1) // world space
    {
        float3 extrusionDir = normalize(worldNormal);
        float3 newWorldPos = worldPos.xyz + extrusionDir * _OutlineWidth * mask;
        o.pos = mul(UNITY_MATRIX_VP, float4(newWorldPos, 1.0));
    }
    else // view space
    {
        float4 viewPos = mul(UNITY_MATRIX_V, worldPos);
        float3 viewNormal = mul((float3x3)UNITY_MATRIX_V, worldNormal);
        viewNormal = normalize(viewNormal);
        viewPos.xyz += viewNormal * _OutlineWidth * mask * viewPos.w;
        o.pos = mul(UNITY_MATRIX_P, viewPos);
    }
    o.worldPos = worldPos.xyz;
    o.screenPos = ComputeScreenPos(o.pos); // for dithering
    #if defined(BACKLACE_CAPABILITIES_HIGH)
        [branch] if (_TogglePS1 == 1) ApplyPS1Vertex(o.pos, v.vertex);
    #endif // BACKLACE_CAPABILITIES_HIGH
    return o;
}


// [ ♡ ] ────────────────────── [ ♡ ]
//
//           Pixel Shader
//
// [ ♡ ] ────────────────────── [ ♡ ]


fixed4 frag(FragmentData i) : SV_Target
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
    #if defined(BACKLACE_CAPABILITIES_HIGH)
        [branch] if (_ToggleDither == 1)
        {
            // calculate dithered alpha
            float ditheredAlpha = lerp(baseAlpha, 0.0, _DitherAmount);
            float2 ditherUV = 0;
            switch (_DitherSpace) {
                case 1: // world
                    ditherUV = frac(i.worldPos.xy) * _ScreenParams.xy;
                    break;
                case 2: // uv
                    ditherUV = i.uv * _ScreenParams.xy;
                    break;
                default: // screen
                    ditherUV = i.screenPos.xy / i.screenPos.w * _ScreenParams.xy;
                    break;
            }
            float pattern = 1.0 - GetTiltedCheckerboardPattern(ditherUV, _DitherScale);
            clip(ditheredAlpha - pattern);
        }
    #endif // BACKLACE_CAPABILITIES_HIGH
    // finally, draw the outline
    fixed4 finalColor = _OutlineColor;
    if (_OutlineMode == 1) // texture
    {
        float2 outlineTexUV;
        switch (_OutlineTexMap) {
            case 1: // world space
                outlineTexUV = i.worldPos.xz;
                break;
            case 2: // uv space
                outlineTexUV = i.uv;
                break;
            default: // screen space
                outlineTexUV = i.screenPos.xy / i.screenPos.w;
                break;
        }
        outlineTexUV = frac(frac(outlineTexUV * _OutlineTexTiling) + (_OutlineTexScroll * _Time.y));
        fixed4 outlineTexColor = UNITY_SAMPLE_TEX2D_SAMPLER(_OutlineTex, _MainTex, outlineTexUV);
        finalColor.rgb = outlineTexColor;
    }
    else if (_OutlineMode == 2) // albedo
    {
        fixed4 albedo = UNITY_SAMPLE_TEX2D(_MainTex, i.uv) * _OutlineColor;
        finalColor.rgb = albedo.rgb;
    }
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
    #if defined(_BACKLACE_LIT_OUTLINE)
        FragData.pos = i.pos;
        FragData.worldPos = i.worldPos;
        FragData.normal = UnityObjectToWorldNormal(i.normal);
        FragData.tangentDir = float4(1, 0, 0, 1); // dummy tangent
        FragData.uv = i.uv;
        #if defined(LIGHTMAP_ON)
            FragData.lightmapUV = i.uv;
        #endif // LIGHTMAP_ON
        #if defined(DYNAMICLIGHTMAP_ON)
            FragData.dynamicLightmapUV = i.uv;
        #endif // DYNAMICLIGHTMAP_ON
        BacklaceSurfaceData Surface = (BacklaceSurfaceData)0;
        Surface.Albedo.rgb = finalColor.rgb;
        Surface.Albedo.a = 1;
        GetGeometryVectors(Surface, FragData);
        float3 NormalMap = float3(0, 0, 1); // flat normal
        GetLightData(Surface);
        float3 direct = Surface.LightColor.rgb * Surface.Attenuation * Surface.NdotL;
        float3 combinedLight = direct + Surface.IndirectDiffuse;
        finalColor.rgb = lerp(finalColor.rgb, finalColor.rgb * direct, _OutlineLitMix);
    #endif // _BACKLACE_LIT_OUTLINE
    finalColor.a *= _OutlineOpacity;
    finalColor.a *= _Alpha;
    finalColor.a *= baseAlpha;
    clip(finalColor.a - 0.001);
    return finalColor;
}


#endif // BACKLACE_OUTLINE_CGINC