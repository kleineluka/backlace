#ifndef BACKLACE_FORWARD_CGINC
#define BACKLACE_FORWARD_CGINC

// clip alpha based on the _Cutoff value or dither mask
// todo: make cutoff passed and not _Cutoff
void ClipAlpha()
{
    #if defined(_ALPHATEST_ON)
        clip(Albedo.a - _Cutoff);
    #else
        #if defined(_ALPHAMODULATE_ON)
            float dither = tex3D(_DitherMaskLOD, float3(FragData.pos.xy * 0.25, Albedo.a * 0.9375)).a; //Dither16x16Bayer(FragData.pos.xy * 0.25) * Albedo.a;
            clip(dither - 0.01);
        #endif
    #endif
}

// sample normal map
// todo: pass maps, not properties
void SampleNormal()
{
    NormalMap = UnpackScaleNormal(UNITY_SAMPLE_TEX2D_SAMPLER(_BumpMap, _MainTex, BACKLACE_TRANSFORM_TEX(Uvs, _BumpMap)), _BumpScale);
}

// safe normalize a half3 vector
half3 Unity_SafeNormalize(half3 inVec)
{
    half dp3 = max(0.001f, dot(inVec, inVec));
    return inVec * rsqrt(dp3);
}

// calculate normals from normal map
void CalculateNormals(inout float3 normal, inout float3 tangent, inout float3 bitangent, float3 normalmap)
{
    float3 tspace0 = float3(tangent.x, bitangent.x, normal.x);
    float3 tspace1 = float3(tangent.y, bitangent.y, normal.y);
    float3 tspace2 = float3(tangent.z, bitangent.z, normal.z);
    float3 calcedNormal;
    calcedNormal.x = dot(tspace0, normalmap);
    calcedNormal.y = dot(tspace1, normalmap);
    calcedNormal.z = dot(tspace2, normalmap);
    calcedNormal = normalize(calcedNormal);
    float3 bumpedTangent = (cross(bitangent, calcedNormal));
    float3 bumpedBitangent = (cross(calcedNormal, bumpedTangent));
    normal = calcedNormal;
    tangent = bumpedTangent;
    bitangent = bumpedBitangent;
}

// get direction vectors
void GetDirectionVectors()
{
    NormalDir = normalize(FragData.normal);
    TangentDir = normalize(UnityObjectToWorldDir(FragData.tangentDir.xyz));
    BitangentDir = normalize(cross(NormalDir, TangentDir) * FragData.tangentDir.w * unity_WorldTransformParams.w);
    CalculateNormals(NormalDir, TangentDir, BitangentDir, NormalMap);
    LightDir = normalize(UnityWorldSpaceLightDir(FragData.worldPos));
    ViewDir = normalize(UnityWorldSpaceViewDir(FragData.worldPos));
    ReflectDir = reflect(-ViewDir, NormalDir);
    HalfDir = Unity_SafeNormalize(LightDir + ViewDir);
}

// get SH length
half3 GetSHLength()
{
    half3 x, x1;
    x.r = length(unity_SHAr);
    x.g = length(unity_SHAg);
    x.b = length(unity_SHAb);
    x1.r = length(unity_SHBr);
    x1.g = length(unity_SHBg);
    x1.b = length(unity_SHBb);
    return x + x1;
}

// fade shadows based on distance
float FadeShadows(FragmentData i, float attenuation)
{
    #if HANDLE_SHADOWS_BLENDING_IN_GI && !defined(SHADOWS_SHADOWMASK)
        // UNITY_LIGHT_ATTENUATION doesn't fade shadows for us.
        float viewZ = dot(_WorldSpaceCameraPos - i.worldPos, UNITY_MATRIX_V[2].xyz);
        float shadowFadeDistance = UnityComputeShadowFadeDistance(i.worldPos, viewZ);
        float shadowFade = UnityComputeShadowFade(shadowFadeDistance);
        attenuation = saturate(attenuation + shadowFade);
    #endif
    #if defined(LIGHTMAP_ON) && defined(SHADOWS_SHADOWMASK)
        // UNITY_LIGHT_ATTENUATION doesn't fade shadows for us.
        float viewZ = dot(_WorldSpaceCameraPos - i.worldPos, UNITY_MATRIX_V[2].xyz);
        float shadowFadeDistance = UnityComputeShadowFadeDistance(i.worldPos, viewZ);
        float shadowFade = UnityComputeShadowFade(shadowFadeDistance);
        float bakedAttenuation = UnitySampleBakedOcclusion(i.lightmapUV, i.worldPos);
        attenuation = UnityMixRealtimeAndBakedShadows(attenuation, bakedAttenuation, shadowFade);
        //attenuation = saturate(attenuation + shadowFade);
        //attenuation = bakedAttenuation;
        
    #endif
    return attenuation;
}

#endif // BACKLACE_FORWARD_CGINC