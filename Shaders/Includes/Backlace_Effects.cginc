#ifndef BACKLACE_EFFECTS_CGINC
#define BACKLACE_EFFECTS_CGINC

// forward passes only features
#if defined(UNITY_PASS_FORWARDBASE) || defined(UNITY_PASS_FORWARDADD)
    #if defined(_BACKLACE_DISSOLVE)
        // properties for dissolve are in Backlace_Properties.cginc (for alpha in other passes)
        void ApplyDissolve(inout BacklaceSurfaceData Surface, FragmentData i)
        {
            float dissolveMapValue = GetDissolveMapValue(i.worldPos, i.vertex.xyz, Surface.NormalDir);
            float halfWidth = max(_DissolveEdgeWidth, 0.0001) * 0.5;
            if (_DissolveEdgeMode == 0) // glow
            {
                float fadeIn = smoothstep(0.0, halfWidth, _DissolveProgress);
                float fadeOut = 1.0 - smoothstep(1.0 - halfWidth, 1.0, _DissolveProgress);
                float masterIntensity = fadeIn * fadeOut;
                float distanceFromLine = abs(dissolveMapValue - _DissolveProgress);
                float baseGradient = 1.0 - smoothstep(0, halfWidth, distanceFromLine);
                float hardnessPower = lerp(1.0, 16.0, _DissolveEdgeSharpness);
                float edgeGlow = pow(baseGradient, hardnessPower);
                edgeGlow *= masterIntensity;
                float surfaceAlpha = step(_DissolveProgress, dissolveMapValue);
                Surface.FinalColor.rgb += _DissolveEdgeColor.rgb * edgeGlow * _DissolveEdgeColor.a;
                Surface.FinalColor.a = max(surfaceAlpha, edgeGlow * _DissolveEdgeColor.a);
            }
            else // smooth fade
            {
                float startEdge = _DissolveProgress - halfWidth;
                float endEdge = _DissolveProgress + halfWidth;
                float alpha = saturate(smoothstep(startEdge, endEdge, dissolveMapValue));
                Surface.FinalColor.a = alpha;
            }
        }
    #endif // _BACKLACE_DISSOLVE
#endif // UNITY_PASS_FORWARDBASE || UNITY_PASS_FORWARDADD

// post-processing features
#if defined(_BACKLACE_POST_PROCESSING)
    UNITY_DECLARE_TEX2D(_ColorGradingLUT);
    float4 _RGBColor;
    float _RGBBlendMode;
    float _HSVMode;
    float _HSVHue;
    float _HSVSaturation;
    float _HSVValue;
    float _ToggleHueShift;
    float _HueShift;
    float _ToggleAutoCycle;
    float _AutoCycleSpeed;
    float _ColorGradingIntensity;
    float _BlackAndWhite;
    float _Brightness;

    void ApplyPostProcessing(inout BacklaceSurfaceData Surface, FragmentData i)
    {
        float3 finalColor = Surface.FinalColor.rgb;
        // rgb tint/replace
        float3 tintedColor = lerp(finalColor * _RGBColor.rgb, _RGBColor.rgb, _RGBBlendMode);
        finalColor = tintedColor;
        // hsv manipulation
        float3 hsv = RGBtoHSV(finalColor);
        [branch] if (_HSVMode == 1) // additive
        {
            hsv.x = frac(hsv.x + _HSVHue);
            hsv.y += _HSVSaturation - 1.0;
            hsv.z += _HSVValue - 1.0;
        }
        else if (_HSVMode == 2) // multiplicative
        {
            hsv.x = frac(hsv.x + _HSVHue);
            hsv.y *= _HSVSaturation;
            hsv.z *= _HSVValue;
        }
        finalColor = HSVtoRGB(saturate(hsv));
        // hue shift/cycle
        [branch] if (_ToggleHueShift > 0)
        {
            #if defined(_BACKLACE_AUDIOLINK)
                finalColor = ApplyHueShift(finalColor, _HueShift + i.alChannel1.z, _ToggleAutoCycle, _AutoCycleSpeed);
            #else // _BACKLACE_AUDIOLINK
                finalColor = ApplyHueShift(finalColor, _HueShift, _ToggleAutoCycle, _AutoCycleSpeed);
            #endif // _BACKLACE_AUDIOLINK
        }
        // colour grading
        [branch] if (_ColorGradingIntensity > 0)
        {
            float3 gradedColor = UNITY_SAMPLE_TEX2D(_ColorGradingLUT, finalColor.rg).rgb;
            finalColor = lerp(finalColor, gradedColor, _ColorGradingIntensity);
        }
        // black and white
        [branch] if (_BlackAndWhite > 0)
        {
            float luma = GetLuma(finalColor);
            finalColor = lerp(finalColor, float3(luma, luma, luma), _BlackAndWhite);
        }
        // brightness
        finalColor *= _Brightness;
        Surface.FinalColor.rgb = finalColor;
    }
#endif // _BACKLACE_POST_PROCESSING

// detail maps features
#if defined(_BACKLACE_DETAIL)
    UNITY_DECLARE_TEX2D(_DetailAlbedoMap);
    UNITY_DECLARE_TEX2D(_DetailNormalMap);
    float _DetailMap_UV;
    float _DetailTiling;
    float _DetailNormalStrength;

    void ApplyDetailMaps(inout BacklaceSurfaceData Surface)
    {
        float2 detailUV = Uvs[_DetailMap_UV] * _DetailTiling;
        float4 detailAlbedo = UNITY_SAMPLE_TEX2D(_DetailAlbedoMap, detailUV);
        Surface.Albedo.rgb *= detailAlbedo.rgb * 2 * detailAlbedo.a;
        float3 detailNormalTS = UnpackScaleNormal(UNITY_SAMPLE_TEX2D(_DetailNormalMap, detailUV), _DetailNormalStrength);
        float3 baseNormalTS = NormalMap;
        NormalMap = normalize(float3(baseNormalTS.xy + detailNormalTS.xy, baseNormalTS.z * detailNormalTS.z));
    }
#endif // _BACKLACE_DETAIL

// subsurface scattering features
#if defined(_BACKLACE_SSS)
    float _ThicknessMap_UV;
    float4 _SSSColor;
    float _SSSStrength;
    float _SSSPower;
    float _SSSDistortion;
    UNITY_DECLARE_TEX2D(_SSSThicknessMap);
    float _SSSThickness;

    void ApplySubsurfaceScattering(inout BacklaceSurfaceData Surface)
    {
        float thickness = UNITY_SAMPLE_TEX2D(_SSSThicknessMap, Uvs[_ThicknessMap_UV]).r * _SSSThickness;
        float3 scatterDir = normalize(Surface.LightDir + Surface.NormalDir * _SSSDistortion);
        float scatterDot = dot(Surface.ViewDir, -scatterDir);
        scatterDot = saturate(scatterDot);
        float scatterFalloff = pow(scatterDot, _SSSPower);
        float3 sss = Surface.LightColor.rgb * _SSSColor.rgb * scatterFalloff * _SSSStrength * thickness;
        Surface.Diffuse += sss;
    }
#endif // _BACKLACE_SSS

