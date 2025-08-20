#ifndef BACKLACE_LIGHTING_CGINC
#define BACKLACE_LIGHTING_CGINC

// easy i/o across lighting functions
struct BacklaceLightData
{
    float3 directColor;
    float3 indirectColor;
    float3 direction;
    float attenuation;
};

// safe normalize a half3 vector
half3 Unity_SafeNormalize(half3 inVec)
{
    half dp3 = max(0.001f, dot(inVec, inVec));
    return inVec * rsqrt(dp3);
}

// get combined length of two sets of spherical harmonics
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
        float viewZ = dot(_WorldSpaceCameraPos - i.worldPos, UNITY_MATRIX_V[2].xyz);
        float shadowFadeDistance = UnityComputeShadowFadeDistance(i.worldPos, viewZ);
        float shadowFade = UnityComputeShadowFade(shadowFadeDistance);
        attenuation = saturate(attenuation + shadowFade);
    #endif // HANDLE_SHADOWS_BLENDING_IN_GI && !SHADOWS_SHADOWMASK
    #if defined(LIGHTMAP_ON) && defined(SHADOWS_SHADOWMASK)
        float viewZ = dot(_WorldSpaceCameraPos - i.worldPos, UNITY_MATRIX_V[2].xyz);
        float shadowFadeDistance = UnityComputeShadowFadeDistance(i.worldPos, viewZ);
        float shadowFade = UnityComputeShadowFade(shadowFadeDistance);
        float bakedAttenuation = UnitySampleBakedOcclusion(i.lightmapUV, i.worldPos);
        attenuation = UnityMixRealtimeAndBakedShadows(attenuation, bakedAttenuation, shadowFade);
    #endif // LIGHTMAP_ON && SHADOWS_SHADOWMASK
    return attenuation;
}

// From Poiyomi For Poiyomi Lighting Mode
float shEvaluateDiffuseL1Geomerics_local(float L0, float3 L1, float3 n)
{
    float R0 = max(0, L0);
    float3 R1 = 0.5f * L1;
    float lenR1 = length(R1);
    float q = dot(normalize(R1), n) * 0.5 + 0.5;
    q = saturate(q);
    float p = 1.0f + 2.0f * lenR1 / R0;
    float a = (1.0f - lenR1 / R0) / (1.0f + lenR1 / R0);
    return R0 * (a + (1.0f - a) * (p + 1.0f) * pow(q, p));
}

// From Poiyomi For Poiyomi Lighting Mode
half3 BetterSH9(half4 normal)
{
    float3 indirect;
    float3 L0 = float3(unity_SHAr.w, unity_SHAg.w, unity_SHAb.w) + float3(unity_SHBr.z, unity_SHBg.z, unity_SHBb.z) / 3.0;
    indirect.r = shEvaluateDiffuseL1Geomerics_local(L0.r, unity_SHAr.xyz, normal.xyz);
    indirect.g = shEvaluateDiffuseL1Geomerics_local(L0.g, unity_SHAg.xyz, normal.xyz);
    indirect.b = shEvaluateDiffuseL1Geomerics_local(L0.b, unity_SHAb.xyz, normal.xyz);
    indirect = max(0, indirect);
    indirect += SHEvalLinearL2(normal);
    return indirect;
}

// From Mochie For Mochie Lighting Mode
float NonlinearSH(float L0, float3 L1, float3 normal)
{
    float R0 = L0;
    float3 R1 = 0.5f * L1;
    float lenR1 = length(R1);
    float q = dot(normalize(R1), normal) * 0.5 + 0.5;
    q = max(0, q);
    float p = 1.0f + 2.0f * lenR1 / R0;
    float a = (1.0f - lenR1 / R0) / (1.0f + lenR1 / R0);
    return R0 * (a + (1.0f - a) * (p + 1.0f) * pow(q, p));
}

// From Mochie For Mochie Lighting Mode
float3 ShadeSHNL(float3 normal)
{
    float3 indirect;
    indirect.r = NonlinearSH(unity_SHAr.w, unity_SHAr.xyz, normal);
    indirect.g = NonlinearSH(unity_SHAg.w, unity_SHAg.xyz, normal);
    indirect.b = NonlinearSH(unity_SHAb.w, unity_SHAb.xyz, normal);
    return max(0, indirect);
}

