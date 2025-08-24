#ifndef BACKLACE_EFFECTS_CGINC
#define BACKLACE_EFFECTS_CGINC

// glitter-specific properties
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

#endif // BACKLACE_EFFECTS_CGINC

  