// parallax features
#if defined(_BACKLACE_PARALLAX)
    // shared across multiple modes
    UNITY_DECLARE_TEX2D(_ParallaxMap);
    float _ParallaxMap_UV;
    float _ParallaxStrength;
    int _ParallaxMode;
    float _ParallaxSteps;
    int _ParallaxBlend;
    float _ParallaxBlendWeight;
    // interior mapping
    samplerCUBE _InteriorCubemap;
    float4 _InteriorColor;
    float _InteriorTiling;
    // layered mapping
    UNITY_DECLARE_TEX2D(_ParallaxLayer1);
    UNITY_DECLARE_TEX2D(_ParallaxLayer2);
    UNITY_DECLARE_TEX2D(_ParallaxLayer3);
    float _ParallaxLayerDepth1;
    float _ParallaxLayerDepth2;
    float _ParallaxLayerDepth3;
    int _ParallaxStack;
    int _ParallaxTile;

    void ApplyParallax_Fast(inout float2 uv, in BacklaceSurfaceData Surface)
    {
        float height = UNITY_SAMPLE_TEX2D(_ParallaxMap, uv).r;
        float3 viewDirTS = float3(dot(Surface.ViewDir, Surface.TangentDir), dot(Surface.ViewDir, Surface.BitangentDir), 0);
        float2 offset = viewDirTS.xy * (height * _ParallaxStrength);
        uv -= offset;
    }
    
    void ApplyParallax_Fancy(inout float2 uv, inout BacklaceSurfaceData Surface)
    {
        float3 viewDirTS = float3(dot(Surface.ViewDir, Surface.TangentDir), dot(Surface.ViewDir, Surface.BitangentDir), dot(Surface.ViewDir, Surface.NormalDir));
        float numSteps = _ParallaxSteps;
        float stepSize = 1.0 / numSteps;
        float2 step = -viewDirTS.xy * _ParallaxStrength * stepSize;
        float currentHeight = 1.0;
        float2 currentUVOffset = 0;
        float surfaceHeight = 1.0;
        [loop] for (int i = 0; i < numSteps; i++)
        {
            currentHeight -= stepSize;
            currentUVOffset += step;
            surfaceHeight = _ParallaxMap.SampleLevel(sampler_ParallaxMap, uv + currentUVOffset, 0).r;
            if (surfaceHeight > currentHeight)
            {
                currentUVOffset -= step;
                currentHeight += stepSize;
                float prevSurfaceHeight = _ParallaxMap.SampleLevel(sampler_ParallaxMap, uv + currentUVOffset, 0).r;
                float distanceToSurface = currentHeight - surfaceHeight;
                float distanceBetweenSamples = surfaceHeight - prevSurfaceHeight;
                currentUVOffset += step * (distanceToSurface / max(distanceBetweenSamples, 0.001));
                uv += currentUVOffset;
                surfaceHeight = _ParallaxMap.SampleLevel(sampler_ParallaxMap, uv, 0).r;
                break;
            }
        }
    }

    float3 GetViewTangent(in BacklaceSurfaceData Surface)
    {
        // helper shared between interior and layered mapping
        float3 viewDirTS = float3(
            dot(Surface.ViewDir, Surface.TangentDir),
            dot(Surface.ViewDir, Surface.BitangentDir),
            dot(Surface.ViewDir, Surface.NormalDir)
        );
        return normalize(viewDirTS);
    }

    void ApplyParallax_Interior(inout BacklaceSurfaceData Surface, FragmentData i)
    {
        // calculate view direction in tangent space
        float3 viewDirTS = GetViewTangent(Surface);
        // get uvs
        float2 uv = Uvs[_ParallaxMap_UV] * _InteriorTiling;
        float2 roomUV = frac(uv);
        // trace ray into cubemap
        float3 rayPos = float3(roomUV * 2.0 - 1.0, 1.0);
        float3 rayDir = -viewDirTS;
        rayDir.z /= max(_ParallaxStrength, 0.001);
        // find intersection with box
        float3 id = 1.0 / rayDir;
        float3 k = abs(id) - rayPos * id;
        float kMin = min(min(k.x, k.y), k.z);
        float3 hitPos = rayPos + kMin * rayDir;
        // sample cubemap
        float4 roomSample = texCUBE(_InteriorCubemap, hitPos);
        float3 roomColor = roomSample.rgb * _InteriorColor.rgb;
        // apply
        switch(_ParallaxBlend)
        {
            case 0: // additive
                roomColor += Surface.Albedo.rgb;
                break;
            case 1: // multiply
                roomColor *= Surface.Albedo.rgb;
                break;
            case 2: // alpha blend
                roomColor = lerp(Surface.Albedo.rgb, roomColor, _InteriorColor.a);
                break;
            default: // replace
                // do nothing
                break;
        }
        Surface.Albedo.rgb = lerp(Surface.Albedo.rgb, roomColor, _ParallaxBlendWeight);
    }

    void ApplyParallax_Layered(inout BacklaceSurfaceData Surface, FragmentData i)
    {
        // calculate view direction in tangent space
        float3 viewDirTS = GetViewTangent(Surface);
        float2 uv = Uvs[_ParallaxMap_UV];
        // create mask and calculate all the parallax offsets
        float4 mask = UNITY_SAMPLE_TEX2D(_ParallaxMap, uv);
        float2 offset1 = viewDirTS.xy * _ParallaxLayerDepth1 * _ParallaxStrength;
        float2 offset2 = viewDirTS.xy * _ParallaxLayerDepth2 * _ParallaxStrength;
        float2 offset3 = viewDirTS.xy * _ParallaxLayerDepth3 * _ParallaxStrength;
        float2 uv1 = uv + offset1;
        float2 uv2 = uv + offset2;
        float2 uv3 = uv + offset3;
        // sample layers based on tile mode
        float4 layer1 = 0;
        float4 layer2 = 0;
        float4 layer3 = 0;
        if (_ParallaxTile == 0) {  
            // dont tile
            layer1 = UNITY_SAMPLE_TEX2D(_ParallaxLayer1, uv1);
            layer2 = UNITY_SAMPLE_TEX2D(_ParallaxLayer2, uv2);
            layer3 = UNITY_SAMPLE_TEX2D(_ParallaxLayer3, uv3);
            if (_ParallaxTile == 0 && (any(uv1 < 0) || any(uv1 > 1))) layer1 = 0;
            if (_ParallaxTile == 0 && (any(uv2 < 0) || any(uv2 > 1))) layer2 = 0;
            if (_ParallaxTile == 0 && (any(uv3 < 0) || any(uv3 > 1))) layer3 = 0;
        } else {
            // tile uv
            uv1 = frac(uv1);
            uv2 = frac(uv2);
            uv3 = frac(uv3);
            layer1 = UNITY_SAMPLE_TEX2D(_ParallaxLayer1, uv1);
            layer2 = UNITY_SAMPLE_TEX2D(_ParallaxLayer2, uv2);
            layer3 = UNITY_SAMPLE_TEX2D(_ParallaxLayer3, uv3);
        }
        // stacking modes
        float3 finalLayerColor = 0;
        switch (_ParallaxStack) {
            case 0:
                // top to bottom
                finalLayerColor = layer3.rgb * layer3.a * mask.b;
                finalLayerColor = lerp(finalLayerColor, layer2.rgb, layer2.a * mask.g);
                finalLayerColor = lerp(finalLayerColor, layer1.rgb, layer1.a * mask.r);
                break;
            case 1:
                // bottom to top
                finalLayerColor = layer1.rgb * layer1.a * mask.r;
                finalLayerColor = lerp(finalLayerColor, layer2.rgb, layer2.a * mask.g);
                finalLayerColor = lerp(finalLayerColor, layer3.rgb, layer3.a * mask.b);
                break;
            case 2:
                // additive
                finalLayerColor += layer1.rgb * mask.r * layer1.a;
                finalLayerColor += layer2.rgb * mask.g * layer2.a;
                finalLayerColor += layer3.rgb * mask.b * layer3.a;
                break;
            default:
                // average
                finalLayerColor += layer1.rgb * mask.r * layer1.a;
                finalLayerColor += layer2.rgb * mask.g * layer2.a;
                finalLayerColor += layer3.rgb * mask.b * layer3.a;
                finalLayerColor /= 3;
                break;
        }
        // apply
        switch(_ParallaxBlend)
        {
            case 0: // additive
                finalLayerColor += Surface.Albedo.rgb;
                break;
            case 1: // multiply
                finalLayerColor *= Surface.Albedo.rgb;
                break;
            case 2: // alpha blend
                finalLayerColor = lerp(Surface.Albedo.rgb, finalLayerColor, mask.a);
                break;
            default: // replace
                // do nothing
                break;
        }
        Surface.Albedo.rgb = lerp(Surface.Albedo.rgb, finalLayerColor, _ParallaxBlendWeight);
    }
#endif // _BACKLACE_PARALLAX

// cubemap features
#if defined(_BACKLACE_CUBEMAP)
    samplerCUBE _CubemapTex;
    float4 _CubemapTint;
    float _CubemapIntensity;
    int _CubemapBlendMode;

    void ApplyCubemap(inout BacklaceSurfaceData Surface)
    {
        float3 cubemapColor = texCUBE(_CubemapTex, Surface.ReflectDir).rgb * _CubemapTint.rgb;
        float intensity = _CubemapIntensity;
        switch(_CubemapBlendMode)
        {
            case 0: // additive
                Surface.FinalColor.rgb += cubemapColor * intensity;
                break;
            case 1: // multiply
                Surface.FinalColor.rgb = lerp(Surface.FinalColor.rgb, Surface.FinalColor.rgb * cubemapColor, intensity);
                break;
            case 2: // replace
                Surface.FinalColor.rgb = lerp(Surface.FinalColor.rgb, cubemapColor, intensity);
                break;
        }
    }
#endif // _BACKLACE_CUBEMAP

// matcap features
#if defined(_BACKLACE_MATCAP)
    UNITY_DECLARE_TEX2D(_MatcapTex);
    UNITY_DECLARE_TEX2D(_MatcapMask);
    float4 _MatcapTex_ST;
    float _MatcapIntensity;
    float3 _MatcapTint;
    float _MatcapSmoothnessEnabled;
    float _MatcapSmoothness;
    float _MatcapMask_UV;
    int _MatcapBlendMode;

    void ApplyMatcap(inout BacklaceSurfaceData Surface, FragmentData i)
    {
        float3 matcapColor;
        [branch] if (_MatcapSmoothnessEnabled == 1) 
        {
            // use smoothness to sample a mip level
            float mipLevel = _MatcapSmoothness * 10.0;
            matcapColor = UNITY_SAMPLE_TEX2D_LOD(_MatcapTex, i.matcapUV, mipLevel).rgb;
        }
        else
        {
            matcapColor = UNITY_SAMPLE_TEX2D(_MatcapTex, i.matcapUV).rgb;
        }
        matcapColor *= _MatcapTint.rgb;
        float mask = UNITY_SAMPLE_TEX2D(_MatcapMask, Uvs[_MatcapMask_UV]).r;
        float finalMatcapIntensity = _MatcapIntensity;
        #if defined(_BACKLACE_AUDIOLINK)
            finalMatcapIntensity *= i.alChannel1.w;
        #endif // _BACKLACE_AUDIOLINK
        float3 finalMatcap = matcapColor * finalMatcapIntensity * mask;
        switch(_MatcapBlendMode)
        {
            case 0: // additive
                Surface.FinalColor.rgb += finalMatcap;
                break;
            case 1: // multiply
                Surface.FinalColor.rgb = lerp(Surface.FinalColor.rgb, Surface.FinalColor.rgb * matcapColor, mask * _MatcapIntensity);
                break;
            case 2: // replace
                Surface.FinalColor.rgb = lerp(Surface.FinalColor.rgb, matcapColor * _MatcapIntensity, mask);
                break;
        }
    }
#endif // _BACKLACE_MATCAP

// rim features
#if defined(_BACKLACE_RIMLIGHT)
    float3 Rimlight;
    float4 _RimColor;
    float _RimWidth;
    float _RimIntensity;
    float _RimLightBased;
    
    void CalculateRimlight(inout BacklaceSurfaceData Surface)
    {
        float fresnel = 1 - saturate(dot(Surface.NormalDir, Surface.ViewDir));
        fresnel = pow(fresnel, _RimWidth);
        [branch] if (_RimLightBased > 0)
        {
            fresnel *= Surface.NdotL;
        }
        Rimlight = fresnel * _RimColor.rgb * _RimIntensity;
    }
