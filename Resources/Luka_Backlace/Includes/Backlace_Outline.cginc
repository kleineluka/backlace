#ifndef BACKLACE_OUTLINE_CGINC
#define BACKLACE_OUTLINE_CGINC

// defines
#pragma vertex vert
#pragma fragment frag

// includes
#include "UnityCG.cginc"
#include "./Backlace_Universal.cginc"

// properties
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

};

// vertex shader
v2f vert(appdata v)
{
    v2f o;
    float mask = lerp(1.0, v.color.r, _OutlineVertexColorMask);
    float4 worldPos = mul(unity_ObjectToWorld, v.vertex);
    float3 worldNormal = UnityObjectToWorldNormal(v.normal);
    float4 viewPos = mul(UNITY_MATRIX_V, worldPos);
    float3 viewNormal = mul((float3x3)UNITY_MATRIX_V, worldNormal);
    viewNormal = normalize(viewNormal);
    viewPos.xyz += viewNormal * _OutlineWidth * mask * viewPos.w;
    o.pos = mul(UNITY_MATRIX_P, viewPos);
    o.worldPos = worldPos.xyz;
    return o;
}

// fragment shader
fixed4 frag(v2f i) : SV_Target
{
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
    clip(finalColor.a - 0.001);
    return finalColor;
}

#endif // BACKLACE_OUTLINE_CGINC