#ifndef BACKLACE_SHADING_CGINC
#define BACKLACE_SHADING_CGINC

// clip alpha based on the _Cutoff value or dither mask
void ClipAlpha(inout BacklaceSurfaceData Surface)
{
    #if defined(_BLENDMODE_CUTOUT)
        clip(Surface.Albedo.a - _Cutoff);
    #elif defined(_BLENDMODE_FADE)
        float dither = tex3D(_DitherMaskLOD, float3(FragData.pos.xy * 0.25, Surface.Albedo.a * 0.9375)).a;
        clip(dither - 0.01);
    #endif // _BLENDMODE_CUTOUT
}

// sample normal map
void SampleNormal()
{
    NormalMap = UnpackScaleNormal(UNITY_SAMPLE_TEX2D_SAMPLER(_BumpMap, _MainTex, BACKLACE_TRANSFORM_TEX(Uvs, _BumpMap)), _BumpScale);
}

// calculate normals from normal map
void CalculateNormals(inout float3 normal, inout float3 tangent, inout float3 bitangent, float3 normalmap)
{
    float3x3 tbn = float3x3(tangent, bitangent, normal);
    normal = normalize(mul(normalmap, tbn));
    tangent = normalize(cross(bitangent, normal));
    bitangent = normalize(cross(normal, tangent));
}

// get geometry vectors
void GetGeometryVectors(inout BacklaceSurfaceData Surface, FragmentData FragData)
{
    Surface.NormalDir = normalize(FragData.normal);
    Surface.TangentDir = normalize(UnityObjectToWorldDir(FragData.tangentDir.xyz));
    Surface.BitangentDir = normalize(cross(Surface.NormalDir, Surface.TangentDir) * FragData.tangentDir.w * unity_WorldTransformParams.w);
    Surface.ViewDir = normalize(UnityWorldSpaceViewDir(FragData.worldPos));
    Surface.ScreenCoords = FragData.pos.xy / _ScreenParams.xy;
}

// get direction vectors
void GetDirectionVectors(inout BacklaceSurfaceData Surface)
{
    CalculateNormals(Surface.NormalDir, Surface.TangentDir, Surface.BitangentDir, NormalMap);
    Surface.LightDir = normalize(UnityWorldSpaceLightDir(FragData.worldPos));
    Surface.ReflectDir = reflect(-Surface.ViewDir, Surface.NormalDir);
    Surface.HalfDir = Unity_SafeNormalize(Surface.LightDir + Surface.ViewDir);
}

// get dot products
void GetDotProducts(inout BacklaceSurfaceData Surface)
{
    Surface.UnmaxedNdotL = dot(Surface.NormalDir, Surface.LightDir);
    Surface.UnmaxedNdotL = min(Surface.UnmaxedNdotL, Surface.LightColor.a);
    #if defined(_BACKLACE_SHADOW_MAP)
        float shadowMask = UNITY_SAMPLE_TEX2D(_ShadowMap, Uvs[_ShadowMap_UV]).r;
        Surface.UnmaxedNdotL -= (shadowMask * _ShadowMapIntensity);
    #endif // _BACKLACE_SHADOW_MAP
    Surface.NdotL = max(Surface.UnmaxedNdotL, 0);
    Surface.NdotV = abs(dot(Surface.NormalDir, Surface.ViewDir));
    Surface.NdotH = max(dot(Surface.NormalDir, Surface.HalfDir), 0);
    Surface.LdotH = max(dot(Surface.LightDir, Surface.HalfDir), 0);
}

// premultiply alpha
void PremultiplyAlpha(inout BacklaceSurfaceData Surface)
{
    #if defined(_BLENDMODE_PREMULTIPLY)
        Surface.Albedo.rgb *= Surface.Albedo.a;
    #endif
}

// unity's base diffuse based on disney implementation
float DisneyDiffuse(half perceptualRoughness, inout BacklaceSurfaceData Surface)
{
    float fd90 = 0.5 + 2 * Surface.LdotH * Surface.LdotH * perceptualRoughness;
    // Two schlick fresnel term
    float lightScatter = (1 + (fd90 - 1) * Pow5(1 - Surface.NdotL));
    float viewScatter = (1 + (fd90 - 1) * Pow5(1 - Surface.NdotV));
    return lightScatter * viewScatter;
}

// get the direct diffuse contribution using disney's diffuse implementation
void GetPBRDiffuse(inout BacklaceSurfaceData Surface)
{
    Surface.Diffuse = 0;
    float ramp = DisneyDiffuse(Surface.Roughness, Surface) * Surface.NdotL;
    #if defined(_BACKLACE_PARALLAX) && defined(_BACKLACE_PARALLAX_SHADOWS)
        ramp *= ParallaxShadow;
    #endif // _BACKLACE_PARALLAX_SHADOWS
    Surface.Diffuse = Surface.Albedo * (Surface.LightColor.rgb * Surface.LightColor.a * ramp + Surface.IndirectDiffuse);
    Surface.Attenuation = ramp;
    #if defined(_BACKLACE_SHADOW_TEXTURE)
        float3 litColor = Surface.Diffuse;
        float3 shadowColor = GetTexturedShadowColor(Surface);
        Surface.Diffuse = lerp(shadowColor, litColor, Surface.Attenuation);
    #endif // _BACKLACE_SHADOW_TEXTURE
}