#endif // _BACKLACE_RIMLIGHT

// clearcoat features
#if defined(_BACKLACE_CLEARCOAT)
    UNITY_DECLARE_TEX2D(_ClearcoatMap);
    float4 _ClearcoatMap_ST;
    float _ClearcoatStrength;
    float _ClearcoatRoughness;
    float _ClearcoatReflectionStrength;
    float _ClearcoatMap_UV;
    float4 _ClearcoatColor;

    void CalculateClearcoat(inout BacklaceSurfaceData Surface, out float3 highlight, out float3 occlusion)
    {
        float4 clearcoatMap = UNITY_SAMPLE_TEX2D(_ClearcoatMap, Uvs[_ClearcoatMap_UV]);
        float mask = _ClearcoatStrength * clearcoatMap.r;
        float roughness = _ClearcoatRoughness * clearcoatMap.g;
        float3 F0 = lerp(0.04, 1.0, _ClearcoatReflectionStrength);
        float3 fresnel = FresnelTerm(F0, Surface.LdotH);
        float squareRoughness = max(roughness * roughness, 0.002);
        float distribution = GTR2(Surface.NdotH, squareRoughness);
        float geometry = smithG_GGX(Surface.NdotL, squareRoughness) * smithG_GGX(Surface.NdotV, squareRoughness);
        float3 clearcoatSpec = fresnel * distribution * geometry;
        highlight = clearcoatSpec * lerp(Surface.LightColor.rgb, Surface.LightColor.rgb * _ClearcoatColor.rgb, _ClearcoatColor.a) * mask;
        float3 occlusionTint = lerp(1.0, _ClearcoatColor.rgb, fresnel);
        occlusion = lerp(1.0, occlusionTint, mask);
    }

    #if defined(_BACKLACE_VERTEX_SPECULAR) && defined(VERTEXLIGHT_ON)
        void AddClearcoatVertex(inout BacklaceSurfaceData Surface)
        {
            float3 VLightDir = normalize(VertexLightDir);
            if (dot(VLightDir, VLightDir) < 0.01) return;
            float3 F0 = lerp(0.04, 1.0, _ClearcoatReflectionStrength);
            float3 fresnel = FresnelTerm(F0, saturate(dot(normalize(VLightDir + Surface.ViewDir), VLightDir)));
            float roughness = _ClearcoatRoughness; // no map for this to keep it simple
            float squareRoughness = max(roughness * roughness, 0.002);
            float distribution = GTR2(saturate(dot(Surface.NormalDir, normalize(VLightDir + Surface.ViewDir))), squareRoughness);
            float geometry = smithG_GGX(saturate(dot(Surface.NormalDir, VLightDir)), squareRoughness) * smithG_GGX(Surface.NdotV, squareRoughness);
            float3 clearcoatV_Spec = fresnel * distribution * geometry;
            Surface.FinalColor.rgb += clearcoatV_Spec * Surface.VertexDirectDiffuse * _ClearcoatColor.rgb * _ClearcoatStrength;
        }
    #endif // _BACKLACE_VERTEX_SPECULAR && VERTEXLIGHT_ON
#endif // _BACKLACE_CLEARCOAT

// screen space rim feature
#if defined(_BACKLACE_DEPTH_RIMLIGHT) 
    #ifndef BACKLACE_DEPTH
        UNITY_DECLARE_DEPTH_TEXTURE(_CameraDepthTexture);
        float4 _CameraDepthTexture_TexelSize;
        #define BACKLACE_DEPTH
    #endif // BACKLACE_DEPTH
    float4 _DepthRimColor;
    float _DepthRimWidth;
    float _DepthRimThreshold;
    float _DepthRimSharpness;
    int _DepthRimBlendMode;

    // sobel point array
    static const int2 sobelPoints[9] = {
        int2(-1, -1), int2(0, -1), int2(1, -1),
        int2(-1,  0), int2(0,  0), int2(1,  0),
        int2(-1,  1), int2(0,  1), int2(1,  1)
    };

    // logic to keep rim consistent regardless of camera distance / depth
    float ScaleRimWidth(float z) {
        float scale = 1.0 / z;
        return _DepthRimWidth * 50.0 / _ScreenParams.y * scale;
    }

    void ApplyDepthRim(inout BacklaceSurfaceData Surface, FragmentData i)
    {
        float sceneDepthRaw = tex2D(_CameraDepthTexture, float2(i.scrPos.xy / i.scrPos.w)).r;
        float sceneDepthLinear = LinearEyeDepth(sceneDepthRaw);
        float modelDepthLinear = i.scrPos.w;;
        float depthStatus = 0;
        [unroll(9)]
        for (int idx = 0; idx < 9; idx++)
        {
            float2 offset = sobelPoints[idx] * ScaleRimWidth(modelDepthLinear);
            float sampleDepthRaw = tex2D(_CameraDepthTexture, float2(i.scrPos.xy / i.scrPos.w) + offset).r;
            float sampleDepthLinear = LinearEyeDepth(sampleDepthRaw);
            depthStatus += step(modelDepthLinear + _DepthRimThreshold, sampleDepthLinear);
        }
        float edgeFactor = depthStatus / 9.0;
        edgeFactor = pow(edgeFactor, _DepthRimSharpness);
        float rimIntensity = edgeFactor * _DepthRimColor.a;
        switch(_DepthRimBlendMode)
        {
            case 0: // additive
                Surface.FinalColor.rgb += _DepthRimColor.rgb * rimIntensity;
                break;
            case 1: // replace
                Surface.FinalColor.rgb = lerp(Surface.FinalColor.rgb, _DepthRimColor.rgb, rimIntensity);
                break;
            default: // multiply (case 2)
                Surface.FinalColor.rgb = lerp(Surface.FinalColor.rgb, Surface.FinalColor.rgb * _DepthRimColor.rgb, rimIntensity);
                break;
        }
    }
#endif // _BACKLACE_DEPTH_RIMLIGHT

// pathing feature
#if defined(_BACKLACE_PATHING)
    UNITY_DECLARE_TEX2D(_PathingMap);
    float2 _PathingMap_ST;
    float4 _PathingColor;
    float _PathingEmission;
    int _PathingType;
    float _PathingSpeed;
    float _PathingWidth;
    float _PathingSoftness;
    float _PathingOffset;
    float _PathingMap_UV;
    float _PathingScale;
    int _PathingBlendMode;
    int _PathingMappingMode;
    int _PathingColorMode;
    float4 _PathingColor2;
    UNITY_DECLARE_TEX2D(_PathingTexture);
    float _PathingTexture_UV;
    float _PathingStart;
    float _PathingEnd;

    void ApplyPathing(inout BacklaceSurfaceData Surface, FragmentData i)
    {
        float pathValue;
        if (_PathingMappingMode == 0) // albedo uv

        {
            pathValue = UNITY_SAMPLE_TEX2D(_PathingMap, frac(Uvs[_PathingMap_UV] * _PathingScale)).r;
        }
        else // triplanar

        {
            pathValue = SampleTextureTriplanar(
                _PathingMap, sampler_PathingMap,
                FragData.worldPos, Surface.NormalDir,
                float3(0, 0, 0), _PathingScale, float3(0, 0, 0),
                2.0, true, float2(0, 0)
            ).r;
        }
        float pathTime = frac(_Time.y * _PathingSpeed + _PathingOffset);
        pathTime = lerp(_PathingStart, _PathingEnd, pathTime);
        float pathAlpha = 0;
        switch(_PathingType)
        {
            case 1: // path
                pathAlpha = 1.0 - saturate(abs(pathTime - pathValue) / _PathingWidth);
                break;
            case 2: // loop
                float loop_dist = abs(pathTime - pathValue);
                loop_dist = min(loop_dist, 1.0 - loop_dist);
                pathAlpha = 1.0 - saturate(loop_dist / _PathingWidth);
                break;
            case 3: // ping-pong
                pathTime = 1.0 - abs(1.0 - 2.0 *  frac(_Time.y * _PathingSpeed + _PathingOffset)); // goes from 0 -> 1 -> 0
                pathTime = lerp(_PathingStart, _PathingEnd, pathTime);  
                pathAlpha = 1.0 - saturate(abs(pathTime - pathValue) / _PathingWidth);
                break;
            case 4: // trail
                float trail_dist = pathTime - pathValue;
                pathAlpha = smoothstep(0, _PathingWidth, trail_dist) - smoothstep(_PathingWidth, _PathingWidth + 0.001, trail_dist);
                break;
            case 5: // converge
                float convergeTime = abs(1.0 - 2.0 * pathTime); // 1 -> 0 -> 1
                float convergeDist = abs(convergeTime - (abs(1.0 - 2.0 * pathValue)));
                pathAlpha = 1.0 - saturate(convergeDist / _PathingWidth);
                break;
            default: // fill (0)
                pathAlpha = pathTime > pathValue;
                break;
        }
        pathAlpha = smoothstep(0, _PathingSoftness, pathAlpha);
        #if defined(_BACKLACE_AUDIOLINK)
            pathAlpha *= i.alChannel2.x;
        #endif // _BACKLACE_AUDIOLINK
        if (pathAlpha <= 0.001) return;
        //float3 pathEmission = pathAlpha * _PathingColor.rgb * _PathingEmission;
        float3 pathEmission = pathAlpha * _PathingEmission;
        float pathBlend = _PathingColor.a;
        switch(_PathingColorMode)
        {
            case 1: // texture
                float4 pathSample = UNITY_SAMPLE_TEX2D(_PathingTexture, Uvs[_PathingTexture_UV]);
                pathEmission *= pathSample.rgb;
                pathBlend = pathSample.a;
                break;
            case 2: // gradient (two colours)
                float4 pathGradinet = lerp(_PathingColor, _PathingColor2, pathValue);
                pathEmission *= pathGradinet.rgb;
                pathBlend = pathGradinet.a;
                break;
            default: // single colour
                pathEmission *= _PathingColor.rgb;
                break;
        }
        switch(_PathingBlendMode)
        {
            case 0: // additive
                Surface.FinalColor.rgb += pathEmission;
                break;
            case 1: // multiply
                Surface.FinalColor.rgb = lerp(Surface.FinalColor.rgb, Surface.FinalColor.rgb * pathEmission.rgb, pathAlpha);
                break;
            case 2: // alpha blend
                float blendIntensity = pathAlpha * pathBlend;
                Surface.FinalColor.rgb = lerp(Surface.FinalColor.rgb, pathEmission.rgb, blendIntensity);
            break;
        }
    }
