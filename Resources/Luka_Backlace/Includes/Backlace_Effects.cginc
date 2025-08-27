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
        float sparkle = pow(saturate(dot(Surface.ViewDir, glitter_normal)), _GlitterContrast);
        float3 glitter_color = _GlitterTint.rgb;
        if (_ToggleGlitterRainbow > 0)
        {
            float rainbow_time = _Time.y * _GlitterRainbowSpeed;
            glitter_color = lerp(glitter_color, Sinebow(unique_flake_id + rainbow_time), _ToggleGlitterRainbow);
        }
        final_glitter = glitter_mask * glitter_color * _GlitterBrightness;
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

    void ApplyIridescence(inout BacklaceSurfaceData Surface)
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
        float finalIntensity = _IridescenceIntensity * pow(fresnel_base, 2.0) * mask;
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
                    _ShadowPatternTriplanarSharpness, true
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

#endif // BACKLACE_EFFECTS_CGINC

  