//modified version of Shade4PointLights
void Shade4PointLights(float3 normal, float3 worldPos, out float3 color, out float3 direction)
{
    float4 toLightX = unity_4LightPosX0 - worldPos.x;
    float4 toLightY = unity_4LightPosY0 - worldPos.y;
    float4 toLightZ = unity_4LightPosZ0 - worldPos.z;
    float4 lengthSq = 0;
    lengthSq += toLightX * toLightX;
    lengthSq += toLightY * toLightY;
    lengthSq += toLightZ * toLightZ;
    float4 ndl = 0;
    ndl += toLightX * normal.x;
    ndl += toLightY * normal.y;
    ndl += toLightZ * normal.z;
    float4 corr = rsqrt(lengthSq);
    ndl = max(0, ndl * corr);
    float4 atten = 1.0 / (1.0 + lengthSq * unity_4LightAtten0);
    float4 diff = ndl * atten;
    color = 0;
    color += unity_LightColor[0].rgb * diff.x;
    color += unity_LightColor[1].rgb * diff.y;
    color += unity_LightColor[2].rgb * diff.z;
    color += unity_LightColor[3].rgb * diff.w;
    direction = 0;
    #if defined(_BACKLACE_SPECULAR) && defined(_BACKLACE_VERTEX_SPECULAR)
        direction += (float3(toLightX.x, toLightY.x, toLightZ.x) * corr.x) * dot(unity_LightColor[0].rgb, 1) * diff.x;
        direction += (float3(toLightX.y, toLightY.y, toLightZ.y) * corr.y) * dot(unity_LightColor[1].rgb, 1) * diff.y;
        direction += (float3(toLightX.z, toLightY.z, toLightZ.z) * corr.z) * dot(unity_LightColor[2].rgb, 1) * diff.z;
        direction += (float3(toLightX.w, toLightY.w, toLightZ.w) * corr.w) * dot(unity_LightColor[3].rgb, 1) * diff.w;
    #endif // _BACKLACE_SPECULAR && _BACKLACE_VERTEX_SPECULAR
}