#endif // _BACKLACE_PATHING

// glitter-specific features
#if defined(_BACKLACE_GLITTER)
    // glitter properties
    UNITY_DECLARE_TEX2D(_GlitterMask);
    UNITY_DECLARE_TEX2D(_GlitterNoiseTex);
    float _Glitter_UV;
    float _GlitterMask_UV;
    float _ToggleGlitterRainbow;
    float _GlitterMode;
    float4 _GlitterTint;
    float _GlitterFrequency;
    float _GlitterThreshold;
    float _GlitterSize;
    float _GlitterFlickerSpeed;
    float _GlitterBrightness;
    float _GlitterContrast;
    float _GlitterRainbowSpeed;
    
    // glitter with either a voronoi pattern or a noise texture
    void ApplyGlitter(inout BacklaceSurfaceData Surface)
    {
        float3 final_glitter = 0;
        float unique_flake_id = 0;
        float glitter_mask = 0;
        float2 uv = Uvs[_Glitter_UV] * _GlitterFrequency;
        float2 i_uv = floor(uv);
        float2 f_uv = frac(uv);
        [branch] if (_GlitterMode == 0) // PROCEDURAL - is this really needed?
        {
            float min_dist = 1.0;
            float2 closest_point_id = 0;
            for (int y = -1; y <= 1; y++)
            {
                for (int x = -1; x <= 1; x++)
                {
                    float2 neighbor_offset = float2(x, y);
                    float2 point_pos = Hash22(i_uv + neighbor_offset);
                    float dist = length(neighbor_offset +point_pos - f_uv);
                    if (dist < min_dist)
                    {
                        min_dist = dist;
                        closest_point_id = i_uv + neighbor_offset;
                    }
                }
            }
            unique_flake_id = Hash12(closest_point_id);
            if (unique_flake_id < _GlitterThreshold) return;
            glitter_mask = saturate((_GlitterSize - min_dist) / max(fwidth(min_dist), 0.001));
        }
        else if (_GlitterMode == 1) // TEXTURE
        {
            // todo: is noise tex needed if we just use another hash before?
            float noise_val = UNITY_SAMPLE_TEX2D_LOD(_GlitterNoiseTex, i_uv / _GlitterFrequency, 0).r;
            if (noise_val < _GlitterThreshold) return;
            float dist_from_center = length(f_uv - 0.5);
            glitter_mask = saturate((_GlitterSize - dist_from_center) / max(fwidth(dist_from_center), 0.001));
            unique_flake_id = Hash12(i_uv);
        }
        if (glitter_mask <= 0) return;
        float time = _Time.y * _GlitterFlickerSpeed + unique_flake_id * 100;
        float3 glitter_normal = normalize(float3(sin(time * 1.2), cos(time * 1.7), sin(time * 1.5)));
        float sparkle = fastpow(saturate(dot(Surface.ViewDir, glitter_normal)), _GlitterContrast);
        float3 glitter_color = _GlitterTint.rgb;
        if (_ToggleGlitterRainbow > 0)
        {
            float rainbow_time = _Time.y * _GlitterRainbowSpeed;
            glitter_color = lerp(glitter_color, Sinebow(unique_flake_id + rainbow_time), _ToggleGlitterRainbow);
        }
        float finalGlitterBrightness = _GlitterBrightness;
        #if defined(_BACKLACE_AUDIOLINK)
            finalGlitterBrightness *= i.alChannel2.y;
        #endif // _BACKLACE_AUDIOLINK
        final_glitter = glitter_mask * glitter_color * finalGlitterBrightness;
        float mask_val = UNITY_SAMPLE_TEX2D(_GlitterMask, Uvs[_GlitterMask_UV]).r;
        sparkle *= mask_val;
        Surface.FinalColor.rgb = lerp(Surface.FinalColor.rgb, final_glitter, sparkle);
    }
#endif // _BACKLACE_GLITTER

// distance fading-specific features
#if defined(_BACKLACE_DISTANCE_FADE)
    // distance fade properties
    float _DistanceFadeReference;
    float _ToggleNearFade;
    float _NearFadeMode;
    float _NearFadeDitherScale;
    float _NearFadeStart;
    float _NearFadeEnd;
    float _ToggleFarFade;
    float _FarFadeStart;
    float _FarFadeEnd;

    // fade based on how far or close the object is to the camera
    void CalculateDistanceFade(FragmentData i, inout bool isNearFading, out float fade_factor)
    {
        fade_factor = 1.0;
        float3 referencePos = _DistanceFadeReference == 1 ? i.worldObjectCenter : i.worldPos;
        float view_dist = distance(referencePos, GetCameraPos());
        isNearFading = false;
        if (_ToggleNearFade == 1 && _NearFadeStart > _NearFadeEnd)
        {
            float nearFade = smoothstep(_NearFadeEnd, _NearFadeStart, view_dist);
            fade_factor *= nearFade;
            isNearFading = nearFade < 1.0;
        }
        if (_ToggleFarFade == 1 && _FarFadeEnd > _FarFadeStart)
        {
            float farFade = 1.0 - smoothstep(_FarFadeStart, _FarFadeEnd, view_dist);
            fade_factor *= farFade;
        }
    }

    // before we do any math, maybe we can optimise and not do anything at all!
    float ApplyDistanceFadePre(bool isNearFading, float fade_factor)
    {
        if (_NearFadeMode == 0) { // don't need to worry about dither
            if (fade_factor == 0) {
                return -1; // fully faded out, skip all processing
            }
        }
        return fade_factor; // we'll handle this in the fade post function
    }

    // this is just the normal fade at the end if we need to partially show the object
    void ApplyDistanceFadePost(FragmentData i, float fade_factor, bool isNearFading, inout BacklaceSurfaceData Surface)
    {
        [branch] if (_NearFadeMode == 1 && isNearFading) {
            float pattern = GetTiltedCheckerboardPattern(Surface.ScreenCoords * _ScreenParams.xy, _NearFadeDitherScale);
            Surface.FinalColor.a *= step(fade_factor, pattern);
        } else {
            // just a normal fade
            Surface.FinalColor.a *= fade_factor;
        }
    }
#endif // _BACKLACE_DISTANCE_FADE

// iridescence features
#if defined(_BACKLACE_IRIDESCENCE)
    UNITY_DECLARE_TEX2D(_IridescenceMask);
    float _IridescenceMask_UV;
    float4 _IridescenceTint;
    float _IridescenceIntensity;
    int _IridescenceBlendMode;
    UNITY_DECLARE_TEX2D(_IridescenceRamp);
    float _IridescencePower;
    float _IridescenceFrequency;
    float _IridescenceMode;
    float _IridescenceParallax;;

    void ApplyIridescence(inout BacklaceSurfaceData Surface, FragmentData i)
    {
        float3 shiftedNormal = normalize(Surface.NormalDir + Surface.ViewDir * _IridescenceParallax);
        float fresnel_base = 1.0 - saturate(dot(Surface.NormalDir, Surface.ViewDir));
        float fresnel_shifted = 1.0 - saturate(dot(shiftedNormal, Surface.ViewDir));
        float interference = abs(fresnel_shifted - fresnel_base);
        float3 iridescenceColor = 0;
        float finalFresnel = pow(interference, _IridescencePower);
        if (_IridescenceMode == 0) // RAMP-BASED
        {
            iridescenceColor = UNITY_SAMPLE_TEX2D(_IridescenceRamp, float2(finalFresnel, 0.5)).rgb;
        }
        else if (_IridescenceMode == 1) // SINEBOW
        {
            float hue = finalFresnel * _IridescenceFrequency;
            iridescenceColor = Sinebow(hue);
        }
        float mask = UNITY_SAMPLE_TEX2D(_IridescenceMask, Uvs[_IridescenceMask_UV]).r;
        float finalIridescenceIntensity = _IridescenceIntensity;
        #if defined(_BACKLACE_AUDIOLINK)
            finalIridescenceIntensity *= i.alChannel2.z;
        #endif // _BACKLACE_AUDIOLINK
        float finalIntensity = finalIridescenceIntensity * pow(fresnel_base, 2.0) * mask;
        iridescenceColor *= _IridescenceTint.rgb * finalIntensity;
        [branch] switch(_IridescenceBlendMode)
        {
            case 0: // Additive
                Surface.FinalColor.rgb += iridescenceColor;
                break;
            case 1: // Screen
                Surface.FinalColor.rgb = 1.0 - (1.0 - Surface.FinalColor.rgb) * (1.0 - iridescenceColor);
                break;
            case 2: // Alpha Blend
                Surface.FinalColor.rgb = lerp(Surface.FinalColor.rgb, iridescenceColor, finalIntensity);
                break;
        }
    }
#endif // _BACKLACE_IRIDESCENCE

