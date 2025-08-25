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

            // dithering threshold
            float dither_threshold = fade_factor;
            float pattern = GetTiltedCheckerboardPattern(Surface.ScreenCoords * _ScreenParams.xy);
            Surface.FinalColor.a *= step(dither_threshold, pattern);
        } else {
            // just a normal fade
            Surface.FinalColor.a *= fade_factor;
        }
    }
#endif // _BACKLACE_DISTANCE_FADE

#endif // BACKLACE_EFFECTS_CGINC

  