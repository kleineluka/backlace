#ifndef BACKLACE_LIGHTING_CGINC
#define BACKLACE_LIGHTING_CGINC

// [ ♡ ] ────────────────────── [ ♡ ]
//
//          Helper Functions!
//
// [ ♡ ] ────────────────────── [ ♡ ]

// calculate normals from normal map
void CalculateNormals(inout float3 normal, inout float3 tangent, inout float3 bitangent, float3 normalmap)
{
    float3x3 tbn = float3x3(tangent, bitangent, normal);
    normal = normalize(mul(normalmap, tbn));
    tangent = normalize(tangent - normal * dot(normal, tangent));
    bitangent = cross(normal, tangent) * unity_WorldTransformParams.w;
}

// safe normalize a half3 vector
half3 UnitySafeNormalize(half3 inVec)
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

// used in BetterSH9 for Poiyomi
float SHEvalLinearL1Geomerics(float L0, float3 L1, float3 n)
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

// from Poiyomi For Poiyomi Lighting Mode
half3 BetterSH9(half4 normal)
{
    float3 indirect;
    float3 L0 = float3(unity_SHAr.w, unity_SHAg.w, unity_SHAb.w) + float3(unity_SHBr.z, unity_SHBg.z, unity_SHBb.z) / 3.0;
    indirect.r = SHEvalLinearL1Geomerics(L0.r, unity_SHAr.xyz, normal.xyz);
    indirect.g = SHEvalLinearL1Geomerics(L0.g, unity_SHAg.xyz, normal.xyz);
    indirect.b = SHEvalLinearL1Geomerics(L0.b, unity_SHAb.xyz, normal.xyz);
    indirect = max(0, indirect);
    indirect += SHEvalLinearL2(normal);
    return indirect;
}

// from Mochie For Mochie Lighting Mode
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

// from Mochie For Mochie Lighting Mode
float3 ShadeSHNL(float3 normal)
{
    float3 indirect;
    indirect.r = NonlinearSH(unity_SHAr.w, unity_SHAr.xyz, normal);
    indirect.g = NonlinearSH(unity_SHAg.w, unity_SHAg.xyz, normal);
    indirect.b = NonlinearSH(unity_SHAb.w, unity_SHAb.xyz, normal);
    return max(0, indirect);
}

// from OpenLit For OpenLit Lighting Mode
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


// [ ♡ ] ────────────────────── [ ♡ ]
//
//     Retriievve Lighting Data
//
// [ ♡ ] ────────────────────── [ ♡ ]


// solution to get indirect lighting to apply to all light modes
float3 GetUniversalIndirectLight(BacklaceSurfaceData Surface)
{
    float3 indirectColor = float3(0, 0, 0);
    #if defined(UNITY_PASS_FORWARDBASE)
        indirectColor = float3(unity_SHAr.w, unity_SHAg.w, unity_SHAb.w);
        #if defined(LIGHTMAP_ON)
            float3 indirectBaked = Surface.Lightmap;
            #if defined(DIRLIGHTMAP_COMBINED)
                float3 combinedBaked = DecodeDirectionalLightmap(indirectBaked, Surface.LightmapDirection, Surface.NormalDir);
                float3 directBaked = combinedBaked - indirectBaked;
                indirectColor = (indirectBaked * _BakedIndirectIntensity) + (directBaked * _BakedDirectIntensity);
            #else // DIRLIGHTMAP_COMBINED
                indirectColor = indirectBaked * _BakedIndirectIntensity;
            #endif // DIRLIGHTMAP_COMBINED
        #endif // LIGHTMAP_ON
        #if defined(DYNAMICLIGHTMAP_ON)
            #if defined(DIRLIGHTMAP_COMBINED)
                indirectColor += DecodeDirectionalLightmap(Surface.DynamicLightmap, Surface.DynamicLightmapDirection, Surface.NormalDir);
            #else // DIRLIGHTMAP_COMBINED
                indirectColor += Surface.DynamicLightmap;
            #endif // DIRLIGHTMAP_COMBINED
        #endif // DYNAMICLIGHTMAP_ON
    #endif // UNITY_PASS_FORWARDBASE
    return indirectColor;
}