// shadow texture features
#if defined(_BACKLACE_SHADOW_TEXTURE)
    UNITY_DECLARE_TEX2D(_ShadowTex);
    float _ShadowTex_UV;
    float4 _ShadowPatternColor;
    float _ShadowPatternScale;
    float _ShadowTextureIntensity;
    int _ShadowTextureMappingMode;
    float _ShadowPatternTriplanarSharpness;
    float _ShadowPatternTransparency;
    int _ShadowTextureBlendMode;

    float3 GetTexturedShadowColor(inout BacklaceSurfaceData Surface, float3 shadowTint)
    {
        float3 texturedShadow;
        float blendFactor;
        float3 albedoTintedShadow = shadowTint * Surface.Albedo.rgb;
        float shadowMask = 1.0 - Surface.NdotL;
        switch(_ShadowTextureMappingMode)
        {
            case 0: // uv albedo
            {
                float4 shadowAlbedoSample = UNITY_SAMPLE_TEX2D(_ShadowTex, Uvs[_ShadowTex_UV]);
                texturedShadow = shadowAlbedoSample.rgb;
                blendFactor = shadowAlbedoSample.a * shadowMask;
                break;
            }
            case 1: // screen pattern
            {
                float2 screenUVs = frac(Surface.ScreenCoords * _ShadowPatternScale);
                float4 patternSample = UNITY_SAMPLE_TEX2D(_ShadowTex, screenUVs);
                texturedShadow = albedoTintedShadow;
                blendFactor = patternSample.r * patternSample.a * shadowMask;
                break;
            }
            case 2: // triplanar
            {
                float4 patternSample = SampleTextureTriplanar(
                    _ShadowTex, sampler_MainTex,
                    FragData.worldPos, Surface.NormalDir,
                    float3(0, 0, 0), _ShadowPatternScale, float3(0, 0, 0),
                    _ShadowPatternTriplanarSharpness, true, float2(0, 0)
                );
                texturedShadow = albedoTintedShadow;
                blendFactor = patternSample.r * patternSample.a * shadowMask;
                break;
            }
        }
        float3 baseShadowColour = Surface.Albedo.rgb * lerp(Surface.IndirectDiffuse, 1.0, _ShadowPatternTransparency);
        float3 finalShadowColor;
        switch(_ShadowTextureBlendMode)
        {
            case 0: // additive
                finalShadowColor = baseShadowColour + texturedShadow * blendFactor;
                break;
            case 1: // multiply
                finalShadowColor = lerp(baseShadowColour, baseShadowColour * texturedShadow, blendFactor);
                break;
            default: // alpha blend (2)
                finalShadowColor = lerp(baseShadowColour, texturedShadow, blendFactor);
                break;
        }
        float3 originalShadowColor = Surface.Albedo.rgb * Surface.IndirectDiffuse;
        return lerp(originalShadowColor, finalShadowColor, _ShadowTextureIntensity);
    }

    float3 GetTexturedShadowColor(inout BacklaceSurfaceData Surface)
    {
        return GetTexturedShadowColor(Surface, _ShadowPatternColor.rgb);
    }
#endif // _BACKLACE_SHADOW_TEXTURE

// flat model feature
#if defined(_BACKLACE_FLAT_MODEL)
    float _FlatModel;
    float _FlatModelDepthCorrection;
    float _FlatModelFacing;
    float _FlatModelLockAxis;
    float _FlatModelEnable;
    float _FlatModeAutoflip;

    // inspired by lyuma's waifu2d shader, but a much worse (and a bit simpler) implementation
    void FlattenModel(inout float4 vertex, float3 normal, out float4 finalClipPos, out float3 finalWorldPos, out float3 finalWorldNormal)
    {
        float facingAngle = _FlatModelFacing * - UNITY_PI / 2.0;
        float s, c;
        sincos(facingAngle, s, c);
        float3 targetFwd_object = float3(s, 0, c);
        float3 camPos_object = mul(unity_WorldToObject, float4(GetCameraPos(), 1.0)).xyz;
        float flipSign = sign(dot(camPos_object, targetFwd_object));
        if (flipSign == 0.0) flipSign = 1.0;
        if (_FlatModeAutoflip == 0) flipSign = 1.0;
        float3 virtualCamDir_object = targetFwd_object * flipSign * length(camPos_object);
        float3 virtualCamPos_world = mul(unity_ObjectToWorld, float4(virtualCamDir_object, 1.0)).xyz;
        float3 finalCamPos_world = lerp(GetCameraPos(), virtualCamPos_world, _FlatModelLockAxis);
        float3 worldObjectPivot = mul(unity_ObjectToWorld, float4(0, 0, 0, 1)).xyz;
        float3 billboardFwd = normalize(finalCamPos_world - worldObjectPivot);
        float3 billboardUp = float3(0, 1, 0);
        float3 billboardRight = normalize(cross(billboardUp, billboardFwd));
        billboardUp = cross(billboardFwd, billboardRight);
        float3 flattenedWorldPos = worldObjectPivot;
        flattenedWorldPos += billboardRight * vertex.x;
        flattenedWorldPos += billboardUp * vertex.y;
        flattenedWorldPos -= billboardFwd * vertex.z * _FlatModelDepthCorrection;
        float3 originalWorldPos = mul(unity_ObjectToWorld, vertex).xyz;
        finalWorldPos = lerp(originalWorldPos, flattenedWorldPos, _FlatModel);
        finalClipPos = UnityWorldToClipPos(float4(finalWorldPos, 1.0));
        finalWorldNormal = UnityObjectToWorldNormal(normal);
    }
#endif // _BACKLACE_FLAT_MODEL

// world aligned texture feature
#if defined(_BACKLACE_WORLD_EFFECT)
    UNITY_DECLARE_TEX2D(_WorldEffectTex);
    float4 _WorldEffectColor;
    float4 _WorldEffectDirection;
    float _WorldEffectScale;
    float _WorldEffectBlendSharpness;
    float _WorldEffectIntensity;
    int _WorldEffectBlendMode;
    float3 _WorldEffectPosition;
    float3 _WorldEffectRotation;
    UNITY_DECLARE_TEX2D(_WorldEffectMask);

    void ApplyWorldAlignedEffect(inout BacklaceSurfaceData Surface, FragmentData i)
    {
        float3 effectDir = normalize(_WorldEffectDirection.xyz);
        float directionMask = saturate(dot(Surface.NormalDir, effectDir));
        directionMask = pow(directionMask, _WorldEffectBlendSharpness);
        if (directionMask <= 0.001)
        {
            return;
        }
        float4 effectSample = SampleTextureTriplanar(
            _WorldEffectTex, sampler_WorldEffectTex,
            i.worldPos, Surface.NormalDir,
            _WorldEffectPosition, _WorldEffectScale, _WorldEffectRotation,
            1.0,
            true, 
            float2(0, 0)
        );
        float3 finalEffectColor = effectSample.rgb * _WorldEffectColor.rgb;
        float mask = UNITY_SAMPLE_TEX2D(_WorldEffectMask, Uvs[0]).r;
        float blendStrength = directionMask * effectSample.a * _WorldEffectIntensity * mask;
        switch(_WorldEffectBlendMode)
        {
            case 1: // Additive
                Surface.FinalColor.rgb += finalEffectColor * blendStrength;
                break;
            case 2: // Multiply
                Surface.FinalColor.rgb = lerp(Surface.FinalColor.rgb, Surface.FinalColor.rgb * finalEffectColor, blendStrength);
                break;
            default: // Alpha Blend
                Surface.FinalColor.rgb = lerp(Surface.FinalColor.rgb, finalEffectColor, blendStrength);
                break;
        }
    }
#endif // _BACKLACE_WORLD_EFFECT

// vrchat mirror detection feature
#if defined(_BACKLACE_VRCHAT_MIRROR)
    UNITY_DECLARE_TEX2D(_MirrorDetectionTexture);
    float _MirrorDetectionTexture_UV;
    float _MirrorDetectionMode; // 0 = texture, 1 = hide, 2 = only show
    float _VRChatMirrorMode; // assigned by vrchat, 0 = none, 1 = mirror in vr, 2 = mirror in desktop
    
    bool IsInMirrorView()
    {
        if (_VRChatMirrorMode > 0.5) return true;
        // otherwise, try and check for a generic mirror
        return unity_CameraProjection[2][0] != 0.f || unity_CameraProjection[2][1] != 0.f;
    }

    // dont run things that need to sample uvs in the outline pass
    #ifndef UNITY_PASS_OUTLINE
        // run after sampling albedo but before lighting
        void ApplyMirrorDetectionPre(inout BacklaceSurfaceData Surface)
        {
            if (_MirrorDetectionMode == 0 && IsInMirrorView()) // texture
            {
                float mask = UNITY_SAMPLE_TEX2D(_MirrorDetectionTexture, Uvs[_MirrorDetectionTexture_UV]).r;
                Surface.FinalColor.a *= mask;
            }
        }

        // run at the end of the shader
        void ApplyMirrorDetectionPost(inout BacklaceSurfaceData Surface)
        {
            if (_MirrorDetectionMode == 1 && IsInMirrorView()) // hide
            {
                Surface.FinalColor.a = 0;
            }
            else if (_MirrorDetectionMode == 2 && !IsInMirrorView()) // only show
            {
                Surface.FinalColor.a = 0;
            }
        }
    #endif // UNITY_PASS_OUTLINE
#endif // _BACKLACE_VRCHAT_MIRROR