// toon shading
#if defined(_BACKLACE_TOON)
    // apply a gradient based on the world normal y
    void ApplyAmbientGradient(inout BacklaceSurfaceData Surface)
    {
        [branch] if (_ToggleAmbientGradient == 1) {
            float3 worldNormal = normalize(FragData.normal);
            float updownGradient = worldNormal.y * 0.5 + 0.5; // 0 when pointing down, 0.5 horizontal, 1 pointing up.
            float skyMask = smoothstep(_AmbientSkyThreshold, 1.0, updownGradient);
            float groundMask = smoothstep(_AmbientGroundThreshold, 0.0, updownGradient);
            float3 skyGradientColor = _AmbientUp.rgb * skyMask;
            float3 groundGradientColor = _AmbientDown.rgb * groundMask;
            Surface.Diffuse += (skyGradientColor + groundGradientColor) * _AmbientIntensity;
        }
    }

    // apply area tinting based on light and shadow areas
    void ApplyAreaTint(inout BacklaceSurfaceData Surface)
    {
        [branch] if (_TintMaskSource != 0)
        {
            float finalMask;
            switch(_TintMaskSource)
            {
                case 2: // tuned light
                {
                    float rawMask = Surface.UnmaxedNdotL * 0.5 + 0.5;
                    finalMask = smoothstep(_ShadowThreshold, max(_ShadowThreshold, _LitThreshold), rawMask);
                    break;
                }
                case 1: // raw light
                {
                    finalMask = Surface.UnmaxedNdotL * 0.5 + 0.5;
                    break;
                }
                default: // ramp based (from RampDotL)
                {
                    finalMask = Surface.Attenuation;
                    break;
                }
            }
            float shadowInfluence = (1 - finalMask) * _ShadowTint.a;
            Surface.Diffuse.rgb = lerp(Surface.Diffuse.rgb, Surface.Diffuse.rgb * _ShadowTint.rgb, shadowInfluence);
            float litInfluence = finalMask * _LitTint.a;
            Surface.Diffuse.rgb = lerp(Surface.Diffuse.rgb, Surface.Diffuse.rgb * _LitTint.rgb, litInfluence);
        }
    }

    #if defined(_TOONMODE_RAMP)
        // for toon lighting, we use a ramp texture
        float4 RampDotL(inout BacklaceSurfaceData Surface)
        {
            float offset = _RampOffset + (Surface.Occlusion * _OcclusionOffsetIntensity) - _OcclusionOffsetIntensity;
            float newMin = max(offset, 0);
            float newMax = max(offset +1, 0);
            float rampUv = remap(Surface.UnmaxedNdotL, -1, 1, newMin, newMax);
            float3 ramp = UNITY_SAMPLE_TEX2D(_Ramp, float2(rampUv, rampUv)).rgb;
            ramp *= _RampColor.rgb;
            float intensity = max(_ShadowIntensity, 0.001);
            ramp = remap(ramp, float3(0, 0, 0), float3(1, 1, 1), 1 - intensity, float3(1, 1, 1));
            float3 rmin = remap(_RampMin, 0, 1, 1 - intensity, 1);
            float3 rampA = remap(ramp, rmin, 1, 0, 1);
            float rampGrey = max(max(rampA.r, rampA.g), rampA.b);
            #if defined(DIRECTIONAL) || defined(DIRECTIONAL_COOKIE)
                return float4(ramp, rampGrey);
            #else // DIRECTIONAL || DIRECTIONAL_COOKIE
                return float4(rampA, rampGrey);
            #endif // DIRECTIONAL || DIRECTIONAL_COOKIE

        }

        // Specific Shade4PointLights function for ramp toon shading
        void RampDotLVertLight(float3 normal, float3 worldPos, float occlusion, out float3 color, out float3 direction)
        {
            //from Shade4PointLights function to get NdotL + attenuation
            float4 toLightX = unity_4LightPosX0 - worldPos.x;
            float4 toLightY = unity_4LightPosY0 - worldPos.y;
            float4 toLightZ = unity_4LightPosZ0 - worldPos.z;
            float4 lengthSq = 0;
            lengthSq += toLightX * toLightX;
            lengthSq += toLightY * toLightY;
            lengthSq += toLightZ * toLightZ;
            float4 ndl = 0;
            ndl += toLightX * normal.x;
            ndl += toLightY * normal.y;
            ndl += toLightZ * normal.z;
            // correct NdotL
            float4 corr = rsqrt(lengthSq);
            ndl = ndl * corr;
            //attenuation
            float4 atten = 1.0 / (1.0 + lengthSq * unity_4LightAtten0);
            float4 atten2 = saturate(1 - (lengthSq * unity_4LightAtten0 / 25));
            atten = min(atten, atten2 * atten2);
            //ramp calculation for all 4 vertex lights
            float offset = _RampOffset + (occlusion * _OcclusionOffsetIntensity) - _OcclusionOffsetIntensity;
            //Calculating ramp uvs based on offset
            float newMin = max(offset, 0);
            float newMax = max(offset +1, 0);
            float4 rampUv = remap(ndl, float4(-1, -1, -1, -1), float4(1, 1, 1, 1), float4(newMin, newMin, newMin, newMin), float4(newMax, newMax, newMax, newMax));
            float intensity = max(_ShadowIntensity, 0.001);
            float3 rmin = remap(_RampMin, 0, 1, 1 - intensity, 1);
            float3 ramp0 = remap(remap(UNITY_SAMPLE_TEX2D(_Ramp, float2(rampUv.x, rampUv.x)).rgb * _RampColor.rgb, float3(0, 0, 0), float3(1, 1, 1), 1 - intensity, float3(1, 1, 1)), rmin, 1, 0, 1).rgb * unity_LightColor[0].rgb * atten.r;
            float3 ramp1 = remap(remap(UNITY_SAMPLE_TEX2D(_Ramp, float2(rampUv.y, rampUv.y)).rgb * _RampColor.rgb, float3(0, 0, 0), float3(1, 1, 1), 1 - intensity, float3(1, 1, 1)), rmin, 1, 0, 1).rgb * unity_LightColor[1].rgb * atten.g;
            float3 ramp2 = remap(remap(UNITY_SAMPLE_TEX2D(_Ramp, float2(rampUv.z, rampUv.z)).rgb * _RampColor.rgb, float3(0, 0, 0), float3(1, 1, 1), 1 - intensity, float3(1, 1, 1)), rmin, 1, 0, 1).rgb * unity_LightColor[2].rgb * atten.b;
            float3 ramp3 = remap(remap(UNITY_SAMPLE_TEX2D(_Ramp, float2(rampUv.w, rampUv.w)).rgb * _RampColor.rgb, float3(0, 0, 0), float3(1, 1, 1), 1 - intensity, float3(1, 1, 1)), rmin, 1, 0, 1).rgb * unity_LightColor[3].rgb * atten.a;
            color = ramp0 + ramp1 + ramp2 + ramp3;
            // direction calculation
            direction = 0;
            #if defined(_BACKLACE_SPECULAR) && defined(_BACKLACE_VERTEX_SPECULAR)
                direction += (float3(toLightX.x, toLightY.x, toLightZ.x) * corr.x) * dot(ramp0, 1);
                direction += (float3(toLightX.y, toLightY.y, toLightZ.y) * corr.y) * dot(ramp1, 1);
                direction += (float3(toLightX.z, toLightY.z, toLightZ.z) * corr.z) * dot(ramp2, 1);
                direction += (float3(toLightX.w, toLightY.w, toLightZ.w) * corr.w) * dot(ramp3, 1);
            #endif // _BACKLACE_SPECULAR && _BACKLACE_VERTEX_SPECULAR
        }

        // get the direct diffuse contribution using a toon ramp
        void GetRampDiffuse(inout BacklaceSurfaceData Surface)
        {
            Surface.Diffuse = 0;
            float4 ramp = RampDotL(Surface);
            ApplyAmbientGradient(Surface);
            #if defined(_BACKLACE_PARALLAX) && defined(_BACKLACE_PARALLAX_SHADOWS)
                ramp *= ParallaxShadow;
            #endif // _BACKLACE_PARALLAX_SHADOWS
            #if defined(_BACKLACE_SHADOW_TEXTURE)
                float3 litColor;
                #if defined(DIRECTIONAL) || defined(DIRECTIONAL_COOKIE)
                    litColor = Surface.Albedo * (Surface.LightColor.rgb + Surface.IndirectDiffuse);
                #else // DIRECTIONAL || DIRECTIONAL_COOKIE
                    litColor = Surface.Albedo * Surface.LightColor.rgb * Surface.LightColor.a;
                #endif // DIRECTIONAL || DIRECTIONAL_COOKIE
                float3 shadowColor = GetTexturedShadowColor(Surface);
                Surface.Diffuse = lerp(shadowColor, litColor, GetLuma(ramp.rgb));
            #else // _BACKLACE_SHADOW_TEXTURE
                // original portion of the code before shadow texture
                #if defined(DIRECTIONAL) || defined(DIRECTIONAL_COOKIE)
                    Surface.Diffuse = Surface.Albedo * ramp.rgb * (Surface.LightColor.rgb + Surface.IndirectDiffuse);
                #else // DIRECTIONAL || DIRECTIONAL_COOKIE
                    Surface.Diffuse = Surface.Albedo * ramp.rgb * Surface.LightColor.rgb * Surface.LightColor.a;
                #endif // DIRECTIONAL || DIRECTIONAL_COOKIE
            #endif // _BACKLACE_SHADOW_TEXTURE
            Surface.Attenuation = ramp.a; // so that way specular gets the proper attenuation
            ApplyAreaTint(Surface);
        }

        // get the vertex diffuse contribution using a toon ramp
        void GetRampVertexDiffuse(inout BacklaceSurfaceData Surface)
        {
            Surface.VertexDirectDiffuse = 0;
            #if defined(VERTEXLIGHT_ON)
                #if defined(_BACKLACE_VERTEX_SPECULAR)
                    RampDotLVertLight(Surface.NormalDir, FragData.worldPos, Surface.Occlusion, VertexDirectDiffuse, VertexLightDir);
                #else
                    float3 ignoredDir;
                    RampDotLVertLight(Surface.NormalDir, FragData.worldPos, Surface.Occlusion, VertexDirectDiffuse, ignoredDir);
                #endif
                Surface.VertexDirectDiffuse *= Surface.Albedo * _VertexIntensity;
            #endif
        }
    #elif defined(_TOONMODE_ANIME) // _TOONMODE_RAMP
        // specific anime-style vertex light function
        void AnimeVertLight(float3 normal, float3 worldPos, float occlusion, out float3 color, out float3 direction)
        {
            Shade4PointLights(normal, worldPos, color, direction);
            float luma = GetLuma(color);
            float shadowMask = step(_AnimeHalftoneThreshold, luma + (1.0 - occlusion) * _AnimeOcclusionToShadow * 0.1);
            color = lerp(color * _AnimeShadowColor.rgb, color, shadowMask);
        }

        // diffuse function for anime-style lighting
        void GetAnimeDiffuse(inout BacklaceSurfaceData Surface)
        {
            float lightTerm = saturate(Surface.UnmaxedNdotL * 0.5 + 0.5);
            lightTerm = saturate(lightTerm - (1.0 - Surface.Occlusion) * _AnimeOcclusionToShadow);
            float3 finalColor = Surface.Albedo.rgb * unity_AmbientSky.rgb;
            float halftoneShadow = smoothstep(_AnimeHalftoneThreshold + _AnimeShadowSoftness, _AnimeHalftoneThreshold - _AnimeShadowSoftness, lightTerm);
            float coreShadow = smoothstep(_AnimeShadowThreshold + _AnimeShadowSoftness, _AnimeShadowThreshold - _AnimeShadowSoftness, lightTerm);
            #if defined(_BACKLACE_SHADOW_TEXTURE)
                float3 texturedHalftone = GetTexturedShadowColor(Surface, _AnimeHalftoneColor.rgb * _ShadowPatternColor.rgb);
                float3 texturedCore = GetTexturedShadowColor(Surface, _AnimeShadowColor.rgb * _ShadowPatternColor.rgb);
                finalColor = lerp(finalColor, texturedHalftone, halftoneShadow);
                finalColor = lerp(finalColor, texturedCore, coreShadow);
            #else // _BACKLACE_SHADOW_TEXTURE
                // original portion of the code before shadow texture
                finalColor = lerp(finalColor, Surface.Albedo.rgb * _AnimeHalftoneColor.rgb, halftoneShadow);
                finalColor = lerp(finalColor, Surface.Albedo.rgb * _AnimeShadowColor.rgb, coreShadow);
            #endif // _BACKLACE_SHADOW_TEXTURE
            float3 directLight = Surface.LightColor.rgb * Surface.Albedo.rgb;
            float lightMask = 1.0 - halftoneShadow;
            finalColor = lerp(finalColor, directLight, lightMask);
            Surface.Diffuse = finalColor;
            ApplyAmbientGradient(Surface);
            #if defined(_BACKLACE_PARALLAX) && defined(_BACKLACE_PARALLAX_SHADOWS)
                Surface.Diffuse *= ParallaxShadow;
            #endif
            Surface.Attenuation = lightMask;
            ApplyAreaTint(Surface);
        }

        // get the vertex diffuse contribution using anime-style lighting
        void GetAnimeVertexDiffuse(inout BacklaceSurfaceData Surface)
        {
            Surface.VertexDirectDiffuse = 0;
            #if defined(VERTEXLIGHT_ON)
                #if defined(_BACKLACE_VERTEX_SPECULAR)
                    AnimeVertLight(Surface.NormalDir, FragData.worldPos, Surface.Occlusion, Surface.VertexDirectDiffuse, VertexLightDir);
                #else
                    float3 ignoredDir;
                    AnimeVertLight(Surface.NormalDir, FragData.worldPos, Surface.Occlusion, Surface.VertexDirectDiffuse, ignoredDir);
                #endif
                Surface.VertexDirectDiffuse *= Surface.Albedo * _VertexIntensity;
            #endif
        }
    #endif // _TOONMODE_ANIME

    // wrapper function for toon diffuse
    void GetToonDiffuse(inout BacklaceSurfaceData Surface)
    {
        #if defined(_TOONMODE_RAMP)
            // traditional toony ramp
            GetRampDiffuse(Surface);
            GetRampVertexDiffuse(Surface);
        #elif defined(_TOONMODE_ANIME) // _TOONMODE_RAMP
            // procedural anime style
            GetAnimeDiffuse(Surface);
            GetAnimeVertexDiffuse(Surface);
        #endif // _TOONMODE_RAMP
    }