// From OpenLit For OpenLit Lighting Mode
void OpenLitShadeSH9ToonDouble(float3 lightDirection, out float3 shMax, out float3 shMin)
{
    #if !defined(LIGHTMAP_ON)
        float3 N = lightDirection * 0.666666;
        float4 vB = N.xyzz * N.yzzx;
        float3 res = float3(unity_SHAr.w, unity_SHAg.w, unity_SHAb.w);
        res.r += dot(unity_SHBr, vB);
        res.g += dot(unity_SHBg, vB);
        res.b += dot(unity_SHBb, vB);
        res += unity_SHC.rgb * (N.x * N.x - N.y * N.y);
        float3 l1;
        l1.r = dot(unity_SHAr.rgb, N);
        l1.g = dot(unity_SHAg.rgb, N);
        l1.b = dot(unity_SHAb.rgb, N);
        shMax = res + l1;
        shMin = res - l1;
        #if defined(UNITY_COLORSPACE_GAMMA)
            shMax = LinearToGammaSpace(shMax);
            shMin = LinearToGammaSpace(shMin);
        #endif // UNITY_COLORSPACE_GAMMA
    #else // LIGHTMAP_ON
        shMax = 0.0;
        shMin = 0.0;
    #endif // LIGHTMAP_ON
}

// solution to get indirect lighting to apply to all lightm odes
float3 GetUniversalIndirectLight(float3 normal)
{
    float3 indirectColor = float3(0, 0, 0);
    #if defined(UNITY_PASS_FORWARDBASE)
        indirectColor = float3(unity_SHAr.w, unity_SHAg.w, unity_SHAb.w);
        #if defined(LIGHTMAP_ON)
            indirectColor = DecodeLightmap(UNITY_SAMPLE_TEX2D(unity_Lightmap, FragData.lightmapUV));
            #if defined(DIRLIGHTMAP_COMBINED)
                indirectColor = DecodeDirectionalLightmap(indirectColor, LightmapDirection, normal);
            #endif
        #endif
        #if defined(DYNAMICLIGHTMAP_ON)
            #if defined(DIRLIGHTMAP_COMBINED)
                indirectColor += DecodeDirectionalLightmap(DynamicLightmap, DynamicLightmapDirection, normal);
            #else
                indirectColor += DynamicLightmap;
            #endif
        #endif
    #endif
    return indirectColor;
}

// the original backlace light color function
void GetBacklaceLightColor(inout BacklaceLightData lightData, float3 normal)
{
    #if defined(UNITY_PASS_FORWARDBASE)
        lightData.directColor = _LightColor0.rgb;
        lightData.indirectColor = GetUniversalIndirectLight(normal);
        lightData.directColor = lerp(GetSHLength(), lightData.directColor, .75);
        if (any(_WorldSpaceLightPos0.xyz) == 0 || _LightColor0.a < 0.01)
        {
            if (_DirectLightMode > 0) 
            {
                lightData.directColor = lightData.indirectColor;
                lightData.indirectColor = 0;
            }
        }
    #else // UNITY_PASS_FORWARDADD
        lightData.directColor = _LightColor0.rgb;
        lightData.indirectColor = 0;
    #endif
}

// From Poiyomi For Poiyomi Lighting Mode
void GetPoiyomiLightColor(inout BacklaceLightData lightData, float3 normal)
{
    #if defined(UNITY_PASS_FORWARDBASE)
        float3 ambientMagic = max(BetterSH9(normalize(unity_SHAr + unity_SHAg + unity_SHAb)), 0);
        float3 normalLight = _LightColor0.rgb + BetterSH9(float4(0, 0, 0, 1));
        float magicLuma = GetLuma(ambientMagic);
        float normalLuma = GetLuma(normalLight);
        float totalLuma = magicLuma + normalLuma;
        if (totalLuma > 0.0001)
        {
            float magicRatio = magicLuma / totalLuma;
            float normalRatio = normalLuma / totalLuma;
            float targetLuma = GetLuma(ambientMagic * magicRatio + normalLight * normalRatio);
            float3 properLightColor = ambientMagic + normalLight;
            float properLuminance = GetLuma(properLightColor);
            lightData.directColor = properLightColor * max(0.0001, (targetLuma / properLuminance));
        }
        else
        {
            lightData.directColor = float3(0, 0, 0);
        }
        lightData.indirectColor = GetUniversalIndirectLight(normal);
        bool lightExists = any(_WorldSpaceLightPos0.xyz) && _LightColor0.a > 0.01;
        if (!lightExists && _DirectLightMode > 0)
        {
            lightData.directColor = lightData.indirectColor;
            lightData.indirectColor = 0;
        }
    #else // UNITY_PASS_FORWARDADD
        lightData.directColor = _LightColor0.rgb;
        lightData.indirectColor = 0;
    #endif
}