// touch reactive effect
#if defined(_BACKLACE_TOUCH_REACTIVE)
    #ifndef BACKLACE_DEPTH // prevent re-declaration of depth texture
        UNITY_DECLARE_DEPTH_TEXTURE(_CameraDepthTexture);
        float4 _CameraDepthTexture_TexelSize;
        #define BACKLACE_DEPTH
    #endif // BACKLACE_DEPTH
    float4 _TouchColor;
    float _TouchRadius;
    float _TouchHardness;
    int _TouchMode; // 0 = additive, 1 = replace, 2 = multiply, 3 = rainbow
    float _TouchRainbowSpeed;
    float _TouchRainbowSpread;

    void ApplyTouchReactive(inout BacklaceSurfaceData Surface, FragmentData i)
    {
        float sceneDepthRaw = tex2Dproj(_CameraDepthTexture, UNITY_PROJ_COORD(i.scrPos)).r;
        float sceneDepthLinear = LinearEyeDepth(sceneDepthRaw);
        float depthDifference = sceneDepthLinear - i.scrPos.w;
        float intersect = 1.0 - smoothstep(0, _TouchRadius, depthDifference);
        if (intersect <= 0) return;
        intersect = fastpow(intersect, _TouchHardness);
        float3 touchEffect = _TouchColor.rgb * intersect * _TouchColor.a;
        switch (_TouchMode) {
            case 1: // replace
                Surface.FinalColor.rgb = lerp(Surface.FinalColor.rgb, touchEffect, intersect);
                break;
            case 2: // multiply
                Surface.FinalColor.rgb = lerp(Surface.FinalColor.rgb, Surface.FinalColor.rgb * touchEffect, intersect);
                break;
            case 3: // rainbow
                float time = _Time.y * _TouchRainbowSpeed;
                float3 rainbowColor = Sinebow(depthDifference * _TouchRainbowSpread + time);
                touchEffect = rainbowColor * intersect * _TouchColor.a;
                Surface.FinalColor.rgb = lerp(Surface.FinalColor.rgb, touchEffect, intersect);
                break;
            default: // additive
                Surface.FinalColor.rgb += touchEffect;
                break;
        }
    }
#endif // _BACKLACE_TOUCH_REACTIVE
  
// vertex distortion feature
#if defined(_BACKLACE_VERTEX_DISTORTION)
    int _VertexDistortionMode;
    int _VertexDistortionColorMask; // 0 = disabled, 1 = red, 2 = green, 3 = blue, 4 = all
    float3 _VertexDistortionStrength;
    float3 _VertexDistortionSpeed;
    float3 _VertexDistortionFrequency;
    float _WindStrength;
    float _WindSpeed;
    float _WindScale;
    float4 _WindDirection;
    UNITY_DECLARE_TEX2D(_WindNoiseTex);
    float _BreathingStrength;
    float _BreathingSpeed;
    int _VertexEffectType; // 0 = distortion, 1 = glitch
    int _VertexGlitchMode; // 0 = slice, 1 = blocky, 2 = wave, 3 = jitter
    float _GlitchFrequency;

    // for distortion mode
    void DistortVertex(inout float4 vertex, float3 worldPos, float4 vertexColor)
    {
        float time = _Time.y;
        float3 distortion = 0;
        // calculate vertex colour mask
        float mask = 1.0;
        switch (_VertexDistortionColorMask)
        {
            case 1: // red
                mask = vertexColor.r;
                break;
            case 2: // green
                mask = vertexColor.g;
                break;
            case 3: // blue
                mask = vertexColor.b;
                break;
            case 4: // all
                mask = (vertexColor.r + vertexColor.g + vertexColor.b) / 3.0;
                break;
            default: // disabled
                mask = 1.0;
                break;
        }
        // apply mask to strength
        switch(_VertexDistortionMode)
        {
            case 0: // wave
            {
                distortion.x = sin(vertex.y * _VertexDistortionFrequency.x + time * _VertexDistortionSpeed.x) * _VertexDistortionStrength.x;
                distortion.y = sin(vertex.x * _VertexDistortionFrequency.y + time * _VertexDistortionSpeed.y) * _VertexDistortionStrength.y;
                distortion.z = sin(vertex.x * _VertexDistortionFrequency.z + time * _VertexDistortionSpeed.z) * _VertexDistortionStrength.z;
                break;
            }
            case 1: // jumble
            {
                float offsetX = sin(vertex.x * _VertexDistortionFrequency.x) * cos(vertex.y * _VertexDistortionFrequency.x) * _VertexDistortionStrength.x;
                float offsetY = cos(vertex.y * _VertexDistortionFrequency.y) * sin(vertex.z * _VertexDistortionFrequency.y) * _VertexDistortionStrength.y;
                float offsetZ = sin(vertex.z * _VertexDistortionFrequency.z) * cos(vertex.x * _VertexDistortionFrequency.z) * _VertexDistortionStrength.z;
                distortion = float3(offsetX, offsetY, offsetZ) * sin(time * _VertexDistortionSpeed.x); // Use one speed channel for sync
                break;
            }
            case 2: // wind
            {
                float2 windUV = worldPos.xz * _WindScale + (_Time.y * _WindSpeed * _WindDirection.xz);
                float noise = UNITY_SAMPLE_TEX2D_LOD(_WindNoiseTex, windUV, 0).r * 2.0 - 1.0;
                float sineWave = sin(_Time.y * _WindSpeed + worldPos.x + worldPos.z);
                distortion = normalize(_WindDirection.xyz) * (noise + sineWave) * _WindStrength * mask;
                break;
            }
            case 3: // breathing
            {
                float breath = (sin(_Time.y * _BreathingSpeed) + 1.0) * 0.5; 
                float3 localNormal = normalize(vertex.xyz);
                distortion = localNormal * breath * _BreathingStrength * mask;
                break;
            }
        }
        vertex.xyz += distortion;
    }

    // glitch helpers
    float GlitchHash(float2 p)
    {
        float h = dot(p, float2(127.1, 311.7));
        return frac(sin(h) * 43758.5453);
    }

    float GlitchBlockNoise(float2 p, float blockSize)
    {
        float2 block = floor(p / blockSize) * blockSize;
        return GlitchHash(block);
    }

    // for glitch mode
    void GlitchVertex(inout float4 vertex, float3 worldPos, float4 vertexColor)
    {
        float time = _Time.y * _VertexDistortionSpeed.x;
        float3 glitchOffset = 0;
        float mask = 1.0;
        switch (_VertexDistortionColorMask)
        {
            case 1: mask = vertexColor.r; break;
            case 2: mask = vertexColor.g; break;
            case 3: mask = vertexColor.b; break;
            case 4: mask = (vertexColor.r + vertexColor.g + vertexColor.b) / 3.0; break;
            default: mask = 1.0; break;
        }
        float glitchTrigger = step(_GlitchFrequency, GlitchHash(float2(floor(time * 10.0), 0.0)));
        float blockSize = 1.0 / max(_VertexDistortionFrequency.x, 0.001);
        switch (_VertexGlitchMode)
        {
            case 0: // slice, horizontal slicing glitch
            {
                float sliceY = floor(vertex.y / blockSize) * blockSize;
                float sliceNoise = GlitchHash(float2(sliceY, floor(time * 5.0)));
                float sliceActive = step(0.7, sliceNoise) * glitchTrigger;
                float offsetAmount = (sliceNoise * 2.0 - 1.0) * _VertexDistortionStrength.x * sliceActive;
                glitchOffset.x = offsetAmount;
                break;
            }
            case 1: // blocky, random block displacement
            {
                float2 blockPos = float2(vertex.x + vertex.z, vertex.y);
                float blockNoise = GlitchBlockNoise(blockPos, blockSize);
                float blockActive = step(0.8, blockNoise) * glitchTrigger;
                float3 randomDir = normalize(float3(
                    GlitchHash(float2(blockNoise, 1.0)) * 2.0 - 1.0,
                    GlitchHash(float2(blockNoise, 2.0)) * 2.0 - 1.0,
                    GlitchHash(float2(blockNoise, 3.0)) * 2.0 - 1.0
                ));
                glitchOffset = randomDir * _VertexDistortionStrength * blockActive;
                break;
            }
            case 2: // wave, "corrupted" wave distortion
            {
                float wavePhase = sin(vertex.y * _VertexDistortionFrequency.y + time * 20.0) * glitchTrigger;
                float waveNoise = GlitchHash(float2(floor(time * 8.0), floor(vertex.y * 5.0)));
                glitchOffset.x = wavePhase * waveNoise * _VertexDistortionStrength.x;
                glitchOffset.z = wavePhase * (1.0 - waveNoise) * _VertexDistortionStrength.z * 0.5;
                break;
            }
            case 3: // jitter, rapid smol displacements
            {
                float jitterTime = floor(time * 30.0);
                float3 jitter = float3(
                    GlitchHash(float2(jitterTime, vertex.x * 100.0)),
                    GlitchHash(float2(jitterTime, vertex.y * 100.0)),
                    GlitchHash(float2(jitterTime, vertex.z * 100.0))
                ) * 2.0 - 1.0;
                glitchOffset = jitter * _VertexDistortionStrength * 0.1 * glitchTrigger;
                break;
            }
        }
        vertex.xyz += glitchOffset * mask;
    }

    // wrapper to select between distortion and glitch modes
    void ApplyVertexDistortion(inout float4 vertex, float3 worldPos, float4 vertexColor)
    {
        [branch] if (_VertexEffectType == 1)
        {
            GlitchVertex(vertex, worldPos, vertexColor);
        }
        else
        {
            DistortVertex(vertex, worldPos, vertexColor);
        }
    }
#endif // _BACKLACE_VERTEX_DISTORTION