#endif // _BACKLACE_TOON

// get vertex diffuse for vertex lighting
void GetPBRVertexDiffuse(inout BacklaceSurfaceData Surface)
{
    Surface.VertexDirectDiffuse = 0;
    #if defined(VERTEXLIGHT_ON)
        #if defined(_BACKLACE_VERTEX_SPECULAR)
            Shade4PointLights(Surface.NormalDir, FragData.worldPos, Surface.VertexDirectDiffuse, VertexLightDir);
        #else
            float3 ignoredDir;
            Shade4PointLights(Surface.NormalDir, FragData.worldPos, Surface.VertexDirectDiffuse, ignoredDir);
        #endif
        Surface.VertexDirectDiffuse *= Surface.Albedo * _VertexIntensity;
    #endif
}

// diffuse add
void AddDiffuse(inout BacklaceSurfaceData Surface)
{
    Surface.FinalColor.rgb += Surface.Diffuse + Surface.VertexDirectDiffuse;
}

// ...
void AddAlpha(inout BacklaceSurfaceData Surface)
{
    // stored as -1 if not set
    // note: if ever weird transparency blending, THIS is likely the cause
    if (Surface.FinalColor.a == -1) {
        Surface.FinalColor.a = Surface.Albedo.a;
    } else {
        Surface.FinalColor.a *= Surface.Albedo.a;
    }
}

