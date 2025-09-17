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
        // Here are the changes, my darling. So simple, so clean.
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

// grabpass only features
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
                    float caOffset = _RefractionBlurStrength;
                    if (_RefractionCAUseFresnel == 1)
                    {
                        float caFresnel = fastpow(fresnel, _RefractionCAEdgeFade);
                        caOffset *= caFresnel;
                    }
                    refractedColor.r = UNITY_SAMPLE_SCREENSPACE_TEXTURE(_BacklaceGP, distortedUV + float2(caOffset, 0)).r * _RefractionCAStrength;
                    refractedColor.g = UNITY_SAMPLE_SCREENSPACE_TEXTURE(_BacklaceGP, distortedUV).g;
                    refractedColor.b = UNITY_SAMPLE_SCREENSPACE_TEXTURE(_BacklaceGP, distortedUV - float2(caOffset, 0)).b * _RefractionCAStrength;
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

        #ifndef BACKLACE_DEPTH
            UNITY_DECLARE_DEPTH_TEXTURE(_CameraDepthTexture);
            float4 _CameraDepthTexture_TexelSize;
            #define BACKLACE_DEPTH
        #endif

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
                    return 0;
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
                        case 3: // mirror
                            if (finalUV.x < x_min) finalUV.x = x_min + (x_min - finalUV.x);
                            if (finalUV.x > x_max) finalUV.x = x_max - (finalUV.x - x_max);
                            if (finalUV.y < 0.0) finalUV.y = -finalUV.y;
                            if (finalUV.y > 1.0) finalUV.y = 1.0 - (finalUV.y - 1.0);
                            break;
                    }
                    float3 reflection = tex2D(_BacklaceGP, finalUV).rgb;
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
            float3 reflectedColor = UNITY_SAMPLE_SCREENSPACE_TEXTURE(_BacklaceGP, reflectionUV).rgb;
            float2 blurOffset = _BacklaceGP_TexelSize.xy * _SSRBlur;
            [unroll]
            for (int k = 0; k < SSR_BLUR_SAMPLES; k++)
            {
                float angle = (float)k / SSR_BLUR_SAMPLES * 2.0 * UNITY_PI;
                float s, c;
                sincos(angle, s, c);
                float2 offset = float2(c, s) * blurOffset;
                reflectedColor += UNITY_SAMPLE_SCREENSPACE_TEXTURE(_BacklaceGP, reflectionUV + offset).rgb;
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
            [branch] switch((int)_SSRBlendMode)
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

#endif // BACKLACE_EFFECTS_CGINC