// dither feature
#if defined(_BACKLACE_DITHER)
    float _DitherAmount;
    float _DitherScale;
    float _DitherSpace;
    int _Dither_UV;

    void ApplyDither(inout BacklaceSurfaceData Surface, float2 worldPos, float2 uvs)
    {
        float2 ditherUV = 0;
        switch (_DitherSpace) {
            case 1: // world
                ditherUV = frac(worldPos) * _ScreenParams.xy;
                break;
            case 2: // uv
                ditherUV = uvs * _ScreenParams.xy; // passed to avoid outline pass needing Uvs[]
                break;
            default: // screen
                ditherUV = Surface.ScreenCoords * _ScreenParams.xy;
                break;
        }
        float pattern = GetTiltedCheckerboardPattern(ditherUV, _DitherScale);
        Surface.FinalColor.a = lerp(Surface.FinalColor.a, Surface.FinalColor.a * pattern, _DitherAmount);
    }
#endif // _BACKLACE_DITHER

// ps1 feature
#if defined(_BACKLACE_PS1)
    int _PS1Rounding;
    float _PS1RoundingPrecision;
    int _PS1Affine;
    int _PS1Compression;
    float _PS1CompressionPrecision;

    void ApplyPS1Vertex(inout FragmentData i, in VertexData v)
    {
        if (_PS1Rounding == 1)
        {
            float4 worldPos = mul(unity_ObjectToWorld, v.vertex);
            worldPos.xyz = ceil(worldPos.xyz * _PS1RoundingPrecision) / _PS1RoundingPrecision;
            i.pos = mul(UNITY_MATRIX_VP, worldPos);
        }
        else if (_PS1Rounding == 2)
        {
            float4 pos = i.pos;
            pos.xy /= pos.w;
            pos.xy = round(pos.xy * _PS1RoundingPrecision) / _PS1RoundingPrecision;
            pos.xy *= pos.w;
            i.pos = pos;
        }
        if (_PS1Affine == 1)
        {
            i.affineUV = float4(v.uv.x, v.uv.y, 0, 0) * i.pos.w;
        }
    }

    void ApplyPS1AffineUV(inout float2 uv, in FragmentData i)
    {
        if (_PS1Affine == 1)
        {
            uv = i.affineUV.xy / i.pos.w;
        }
    }

    void ApplyPS1ColorCompression(inout float4 finalColor)
    {
        if (_PS1Compression == 1)
        {
            finalColor.rgb = floor(finalColor.rgb * _PS1CompressionPrecision) / _PS1CompressionPrecision;
        }
    }
#endif // _BACKLACE_PS1

