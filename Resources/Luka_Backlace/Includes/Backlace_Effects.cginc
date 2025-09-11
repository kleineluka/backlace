#ifndef BACKLACE_EFFECTS_CGINC
#define BACKLACE_EFFECTS_CGINC

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
                    float2 point_pos = Hash2(i_uv + neighbor_offset);
                    float dist = length(neighbor_offset +point_pos - f_uv);
                    if (dist < min_dist)
                    {
                        min_dist = dist;
                        closest_point_id = i_uv + neighbor_offset;
                    }
                }
            }
            unique_flake_id = Hash(closest_point_id);
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
            unique_flake_id = Hash(i_uv);
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

    // fake dithering stylised as checkerboard pattern for the aesthetics
    float GetTiltedCheckerboardPattern(float2 screenPos)
    {
        float u = screenPos.x + screenPos.y;
        float v = screenPos.x - screenPos.y;
        float2 gridPos = floor(float2(u, v) / _NearFadeDitherScale);
        return fmod(gridPos.x + gridPos.y, 2.0);
    }

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
            float pattern = GetTiltedCheckerboardPattern(Surface.ScreenCoords * _ScreenParams.xy);
            Surface.FinalColor.a *= step(fade_factor, pattern);
        } else {
            // just a normal fade
            Surface.FinalColor.a *= fade_factor;
        }
    }
#endif // _BACKLACE_DISTANCE_FADE

// iridescence-only features
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