// easy helper for the add pass
void GetForwardAddLightData(out BacklaceLightData lightData)
{
    lightData.directColor = _LightColor0.rgb;
    lightData.indirectColor = float3(0, 0, 0);
    lightData.direction = normalize(_WorldSpaceLightPos0.xyz - FragData.worldPos.xyz * _WorldSpaceLightPos0.w);
    /*#if defined(POINT) || defined(POINT_COOKIE)
        unityShadowCoord3 lightCoord = mul(unity_WorldToLight, float4(FragData.worldPos, 1)).xyz;
        #if defined(POINT_COOKIE)
            lightData.attenuation = tex2D(_LightTextureB0, dot(lightCoord, lightCoord).rr).r;
            lightData.attenuation *= texCUBE(_LightTexture0, lightCoord).w;
        #else // POINT
            lightData.attenuation = tex2D(_LightTexture0, dot(lightCoord, lightCoord).rr).r;
        #endif // POINT_COOKIE
    #elif defined(SPOT)
        unityShadowCoord4 lightCoord = mul(unity_WorldToLight, float4(FragData.worldPos, 1));
        lightData.attenuation = (lightCoord.z > 0) * UnitySpotCookie(lightCoord) * UnitySpotAttenuate(lightCoord.xyz);
    #else // DIRECTIONAL
        UNITY_LIGHT_ATTENUATION(atten, FragData, FragData.worldPos);
        lightData.attenuation = atten;
    #endif // DIRECTIONAL
    lightData.attenuation *= UNITY_SHADOW_ATTENUATION(FragData, FragData.worldPos);*/
    UNITY_LIGHT_ATTENUATION(attenuation, FragData, FragData.worldPos);
    lightData.attenuation = attenuation;
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


// [ ♡ ] ────────────────────── [ ♡ ]
//
//          Lighting Modes
//
// [ ♡ ] ────────────────────── [ ♡ ]


// the original backlace light color function
void GetBacklaceLightColor(inout BacklaceLightData lightData, BacklaceSurfaceData Surface)
{
    #if defined(UNITY_PASS_FORWARDBASE)
        lightData.directColor = _LightColor0.rgb;
        lightData.indirectColor = GetUniversalIndirectLight(Surface);
        // lightData.directColor = lerp(GetSHLength(), lightData.directColor, .75);
        float3 ambientColor = ShadeSH9(float4(Surface.NormalDir, 1.0)); // note: upgraded from SHLength to full SH eval
        lightData.directColor = lerp(ambientColor, lightData.directColor, 0.75);
        if (any(_WorldSpaceLightPos0.xyz) == 0 || _LightColor0.a < 0.01)
        {
            #if defined(BACKLACE_TOON)
                lightData.directColor = lightData.indirectColor;
                lightData.indirectColor = 0;
            #endif // BACKLACE_TOON
        }
    #else // UNITY_PASS_FORWARDADD
        lightData.directColor = _LightColor0.rgb;
        lightData.indirectColor = 0;
    #endif
}

// From Poiyomi For Poiyomi Lighting Mode
void GetPoiyomiLightColor(inout BacklaceLightData lightData, BacklaceSurfaceData Surface)
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
        lightData.indirectColor = GetUniversalIndirectLight(Surface);
        bool lightExists = dot(_WorldSpaceLightPos0.xyz, _WorldSpaceLightPos0.xyz) > 0.000001 && _LightColor0.a > 0.01;
        #if defined(BACKLACE_TOON)
            if (!lightExists > 0)
            {
                lightData.directColor = lightData.indirectColor;
                lightData.indirectColor = 0;
            }
        #endif // BACKLACE_TOON
    #else // UNITY_PASS_FORWARDADD
        lightData.directColor = _LightColor0.rgb;
        lightData.indirectColor = 0;
    #endif
}

// From OpenLit For OpenLit Lighting Mode
void GetOpenLitLightColor(inout BacklaceLightData lightData, BacklaceSurfaceData Surface)
{
    #if defined(UNITY_PASS_FORWARDBASE)
        float3 directSH, indirectSH_OpenLit; 
        OpenLitShadeSH9ToonDouble(Surface.NormalDir, directSH, indirectSH_OpenLit);
        lightData.directColor = directSH + _LightColor0.rgb;
        lightData.indirectColor = GetUniversalIndirectLight(Surface);
        bool lightExists = any(_WorldSpaceLightPos0.xyz) && _LightColor0.a > 0.01;
        #if defined(BACKLACE_TOON)
            if (!lightExists)
            {
                lightData.directColor = lightData.indirectColor;
                lightData.indirectColor = 0;
            }
        #endif // BACKLACE_TOON
    #else // UNITY_PASS_FORWARDADD
        lightData.directColor = _LightColor0.rgb;
        lightData.indirectColor = 0;
    #endif
}
 