// From OpenLit For OpenLit Lighting Mode
void GetOpenLitLightColor(inout BacklaceLightData lightData, float3 normal)
{
    #if defined(UNITY_PASS_FORWARDBASE)
        float3 directSH, indirectSH_OpenLit; 
        OpenLitShadeSH9ToonDouble(normal, directSH, indirectSH_OpenLit);
        lightData.directColor = directSH + _LightColor0.rgb;
        lightData.indirectColor = GetUniversalIndirectLight(normal);
        bool lightExists = any(_WorldSpaceLightPos0.xyz) && _LightColor0.a > 0.01;
        if (!lightExists && _DirectLightMode > 0)
        {
            lightData.directColor = lightData.indirectColor;
            lightData.indirectColor = 0;
        }
    #else // UNITY_PASS_FORWARDADD
        lightData.directColor = _LightColor0.rgb;
        lightData.indirectColor = 0;
    #endif
}
 
// naive unity light colour functions
void GetStandardLightColor(inout BacklaceLightData lightData, float3 normal)
{
    #if defined(UNITY_PASS_FORWARDBASE)
        bool lightExists = any(_WorldSpaceLightPos0.xyz) && _LightColor0.a > 0.01;
        lightData.indirectColor = GetUniversalIndirectLight(normal);
        if (lightExists)
        {
            lightData.directColor = _LightColor0.rgb;
        }
        else
        {
            lightData.directColor = float3(0, 0, 0);
        }
        if (!lightExists && _DirectLightMode > 0)
        {
            lightData.directColor = lightData.indirectColor;
            lightData.indirectColor = 0;
        }

    #else // UNITY_PASS_FORWARDADD
        lightData.directColor = _LightColor0.rgb;
        lightData.indirectColor = 0;
    #endif
}

// From Mochie For Mochie Lighting Mode
void GetMochieLightColor(inout BacklaceLightData lightData, float3 normal)
{
    #if defined(UNITY_PASS_FORWARDBASE)
        bool lightExists = any(_WorldSpaceLightPos0.xyz);
        lightData.indirectColor = GetUniversalIndirectLight(normal);
        if (lightExists)
        {
            lightData.directColor = _LightColor0.rgb;
        }
        else
        {
            lightData.directColor = ShadeSHNL(normal);
        }
        if (!lightExists || _LightColor0.a < 0.01)
        {
            if (_DirectLightMode > 0) 
            {
                lightData.directColor = lightData.indirectColor;
                lightData.indirectColor = 0;
            }
        }
    #else // UNITY_PASS_FORWARDADD
        lightData.directColor = _LightColor0.rgb;
        lightData.indirectColor = 0;
    #endif
}

// original backlace light direction modes
float3 GetBacklaceLightDirection()
{
    return normalize(UnityWorldSpaceLightDir(FragData.worldPos));
}

// simply force a world light direction
float3 GetForcedWorldLightDirection()
{
    return normalize(_ForcedLightDirection.xyz);
}

// view light direction with optional offsets
float3 GetViewLightDirection()
{
    float3 viewLightDirection = -UNITY_MATRIX_V[2].xyz;
    viewLightDirection += UNITY_MATRIX_V[0].xyz * _ViewDirectionOffsetX; // right vector for X offset
    viewLightDirection += UNITY_MATRIX_V[1].xyz * _ViewDirectionOffsetY; // up vector for Y offset

    return normalize(viewLightDirection);
}

// limit brightness of light colour
float3 LimitLightBrightness(float3 lightColor, float minVal, float maxVal)
{
    // find brightest colour channel
    float brightness = max(lightColor.r, max(lightColor.g, lightColor.b));
    // avoid division by zero
    if (brightness > 0.0001)
    {
        float newBrightness = clamp(brightness, minVal, maxVal);
        float scale = newBrightness / brightness;
        return lightColor * scale;
    }
    return lightColor;
}