// ...
inline half3 FresnelTerm(half3 F0, half cosA)
{
    half t = Pow5(1 - cosA);   // ala Schlick interpoliation
    return F0 + (1 - F0) * t;
}

// specular-only features
#if defined(_BACKLACE_SPECULAR)

    // ...
    half4 Unity_GlossyEnvironment(UNITY_ARGS_TEXCUBE(tex), half4 hdr, Unity_GlossyEnvironmentData glossIn)
    {
        half perceptualRoughness = glossIn.roughness;
        perceptualRoughness = perceptualRoughness * (1.7 - 0.7 * perceptualRoughness);
        half mip = perceptualRoughness * UNITY_SPECCUBE_LOD_STEPS;
        half3 R = glossIn.reflUVW;
        half4 rgbm = UNITY_SAMPLE_TEXCUBE_LOD(tex, R, mip);
        return float4(DecodeHDR(rgbm, hdr), rgbm.a);
    }

    // gtr2 distribution function
    float GTR2(float NdotH, float a)
    {
        float a2 = a * a;
        float t = 1 + (a2 - 1) * NdotH * NdotH;
        return a2 / (UNITY_PI * t * t + 1e-7f);
    }

    // ggx distribution function
    float smithG_GGX(float NdotV, float alphaG)
    {
        float a = alphaG * alphaG;
        float b = NdotV * NdotV;
        return 1 / (NdotV + sqrt(a + b - a * b) + 1e-7f);
    }

    // gets the indirect lighting color from a fallback cubemap using the reflected direction and remapped roughness
    void GetFallbackCubemap(inout BacklaceSurfaceData Surface)
    {
        Surface.CustomIndirect = texCUBElod(_FallbackCubemap, half4(Surface.ReflectDir.xyz, remap(Surface.SquareRoughness, 1, 0, 5, 0))).rgb;
    }

    // modified tangent space
    float3 GetModifiedTangent(float3 tangentTS, float3 tangentDir)
    {
        float3x3 worldToTangent;
        worldToTangent[0] = float3(1, 0, 0);
        worldToTangent[1] = float3(0, 1, 0);
        worldToTangent[2] = float3(0, 0, 1);
        float3 tangentTWS = mul(tangentTS, worldToTangent);
        float3 fTangent;
        if (tangentTS.z < 1)
        {
            fTangent = tangentTWS;
        }
        else
        {
            fTangent = tangentDir;
        }
        return fTangent;
    }

    // gtr2 anisotropic distribution function
    float GTR2_aniso(float NdotH, float HdotX, float HdotY, float ax, float ay)
    {
        return 1 / (UNITY_PI * ax * ay * sqr(sqr(HdotX / ax) + sqr(HdotY / ay) + NdotH * NdotH));
    }

    // ggx anisotropic distribution function
    float smithG_GGX_aniso(float NdotV, float VdotX, float VdotY, float ax, float ay)
    {
        return 1 / (NdotV + sqrt(sqr(VdotX * ax) + sqr(VdotY * ay) + sqr(NdotV)));
    }

    // shift a tangent
    float3 ShiftTangent(float3 T, float3 N, float shift)
    {
        return normalize(T + shift * N);
    }

    // setup albedo and specular color
    void SetupDFG(inout BacklaceSurfaceData Surface)
    {
        float3 dfguv = float3(Surface.NdotV, Surface.Roughness, 0);
        Surface.Dfg = _DFG.Sample(sampler_DFG, dfguv).xyz;
        Surface.Dfg.y = max(Surface.Dfg.y, 1e-7f); // prevent division by zero
        Surface.EnergyCompensation = lerp(1.0 + Surface.SpecularColor * (1.0 / Surface.Dfg.y - 1.0), 1, _DFGType);
    }

    // standard direct specular calculation (used in a few modes)
    void StandardDirectSpecular(float ndotH, float ndotL, float ndotV, out float outNDF, out float outGFS, inout BacklaceSurfaceData Surface)
    {
        outNDF = 0;
        outGFS = 0;
        outNDF = GTR2(ndotH, Surface.SquareRoughness) * UNITY_PI;
        outGFS = smithG_GGX(max(ndotL, lerp(0.3, 0, Surface.SquareRoughness)), Surface.Roughness) * smithG_GGX(ndotV, Surface.Roughness);
    }

    #if defined(_SPECULARMODE_ANISOTROPIC) // _SPECULARMODE_STANDARD || _SPECULARMODE_ANISOTROPIC || _SPECULARMODE_TOON || _SPECULARMODE_HAIR
        // calculates anisotropic direct specular reflection using tangent space and view/light directions
        void AnisotropicDirectSpecular(float3 tangentDir, float3 bitangentDir, float3 lightDir, float3 halfDir, float ndotH, float ndotL, float ndotV, out float outNDF, out float outGFS, inout BacklaceSurfaceData Surface)
        {
            outNDF = 0;
            outGFS = 0;
            float4 tangentTS = UNITY_SAMPLE_TEX2D_SAMPLER(_TangentMap, _MainTex, BACKLACE_TRANSFORM_TEX(Uvs, _TangentMap));
            float anisotropy = tangentTS.a * _Anisotropy;
            float3 tangent = GetModifiedTangent(tangentTS.rgb, tangentDir);
            float3 anisotropyDirection = anisotropy >= 0.0 ? bitangentDir : tangentDir;
            float3 anisotropicTangent = cross(anisotropyDirection, Surface.ViewDir);
            float3 anisotropicNormal = cross(anisotropicTangent, anisotropyDirection);
            float bendFactor = abs(anisotropy) * saturate(1 - (Pow5(1 - Surface.SquareRoughness)));
            float3 bentNormal = normalize(lerp(Surface.NormalDir, anisotropicNormal, bendFactor));
            Surface.ReflectDir = reflect(-Surface.ViewDir, bentNormal);
            float TdotH = dot(tangent, halfDir);
            float TdotL = dot(tangent, lightDir);
            float BdotH = dot(bitangentDir, halfDir);
            float BdotL = dot(bitangentDir, lightDir);
            float TdotV = dot(Surface.ViewDir, tangent);
            float BdotV = dot(bitangentDir, Surface.ViewDir);
            float ax = max(Surface.SquareRoughness * (1.0 + anisotropy), 0.005);
            float ay = max(Surface.SquareRoughness * (1.0 - anisotropy), 0.005);
            outNDF = GTR2_aniso(ndotH, TdotH, BdotH, ax, ay) * UNITY_PI;
            outGFS = smithG_GGX_aniso(ndotL, TdotL, BdotL, ax, ay);
            outGFS *= smithG_GGX_aniso(ndotV, TdotV, BdotV, ax, ay);
        }
    #elif defined(_SPECULARMODE_TOON) // _SPECULARMODE_STANDARD || _SPECULARMODE_ANISOTROPIC || _SPECULARMODE_TOON || _SPECULARMODE_HAIR
        // toon highlights specular
        float3 ApplyToonHighlights(float NDF, inout BacklaceSurfaceData Surface)
        {
            float newMin = max(_HighlightRampOffset, 0);
            float newMax = max(_HighlightRampOffset +1, 0);
            float Duv = remap(clamp(NDF, 0, 2), 0, 2, newMin, newMax);
            return UNITY_SAMPLE_TEX2D(_HighlightRamp, float2(Duv, Duv)).rgb * _HighlightRampColor.rgb * _HighlightIntensity * 10 * (1 - Surface.Metallic + (0.2 * Surface.Metallic));
        }
    #elif defined(_SPECULARMODE_HAIR) // _SPECULARMODE_STANDARD || _SPECULARMODE_ANISOTROPIC || _SPECULARMODE_TOON || _SPECULARMODE_HAIR
        // kajiya-kay hair specular
        float3 HairDirectSpecular(float3 tangentDir, float3 lightDir, inout BacklaceSurfaceData Surface)
        {
            float2 flow = UNITY_SAMPLE_TEX2D(_HairFlowMap, Uvs[_HairFlowMap_UV]).rg * 2 - 1;
            float3 hairTangent = normalize(flow.x * Surface.TangentDir + flow.y * Surface.BitangentDir);
            float3 shiftedTangent1 = normalize(hairTangent + Surface.NormalDir * _PrimarySpecularShift);
            float dotT1L = dot(shiftedTangent1, lightDir);
            float dotT1V = dot(shiftedTangent1, Surface.ViewDir);
            float sinT1L = sqrt(1.0 - dotT1L * dotT1L);
            float sinT1V = sqrt(1.0 - dotT1V * dotT1V);
            float primarySpec = pow(saturate(dotT1L * dotT1V + sinT1L * sinT1V), _SpecularExponent);
            float3 shiftedTangent2 = normalize(hairTangent + Surface.NormalDir * _SecondarySpecularShift);
            float dotT2L = dot(shiftedTangent2, lightDir);
            float dotT2V = dot(shiftedTangent2, Surface.ViewDir);
            float sinT2L = sqrt(1.0 - dotT2L * dotT2L);
            float sinT2V = sqrt(1.0 - dotT2V * dotT2V);
            float secondarySpec = pow(saturate(dotT2L * dotT2V + sinT2L * sinT2V), _SpecularExponent);
            float3 secondaryColor = Surface.Albedo.rgb * _SecondarySpecularColor.rgb;
            return (primarySpec * Surface.SpecularColor) + (secondarySpec * secondaryColor);
        }
    #elif defined(_SPECULARMODE_CLOTH)
        // charlie sheen ndf as Estevez and Kulla of Sony Imageworks describe
        float CharlieSheenNDF(float roughness, float NdotH)
        {
            float invAlpha = 1.0 / roughness;
            float cos2h = NdotH * NdotH;
            float sin2h = max(1.0 - cos2h, 0.0078125); // prevent fp16 issues
            // pow(sin^2(h), invA * 0.5) is the same as pow(sin(h), invA) but faster.
            return (2.0 + invAlpha) * pow(sin2h, invAlpha * 0.5) / (2.0 * UNITY_PI);
        }
    #endif // _SPECULARMODE_STANDARD || _SPECULARMODE_ANISOTROPIC || _SPECULARMODE_TOON || _SPECULARMODE_HAIR || _SPECULARMODE_CLOTH

    // ...
    void GetIndirectSpecular(inout BacklaceSurfaceData Surface)
    {
        Unity_GlossyEnvironmentData envData;
        envData.roughness = Surface.Roughness;
        envData.reflUVW = BoxProjectedCubemapDirection(Surface.ReflectDir, FragData.worldPos, unity_SpecCube0_ProbePosition, unity_SpecCube0_BoxMin, unity_SpecCube0_BoxMax);
        float4 indirectSpecularRGBA = Unity_GlossyEnvironment(UNITY_PASS_TEXCUBE(unity_SpecCube0), unity_SpecCube0_HDR, envData);
        #if defined(UNITY_SPECCUBE_BLENDING) && !defined(SHADER_API_MOBILE)
            UNITY_BRANCH
            if (unity_SpecCube0_BoxMin.w < 0.99999)
            {
                envData.reflUVW = BoxProjectedCubemapDirection(Surface.ReflectDir, FragData.worldPos, unity_SpecCube1_ProbePosition, unity_SpecCube1_BoxMin, unity_SpecCube1_BoxMax);
                float4 indirectSpecularRGBA1 = Unity_GlossyEnvironment(UNITY_PASS_TEXCUBE_SAMPLER(unity_SpecCube1, unity_SpecCube0), unity_SpecCube1_HDR, envData);
                indirectSpecularRGBA = lerp(indirectSpecularRGBA1, indirectSpecularRGBA, unity_SpecCube0_BoxMin.w);
            }
        #endif
        Surface.IndirectSpecular = indirectSpecularRGBA.rgb;
        if ((_IndirectFallbackMode > 0 && indirectSpecularRGBA.a == 0) || (_IndirectOverride > 0))
        {
            //using the fake specular probe toned down based on the average light, it's not phisically accurate
            //but having a probe that reflects arbitrary stuff isn't accurate to begin with
            half lightColGrey = max((Surface.LightColor.r + Surface.LightColor.g + Surface.LightColor.b) / 3, (Surface.IndirectDiffuse.r + Surface.IndirectDiffuse.g + Surface.IndirectDiffuse.b) / 3);
            Surface.IndirectSpecular = Surface.CustomIndirect * min(lightColGrey, 1);
        }
        float horizon = min(1 + Surface.NdotH, 1.0);
        float grazingTerm = saturate(1 - Surface.SquareRoughness + (1 - Surface.OneMinusReflectivity));
        Surface.Dfg.x *= lerp(1.0, saturate(dot(Surface.IndirectDiffuse, 1.0)), Surface.Occlusion);
        Surface.IndirectSpecular *= Surface.EnergyCompensation * horizon * horizon * lerp(lerp(Surface.Dfg.xxx, Surface.Dfg.yyy, Surface.SpecularColor), Surface.SpecularColor * Surface.Dfg.z, _DFGType);
        #if defined(_BACKLACE_CLEARCOAT)
            Surface.IndirectSpecular *= _ClearcoatReflectionStrength;
        #endif // _BACKLACE_CLEARCOAT
    }

    // ...
    void AddIndirectSpecular(inout BacklaceSurfaceData Surface)
    {
        Surface.FinalColor.rgb += Surface.IndirectSpecular * clamp(pow(Surface.NdotV + Surface.Occlusion, exp2(-16.0 * Surface.SquareRoughness - 1.0)) - 1.0 + Surface.Occlusion, 0.0, 1.0);
    }

    // direct specular calculations
    float3 CalculateDirectSpecular(float3 tangentDir, float3 bitangentDir, float3 lightDir, float3 halfDir, float ndotH, float ndotL, float ndotV, float ldotH, float attenuation, inout BacklaceSurfaceData Surface)
    {
        float NDF_Term, GFS_Term;
        float3 ToonHighlight_Term;
        float3 specTerm = 0; // using local variable for the result
        #if defined(_SPECULARMODE_STANDARD)
            StandardDirectSpecular(ndotH, ndotL, ndotV, NDF_Term, GFS_Term, Surface);
            specTerm = GFS_Term * NDF_Term;
        #elif defined(_SPECULARMODE_ANISOTROPIC)
            AnisotropicDirectSpecular(tangentDir, bitangentDir, lightDir, halfDir, ndotH, ndotL, ndotV, NDF_Term, GFS_Term, Surface);
            specTerm = GFS_Term * NDF_Term;
        #elif defined(_SPECULARMODE_TOON)
            StandardDirectSpecular(ndotH, ndotL, ndotV, NDF_Term, GFS_Term, Surface);
            ToonHighlight_Term = ApplyToonHighlights(NDF_Term, Surface);
            specTerm = GFS_Term * ToonHighlight_Term;
        #elif defined(_SPECULARMODE_HAIR)
            specTerm = HairDirectSpecular(tangentDir, lightDir, Surface);
        #elif defined(_SPECULARMODE_CLOTH)
            NDF_Term = CharlieSheenNDF(Surface.Roughness * _SheenRoughness, ndotH);
            specTerm = NDF_Term * _SheenColor.rgb * _SheenColor.a * _SheenIntensity;
            return max(0, specTerm * attenuation); // don't need rest of logic..
        #endif // _SPECULARMODE_STANDARD || _SPECULARMODE_ANISOTROPIC || _SPECULARMODE_TOON || _SPECULARMODE_HAIR || _SPECULARMODE_CLOTH
        // finalise the term
        specTerm *= FresnelTerm(Surface.SpecularColor, ldotH) * Surface.EnergyCompensation;
        #ifdef UNITY_COLORSPACE_GAMMA
            specTerm = sqrt(max(1e-4h, specTerm));
        #endif
        specTerm = max(0, specTerm * attenuation);
        specTerm *= any(Surface.SpecularColor) ? 1.0 : 0.0;
        return specTerm;
    }

    // ...
    void AddDirectSpecular(inout BacklaceSurfaceData Surface)
    {
        Surface.FinalColor.rgb += Surface.DirectSpecular * Surface.SpecLightColor.rgb * Surface.SpecLightColor.a;
    }

    // vertex specular feature
    #if defined(_BACKLACE_VERTEX_SPECULAR)
        void AddVertexSpecular(inout BacklaceSurfaceData Surface)
        {
            float3 VLightDir = normalize(VertexLightDir);
            if (dot(VLightDir, VLightDir) < 0.01) return;
            float3 V_HalfDir = normalize(VLightDir + Surface.ViewDir);
            float V_NdotL = saturate(dot(Surface.NormalDir, VLightDir));
            float V_NdotH = saturate(dot(Surface.NormalDir, V_HalfDir));
            float V_LdotH = saturate(dot(VLightDir, V_HalfDir));
            // note: just passing 1.0 for attenuation as the colour is already attenuated
            float3 VertexSpecular = CalculateDirectSpecular(Surface.TangentDir, Surface.BitangentDir, VLightDir, V_HalfDir, V_NdotH, V_NdotL, Surface.NdotV, V_LdotH, 1.0, Surface);
            Surface.FinalColor.rgb += VertexSpecular * Surface.VertexDirectDiffuse;
        }
    #endif // _BACKLACE_VERTEX_SPECULAR