// grabpass variant only features
#if defined(BACKLACE_GRABPASS)
    UNITY_DECLARE_SCREENSPACE_TEXTURE(_BacklaceGP);
    float4 _BacklaceGP_TexelSize;

    // refraction feature
    #if defined(_BACKLACE_REFRACTION)
        UNITY_DECLARE_TEX2D(_RefractionMask);
        float _RefractionMask_UV;
        float4 _RefractionTint;
        float _RefractionIOR;
        float _RefractionFresnel;
        UNITY_DECLARE_TEX2D(_CausticsTex);
        float _CausticsTiling;
        float _CausticsSpeed;
        float _CausticsIntensity;
        UNITY_DECLARE_TEX2D(_DistortionNoiseTex);
        float _DistortionNoiseTiling;
        float _DistortionNoiseStrength;
        int _RefractionDistortionMode;
        float _RefractionCAStrength;
        float _RefractionBlurStrength;
        float _RefractionOpacity;
        float _RefractionMixStrength;
        int _RefractionCAUseFresnel;
        float _RefractionCAEdgeFade;
        float _RefractionMode; // 0 = reverse fresnel, 1 = fresnel, 2 = soft fresnel, 3 = manual
        float4 _CausticsColor;
        float _RefractionBlendMode;
        float _RefractionSeeThrough;
        float3 _RefractionGrabpassTint;
        int _RefractionZoomToggle;
        float _RefractionZoom;
        int _RefractionSourceMode;
        UNITY_DECLARE_TEX2D(_RefractionTexture);

        float3 SampleRefractionSource(float2 uv)
        {
            [branch] if (_RefractionSourceMode == 1)
            {
                return UNITY_SAMPLE_TEX2D(_RefractionTexture, uv).rgb;
            }
            else
            {
                return UNITY_SAMPLE_SCREENSPACE_TEXTURE(_BacklaceGP, uv).rgb;
            }
        }

        void ApplyRefraction(inout BacklaceSurfaceData Surface, FragmentData i)
        {
            float fresnel = 1.0 - saturate(dot(Surface.NormalDir, Surface.ViewDir));
            fresnel = pow(fresnel, _RefractionFresnel);
            float2 noise = (SampleTextureTriplanar(_DistortionNoiseTex, sampler_DistortionNoiseTex, i.worldPos, Surface.NormalDir, float3(0, 0, 0), _DistortionNoiseTiling, float3(0, 0, 0), 2.0, true, float2(0, 0)).rg * 2.0 - 1.0) * _DistortionNoiseStrength;
            float3 distortionNormal = Surface.NormalDir + float3(noise.x, noise.y, 0);
            float3 refractionVector = distortionNormal * _RefractionIOR;
            float4 screenPos = i.scrPos;
            float2 baseUV = screenPos.xy / screenPos.w;
            float2 distortedUV = baseUV + refractionVector.xy;
            [branch] if (_RefractionZoomToggle == 1)
            {
                float normalFactor = frac(dot(Surface.NormalDir, float3(12.9898, 78.233, 37.719))) * 2.0 - 1.0;
                float zoomFactor = 1.0 - (normalFactor * _RefractionZoom);
                float2 center = 0.5;
                distortedUV = (distortedUV - center) * zoomFactor + center;
            }
            float3 refractedColor = 0;
            switch(_RefractionDistortionMode)
            {
                case 1: // chromatic aberration
                {
                    float caOffset = _RefractionBlurStrength;
                    if (_RefractionCAUseFresnel == 1)
                    {
                        float caFresnel = fastpow(fresnel, _RefractionCAEdgeFade);
                        caOffset *= caFresnel;
                    }
                    refractedColor.r = SampleRefractionSource(distortedUV + float2(caOffset, 0)).r * _RefractionCAStrength;
                    refractedColor.g = SampleRefractionSource(distortedUV).g;
                    refractedColor.b = SampleRefractionSource(distortedUV - float2(caOffset, 0)).b * _RefractionCAStrength;
                    break;
                }
                case 2: // blur
                {
                    const int BLUR_SAMPLES = 8;
                    float2 blurOffset = _BacklaceGP_TexelSize.xy * _RefractionBlurStrength;
                    refractedColor = SampleRefractionSource(distortedUV).rgb;
                    [unroll] for (int i = 0; i < BLUR_SAMPLES; i++)
                    {
                        float angle = (float)i / BLUR_SAMPLES * 2.0 * UNITY_PI;
                        float s, c;
                        sincos(angle, s, c);
                        float2 offset = float2(c, s) * blurOffset;
                        refractedColor += UNITY_SAMPLE_SCREENSPACE_TEXTURE(_BacklaceGP, distortedUV + offset).rgb;
                    }
                    refractedColor /= (BLUR_SAMPLES + 1);
                    break;
                }
                default: // no extra distortion
                {
                    refractedColor = SampleRefractionSource(distortedUV).rgb;
                    break;
                }
            }
            refractedColor *= _RefractionGrabpassTint;
            float3 reflectionVector = reflect(-Surface.ViewDir, Surface.NormalDir);
            float2 causticsUV = reflectionVector.xy * _CausticsTiling + (_Time.y * _CausticsSpeed);
            float3 caustics = UNITY_SAMPLE_TEX2D(_CausticsTex, causticsUV).rgb * _CausticsIntensity;
            float mask = UNITY_SAMPLE_TEX2D(_RefractionMask, Uvs[_RefractionMask_UV]).r;
            float3 crystalColor = lerp(_RefractionTint.rgb + caustics, lerp(_RefractionTint.rgb, _CausticsColor.rgb, caustics), _RefractionBlendMode);
            float3 finalColor;
            switch(int(_RefractionMode))
            {
                case 1: // fresnel
                    finalColor = lerp(refractedColor, crystalColor, fresnel * _RefractionMixStrength);
                    break;
                case 2: // soft fresnel (Gummy...)
                    finalColor = lerp(refractedColor, crystalColor, fastpow(fresnel, _RefractionMixStrength));
                    break;
                case 3: // manual
                    finalColor = lerp(refractedColor, crystalColor, _RefractionMixStrength);
                    break;
                default: // reverse fresnel
                    finalColor = lerp(refractedColor, crystalColor, (1.0 - fresnel) * _RefractionMixStrength);
                    break;
            }
            finalColor = lerp(finalColor, _RefractionTint.rgb, _RefractionTint.a * (1.0 - fresnel));
            float finalAlpha = lerp(_RefractionTint.a, 1.0, fresnel) * mask;
            Surface.FinalColor.rgb = lerp(Surface.FinalColor.rgb, finalColor, finalAlpha);
            Surface.FinalColor.rgb = lerp(Surface.FinalColor.rgb, refractedColor, _RefractionSeeThrough); // extra see-through control
            Surface.FinalColor.a = finalAlpha * _RefractionOpacity;
        }
    #endif // _BACKLACE_REFRACTION

    // screen space reflection feature
    #if defined(_BACKLACE_SSR)
        float _SSRMode;
        UNITY_DECLARE_TEX2D(_SSRMask);
        float4 _SSRTint;
        float _SSRIntensity;
        int _SSRBlendMode;
        float _SSRFresnelPower;
        float _SSRFresnelScale;
        float _SSRFresnelBias;
        float _SSRCoverage;
        // planar
        float _SSRParallax;
        UNITY_DECLARE_TEX2D(_SSRDistortionMap);
        float _SSRDistortionStrength;
        float _SSRBlur;
        float _SSRWorldDistortion;
        // raymarched
        int _SSRMaxSteps;
        float _SSRStepSize;
        float _SSREdgeFade;
        float _SSRThickness;
        float _SSRAdaptiveStep;
        float _SSRFlipUV;
        int _SSROutOfViewMode;
        int _SSRCamFade;
        float _SSRCamFadeStart;
        float _SSRCamFadeEnd;
        int _SSRSourceMode;
        UNITY_DECLARE_TEX2D(_SSRTexture);

        #ifndef BACKLACE_DEPTH
            UNITY_DECLARE_DEPTH_TEXTURE(_CameraDepthTexture);
            float4 _CameraDepthTexture_TexelSize;
            #define BACKLACE_DEPTH
        #endif // BACKLACE_DEPTH

        float3 SampleSSRSource(float2 uv)
        {
            [branch] if (_SSRSourceMode == 1)
            {
                return UNITY_SAMPLE_TEX2D(_SSRTexture, uv).rgb;
            }
            else
            {
                return UNITY_SAMPLE_SCREENSPACE_TEXTURE(_BacklaceGP, uv).rgb;
            }
        }

        // somewhat based on the orels1/mochie method, but completely butchered by me for my purposes
        float3 GetSSRMarched(inout BacklaceSurfaceData Surface, FragmentData i)
        {
            #if UNITY_SINGLE_PASS_STEREO
                float x_min = 0.5 * unity_StereoEyeIndex;
                float x_max = 0.5 + 0.5 * unity_StereoEyeIndex;
            #else // UNITY_SINGLE_PASS_STEREO
                float x_min = 0.0;
                float x_max = 1.0;
            #endif // UNITY_SINGLE_PASS_STEREO
            float3 viewPos = mul(UNITY_MATRIX_V, float4(i.worldPos, 1.0)).xyz;
            float3 viewRefl = mul((float3x3)UNITY_MATRIX_V, Surface.ReflectDir);
            float3 currentRayPos = viewPos + viewRefl * (UNITY_MATRIX_P._33 * 0.1); 
            float3 prevRayPos = viewPos;
            [loop] for (int j = 0; j < _SSRMaxSteps; j++)
            {
                float4 screenPos = mul(UNITY_MATRIX_P, float4(currentRayPos, 1.0));
                float2 screenUV = (screenPos.xy / screenPos.w) * 0.5 + 0.5;
                if (screenUV.x > x_max || screenUV.x < x_min || screenUV.y > 1.0 || screenUV.y < 0.0)
                {
                    return 0; // out of view
                }
                // get and compare depths
                float sceneDepth = LinearEyeDepth(tex2Dproj(_CameraDepthTexture, UNITY_PROJ_COORD(screenPos)).r);
                float rayDepth = -currentRayPos.z;
                if (rayDepth > sceneDepth - _SSRThickness)
                {
                    float4 finalClipPos = mul(UNITY_MATRIX_P, float4(currentRayPos, 1.0));
                    finalClipPos.y = lerp(finalClipPos.y, -finalClipPos.y + finalClipPos.w, _SSRFlipUV);
                    float fadeFactor = 1.0;
                    float2 finalUV = finalClipPos.xy / finalClipPos.w;
                    switch (_SSROutOfViewMode)
                    {
                        case 1: // fade
                            fadeFactor = smoothstep(x_min, x_min + 0.05, finalUV.x) * smoothstep(1.0 - x_max, 1.0 - x_max + 0.05, finalUV.x);
                            fadeFactor *= smoothstep(0.0, 0.05, finalUV.y) * smoothstep(1.0, 1.0 - 0.05, finalUV.y);
                            break;
                        case 2: // cutoff
                            if (finalUV.x < x_min || finalUV.x > x_max || finalUV.y < 0.0 || finalUV.y > 1.0) fadeFactor = 0;
                            break;
                        default: // (3) mirror
                            if (finalUV.x < x_min) finalUV.x = x_min + (x_min - finalUV.x);
                            if (finalUV.x > x_max) finalUV.x = x_max - (finalUV.x - x_max);
                            if (finalUV.y < 0.0) finalUV.y = -finalUV.y;
                            if (finalUV.y > 1.0) finalUV.y = 1.0 - (finalUV.y - 1.0);
                            break;
                    }
                    if (_SSRDistortionStrength > 0)
                    {
                        // note to self: sampling multiple times, yes, BUT only per-hit rather than all pixels
                        float2 distortion = (UNITY_SAMPLE_TEX2D(_SSRDistortionMap, screenUV).rg * 2.0 - 1.0) * _SSRDistortionStrength;
                        finalUV += distortion;
                    }
                    float3 reflection = SampleSSRSource(finalUV);
                    finalUV = finalUV * 0.5 + 0.5;
                    float2 fade = smoothstep(0.0, _SSREdgeFade, finalUV) * (1.0 - smoothstep(1.0 - _SSREdgeFade, 1.0, finalUV));
                    reflection *= fade.x * fade.y * fadeFactor;
                    return reflection;
                }
                // move to the next step
                float depthDifference = sceneDepth - rayDepth;
                float step = (_SSRAdaptiveStep) ? clamp(depthDifference * _SSRStepSize, 0.02, 0.5) : _SSRStepSize;
                prevRayPos = currentRayPos;
                currentRayPos += viewRefl * step;
            }
            return 0; // no hit
        }

        // simple grabpass with parallax distortion
        float3 GetSSRPlanar(inout BacklaceSurfaceData Surface, FragmentData i)
        {
            float2 screenUV = i.scrPos.xy / i.scrPos.w;
            float2 distortionUV = lerp(screenUV, i.worldPos.xy, _SSRWorldDistortion);
            float2 distortionOffset = (UNITY_SAMPLE_TEX2D(_SSRDistortionMap, distortionUV).rg * 2.0 - 1.0) * _SSRDistortionStrength;
            float3 viewSpaceReflection = mul((float3x3)UNITY_MATRIX_V, Surface.ReflectDir);
            float parallax = _SSRParallax * saturate(1.0 - viewSpaceReflection.z);
            float2 reflectionOffset = viewSpaceReflection.xy * parallax;
            float2 reflectionUV = screenUV + reflectionOffset +distortionOffset;
            const int SSR_BLUR_SAMPLES = 8;
            float3 reflectedColor = SampleSSRSource(reflectionUV);
            float2 blurOffset = _BacklaceGP_TexelSize.xy * _SSRBlur;
            [unroll] for (int k = 0; k < SSR_BLUR_SAMPLES; k++)
            {
                float angle = (float)k / SSR_BLUR_SAMPLES * 2.0 * UNITY_PI;
                float s, c;
                sincos(angle, s, c);
                float2 offset = float2(c, s) * blurOffset;
                reflectedColor += SampleSSRSource(reflectionUV + offset);
            }
            reflectedColor /= (SSR_BLUR_SAMPLES + 1);
            return reflectedColor;
        }

        // master function to apply ssr
        void ApplyScreenSpaceReflections(inout BacklaceSurfaceData Surface, FragmentData i)
        {
            float3 reflectedColor;
            // branch between qualities
            [branch] if (_SSRMode == 1)
            {
                reflectedColor = GetSSRMarched(Surface, i);
            }
            else
            {
                reflectedColor = GetSSRPlanar(Surface, i);
            }
            // additional fading
            float fadeFactor = 1.0;
            if (_SSRCamFade == 1) 
            {
                float camDistance = distance(i.worldPos, GetCameraPos());
                fadeFactor *= 1.0 - saturate((camDistance - _SSRCamFadeStart) / (_SSRCamFadeEnd - _SSRCamFadeStart));
            }
            // fresnel, mask, etc.
            float fresnel_base = 1.0 - saturate(dot(Surface.NormalDir, Surface.ViewDir));
            float fresnel_powered = pow(fresnel_base, _SSRFresnelPower);
            float fresnel = saturate(_SSRFresnelBias + fresnel_powered * _SSRFresnelScale + _SSRCoverage);
            float mask = UNITY_SAMPLE_TEX2D(_SSRMask, Uvs[0]).r;
            float finalStrength = fresnel * mask * _SSRIntensity * fadeFactor;
            float3 finalReflection = reflectedColor * _SSRTint.rgb;
            switch((int)_SSRBlendMode)
            {
                case 0: // additive
                    Surface.FinalColor.rgb += finalReflection * finalStrength;
                    break;
                case 1: // alpha blend
                    Surface.FinalColor.rgb = lerp(Surface.FinalColor.rgb, finalReflection, finalStrength);
                    break;
                case 2: // multiply
                    Surface.FinalColor.rgb = lerp(Surface.FinalColor.rgb, Surface.FinalColor.rgb * finalReflection, finalStrength);
                    break;
                default: // screen
                    Surface.FinalColor.rgb = lerp(Surface.FinalColor.rgb, 1.0 - (1.0 - Surface.FinalColor.rgb) * (1.0 - finalReflection), finalStrength);
                    break;
            }
        }
    #endif // _BACKLACE_SSR
#endif // BACKLACE_GRABPASS

// world variant only effects
#if defined(BACKLACE_WORLD) 

    // stochastic sampling feature
    #if defined(_BACKLACE_STOCHASTIC)
        UNITY_DECLARE_TEX2D(_StochasticHeightMap);
        float _StochasticScale;
        float _StochasticBlend;
        float _StochasticRotationRange;
        float _StochasticContrastScale;
        float _StochasticContrastStrength;
        float _StochasticContrastThreshold;
        float _StochasticHeightStrength;
        float _StochasticAntiTileStrength;
        float _StochasticMipBias;
        int _StochasticSamplingMode;
        int _StochasticHeightBlend;
        int _StochasticPreserveContrast;
        int _StochasticDither;


    #endif // _BACKLACE_STOCHASTIC

#endif // BACKLACE_WORLD

#endif // BACKLACE_EFFECTS_CGINC