// easy helper for the add pass
void GetForwardAddLightData(out BacklaceLightData lightData)
{
    lightData.directColor = _LightColor0.rgb;
    lightData.indirectColor = float3(0, 0, 0);
    lightData.direction = normalize(_WorldSpaceLightPos0.xyz - FragData.worldPos.xyz * _WorldSpaceLightPos0.w);
    #if defined(POINT) || defined(POINT_COOKIE)
        unityShadowCoord3 lightCoord = mul(unity_WorldToLight, float4(FragData.worldPos, 1)).xyz;
        lightData.attenuation = tex2D(_LightTexture0, dot(lightCoord, lightCoord).rr).r;
        #if defined(POINT_COOKIE)
            lightData.attenuation *= texCUBE(_LightTexture0, lightCoord).w;
        #endif
    #elif defined(SPOT)
        unityShadowCoord4 lightCoord = mul(unity_WorldToLight, float4(FragData.worldPos, 1));
        lightData.attenuation = (lightCoord.z > 0) * UnitySpotCookie(lightCoord) * UnitySpotAttenuate(lightCoord.xyz);
    #else
        UNITY_LIGHT_ATTENUATION(atten, FragData, FragData.worldPos);
        lightData.attenuation = atten;
    #endif
    lightData.attenuation *= UNITY_SHADOW_ATTENUATION(FragData, FragData.worldPos);
}

// get light data
void GetLightData(inout BacklaceSurfaceData Surface)
{
    BacklaceLightData lightData;
    #if defined(UNITY_PASS_FORWARDBASE)
        UNITY_LIGHT_ATTENUATION(attenuation, FragData, FragData.worldPos);
        lightData.attenuation = FadeShadows(FragData, attenuation);
        switch(_LightingDirectionMode)
        {
            case 1: lightData.direction = GetForcedWorldLightDirection(); break;
            case 2: lightData.direction = GetViewLightDirection(); break;
            case 0: default: lightData.direction = GetBacklaceLightDirection(); break;
        }
        if (any(_WorldSpaceLightPos0.xyz) == 0 || _LightColor0.a < 0.01)
        {
            lightData.direction = normalize(unity_SHAr.xyz + unity_SHAg.xyz + unity_SHAb.xyz);
        }
        Surface.LightDir = lightData.direction;
        Surface.HalfDir = Unity_SafeNormalize(Surface.LightDir + Surface.ViewDir);
        switch(_LightingColorMode)
        {
            case 1: GetPoiyomiLightColor(lightData, Surface.NormalDir); break;
            case 2: GetOpenLitLightColor(lightData, Surface.NormalDir); break;
            case 3: GetStandardLightColor(lightData, Surface.NormalDir); break;
            case 4: GetMochieLightColor(lightData, Surface.NormalDir); break;
            case 0: default: GetBacklaceLightColor(lightData, Surface.NormalDir); break;
        }
    #else // UNITY_PASS_FORWARDADD
        GetForwardAddLightData(lightData);
        Surface.LightDir = lightData.direction;
        Surface.HalfDir = Unity_SafeNormalize(Surface.LightDir + Surface.ViewDir);
        switch(_LightingColorMode)
        {
            case 1: GetPoiyomiLightColor(lightData, Surface.NormalDir); break;
            case 2: GetOpenLitLightColor(lightData, Surface.NormalDir); break;
            case 3: GetStandardLightColor(lightData, Surface.NormalDir); break;
            case 4: GetMochieLightColor(lightData, Surface.NormalDir); break;
            case 0: default: GetBacklaceLightColor(lightData, Surface.NormalDir); break;
        }
    #endif

    //global modifiers for both passes
    float3 finalDirectColor = lightData.directColor;
    float3 finalIndirectColor = lightData.indirectColor;

    // light limiting
    #if defined(UNITY_PASS_FORWARDBASE)
        if (_EnableBaseLightLimit == 1)
        {
            finalDirectColor = LimitLightBrightness(finalDirectColor, _BaseLightMin, _BaseLightMax);
            finalIndirectColor = LimitLightBrightness(finalIndirectColor, _BaseLightMin, _BaseLightMax);
        }
    #else // UNITY_PASS_FORWARDADD
        if (_EnableAddLightLimit == 1)
        {
            finalDirectColor = LimitLightBrightness(finalDirectColor, _AddLightMin, _AddLightMax);
        }
    #endif // UNITY_PASS_FORWARDADD

    // greyscale lighting
    float3 combinedLight = finalDirectColor;
    if (_GreyscaleLighting != 0)
    {
        float luma = GetLuma(combinedLight);
        combinedLight = lerp(combinedLight, float3(luma, luma, luma), _GreyscaleLighting);
    }
    if (_ForceLightColor != 0)
    {
        combinedLight = lerp(combinedLight, _ForcedLightColor.rgb, _ForceLightColor);
    }

    // finalize and output
    Surface.LightColor = float4(combinedLight, lightData.attenuation);
    Surface.SpecLightColor = Surface.LightColor;
    Surface.IndirectDiffuse = finalIndirectColor;
}

#endif // BACKLACE_LIGHTING_CGINC