#endif // _BACKLACE_SPECULAR

// rim-only features
#if defined(_BACKLACE_RIMLIGHT)
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

// clearcoat-only features
#if defined(_BACKLACE_CLEARCOAT)
    void CalculateClearcoat(inout BacklaceSurfaceData Surface, out float3 highlight, out float3 occlusion)
    {
        float4 clearcoatMap = UNITY_SAMPLE_TEX2D(_ClearcoatMap, Uvs[_ClearcoatMap_UV]);
        float mask = _ClearcoatStrength * clearcoatMap.r; 
        float roughness = _ClearcoatRoughness * clearcoatMap.g;
        float3 F0 = 0.04;
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
            float3 F0 = 0.04;
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

// matcap-only features
#if defined(_BACKLACE_MATCAP)
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

// cubemap-only features
#if defined(_BACKLACE_CUBEMAP)
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

// parallax-only features
#if defined(_BACKLACE_PARALLAX)
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
        #if defined(_BACKLACE_PARALLAX_SHADOWS)
            ParallaxShadow = 1.0;
            float3 lightDirTS = float3(dot(Surface.LightDir, Surface.TangentDir), dot(Surface.LightDir, Surface.BitangentDir), dot(Surface.LightDir, Surface.NormalDir));
            float shadowSteps = _ParallaxShadowSteps;
            float shadowStepSize = 1.0 / shadowSteps;
            float2 shadowStep = lightDirTS.xy * _ParallaxStrength * shadowStepSize;
            float shadowRayHeight = surfaceHeight + shadowStepSize;
            [loop] for (int j = 0; j < shadowSteps; j++)
            {
                float shadowSampleHeight = _ParallaxMap.SampleLevel(sampler_ParallaxMap, uv + shadowStep * j, 0).r;
                if (shadowSampleHeight > shadowRayHeight)
                {
                    ParallaxShadow = 0.0;
                    break;
                }
                shadowRayHeight += shadowStepSize;
            }
            ParallaxShadow = lerp(1.0, ParallaxShadow, _ParallaxShadowStrength);
        #endif // _BACKLACE_PARALLAX_SHADOWS
    }
