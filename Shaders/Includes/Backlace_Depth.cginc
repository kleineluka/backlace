#ifndef BACKLACE_DEPTH_CGINC
#define BACKLACE_DEPTH_CGINC


// [ ♡ ] ────────────────────── [ ♡ ]
//
//           Depth Utilities
//
// [ ♡ ] ────────────────────── [ ♡ ]


// shared depth texture declarations
#ifndef BACKLACE_DEPTH
    UNITY_DECLARE_DEPTH_TEXTURE(_CameraDepthTexture);
    float4 _CameraDepthTexture_TexelSize;
    #define BACKLACE_DEPTH
#endif // BACKLACE_DEPTH

// helper functions for depth sampling
float SampleSceneDepthRaw(float2 screenUV)
{
    return SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, screenUV);
}

float SampleSceneDepthLinear(float2 screenUV)
{
    float rawDepth = SampleSceneDepthRaw(screenUV);
    return LinearEyeDepth(rawDepth);
}

float GetDepthDifference(float2 screenUV, float currentDepth)
{
    float sceneDepth = SampleSceneDepthLinear(screenUV);
    return sceneDepth - currentDepth;
}

// collection of functions from my junelite shader to have vrchat-friendly depth sampling
float4 getFrustumCorrection()
{
    // attribution: lukis101
    float x1 = -UNITY_MATRIX_P._31 / (UNITY_MATRIX_P._11 * UNITY_MATRIX_P._34);
    float x2 = -UNITY_MATRIX_P._32 / (UNITY_MATRIX_P._22 * UNITY_MATRIX_P._34);
    return float4(x1, x2, 0, UNITY_MATRIX_P._33 / UNITY_MATRIX_P._34 + x1 * UNITY_MATRIX_P._13 + x2 * UNITY_MATRIX_P._23);
}

float ManualLinear01Depth(float z)
{
    return 1.0 / (_ZBufferParams.z * z + _ZBufferParams.w);
}

float GetLinearZFromZDepthWorksWithMirrors(float zDepthFromMap, float2 screenUV)
{
    // attribution: shadertrixx method
    #if defined(UNITY_REVERSED_Z)
        zDepthFromMap = 1 - zDepthFromMap;
        if (zDepthFromMap >= 1.0) return _ProjectionParams.z;
    #endif // UNITY_REVERSED_Z
    float4 clipPos = float4(screenUV.xy, zDepthFromMap, 1.0);
    clipPos.xyz = 2.0f * clipPos.xyz - 1.0f;
    float4 camPos = mul(unity_CameraInvProjection, clipPos);
    return -camPos.z / camPos.w;
}

float getVRCLinearDepth(float4 inputVertexPosition, 
        float3 inputScreenPosition, float4 inputWorldDirection, 
        float3 inputWorldPosition)
{
    // attribution: shadertrix method, lukis method, my own frankeinstein
    float3 fullVectorFromEyeToGeometry = inputWorldPosition - _WorldSpaceCameraPos;
    // fix perspective stuffs
    float perspectiveDivide = 1.0f / inputVertexPosition.w;
    float2 screenPos = inputScreenPosition.xy * perspectiveDivide;
    // get working depth (works in unity and vrchat mirrors!)
    float perspectiveFactor = length(fullVectorFromEyeToGeometry * perspectiveDivide);
    float eyeDepthWorld = GetLinearZFromZDepthWorksWithMirrors(SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, screenPos), screenPos);
    eyeDepthWorld *= perspectiveFactor;
    // correct by size of vertex
    float3 vertexSize = inputWorldDirection.xyz * perspectiveDivide;
    float vertexSizeWorld = length(vertexSize);
    float correctedDepth = eyeDepthWorld / vertexSizeWorld;
    return correctedDepth;
}

float getVRCLinearDepth01(float4 inputVertexPosition,
    float3 inputScreenPosition, float4 inputWorldDirection,
    float3 inputWorldPosition)
{
    // attribution: shadertrix method, lukis method, my own frankeinstein
    float3 fullVectorFromEyeToGeometry = inputWorldPosition - _WorldSpaceCameraPos;
    // fix perspective stuffs
    float perspectiveDivide = 1.0f / inputVertexPosition.w;
    float2 screenPos = inputScreenPosition.xy * perspectiveDivide;
    // get working depth (works in unity and vrchat mirrors!)
    float perspectiveFactor = length(fullVectorFromEyeToGeometry * perspectiveDivide);
    float eyeDepthWorld = GetLinearZFromZDepthWorksWithMirrors(tex2D(_CameraDepthTexture, screenPos), screenPos);
    eyeDepthWorld *= perspectiveFactor;
    eyeDepthWorld = ManualLinear01Depth(eyeDepthWorld);
    // correct by size of vertex
    float3 vertexSize = inputWorldDirection.xyz * perspectiveDivide;
    float vertexSizeWorld = length(vertexSize);
    float correctedDepth = eyeDepthWorld / vertexSizeWorld;
    return correctedDepth;
}

#endif // BACKLACE_DEPTH_CGINC