// naive unity light colour functions
void GetStandardLightColor(inout BacklaceLightData lightData, BacklaceSurfaceData Surface)
{
    #if defined(UNITY_PASS_FORWARDBASE)
        bool lightExists = any(_WorldSpaceLightPos0.xyz) && _LightColor0.a > 0.01;
        lightData.indirectColor = GetUniversalIndirectLight(Surface);
        if (lightExists)
        {
            lightData.directColor = _LightColor0.rgb;
        }
        else
        {
            lightData.directColor = float3(0, 0, 0);
        }
        #if defined(BACKLACE_TOON)
            if (!lightExists)
            {
                lightData.directColor = lightData.indirectColor;
                lightData.indirectColor = 0;
            }
        #endif // BACKLACE_TOON
    #else // UNITY_PASS_FORWARDADD
        lightData.directColor = _LightColor0.rgb;
        lightData.indirectColor = 0;
    #endif
}

// From Mochie For Mochie Lighting Mode
void GetMochieLightColor(inout BacklaceLightData lightData, BacklaceSurfaceData Surface)
{
    #if defined(UNITY_PASS_FORWARDBASE)
        bool lightExists = any(_WorldSpaceLightPos0.xyz);
        lightData.indirectColor = GetUniversalIndirectLight(Surface);
        if (lightExists)
        {
            lightData.directColor = _LightColor0.rgb;
        }
        else
        {
            lightData.directColor = ShadeSHNL(Surface.NormalDir);
        }
        if (!lightExists || _LightColor0.a < 0.01)
        {
            #if defined(BACKLACE_TOON)
                lightData.directColor = lightData.indirectColor;
                lightData.indirectColor = 0;
            #endif // BACKLACE_TOON
        }
    #else // UNITY_PASS_FORWARDADD
        lightData.directColor = _LightColor0.rgb;
        lightData.indirectColor = 0;
    #endif
}


// [ ♡ ] ────────────────────── [ ♡ ]
//
//          Light Directions
//
// [ ♡ ] ────────────────────── [ ♡ ]


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

// object relative light direction
float3 GetObjectLightDirection()
{
    float3 forward = normalize(unity_ObjectToWorld[2].xyz);
    float3 right = normalize(unity_ObjectToWorld[0].xyz);
    float3 up = normalize(unity_ObjectToWorld[1].xyz);
    float3 objectLightDirection = forward;
    objectLightDirection += right * _ViewDirectionOffsetX; // reusing offsets
    objectLightDirection += up * _ViewDirectionOffsetY;
    return normalize(objectLightDirection);
}

// direction based on the brightest point of the spherical harmonics
float3 GetAmbientLightDirection()
{
    float3 ambientDir = unity_SHAr.xyz + unity_SHAg.xyz + unity_SHAb.xyz;
    float len = length(ambientDir);
    return len > 0.001 ? normalize(ambientDir) : float3(0, 1, 0);
}


// [ ♡ ] ────────────────────── [ ♡ ]
//
//       Main Light Function
//
// [ ♡ ] ────────────────────── [ ♡ ]