// shadow texture-only features
#if defined(_BACKLACE_SHADOW_TEXTURE)
    UNITY_DECLARE_TEX2D(_ShadowTex);
    float _ShadowTex_UV;
    float4 _ShadowPatternColor;
    float _ShadowPatternScale;
    float _ShadowTextureIntensity;
    int _ShadowTextureMappingMode;
    float _ShadowPatternTriplanarSharpness;
    float _ShadowPatternTransparency;

    float3 GetTexturedShadowColor(inout BacklaceSurfaceData Surface, float3 shadowTint)
    {
        float3 finalShadowColor;
        float3 albedoTintedShadow = shadowTint * Surface.Albedo.rgb;
        float3 baseShadowColour = Surface.Albedo.rgb * lerp(Surface.IndirectDiffuse, 1.0, _ShadowPatternTransparency);
        switch(_ShadowTextureMappingMode)
        {
            case 0: // uv albedo
            {
                float4 shadowAlbedoSample = UNITY_SAMPLE_TEX2D(_ShadowTex, Uvs[_ShadowTex_UV]);
                finalShadowColor = lerp(baseShadowColour, shadowAlbedoSample.rgb, shadowAlbedoSample.a);
                break;
            }
            case 1: // screen pattern
            {
                float2 screenUVs = frac(Surface.ScreenCoords * _ShadowPatternScale);
                float4 patternSample = UNITY_SAMPLE_TEX2D(_ShadowTex, screenUVs);
                float blendFactor = patternSample.r * patternSample.a;
                finalShadowColor = lerp(baseShadowColour, albedoTintedShadow, blendFactor);
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
                float blendFactor = patternSample.r * patternSample.a;
                finalShadowColor = lerp(baseShadowColour, albedoTintedShadow, blendFactor);
                break;
            }
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
    void FlattenModel(inout VertexData v, out float4 finalClipPos, out float3 finalWorldPos, out float3 finalWorldNormal)
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
        flattenedWorldPos += billboardRight * v.vertex.x;
        flattenedWorldPos += billboardUp * v.vertex.y;
        flattenedWorldPos -= billboardFwd * v.vertex.z * _FlatModelDepthCorrection;
        float3 originalWorldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
        finalWorldPos = lerp(originalWorldPos, flattenedWorldPos, _FlatModel);
        finalClipPos = UnityWorldToClipPos(float4(finalWorldPos, 1.0));
        finalWorldNormal = UnityObjectToWorldNormal(v.normal);
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
        float blendStrength = directionMask * effectSample.a * _WorldEffectIntensity;
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
    float _RefractionMode; // 0 = reverse fresnel, 1 = fresnel, 2 = soft fresnel, 3 = manual
    float4 _CausticsColor;
    float _RefractionBlendMode;
    float _RefractionSeeThrough;

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
        float3 refractedColor = 0;
        switch(_RefractionDistortionMode)
        {
            case 1: // chromatic aberration
            {
                refractedColor.r = UNITY_SAMPLE_SCREENSPACE_TEXTURE(_BacklaceGP, distortedUV + float2(_RefractionBlurStrength, 0)).r * _RefractionCAStrength;
                refractedColor.g = UNITY_SAMPLE_SCREENSPACE_TEXTURE(_BacklaceGP, distortedUV).g;
                refractedColor.b = UNITY_SAMPLE_SCREENSPACE_TEXTURE(_BacklaceGP, distortedUV - float2(_RefractionBlurStrength, 0)).b * _RefractionCAStrength;
                break;
            }
            case 2: // blur
            {
                const int BLUR_SAMPLES = 8;
                float2 blurOffset = _BacklaceGP_TexelSize.xy * _RefractionBlurStrength;
                refractedColor = UNITY_SAMPLE_SCREENSPACE_TEXTURE(_BacklaceGP, distortedUV).rgb;
                [unroll]
                for (int i = 0; i < BLUR_SAMPLES; i++)
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
                refractedColor = UNITY_SAMPLE_SCREENSPACE_TEXTURE(_BacklaceGP, distortedUV).rgb;
                break;
            }
        }
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

#if defined(_BACKLACE_VERTEX_DISTORTION)
    int _VertexDistortionMode;
    float3 _VertexDistortionStrength;
    float3 _VertexDistortionSpeed;
    float3 _VertexDistortionFrequency;

    void DistortVertex(inout float4 vertex)
    {
        float time = _Time.y;
        float3 distortion = 0;
        if (_VertexDistortionMode == 0) // wave
        {
            distortion.x = sin(vertex.y * _VertexDistortionFrequency.x + time * _VertexDistortionSpeed.x) * _VertexDistortionStrength.x;
            distortion.y = sin(vertex.x * _VertexDistortionFrequency.y + time * _VertexDistortionSpeed.y) * _VertexDistortionStrength.y;
            distortion.z = sin(vertex.x * _VertexDistortionFrequency.z + time * _VertexDistortionSpeed.z) * _VertexDistortionStrength.z;
        } 
        else if (_VertexDistortionMode == 1) // jumble 
        {
            float offsetX = sin(vertex.x * _VertexDistortionFrequency.x) * cos(vertex.y * _VertexDistortionFrequency.x) * _VertexDistortionStrength.x;
            float offsetY = cos(vertex.y * _VertexDistortionFrequency.y) * sin(vertex.z * _VertexDistortionFrequency.y) * _VertexDistortionStrength.y;
            float offsetZ = sin(vertex.z * _VertexDistortionFrequency.z) * cos(vertex.x * _VertexDistortionFrequency.z) * _VertexDistortionStrength.z;
            distortion = float3(offsetX, offsetY, offsetZ) * sin(time * _VertexDistortionSpeed);
        }
        vertex.xyz += distortion;
    }
#endif // _BACKLACE_VERTEX_DISTORTION

// screen space reflection feature
#if defined(_BACKLACE_SSR)
    UNITY_DECLARE_TEX2D(_SSRMask);
    float4 _SSRTint;
    float _SSRIntensity;
    int _SSRBlendMode;
    float _SSRFresnelPower;
    float _SSRFresnelScale;
    float _SSRFresnelBias;
    float _SSRParallax;
    UNITY_DECLARE_TEX2D(_SSRDistortionMap);
    float _SSRDistortionStrength;
    float _SSRBlur;
    float _SSRWorldDistortion;

    void ApplyScreenSpaceReflections(inout BacklaceSurfaceData Surface, FragmentData i)
    {
        float2 screenUV = i.scrPos.xy / i.scrPos.w;
        float3 reflectionVector = reflect(-Surface.ViewDir, Surface.NormalDir);
        float2 distortionUV = lerp(screenUV, i.worldPos.xy, _SSRWorldDistortion);
        float2 distortionOffset = (UNITY_SAMPLE_TEX2D(_SSRDistortionMap, distortionUV).rg * 2.0 - 1.0) * _SSRDistortionStrength;
        float3 viewSpaceReflection = mul((float3x3)UNITY_MATRIX_V, reflectionVector);
        float parallax = _SSRParallax * saturate(1.0 - viewSpaceReflection.z);
        float2 reflectionOffset = viewSpaceReflection.xy * parallax;
        float2 reflectionUV = screenUV + reflectionOffset + distortionOffset;
        const int SSR_BLUR_SAMPLES = 8;
        float3 reflectedColor = UNITY_SAMPLE_SCREENSPACE_TEXTURE(_BacklaceGP, reflectionUV).rgb;
        float2 blurOffset = _BacklaceGP_TexelSize.xy * _SSRBlur;
        [unroll]
        for (int i = 0; i < SSR_BLUR_SAMPLES; i++)
        {
            float angle = (float)i / SSR_BLUR_SAMPLES * 2.0 * UNITY_PI;
            float s, c;
            sincos(angle, s, c);
            float2 offset = float2(c, s) * blurOffset;
            reflectedColor += UNITY_SAMPLE_SCREENSPACE_TEXTURE(_BacklaceGP, reflectionUV + offset).rgb;
        }
        reflectedColor /= (SSR_BLUR_SAMPLES + 1);
        float fresnel_base = 1.0 - saturate(dot(Surface.NormalDir, Surface.ViewDir));
        float fresnel_powered = pow(fresnel_base, _SSRFresnelPower);
        float fresnel = saturate(_SSRFresnelBias + fresnel_powered * _SSRFresnelScale);
        float mask = UNITY_SAMPLE_TEX2D(_SSRMask, Uvs[0]).r;
        float finalStrength = fresnel * mask * _SSRIntensity;
        float3 finalReflection = reflectedColor * _SSRTint.rgb;
        if (_SSRBlendMode == 0) // additive
        {
            Surface.FinalColor.rgb += finalReflection * finalStrength;
        }
        else // alpha blend
        {
            Surface.FinalColor.rgb = lerp(Surface.FinalColor.rgb, finalReflection, finalStrength);
        }
    }
#endif // _BACKLACE_SSR

#endif // BACKLACE_EFFECTS_CGINC

    