#endif // _BACKLACE_PARALLAX

// subsurface scattering-only features
#if defined(_BACKLACE_SSS)
    void ApplySubsurfaceScattering(inout BacklaceSurfaceData Surface)
    {
        float thickness = UNITY_SAMPLE_TEX2D(_ThicknessMap, Uvs[_ThicknessMap_UV]).r;
        float3 distortedLightDir = normalize(Surface.LightDir + Surface.NormalDir * _SSSDistortion);
        float sssDot = saturate(dot(Surface.ViewDir, -distortedLightDir));
        sssDot = pow(sssDot, _SSSSpread);
        float3 sssColor = sssDot * Surface.LightColor.rgb * _SSSColor.rgb * thickness * _SSSStrength;
        sssColor = lerp(sssColor, sssColor * Surface.Albedo.rgb, _SSSBaseColorMix);
        Surface.Diffuse += sssColor;
    }
#endif // _BACKLACE_SSS

// detail maps-only features
#if defined(_BACKLACE_DETAIL)
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

// post-processing-only features
#if defined(_BACKLACE_POST_PROCESSING)
    void ApplyPostProcessing(inout BacklaceSurfaceData Surface, FragmentData i)
    {
        float3 finalColor = Surface.FinalColor.rgb;
        // rgb tint/replace
        float3 tintedColor = lerp(finalColor * _RGBColor.rgb, _RGBColor.rgb, _RGBBlendMode);
        finalColor = tintedColor;
        // hsv manipulation
        float3 hsv = RGBtoHSV(finalColor);
        [branch] if (_HSVMode == 0) // additive
        {
            hsv.x = frac(hsv.x + _HSVHue);
            hsv.y += _HSVSaturation - 1.0;
            hsv.z += _HSVValue - 1.0;
        }
        else // multiplicative
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

// dissolve-only features
#if defined(_BACKLACE_DISSOLVE)
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

// pathing feature
#if defined(_BACKLACE_PATHING)
    void ApplyPathing(inout BacklaceSurfaceData Surface)
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
        float pathAlpha = 0;
        switch(_PathingType)
        {
            case 0: // fill
                pathAlpha = pathTime > pathValue;
                break;
            case 1: // path
                pathAlpha = 1.0 - saturate(abs(pathTime - pathValue) / _PathingWidth);
                break;
            case 2: // loop
                float loop_dist = abs(pathTime - pathValue);
                loop_dist = min(loop_dist, 1.0 - loop_dist);
                pathAlpha = 1.0 - saturate(loop_dist / _PathingWidth);
            break;
        }
        pathAlpha = smoothstep(0, _PathingSoftness, pathAlpha);
        #if defined(_BACKLACE_AUDIOLINK)
            pathAlpha *= i.alChannel2.x;
        #endif // _BACKLACE_AUDIOLINK
        if (pathAlpha <= 0.001) return;
        float3 pathEmission = pathAlpha * _PathingColor.rgb * _PathingEmission;
        switch(_PathingBlendMode)
        {
            case 0: // additive
                Surface.FinalColor.rgb += pathEmission;
                break;
            case 1: // multiply
                Surface.FinalColor.rgb = lerp(Surface.FinalColor.rgb, Surface.FinalColor.rgb * _PathingColor.rgb, pathAlpha);
                break;
            case 2: // alpha blend
                float blendIntensity = pathAlpha * _PathingColor.a;
                Surface.FinalColor.rgb = lerp(Surface.FinalColor.rgb, _PathingColor.rgb, blendIntensity);
                Surface.FinalColor.rgb += pathEmission;
                break;
        }
    }
#endif // _BACKLACE_PATHING

// screen space rim feature
#if defined(_BACKLACE_DEPTH_RIMLIGHT) 
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

#endif // BACKLACE_SHADING_CGINC