// get light data
void GetLightData(inout BacklaceSurfaceData Surface)
{
    // get direction vectors
    CalculateNormals(Surface.NormalDir, Surface.TangentDir, Surface.BitangentDir, NormalMap);
    Surface.ReflectDir = reflect(-Surface.ViewDir, Surface.NormalDir);
    // start calculating the light data
    BacklaceLightData lightData;
    #if defined(UNITY_PASS_FORWARDBASE)
        // static lightmap
        #if defined(LIGHTMAP_ON)
            Surface.Lightmap = DecodeLightmap(UNITY_SAMPLE_TEX2D(unity_Lightmap, FragData.lightmapUV));
            Surface.Lightmap = max(Surface.Lightmap, 0);
            #if defined(DIRLIGHTMAP_COMBINED)
                Surface.LightmapDirection = UNITY_SAMPLE_TEX2D_SAMPLER(unity_LightmapInd, unity_Lightmap, FragData.lightmapUV);
            #else // DIRLIGHTMAP_COMBINED
                Surface.LightmapDirection = float4(0, 0, 0, 0);
            #endif // DIRLIGHTMAP_COMBINED
        #else // LIGHTMAP_ON
            Surface.Lightmap = float3(0, 0, 0);
            Surface.LightmapDirection = float4(0, 0, 0, 0);
        #endif // LIGHTMAP_ON
        // dynamic lightmap
        #if defined(DYNAMICLIGHTMAP_ON)
            Surface.DynamicLightmap = DecodeRealtimeLightmap(UNITY_SAMPLE_TEX2D(unity_DynamicLightmap, FragData.dynamicLightmapUV));
            Surface.DynamicLightmap = max(Surface.DynamicLightmap, 0);
            #if defined(DIRLIGHTMAP_COMBINED)
                Surface.DynamicLightmapDirection = UNITY_SAMPLE_TEX2D_SAMPLER(unity_DynamicDirectionality, unity_DynamicLightmap, FragData.dynamicLightmapUV);
            #else // DIRLIGHTMAP_COMBINED
                Surface.DynamicLightmapDirection = float4(0, 0, 0, 0);
            #endif // DIRLIGHTMAP_COMBINED
        #else
            Surface.DynamicLightmap = float3(0, 0, 0);
            Surface.DynamicLightmapDirection = float4(0, 0, 0, 0);
        #endif // DYNAMICLIGHTMAP_ON
        UNITY_LIGHT_ATTENUATION(attenuation, FragData, FragData.worldPos);
        lightData.attenuation = FadeShadows(FragData, attenuation);
        switch(_LightingDirectionMode)
        {
            case 1: lightData.direction = GetForcedWorldLightDirection(); break;
            case 2: lightData.direction = GetViewLightDirection(); break;
            case 3: lightData.direction = GetObjectLightDirection(); break;
            case 4: lightData.direction = GetAmbientLightDirection(); break;
            case 0: default: lightData.direction = GetBacklaceLightDirection(); break;
        }
        if (any(_WorldSpaceLightPos0.xyz) == 0 || _LightColor0.a < 0.01)
        {
            float3 ambientDir = unity_SHAr.xyz + unity_SHAg.xyz + unity_SHAb.xyz;
            float len = length(ambientDir);
            if (len > 0.001) // safe fallback for pitch black ambient
            {
                lightData.direction = normalize(ambientDir);
            }
            else
            {
                lightData.direction = float3(0, 1, 0);
            }
        }
        Surface.LightDir = lightData.direction;
        Surface.HalfDir = UnitySafeNormalize(Surface.LightDir + Surface.ViewDir);
        switch(_LightingColorMode)
        {
            case 1: GetPoiyomiLightColor(lightData, Surface); break;
            case 2: GetOpenLitLightColor(lightData, Surface); break;
            case 3: GetStandardLightColor(lightData, Surface); break;
            case 4: GetMochieLightColor(lightData, Surface); break;
            case 0: default: GetBacklaceLightColor(lightData, Surface); break;
        }
    #else // UNITY_PASS_FORWARDADD
        GetForwardAddLightData(lightData);
        Surface.LightDir = lightData.direction;
        Surface.HalfDir = UnitySafeNormalize(Surface.LightDir + Surface.ViewDir);
        switch(_LightingColorMode)
        {
            case 1: GetPoiyomiLightColor(lightData, Surface); break;
            case 2: GetOpenLitLightColor(lightData, Surface); break;
            case 3: GetStandardLightColor(lightData, Surface); break;
            case 4: GetMochieLightColor(lightData, Surface); break;
            case 0: default: GetBacklaceLightColor(lightData, Surface); break;
        }
    #endif // UNITY_PASS_FORWARDBASE
    //global modifiers for both passes
    float3 finalDirectColor = lightData.directColor;
    float3 finalIndirectColor = lightData.indirectColor;
    // light limiting
    #if defined(UNITY_PASS_FORWARDBASE)
        finalDirectColor *= _DirectIntensity;
        finalIndirectColor *= _IndirectIntensity;
        if (_EnableBaseLightLimit == 1)
        {
            finalDirectColor = LimitLightBrightness(finalDirectColor, _BaseLightMin, _BaseLightMax);
            finalIndirectColor = LimitLightBrightness(finalIndirectColor, _BaseLightMin, _BaseLightMax);
        }
    #else // UNITY_PASS_FORWARDADD
        finalDirectColor *= _AdditiveIntensity;
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
    // finalize the light colours
    Surface.LightColor = float4(combinedLight, lightData.attenuation);
    Surface.SpecLightColor = Surface.LightColor;
    Surface.IndirectDiffuse = finalIndirectColor;
    // prepare dot products
    Surface.UnmaxedNdotL = dot(Surface.NormalDir, Surface.LightDir);
    Surface.UnmaxedNdotL = min(Surface.UnmaxedNdotL, Surface.LightColor.a);
    #if defined(_BACKLACE_SHADOW_MAP)
        float shadowMask = UNITY_SAMPLE_TEX2D_SAMPLER(_ShadowMap, _MainTex, Uvs[_ShadowMap_UV]).r;
        Surface.UnmaxedNdotL -= (shadowMask * _ShadowMapIntensity);
    #endif // _BACKLACE_SHADOW_MAP
    Surface.NdotL = max(Surface.UnmaxedNdotL, 0);
    Surface.NdotV = abs(dot(Surface.NormalDir, Surface.ViewDir));
    Surface.NdotH = max(dot(Surface.NormalDir, Surface.HalfDir), 0);
    Surface.LdotH = max(dot(Surface.LightDir, Surface.HalfDir), 0);
}
#endif // BACKLACE_LIGHTING_CGINC