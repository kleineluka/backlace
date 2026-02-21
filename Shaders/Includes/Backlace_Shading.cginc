#ifndef BACKLACE_SHADING_CGINC
#define BACKLACE_SHADING_CGINC


// [ ♡ ] ────────────────────── [ ♡ ]
//
//          Alpha Helpers
//
// [ ♡ ] ────────────────────── [ ♡ ]


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

// premultiply alpha
void PremultiplyAlpha(inout BacklaceSurfaceData Surface)
{
    #if defined(_BLENDMODE_PREMULTIPLY)
        Surface.Albedo.rgb *= Surface.Albedo.a;
    #endif
}

// add alpha
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


// [ ♡ ] ────────────────────── [ ♡ ]
//
//           Misc Helpers
//
// [ ♡ ] ────────────────────── [ ♡ ]


// derive normals from albedo
float3 AlbedoToNormal(float2 uv, Texture2D tex, SamplerState sampler_tex, float4 texelSize, float strength, float offset)
{
    float2 totalOffset = texelSize.xy * offset;
    float h = GetLuma(tex.Sample(sampler_tex, uv).rgb);
    float hX = GetLuma(tex.Sample(sampler_tex, uv + float2(totalOffset.x, 0)).rgb);
    float hY = GetLuma(tex.Sample(sampler_tex, uv + float2(0, totalOffset.y)).rgb);
    float dHdx = (h - hX) * strength;
    float dHdy = (h - hY) * strength;
    return normalize(float3(dHdx, dHdy, 1.0));
}

// sample normal map
void SampleNormal()
{
    if (_UseBump == 1) 
    {
        if (_BumpFromAlbedo == 1) 
        {
            // derive normals from albedo
            NormalMap = AlbedoToNormal(
                BACKLACE_TRANSFORM_TEX(Uvs, _MainTex),
                _MainTex,
                sampler_MainTex,
                _MainTex_TexelSize,
                _BumpScale,
                _BumpFromAlbedoOffset
            );
        } 
        else 
        {
            // standard normal map sampling
            NormalMap = UnpackScaleNormal(UNITY_SAMPLE_TEX2D_SAMPLER(_BumpMap, _MainTex, BACKLACE_TRANSFORM_TEX(Uvs, _BumpMap)), _BumpScale);
        }
    } 
    else
    {
        // fall back to default normal
        NormalMap = float3(0.0, 0.0, 1.0);
    }
}

// get geometry vectors
void GetGeometryVectors(inout BacklaceSurfaceData Surface, FragmentData FragData)
{
    Surface.NormalDir = normalize(FragData.normal);
    Surface.TangentDir = normalize(UnityObjectToWorldDir(FragData.tangentDir.xyz));
    Surface.BitangentDir = normalize(cross(Surface.NormalDir, Surface.TangentDir) * FragData.tangentDir.w * unity_WorldTransformParams.w);
    [branch] if (_FlipBackfaceNormals == 1 && !Surface.IsFrontFace)
    {
        Surface.NormalDir *= -1;
        Surface.TangentDir *= -1;
        Surface.BitangentDir *= -1;
    }
    Surface.ViewDir = normalize(UnityWorldSpaceViewDir(FragData.worldPos));
    Surface.ScreenCoords = FragData.pos.xy / _ScreenParams.xy;
}


// [ ♡ ] ────────────────────── [ ♡ ]
//
//    Lighting Wrappers/Helpers
//
// [ ♡ ] ────────────────────── [ ♡ ]


// wrapper to decide whether to use stylised attenuation or not
float StyliseAttenuation(float vanilla, float stylised)
{
    if (_AttenuationShaded == 1)
    {
        return stylised;
    }
    else
    {
        return vanilla;
    }
}

// decide on how to stack the indirect lighting with the direct lighting
float3 CombineDiffuses(float3 albedo, float3 directLight, float3 indirectLight)
{
    if (_IndirectAlbedo)
    {
        return float3(albedo * (directLight + indirectLight));
    }
    else
    {
       return float3((albedo * directLight) + indirectLight);
    }
}


// [ ♡ ] ────────────────────── [ ♡ ]
//
//      PBR (Standard) Shading
//
// [ ♡ ] ────────────────────── [ ♡ ]


// unity's base diffuse based on disney implementation
float DisneyDiffuse(half perceptualRoughness, inout BacklaceSurfaceData Surface)
{
    float fd90 = 0.5 + 2 * Surface.LdotH * Surface.LdotH * perceptualRoughness;
    // two schlick fresnel term
    float lightScatter = (1 + (fd90 - 1) * Pow5(1 - Surface.NdotL));
    float viewScatter = (1 + (fd90 - 1) * Pow5(1 - Surface.NdotV));
    return lightScatter * viewScatter;
}

// get the direct diffuse contribution using disney's diffuse implementation
void GetPBRDiffuse(inout BacklaceSurfaceData Surface)
{
    Surface.Diffuse = 0;
    float diff = DisneyDiffuse(Surface.Roughness, Surface) * Surface.NdotL;
    #if defined(_BACKLACE_LTCGI)
        float2 ltcgi_lmUV = 0;
        #if defined(LIGHTMAP_ON)
            ltcgi_lmUV = FragData.lightmapUV;
        #endif // LIGHTMAP_ON
        LTCGI_Contribution(
            FragData.worldPos,
            Surface.NormalDir,
            Surface.ViewDir,
            Surface.Roughness,
            ltcgi_lmUV,
            Surface.IndirectDiffuse,
            Surface.IndirectSpecular
        );
    #endif // _BACKLACE_LTCGI
    Surface.Attenuation = StyliseAttenuation(Surface.LightColor.a, diff * Surface.LightColor.a);
    float3 directLight = (Surface.LightColor.rgb * Surface.LightColor.a) * lerp(1, diff, _DirectDiffuse);
    float3 indirectLight = Surface.IndirectDiffuse * lerp(1, diff, _IndirectDiffuse);
    Surface.Diffuse = CombineDiffuses(Surface.Albedo, directLight, indirectLight);
    #if defined(_BACKLACE_SHADOW_TEXTURE)
        float3 litColor = Surface.Diffuse;
        float3 shadowColor = GetTexturedShadowColor(Surface, directLight, litColor);
        Surface.Diffuse = lerp(shadowColor, litColor, Surface.LightColor.a);
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
    #if defined(_BACKLACE_SPECULAR) && defined(VERTEXLIGHT_ON)
        if (_ToggleVertexSpecular == 1)
        {
            direction += (float3(toLightX.x, toLightY.x, toLightZ.x) * corr.x) * dot(unity_LightColor[0].rgb, 1) * diff.x;
            direction += (float3(toLightX.y, toLightY.y, toLightZ.y) * corr.y) * dot(unity_LightColor[1].rgb, 1) * diff.y;
            direction += (float3(toLightX.z, toLightY.z, toLightZ.z) * corr.z) * dot(unity_LightColor[2].rgb, 1) * diff.z;
            direction += (float3(toLightX.w, toLightY.w, toLightZ.w) * corr.w) * dot(unity_LightColor[3].rgb, 1) * diff.w;
        }
    #endif // _BACKLACE_SPECULAR && VERTEXLIGHT_ON
}

// get vertex diffuse for vertex lighting
void GetPBRVertexDiffuse(inout BacklaceSurfaceData Surface)
{
    Surface.VertexDirectDiffuse = 0;
    #if defined(_BACKLACE_SPECULAR) && defined(VERTEXLIGHT_ON)
        if (_ToggleVertexSpecular == 1)
        {
            Shade4PointLights(Surface.NormalDir, FragData.worldPos, Surface.VertexDirectDiffuse, VertexLightDir);
        }
        else
        {
            float3 ignoredDir;
            Shade4PointLights(Surface.NormalDir, FragData.worldPos, Surface.VertexDirectDiffuse, ignoredDir);
        }
        Surface.VertexDirectDiffuse *= Surface.Albedo;
    #elif defined(VERTEXLIGHT_ON) // _BACKLACE_SPECULAR && VERTEXLIGHT_ON
        float3 ignoredDir;
        Shade4PointLights(Surface.NormalDir, FragData.worldPos, Surface.VertexDirectDiffuse, ignoredDir);
        Surface.VertexDirectDiffuse *= Surface.Albedo;
    #endif // _BACKLACE_SPECULAR && VERTEXLIGHT_ON
}


// [ ♡ ] ────────────────────── [ ♡ ]
//
//          Anime Shading
//
// [ ♡ ] ────────────────────── [ ♡ ]


#if defined(BACKLACE_TOON)


    // [ ♡ ] ────────────────────── [ ♡ ]
    //
    //          Anime Mixins
    //  These can be mixed into any mode.
    //
    // [ ♡ ] ────────────────────── [ ♡ ]


    #if defined(_BACKLACE_ANIME_EXTRAS)
        // apply a gradient based on the world normal y
        void ApplyAmbientGradient(inout BacklaceSurfaceData Surface)
        {
            // avoid rendering per-light in add pass
            #if defined(UNITY_PASS_FORWARDBASE)
                [branch] if (_ToggleAmbientGradient == 1) 
                {
                    float3 worldNormal = normalize(FragData.normal);
                    float updownGradient = worldNormal.y * 0.5 + 0.5; // 0 when pointing down, 0.5 horizontal, 1 pointing up.
                    float skyMask = smoothstep(_AmbientSkyThreshold, 1.0, updownGradient);
                    float groundMask = smoothstep(_AmbientGroundThreshold, 0.0, updownGradient);
                    float3 skyGradientColor = _AmbientUp.rgb * skyMask;
                    float3 groundGradientColor = _AmbientDown.rgb * groundMask;
                    Surface.Diffuse += (skyGradientColor + groundGradientColor) * _AmbientIntensity;
                }
            #endif // UNITY_PASS_FORWARDBASE
        }

        // apply stockings effect based on view angle
        void ApplyStockings(inout BacklaceSurfaceData Surface)
        {
            [branch] if (_ToggleStockings == 1) 
            {
                float4 stockingsMap = UNITY_SAMPLE_TEX2D_SAMPLER(_StockingsMap, _MainTex, Uvs[_StockingsMap_UV]);
                float NoV = saturate(Surface.NdotV);
                float power = max(0.04, _StockingsPower);
                float darkWidth = max(0, _StockingsDarkWidth * power);
                float darkIntensity = (NoV - power) / (darkWidth - power);
                darkIntensity = saturate(darkIntensity * (1 - _StockingsLightedIntensity)) * stockingsMap.r;
                float3 darkColor = lerp(1, _StockingsColorDark.rgb, darkIntensity);
                darkColor = lerp(1, darkColor * Surface.Albedo.rgb, darkIntensity) * Surface.Albedo.rgb;
                float lightIntensity = lerp(0.5, 1, stockingsMap.b * _StockingsRoughness);
                lightIntensity *= stockingsMap.g;
                lightIntensity *= _StockingsLightedIntensity;
                lightIntensity *= max(0.004, pow(NoV, _StockingsLightedWidth));
                float3 stockings = lightIntensity * (darkColor + _StockingsColor.rgb) + darkColor;
                Surface.Albedo.rgb = lerp(Surface.Albedo.rgb, stockings, step(0.01, stockingsMap.r));
            }
        }

        // eye parallax effect with depth, movement reactivity, and breathing
        void ApplyEyeParallax(inout BacklaceSurfaceData Surface)
        {
            [branch] if (_ToggleEyeParallax == 1) 
            {
                // convert spaces
                float3x3 TBN = float3x3(
                    normalize(Surface.TangentDir),
                    normalize(Surface.BitangentDir),
                    normalize(Surface.NormalDir)
                );
                float3 viewDirTS = mul(TBN, normalize(Surface.ViewDir));
                // angular smoothing
                float forward = saturate(viewDirTS.z);
                float smoothForward = smoothstep(0.25, 1.0, forward);
                // eye "curvature"
                float2 eyeDir = viewDirTS.xy / max(forward + 0.15, 0.15);
                float2 eyeOffset = eyeDir * _EyeParallaxStrength * smoothForward;
                // breathing effect
                if (_ToggleEyeParallaxBreathing == 1) 
                {
                    float breathPhase = _Time.y * _EyeParallaxBreathSpeed;
                    float2 breathOffset;
                    breathOffset.x = sin(breathPhase);
                    breathOffset.y = cos(breathPhase * 0.8);
                    eyeOffset += breathOffset * _EyeParallaxBreathStrength;
                }
                // clamp it
                eyeOffset = clamp(eyeOffset, -_EyeParallaxClamp, _EyeParallaxClamp);
                // soft mask
                float2 uv = Uvs[_EyeParallaxEyeMaskTex_UV];
                float irisMask = UNITY_SAMPLE_TEX2D_SAMPLER(_EyeParallaxEyeMaskTex, _MainTex, uv).r;
                irisMask = smoothstep(0.2, 0.8, irisMask);
                // composite all the final colours
                float2 irisBaseUV = Uvs[_EyeParallaxIrisTex_UV];
                float2 irisUV = irisBaseUV + eyeOffset * irisMask;
                float4 sclera = UNITY_SAMPLE_TEX2D(_MainTex, FragData.uv); // scalera is the main texture, presumably
                float4 iris = UNITY_SAMPLE_TEX2D_SAMPLER(_EyeParallaxIrisTex, _MainTex, irisUV);
                Surface.Albedo.rgb = lerp(sclera.rgb, iris.rgb, iris.a * irisMask);
            }
        }
        
        // expression map (applies color tints based on expression channels)
        void ApplyExpressionMap(inout BacklaceSurfaceData Surface)
        {
            [branch] if (_ToggleExpressionMap == 1)
            {
                float4 exprMap = UNITY_SAMPLE_TEX2D_SAMPLER(_ExpressionMap, _MainTex, Uvs[0]);
                // cheek blush (red channel)
                float3 exCheek = lerp(Surface.Albedo.rgb, Surface.Albedo.rgb * _ExCheekColor.rgb, exprMap.r);
                Surface.Albedo.rgb = lerp(Surface.Albedo.rgb, exCheek, _ExCheekIntensity);
                // shy/embarrassment (green channel)
                float3 exShy = lerp(Surface.Albedo.rgb, Surface.Albedo.rgb * _ExShyColor.rgb, exprMap.g);
                Surface.Albedo.rgb = lerp(Surface.Albedo.rgb, exShy, _ExShyIntensity);
                // shadow tint (blue channel)
                float3 exShadow = lerp(Surface.Albedo.rgb, Surface.Albedo.rgb * _ExShadowColor.rgb, exprMap.b);
                Surface.Albedo.rgb = lerp(Surface.Albedo.rgb, exShadow, _ExShadowIntensity);
            }
        }
        
        // face map features (eye masks, nose lines, lip outlines)
        void ApplyFaceMap(inout BacklaceSurfaceData Surface)
        {
            [branch] if (_ToggleFaceMap == 1)
            {
                float3 headForward = normalize(mul((float3x3)unity_ObjectToWorld, _FaceHeadForward.xyz));
                float4 faceMap = UNITY_SAMPLE_TEX2D_SAMPLER(_FaceMap, _MainTex, Uvs[0]);
                // nose line (blue channel)
                [branch] if (_ToggleNoseLine == 1)
                {
                    float FdotV = pow(abs(dot(headForward, Surface.ViewDir)), _NoseLinePower);
                    float noseLineMask = step(1.03 - faceMap.b, FdotV);
                    Surface.Albedo.rgb = lerp(Surface.Albedo.rgb, Surface.Albedo.rgb * _NoseLineColor.rgb, noseLineMask);
                }
                // eye shadow/tint (red channel)
                [branch] if (_ToggleEyeShadow == 1)
                {
                    float3 exEyeShadow = lerp(Surface.Albedo.rgb, Surface.Albedo.rgb * _ExEyeColor.rgb, faceMap.r);
                    Surface.Albedo.rgb = lerp(Surface.Albedo.rgb, exEyeShadow, _EyeShadowIntensity);
                }
                // lip outline (green channel: 0.5 < g < 0.95 is lip area)
                [branch] if (_ToggleLipOutline == 1)
                {
                    float lipMask = step(0.5, faceMap.g) - step(0.95, faceMap.g);
                    Surface.Albedo.rgb = lerp(Surface.Albedo.rgb, Surface.Albedo.rgb * _LipOutlineColor.rgb, lipMask * _LipOutlineIntensity);
                }
            }
        }
        
        // sdf shadow mapping
        void ApplySDFShadow(inout BacklaceSurfaceData Surface)
        {
            [branch] if (_ToggleSDFShadow == 1) 
            {
                // face forward vs light direction
                float3 faceForward = normalize(mul((float3x3)unity_ObjectToWorld, _SDFLocalForward.xyz));
                float3 faceRight = normalize(mul((float3x3)unity_ObjectToWorld, _SDFLocalRight.xyz));
                float forwardDot;
                float rightDot; 
                [branch] if (_SDFMode == 1) // 3d (pitch aware)
                {
                    forwardDot = dot(-faceForward, Surface.LightDir);
                    rightDot = dot(faceRight, Surface.LightDir);
                }
                else // 2D (pitch locked to xz plane)
                {
                    float2 lightDirXZ = normalize(Surface.LightDir.xz + float2(0.00001, 0.00001));
                    float2 faceForwardXZ = normalize(faceForward.xz);
                    float2 faceRightXZ = normalize(faceRight.xz);
                    forwardDot = dot(-faceForwardXZ, lightDirXZ);
                    rightDot = dot(faceRightXZ, lightDirXZ);
                }
                // flip as necessary
                float2 uv = Uvs[_SDFShadowTexture_UV];
                if (rightDot < 0) uv.x = 1.0 - uv.x;
                // sample sdf
                float sdfValue = UNITY_SAMPLE_TEX2D(_SDFShadowTexture, uv).r;
                // thresholding
                float halfLambert = forwardDot * 0.5 + 0.5;
                halfLambert = saturate(halfLambert - (_SDFShadowThreshold - 0.5));
                float shadowMask = smoothstep(sdfValue - _SDFShadowSoftnessLow, sdfValue + _SDFShadowSoftness, halfLambert);
                // apply to NdotL
                Surface.UnmaxedNdotL = min(Surface.UnmaxedNdotL, lerp(-1.0, 1.0, shadowMask));
                Surface.NdotL = max(Surface.UnmaxedNdotL, 0);
            }
        }

        // angle-based hair transparency (inspired by Star Rail)
        void ApplyHairTransparency(inout BacklaceSurfaceData Surface)
        {
            [branch] if (_ToggleHairTransparency == 1) 
            {
                float3 headForward = normalize(mul((float3x3)unity_ObjectToWorld, _HairHeadForward.xyz));
                float3 headUp = normalize(mul((float3x3)unity_ObjectToWorld, _HairHeadUp.xyz));
                float3 headRight = normalize(mul((float3x3)unity_ObjectToWorld, _HairHeadRight.xyz));
                // horizontal angle (70 degrees)
                float3 viewDirXZ = normalize(Surface.ViewDir - dot(Surface.ViewDir, headUp) * headUp);
                float cosHorizontal = max(0, dot(viewDirXZ, headForward));
                float alpha1 = saturate((1.0 - cosHorizontal) / 0.658); // 0.658 = 1 - cos(70°)
                // vertical angle (45 degrees)
                float3 viewDirYZ = normalize(Surface.ViewDir - dot(Surface.ViewDir, headRight) * headRight);
                float cosVertical = max(0, dot(viewDirYZ, headForward));
                float alpha2 = saturate((1.0 - cosVertical) / 0.293); // 0.293 = 1 - cos(45°)
                // optional masking to make other parts of the hair not impacted
                float hairMask = 1.0;
                [branch] if (_HairHeadMaskMode != 0)
                {
                    float3 headCenterWS = mul(unity_ObjectToWorld, float4(_HairHeadCenter.xyz, 1.0)).xyz;
                    float distToHead = distance(FragData.worldPos, headCenterWS);
                    if (_HairHeadMaskMode == 1) //sdf
                    {
                        float radius = _HairSDFScale.x;
                        // signed distance (negative = inside)
                        float sdf = distToHead - radius;
                        hairMask = saturate(1.0 - sdf / max(_HairSDFSoftness, 1e-5));
                        hairMask = pow(hairMask, _HairSDFBlend);
                    }
                    else if (_HairHeadMaskMode == 2) // distance falloff
                    {
                        hairMask = smoothstep(
                            _HairDistanceFalloffStart,
                            _HairDistanceFalloffEnd,
                            distToHead
                        );
                        // invert so near-head = 1
                        hairMask = 1.0 - hairMask;
                        hairMask = lerp(1.0, hairMask, _HairDistanceFalloffStrength);
                    }
                    if (_HairExtremeAngleGuard == 1)
                    {
                        // 0 = side view, 1 = straight up/down
                        float vertical = abs(dot(normalize(Surface.ViewDir), headUp));
                        float start = cos(radians(_HairAngleFadeStart));
                        float end = cos(radians(_HairAngleFadeEnd));
                        // Fade OUT transparency at extreme angles
                        float angleGuard = smoothstep(start, end, vertical);
                        angleGuard = 1.0 - angleGuard;
                        angleGuard = lerp(1.0, angleGuard, _HairAngleGuardStrength);
                        hairMask *= angleGuard;
                    }
                    if (_HairSDFPreview == 1)
                    {
                        Surface.Albedo.rgb = lerp(float3(1, 0, 0), float3(0, 1, 0), hairMask);
                        Surface.Albedo.a = 1;
                        return;
                    }
                }
                // combine angles with base alpha
                float hairAlpha = max(max(alpha1, alpha2), _HairBlendAlpha);
                hairAlpha = lerp(1.0, hairAlpha, _HairTransparencyStrength * hairMask);
                // apply to surface
                Surface.Albedo.a *= hairAlpha;
            }
        }

        // apply an anime gradient
        void ApplyAnimeGradient(inout BacklaceSurfaceData Surface)
        {
            if (_ToggleAnimeGradient == 0)
            { 
                return;
            }
            else
            {
                float3 localPos = mul(unity_WorldToObject, float4(FragData.worldPos.xyz, 1.0)).xyz;
                float grad = dot(localPos.xyz, _AnimeGradientDirection.xyz);
                float mask = saturate((grad + _AnimeGradientOffset) * _AnimeGradientMultiplier);
                float3 gradColour = lerp(_AnimeGradientColourA, _AnimeGradientColourB, mask);
                if (_AnimeGradientMode == 0) // replace
                {
                    Surface.Albedo.rgb = gradColour;
                }
                else // multiply
                {
                    Surface.Albedo.rgb *= gradColour;
                }
            }
        }

        void ApplyToonHighlights(inout BacklaceSurfaceData Surface)
        {
            if (_ToggleSpecularToon == 0)
            {
                return;
            }
            else 
            {
                float blinnPhong = pow(max(0.0, Surface.NdotH), _SpecularToonShininess) * Surface.Attenuation;
                float threshold = 1.05 - _SpecularToonThreshold;
                float specularRaw = smoothstep(threshold - _SpecularToonRoughness, threshold + _SpecularToonRoughness, blinnPhong);
                float sharpCurve = (specularRaw * - 2.0 + 3.0) * pow(specularRaw, 2.0);
                specularRaw = lerp(specularRaw, sharpCurve, _SpecularToonSharpness);
                float specularMask = specularRaw * _SpecularToonIntensity;
                float3 specularColour = _SpecularToonColor.rgb * specularMask;
                if (_SpecularToonUseLighting == 1)
                {
                    specularColour *= Surface.LightColor.rgb * Surface.Attenuation;
                }
                Surface.FinalColor.rgb += specularColour;
            }
        }

        void ApplyAngelRings(inout BacklaceSurfaceData Surface)
        {
            if (_AngelRingMode == 0)
            {
                return;
            }
            else
            {
                // set up between modes
                float3 flowTangent;
                float hairLength;
                if (_AngelRingMode == 2) // uv mode
                {
                    hairLength = Uvs[0].y;
                    flowTangent = normalize(Surface.TangentDir);
                }
                else if (_AngelRingMode == 1) // view aligned
                {
                    /*hairLength = (FragData.worldPos.y - FragData.worldObjectCenter.y) * _AngelRingHeightScale + _AngelRingHeightOffset;
                        hairLength = saturate(hairLength); // keep it 0-1
                        float3 up = float3(0, 1, 0);
                        float3 right = normalize(cross(up, Surface.NormalDir));
                    flowTangent = normalize(cross(Surface.NormalDir, right));*/
                    float3 relativePos = FragData.worldPos - FragData.worldObjectCenter;
                    float projection = dot(relativePos, normalize(_AngelRingHeightDirection.xyz));
                    hairLength = saturate(projection * _AngelRingHeightScale + _AngelRingHeightOffset);
                    float3 up = normalize(_AngelRingHeightDirection.xyz);
                    float3 right = normalize(cross(up, Surface.NormalDir));
                    flowTangent = normalize(cross(Surface.NormalDir, right));
                }
                else // (3) world aligned
                {
                    hairLength = dot(FragData.worldPos, _AngelRingHeightDirection) - _AngelRingHeightScale;
                    float3 right = normalize(cross(_AngelRingHeightDirection, Surface.NormalDir));
                    flowTangent = normalize(cross(Surface.NormalDir, right));
                }
                // optional breakup mix-in
                float breakup = 1.0;
                float heightOffset = 0.0;
                [branch] if (_AngelRingBreakup != 0)
                {
                    float3 toFragment = normalize(FragData.worldPos - FragData.worldObjectCenter);
                    float3 up = normalize(_AngelRingHeightDirection.xyz);
                    float3 forward = normalize(cross(up, float3(1, 0, 0))); // or use view direction
                    float3 right = normalize(cross(up, forward));
                    float angleX = atan2(dot(toFragment, right), dot(toFragment, forward));
                    float strandCoord = (angleX / 6.28318530718) + 0.5; // 0-1 range
                    if (_AngelRingBreakup == 1)
                    {
                        float stripes = frac(strandCoord * _AngelRingBreakupDensity);
                        stripes = abs(stripes - 0.5) * 2.0;
                        breakup = smoothstep(
                            _AngelRingBreakupWidthMin,
                            _AngelRingBreakupWidthMin + _AngelRingBreakupSoftness,
                            stripes
                        );
                    }
                    else if (_AngelRingBreakup == 2)
                    {
                        float cell = floor(strandCoord * _AngelRingBreakupDensity);
                        float rand = frac(sin(cell * 91.3458) * 47453.5453);
                        float verticalRand = frac(sin(cell * 78.233) * 43758.5453);
                        heightOffset = lerp(-1.0, 1.0, verticalRand) * _AngelRingBreakupHeight;
                        float localCoord = frac(strandCoord * _AngelRingBreakupDensity);
                        float width = lerp(
                            _AngelRingBreakupWidthMin,
                            _AngelRingBreakupWidthMax,
                            rand
                        );
                        float center = lerp(0.3, 0.7, rand);
                        float stripeDist = abs(localCoord - center);
                        breakup = smoothstep(
                            width,
                            width + _AngelRingBreakupSoftness,
                            stripeDist
                        );
                    }
                }
                // specular shape
                float dotTH = dot(flowTangent, Surface.HalfDir) + _AngelRingManualOffset;
                float sinTH = sqrt(max(0.0, 1.0 - dotTH * dotTH)) + _AngelRingManualScale + heightOffset;
                float specShape = pow(sinTH, max(1.0, _AngelRingSharpness));
                // ring 1 logic
                float primaryDist = abs(hairLength - _AngelRing1Position);
                float primaryMask = saturate(1.0 - (primaryDist / max(0.01, _AngelRing1Width)));
                float ring1 = specShape * smoothstep(0, 1, primaryMask) * breakup;
                ring1 = smoothstep(_AngelRingThreshold - _AngelRingSoftness, _AngelRingThreshold + _AngelRingSoftness, ring1);
                // ring 2 logic
                float3 ring2Final = 0;
                if (_UseSecondaryRing == 1)
                {
                    float secondaryDist = abs(hairLength - _AngelRing2Position);
                    float secondaryMask = saturate(1.0 - (secondaryDist / max(0.01, _AngelRing2Width)));
                    float ring2 = pow(sinTH, _AngelRingSharpness * 0.6) * smoothstep(0, 1, secondaryMask);
                    ring2 = smoothstep(_AngelRingThreshold * 0.7, (_AngelRingThreshold * 0.7) + _AngelRingSoftness, ring2);
                    ring2Final = ring2 * (_AngelRing2Color.rgb * _AngelRing2Color.a);
                }
                // ring 3 logic
                float3 ring3Final = 0;
                if (_UseTertiaryRing == 1)
                {
                    float tertiaryDist = abs(hairLength - _AngelRing3Position);
                    float tertiaryMask = saturate(1.0 - (tertiaryDist / max(0.01, _AngelRing3Width)));
                    float ring3 = pow(sinTH, _AngelRingSharpness * 0.8) * smoothstep(0, 1, tertiaryMask);
                    ring3 = smoothstep(_AngelRingThreshold * 0.8, (_AngelRingThreshold * 0.8) + _AngelRingSoftness, ring3);
                    ring3Final = ring3 * (_AngelRing3Color.rgb * _AngelRing3Color.a);
                }
                // composite
                float3 ringColours = (ring1 * _AngelRing1Color.rgb * _AngelRing1Color.a) + ring2Final + ring3Final;
                if (_AngelRingUseLighting) 
                {
                    ringColours.rgb *= Surface.LightColor.rgb * Surface.Attenuation;
                }
                Surface.FinalColor.rgb += ringColours;
            }
        }
    #endif // _BACKLACE_ANIME_EXTRAS


    // [ ♡ ] ────────────────────── [ ♡ ]
    //
    //          Ramp Shading
    //
    // [ ♡ ] ────────────────────── [ ♡ ]


    #if defined(_ANIMEMODE_RAMP)
        // for toon lighting, we use a ramp texture
        float4 RampDotL(inout BacklaceSurfaceData Surface)
        {
            float offset = _RampOffset + (Surface.Occlusion * _RampOcclusionOffset) - _RampOcclusionOffset;
            float newMin = max(offset, 0);
            float newMax = max(offset +1, 0);
            float rampUv = remap(Surface.UnmaxedNdotL, -1, 1, newMin, newMax);
            float rampV = (_RampIndex + 0.5) / max(_RampTotal, 0.001);
            float3 ramp = UNITY_SAMPLE_TEX2D(_Ramp, float2(rampUv, rampV)).rgb;
            ramp *= _RampColor.rgb;
            float intensity = max(_RampShadows, 0.001);
            if (_RampNormalIntensity == 1)
            {
                intensity *= saturate(Surface.NdotV + Surface.NdotL);
            }
            ramp = remap(ramp, float3(0, 0, 0), float3(1, 1, 1), 1 - intensity, float3(1, 1, 1));
            float3 rmin = remap(_RampMin, 0, 1, 1 - intensity, 1);
            float3 rampA = remap(ramp, rmin, 1, 0, 1);
            float rampGrey = max(max(rampA.r, rampA.g), rampA.b);
            #if defined(DIRECTIONAL) || defined(DIRECTIONAL_COOKIE)
                return float4(ramp, rampGrey);
            #else // DIRECTIONAL || DIRECTIONAL_COOKIE
                return float4(rampA, rampGrey); // use adjusted ramp for point/spot lights
            #endif // DIRECTIONAL || DIRECTIONAL_COOKIE
        }

        // or.. optionally, a procedural ramp
        float4 PrcoeduralDotL(inout BacklaceSurfaceData Surface)
        {
            float lightIntensity = Surface.UnmaxedNdotL * 0.5 + 0.5;
            if (_RampNormalIntensity == 1)
            {
                lightIntensity *= saturate(Surface.NdotV + Surface.NdotL);
            }
            float maxThreshold = lerp(1.0, _RampProceduralShift, _RampProceduralToony);
            float rampVal = saturate((lightIntensity - _RampProceduralShift) / max(0.0001, (maxThreshold - _RampProceduralShift)));
            return float4(rampVal, rampVal, rampVal, rampVal);
        }

        // modified version of Shade4PointLights to use ramp texture or procedural
        void DotLVertLight(float3 normal, float3 worldPos, float occlusion, out float3 color, out float3 direction)
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
            float3 ramp0, ramp1, ramp2, ramp3;           
            [branch] if (_RampMode == 0) // texture
            {
                // ramp calculation for all 4 vertex lights
                float offset = _RampOffset + (occlusion * _RampOcclusionOffset) - _RampOcclusionOffset;
                // calculating ramp uvs based on offset
                float newMin = max(offset, 0);
                float newMax = max(offset +1, 0);
                float4 rampUv = remap(ndl, float4(-1, -1, -1, -1), float4(1, 1, 1, 1), float4(newMin, newMin, newMin, newMin), float4(newMax, newMax, newMax, newMax));
                float intensity = max(_RampShadows, 0.001);
                float rampV = (_RampIndex + 0.5) / max(_RampTotal, 0.001);
                float3 rmin = remap(_RampMin, 0, 1, 1 - intensity, 1);
                ramp0 = remap(remap(UNITY_SAMPLE_TEX2D(_Ramp, float2(rampUv.x, rampV)).rgb * _RampColor.rgb, float3(0, 0, 0), float3(1, 1, 1), 1 - intensity, float3(1, 1, 1)), rmin, 1, 0, 1).rgb * unity_LightColor[0].rgb * atten.r;
                ramp1 = remap(remap(UNITY_SAMPLE_TEX2D(_Ramp, float2(rampUv.y, rampV)).rgb * _RampColor.rgb, float3(0, 0, 0), float3(1, 1, 1), 1 - intensity, float3(1, 1, 1)), rmin, 1, 0, 1).rgb * unity_LightColor[1].rgb * atten.g;
                ramp2 = remap(remap(UNITY_SAMPLE_TEX2D(_Ramp, float2(rampUv.z, rampV)).rgb * _RampColor.rgb, float3(0, 0, 0), float3(1, 1, 1), 1 - intensity, float3(1, 1, 1)), rmin, 1, 0, 1).rgb * unity_LightColor[2].rgb * atten.b;
                ramp3 = remap(remap(UNITY_SAMPLE_TEX2D(_Ramp, float2(rampUv.w, rampV)).rgb * _RampColor.rgb, float3(0, 0, 0), float3(1, 1, 1), 1 - intensity, float3(1, 1, 1)), rmin, 1, 0, 1).rgb * unity_LightColor[3].rgb * atten.a;
            }
            else // procedural
            {
                float4 lightIntensity = ndl * 0.5 + 0.5;
                float maxThreshold = lerp(1.0, _RampProceduralShift, _RampProceduralToony);
                float4 rampVal = saturate((lightIntensity - _RampProceduralShift) / max(0.0001, (maxThreshold - _RampProceduralShift)));
                ramp0 = rampVal.x * unity_LightColor[0].rgb * atten.r;
                ramp1 = rampVal.y * unity_LightColor[1].rgb * atten.g;
                ramp2 = rampVal.z * unity_LightColor[2].rgb * atten.b;
                ramp3 = rampVal.w * unity_LightColor[3].rgb * atten.a;
            }
            color = ramp0 + ramp1 + ramp2 + ramp3;
            // direction calculation
            direction = 0;
            #if defined(_BACKLACE_SPECULAR) && defined(VERTEXLIGHT_ON)
                if (_ToggleVertexSpecular == 1)
                {
                    direction += (float3(toLightX.x, toLightY.x, toLightZ.x) * corr.x) * dot(ramp0, 1);
                    direction += (float3(toLightX.y, toLightY.y, toLightZ.y) * corr.y) * dot(ramp1, 1);
                    direction += (float3(toLightX.z, toLightY.z, toLightZ.z) * corr.z) * dot(ramp2, 1);
                    direction += (float3(toLightX.w, toLightY.w, toLightZ.w) * corr.w) * dot(ramp3, 1);
                }
            #endif // _BACKLACE_SPECULAR && VERTEXLIGHT_ON
        }

        // get the direct diffuse contribution using a toon ramp
        void GetRampDiffuse(inout BacklaceSurfaceData Surface)
        {
            Surface.Diffuse = 0;
            float4 ramp = float4(0, 0, 0, 0);
            [branch] if (_RampMode == 0) // texture
            {
                ramp = RampDotL(Surface);
            }
            else // procedural
            {
                ramp = PrcoeduralDotL(Surface);
            }
            #if defined(_BACKLACE_LTCGI)
                float2 ltcgi_lmUV = 0;
                #if defined(LIGHTMAP_ON)
                    ltcgi_lmUV = FragData.lightmapUV;
                #endif
                LTCGI_Contribution(
                    FragData.worldPos,
                    Surface.NormalDir,
                    Surface.ViewDir,
                    Surface.Roughness,
                    ltcgi_lmUV,
                    Surface.IndirectDiffuse,
                    Surface.IndirectSpecular
                );
            #endif // _BACKLACE_LTCGI
            float3 indirectLight = Surface.IndirectDiffuse * lerp(1, ramp.rgb, _IndirectDiffuse);
            #if defined(_BACKLACE_SHADOW_TEXTURE)
                float3 totalLight = (Surface.LightColor.rgb * Surface.LightColor.a * lerp(1, ramp.rgb, _DirectDiffuse));
                float3 litColor = CombineDiffuses(Surface.Albedo, totalLight, indirectLight);
                float3 shadowColor = GetTexturedShadowColor(Surface, totalLight, litColor);
                Surface.Diffuse = lerp(shadowColor, litColor, GetLuma(ramp.rgb));
            #else // _BACKLACE_SHADOW_TEXTURE
                float3 directLight = (Surface.LightColor.rgb * Surface.LightColor.a * lerp(1, ramp.rgb, _DirectDiffuse));
                Surface.Diffuse = CombineDiffuses(Surface.Albedo, directLight, indirectLight);
            #endif // _BACKLACE_SHADOW_TEXTURE
            Surface.Attenuation = StyliseAttenuation(Surface.LightColor.a, ramp.a * Surface.LightColor.a);
        }

        // get the vertex diffuse contribution using a toon ramp
        void GetRampVertexDiffuse(inout BacklaceSurfaceData Surface)
        {
            Surface.VertexDirectDiffuse = 0;
            #if defined(_BACKLACE_SPECULAR) && defined(VERTEXLIGHT_ON)
                if (_ToggleVertexSpecular == 1)
                {
                    DotLVertLight(Surface.NormalDir, FragData.worldPos, Surface.Occlusion, Surface.VertexDirectDiffuse, VertexLightDir);
                }
                else
                {
                    float3 ignoredDir;
                    DotLVertLight(Surface.NormalDir, FragData.worldPos, Surface.Occlusion, Surface.VertexDirectDiffuse, ignoredDir);
                }
                Surface.VertexDirectDiffuse *= Surface.Albedo;
            #elif defined(VERTEXLIGHT_ON) // _BACKLACE_SPECULAR && VERTEXLIGHT_ON
                float3 ignoredDir;
                DotLVertLight(Surface.NormalDir, FragData.worldPos, Surface.Occlusion, Surface.VertexDirectDiffuse, ignoredDir);
                Surface.VertexDirectDiffuse *= Surface.Albedo;
            #endif // _BACKLACE_SPECULAR && VERTEXLIGHT_ON
        }


    // [ ♡ ] ────────────────────── [ ♡ ]
    //
    //           Cel Shading
    //
    // [ ♡ ] ────────────────────── [ ♡ ]


    #elif defined(_ANIMEMODE_CEL) // _ANIMEMODE_*
        // modified version of Shade4PointLights to add cel-shading
        void CelShade4PointLights(float3 normal, float3 worldPos, out float3 color, out float3 direction)
        {
            Shade4PointLights(normal, worldPos, color, direction);
            float luma = GetLuma(color);
            float celMask = smoothstep(_CelThreshold, _CelThreshold + _CelFeather, luma);
            color *= celMask;
        }

        // simple cel-shaded diffuse
        void GetCelDiffuse(inout BacklaceSurfaceData Surface)
        {
            float diffuseTerm = 0;
            float shadowTerm = 0;
            float finalLight = 0;
            if (_CelMode == 0) // default
            {
                diffuseTerm = smoothstep(_CelThreshold, _CelThreshold + _CelFeather, Surface.UnmaxedNdotL);
                shadowTerm = smoothstep(0, _CelCastShadowFeather, Surface.LightColor.a);
                shadowTerm = max(shadowTerm, 1.0 - _CelCastShadowPower);
                finalLight = diffuseTerm * shadowTerm;
            }
            else if (_CelMode == 1) // harsh
            {
                diffuseTerm = step(_CelThreshold, Surface.UnmaxedNdotL);
                shadowTerm = step(_CelCastShadowFeather, Surface.LightColor.a);
                shadowTerm = max(shadowTerm, 1.0 - _CelCastShadowPower);
                finalLight = diffuseTerm * shadowTerm;
            }
            else // smooth
            {
                float halfLambert = Surface.UnmaxedNdotL * 0.5 + 0.5;
                halfLambert = saturate(halfLambert + (Surface.Occlusion * _CelSmoothOcclusionStrength) - _CelSmoothOcclusionStrength);
                halfLambert = pow(saturate(halfLambert), _CelSmoothGradientPower);
                diffuseTerm = smoothstep(_CelThreshold, _CelThreshold + _CelFeather, halfLambert);
                shadowTerm = smoothstep(0, _CelCastShadowFeather, Surface.LightColor.a);
                shadowTerm = max(shadowTerm, 1.0 - _CelCastShadowPower);
                finalLight = diffuseTerm * shadowTerm;
            }
            #if defined(_BACKLACE_LTCGI)
                float2 ltcgi_lmUV = 0;
                #if defined(LIGHTMAP_ON)
                    ltcgi_lmUV = FragData.lightmapUV;
                #endif
                LTCGI_Contribution(
                    FragData.worldPos,
                    Surface.NormalDir,
                    Surface.ViewDir,
                    Surface.Roughness,
                    ltcgi_lmUV,
                    Surface.IndirectDiffuse,
                    Surface.IndirectSpecular
                );
            #endif // _BACKLACE_LTCGI
            float3 litColor = float3(0, 0, 0);
            float3 shadowColor = float3(0, 0, 0);
            float3 indirectLight = Surface.IndirectDiffuse;
            indirectLight *= lerp(1, finalLight, _IndirectDiffuse);
            #if defined(_BACKLACE_SHADOW_TEXTURE)
                litColor = Surface.Albedo.rgb * Surface.LightColor.rgb * _CelLitTint.rgb;
                float3 totalLight = (Surface.LightColor.rgb * Surface.LightColor.a * lerp(1, finalLight, _DirectDiffuse));
                shadowColor = GetTexturedShadowColor(Surface, totalLight, litColor);
            #else // _BACKLACE_SHADOW_TEXTURE
                litColor = Surface.Albedo.rgb * _CelLitTint.rgb;
                shadowColor = Surface.Albedo.rgb * _CelShadowTint.rgb;
            #endif // _BACKLACE_SHADOW_TEXTURE
            float3 combinedColour = lerp(shadowColor, litColor, finalLight);
            float3 directLight = Surface.LightColor.rgb * Surface.LightColor.a * lerp(1, finalLight, _DirectDiffuse);
            Surface.Diffuse = CombineDiffuses(Surface.Albedo, directLight, indirectLight);
            Surface.Attenuation = StyliseAttenuation(Surface.LightColor.a, finalLight * Surface.LightColor.a);
        }

        // get the vertex diffuse contribution using cel-shading
        void GetCelVertexDiffuse(inout BacklaceSurfaceData Surface)
        {
            Surface.VertexDirectDiffuse = 0;
            #if defined(_BACKLACE_SPECULAR) && defined(VERTEXLIGHT_ON)
                if (_ToggleVertexSpecular == 1)
                {
                    CelShade4PointLights(Surface.NormalDir, FragData.worldPos, Surface.VertexDirectDiffuse, VertexLightDir);
                }
                else
                {
                    float3 ignoredDir;
                    CelShade4PointLights(Surface.NormalDir, FragData.worldPos, Surface.VertexDirectDiffuse, ignoredDir);
                }
                Surface.VertexDirectDiffuse *= Surface.Albedo;
            #elif defined(VERTEXLIGHT_ON) // _BACKLACE_SPECULAR && VERTEXLIGHT_ON
                float3 ignoredDir;
                CelShade4PointLights(Surface.NormalDir, FragData.worldPos, Surface.VertexDirectDiffuse, ignoredDir);
                Surface.VertexDirectDiffuse *= Surface.Albedo;
            #endif // _BACKLACE_SPECULAR && VERTEXLIGHT_ON
        }


    // [ ♡ ] ────────────────────── [ ♡ ]
    //
    //          NPR Shading
    //
    // [ ♡ ] ────────────────────── [ ♡ ]


    #elif defined(_ANIMEMODE_NPR) // _ANIMEMODE_*

        // a few helpers for stlyised npr (separate from actual sss, rim, etc. functions)
        float SmoothHalfLambert(BacklaceSurfaceData Surface, float minVal, float maxVal)
        {
            float halfLambert = Surface.UnmaxedNdotL * 0.5 + 0.5;
            return smoothstep(minVal, maxVal, halfLambert);
        }

        float ViewDirSpecular(BacklaceSurfaceData Surface)
        {
            return step(1.0 - _NPRForwardSpecularRange, Surface.NdotV);
        }

        float BlinnPhong(BacklaceSurfaceData Surface)
        {
            float spec = pow(Surface.NdotH, _NPRBlinnPower);
            return smoothstep(_NPRBlinnMin, _NPRBlinnMax, spec);
        }

        float FakeSSS(BacklaceSurfaceData Surface)
        {
            float fresnelPower = pow(1.0 - Surface.NdotV, _NPRSSSExp);
            float fresnel = _NPRSSSRef + (1.0 - _NPRSSSRef) * fresnelPower;
            return smoothstep(_NPRSSSMin, _NPRSSSMax, fresnel);
        }

        float FresnelRim(BacklaceSurfaceData Surface, float lightMask)
        {
            float fresnelPower = pow(1.0 - Surface.NdotV, _NPRRimExp);
            float fresnel = fresnelPower * lightMask;
            return smoothstep(_NPRRimMin, _NPRRimMax, fresnel);
        }

        // get the direct diffuse contribution using npr techniques
        void GetNPRDiffuse(inout BacklaceSurfaceData Surface)
        {
            // base diffuse
            float3 directLight = Surface.LightColor.rgb * Surface.LightColor.a;
            float lightMask = SmoothHalfLambert(Surface, _NPRDiffMin, _NPRDiffMax);
            float3 shadowCol = _NPRShadowColor.rgb;
            #if defined(UNITY_PASS_FORWARDADD)
                shadowCol = float3(0, 0, 0);
            #elif defined(_BACKLACE_SHADOW_TEXTURE) // UNITY_PASS_FORWARDADD
                shadowCol = GetTexturedShadowColor(Surface, directLight, shadowCol);
            #endif // UNITY_PASS_FORWARDADD || _BACKLACE_SHADOW_TEXTURE
            float3 colourRamp = lerp(shadowCol, _NPRLitColor.rgb, lightMask);
            float3 outDiffuse = Surface.Albedo * colourRamp;
            float specMask = UNITY_SAMPLE_TEX2D_SAMPLER(_NPRSpecularMask, _MainTex, Uvs[0]).r;
            #if defined(UNITY_PASS_FORWARDBASE)
                // mix in forward specular (the constant shine)
                if (_NPRForwardSpecular > 0) 
                {
                    float forwardSpec = ViewDirSpecular(Surface);
                    forwardSpec *= specMask;
                    float3 specColour = (_NPRForwardSpecular == 1) 
                        ? outDiffuse * _NPRForwardSpecularColor.rgb * _NPRForwardSpecularMultiplier // multiplicative
                        : outDiffuse + (_NPRForwardSpecularColor.rgb * _NPRForwardSpecularMultiplier); // additive
                    outDiffuse = lerp(outDiffuse, specColour, forwardSpec);
                }
            #endif // UNITY_PASS_FORWARDBASE
            // light-dependent specular (blinn-phong)
            if (_NPRBlinn > 0)
            {
                float blinnSpec = BlinnPhong(Surface);
                blinnSpec *= specMask;
                float3 blinnColour = (_NPRBlinn == 1) 
                    ? outDiffuse * _NPRBlinnColor.rgb * _NPRBlinnMultiplier // multiplicative
                    : outDiffuse + (_NPRBlinnColor.rgb * _NPRBlinnMultiplier); // additive
                outDiffuse = lerp(outDiffuse, blinnColour, blinnSpec);
            }
            #if defined(UNITY_PASS_FORWARDBASE)
                // fresnel rim lighting
                if (_NPRRim == 1)
                {
                    float rimMask = SmoothHalfLambert(Surface, 0, 1);
                    float rimFresnel = FresnelRim(Surface, rimMask);
                    //float3 rimColour = rimFresnel * _NPRRimColor.rgb;
                    outDiffuse = lerp(outDiffuse, _NPRRimColor.rgb, rimFresnel);
                }
            #endif // UNITY_PASS_FORWARDBASE
            // fake sss
            if (_NPRSSS == 1)
            {
                float sssFresnel = FakeSSS(Surface);
                sssFresnel *= lerp(_NPRSSSShadows, 1.0, lightMask);
                float3 sssColour = outDiffuse * _NPRSSSColor.rgb;
                outDiffuse = lerp(outDiffuse, sssColour, sssFresnel);
            }
            float3 indirectLight = Surface.IndirectDiffuse * lerp(1, lightMask, _IndirectDiffuse);
            Surface.Diffuse = CombineDiffuses(outDiffuse, directLight * lerp(1, lightMask, _DirectDiffuse), indirectLight);
            Surface.Attenuation = StyliseAttenuation(Surface.LightColor.a, lightMask * Surface.LightColor.a);
        }

        // simple npr-style vertex diffuse
        void GetNPRVertexDiffuse(inout BacklaceSurfaceData Surface)
        {
            Surface.VertexDirectDiffuse = 0;
            #if defined(VERTEXLIGHT_ON)
                float3 pointLightColor;
                float3 ignoredDir;
                Shade4PointLights(Surface.NormalDir, FragData.worldPos, pointLightColor, ignoredDir);
                float luma = GetLuma(pointLightColor);
                float mask = smoothstep(_NPRDiffMin, _NPRDiffMax, luma);
                Surface.VertexDirectDiffuse = Surface.Albedo * pointLightColor * mask;
            #endif // VERTEXLIGHT_ON
        }


    // [ ♡ ] ────────────────────── [ ♡ ]
    //
    //            Tri Band
    //   Previously called "Nitro Fuel"
    //
    // [ ♡ ] ────────────────────── [ ♡ ]


    #elif defined(_ANIMEMODE_TRIBAND) // _ANIMEMODE_*
        float3 NormaliseColours(float3 color)
        {
            float2 magic = float2(0.56275, 0.43725);
            float3 safeColor = color + 0.00006;
            float avg = (safeColor.r + safeColor.g + safeColor.b) * 0.33333;
            float3 colorDiv = saturate(safeColor / avg);
            return color * magic.y + colorDiv * magic.x;
        }

        // calculates the 3 band weights (shadow-shallow-lit)
        float3 GetTriWeights(BacklaceSurfaceData Surface)
        {
            // AO * 2 + NdotL, occlusion from [0,1] to [-1,1] 
            float occlusion = Surface.Occlusion * lerp(1.0, Surface.LightColor.a, _TriBandAttenuatedShadows);
            float shad = (occlusion * 2.0 - 1.0) + Surface.NdotL;
            shad += _TriBandThreshold;
            // edge bands
            float shallowNormalised = _TriBandShallowWidth * 0.5;
            float edge1 = -shallowNormalised; // start of transition (Shadow -> Shallow)
            float edge2 = shallowNormalised;  // end of transition (Shallow -> Lit)
            // weight for the lit area (0 -> 1)
            float litProgress = smoothstep(edge2 - _TriBandSmoothness, edge2 + _TriBandSmoothness, shad);
            // calculate where the shadow ends (edge1)
            float shadowProgress = 1.0 - smoothstep(edge1 - _TriBandSmoothness, edge1 + _TriBandSmoothness, shad);
            // shallow should be leftover
            float weightShallow = saturate(1.0 - litProgress - shadowProgress);
            return float3(shadowProgress, weightShallow, litProgress);
        }

        // basically a wrapper for tri weights..
        void GetTriBandDiffuse(inout BacklaceSurfaceData Surface)
        {
            // get weights
            float3 weights = GetTriWeights(Surface);
            // normalise colours
            float3 shadowColour = NormaliseColours(_TriBandShadowColor.rgb);
            float3 shallowColour = NormaliseColours(_TriBandShallowColor.rgb);
            float3 litColour = NormaliseColours(_TriBandLitColor.rgb);
            // extra post-processing tints
            float3 finalShadow = shadowColour * _TriBandPostShadowTint.rgb;
            float3 directLight = Surface.LightColor.rgb * Surface.LightColor.a;
            float3 indirectLight = Surface.IndirectDiffuse * lerp(1, weights.x, _TriBandIndirectShallow);
            #if defined(_BACKLACE_SHADOW_TEXTURE)
                finalShadow = GetTexturedShadowColor(Surface, directLight, shadowColour);
            #endif // _BACKLACE_SHADOW_TEXTURE
            float3 finalShallow = shallowColour * _TriBandPostShallowTint.rgb;
            float3 finalLit = litColour * _TriBandPostLitTint.rgb;
            // composite all the weights + colours
            float3 diffuseResult = (finalShadow * weights.x) + (finalShallow * weights.y) + (finalLit * weights.z);
            Surface.Diffuse = CombineDiffuses(Surface.Albedo * diffuseResult, directLight, indirectLight);
            Surface.Attenuation = StyliseAttenuation(Surface.LightColor.a, (weights.z + weights.y) * Surface.LightColor.a);
        }

        // apply tri-band shading to vertex lights
        void GetTriBandVertexDiffuse(inout BacklaceSurfaceData Surface)
        {
            Surface.VertexDirectDiffuse = 0;
            #if defined(VERTEXLIGHT_ON)
                // calculate base vertex lighting
                float4 toLightX = unity_4LightPosX0 - FragData.worldPos.x;
                float4 toLightY = unity_4LightPosY0 - FragData.worldPos.y;
                float4 toLightZ = unity_4LightPosZ0 - FragData.worldPos.z;
                float4 lengthSq = toLightX * toLightX + toLightY * toLightY + toLightZ * toLightZ;
                float4 ndl = toLightX * Surface.NormalDir.x + toLightY * Surface.NormalDir.y + toLightZ * Surface.NormalDir.z;
                float4 corr = rsqrt(lengthSq);
                ndl = ndl * corr;
                float4 atten = 1.0 / (1.0 + lengthSq * unity_4LightAtten0);
                // apply tri-band weights for each light
                float3 shadowColour = NormaliseColours(_TriBandShadowColor.rgb) * _TriBandPostShadowTint.rgb;
                float3 shallowColour = NormaliseColours(_TriBandShallowColor.rgb) * _TriBandPostShallowTint.rgb;
                float3 litColour = NormaliseColours(_TriBandLitColor.rgb) * _TriBandPostLitTint.rgb;
                float3 finalColor = 0;
                for (int i = 0; i < 4; i++)
                {
                    float shad = (Surface.Occlusion * 2.0 - 1.0) + ndl[i] + _TriBandThreshold;
                    float shallowNormalised = _TriBandShallowWidth * 0.5;
                    float edge1 = -shallowNormalised;
                    float edge2 = shallowNormalised;
                    float litProgress = smoothstep(edge2 - _TriBandSmoothness, edge2 + _TriBandSmoothness, shad);
                    float shadowProgress = 1.0 - smoothstep(edge1 - _TriBandSmoothness, edge1 + _TriBandSmoothness, shad);
                    float weightShallow = saturate(1.0 - litProgress - shadowProgress);
                    float3 diffuseResult = (shadowColour * shadowProgress) + (shallowColour * weightShallow) + (litColour * litProgress);
                    finalColor += unity_LightColor[i].rgb * diffuseResult * atten[i];
                }
                Surface.VertexDirectDiffuse = Surface.Albedo * finalColor;
            #endif // VERTEXLIGHT_ON
        }


    // [ ♡ ] ────────────────────── [ ♡ ]
    //
    //           Packed Maps
    //     Previously called "Mona"
    //
    // [ ♡ ] ────────────────────── [ ♡ ]


    #elif defined(_ANIMEMODE_PACKED) // _ANIMEMODE_*

        // helper: smoothstep shadow with smoothness toggle
        float DizzyStep(float ndl, float threshold, float smoothness)
        {
            float edge = (ndl / 1.0) + (-smoothness);
            float result = smoothstep(edge, ndl, threshold);
            float hardResult = threshold >= ndl ? 1.0 : 0.0;
            float isHard = smoothness == 0 ? 1.0 : 0.0;
            return lerp(result, hardResult, isHard);
        }

        // mode one: genshin
        void GetGenshinPackedDiffuse(inout BacklaceSurfaceData Surface)
        {
            // r: specular intensity, g: shadow threshold, b: shadow ramp offset, a: specular/metal mask
            float4 lightMapData = UNITY_SAMPLE_TEX2D_SAMPLER(_PackedMapOne, _MainTex, Uvs[0]);
            // 0.5 in texture = neutral. <0.5 = harder to shadow. >0.5 = easier to shadow.
            float halfLambert = Surface.UnmaxedNdotL * 0.5 + 0.5;
            float shadowsLow = lightMapData.g - _PackedShadowSmoothness;
            float shadowsHigh = lightMapData.g + _PackedShadowSmoothness;
            float modelShadows = smoothstep(shadowsLow, shadowsHigh, halfLambert);
            float3 directLight = Surface.LightColor.rgb * Surface.LightColor.a;
            float3 indirectLight = Surface.IndirectDiffuse * _PackedAmbient;
            #if defined(_BACKLACE_SHADOW_TEXTURE)
                float3 shadowColour = GetTexturedShadowColor(Surface, directLight, Surface.Albedo.rgb * _PackedShadowColor.rgb);
            #else // _BACKLACE_SHADOW_TEXTURE
                float3 shadowColour = Surface.Albedo.rgb * _PackedShadowColor.rgb;
            #endif // _BACKLACE_SHADOW_TEXTURE
            float2 rampUV = float2(saturate(modelShadows), lightMapData.b);
            float3 rampColour = UNITY_SAMPLE_TEX2D_SAMPLER(_PackedMapTwo, _MainTex, rampUV).rgb;
            float3 litColour = Surface.Albedo.rgb * _PackedLitColor.rgb;
            float3 finalAlbedo = lerp(shadowColour, litColour, modelShadows) * rampColour;
            Surface.Diffuse = CombineDiffuses(finalAlbedo, directLight, indirectLight);
            // metallic, in case people are not using the metallic channel properly, also gated by toggle
            float metalMask = lightMapData.a;
            if (metalMask > 0.01 && _PackedMapMetals == 1)
            {
                float3 viewNormal = mul((float3x3)UNITY_MATRIX_V, Surface.NormalDir);
                float2 matcapUV = viewNormal.xy * 0.5 + 0.5;
                float3 metalColor = UNITY_SAMPLE_TEX2D_SAMPLER(_PackedMapThree, _MainTex, matcapUV).rgb;
                Surface.Diffuse += metalColor * metalMask;
            }
            // rim lighting
            float rimIntensity = 0.0;
            if (_PackedRimLight == 1)
            {
                float rimDot = 1.0 - saturate(dot(Surface.ViewDir, Surface.NormalDir));
                float rimMask = smoothstep(_PackedRimThreshold, _PackedRimThreshold + 0.1, rimDot);
                float rimIntensity = rimMask * (1.0 - modelShadows) * _PackedRimPower;
            }
            // put it all together
            Surface.Diffuse += _PackedRimColor.rgb * rimIntensity;
            Surface.Attenuation = Surface.LightColor.a; // always use default attenuation for genshin
        }

        // mode two: uma musume
        void GetUmaMusumeDiffuse(inout BacklaceSurfaceData Surface)
        {
            // red: ambient occlusion, green: specular mask, blue: clipping
            float4 baseMap = UNITY_SAMPLE_TEX2D_SAMPLER(_PackedMapOne, _MainTex, Uvs[_PackedMapOne_UV]);
            // rgb: shaded colours
            float3 directLight = Surface.LightColor.rgb * Surface.LightColor.a;
            float3 indirectLight = Surface.IndirectDiffuse * _PackedAmbient;
            #if defined(_BACKLACE_SHADOW_TEXTURE)
                float3 shadedAlbedo = GetTexturedShadowColor(Surface, directLight, UNITY_SAMPLE_TEX2D_SAMPLER(_PackedMapTwo, _MainTex, Uvs[_PackedMapTwo_UV]).rgb);
            #else // _BACKLACE_SHADOW_TEXTURE
                float3 shadedAlbedo = UNITY_SAMPLE_TEX2D_SAMPLER(_PackedMapTwo, _MainTex, Uvs[_PackedMapTwo_UV]).rgb;
            #endif // _BACKLACE_SHADOW_TEXTURE
            // rgb: control map (g: metal, b: rim)
            float3 controlMap = UNITY_SAMPLE_TEX2D_SAMPLER(_PackedMapThree, _MainTex, Uvs[_PackedMapThree_UV]).rgb;
            // basic lighting
            float halfLambert = Surface.UnmaxedNdotL * 0.5 + 0.5;
            float lightValue = baseMap.r * halfLambert * 2.0;
            float modelShadows = smoothstep(0.2 - _PackedShadowSmoothness, 0.2 + _PackedShadowSmoothness, lightValue);
            Surface.Diffuse = lerp(shadedAlbedo, Surface.Albedo.rgb, modelShadows);
            Surface.Diffuse = CombineDiffuses(Surface.Diffuse, directLight, indirectLight);
            // specular
            Surface.Diffuse *= (1.0 + saturate(baseMap.g * _PackedUmaSpecularBoost * (Surface.NdotV - 0.6)));
            // rim lighting
            if (_PackedRimLight == 1)
            {
                float rimDot = 1.0 - saturate(dot(Surface.ViewDir, Surface.NormalDir));
                float rimMask = smoothstep(_PackedRimThreshold, _PackedRimThreshold + 0.1, rimDot) * controlMap.b;
                float rimIntensity = rimMask * (1.0 - modelShadows) * _PackedRimPower;
                Surface.Diffuse += _PackedRimColor.rgb * rimIntensity;
            }
            // metallic, im not adding a fourth packed slot for a matcap so take this.
            float metalMask = controlMap.g;
            if (metalMask > 0.01 && _PackedMapMetals == 1)
            {
                float3 viewNormal = mul((float3x3)UNITY_MATRIX_V, Surface.NormalDir);
                float gradient = viewNormal.y * 0.5 + 0.5;
                float3 gradientColor = lerp(_PackedUmaMetalDark.rgb, _PackedUmaMetalLight.rgb, gradient);
                float3 reflectedView = reflect(-Surface.ViewDir, Surface.NormalDir);
                float3 envReflection = UNITY_SAMPLE_TEXCUBE_LOD(unity_SpecCube0, reflectedView, 0).rgb;
                float fresnel = pow(1.0 - saturate(Surface.NdotV), 3.0);
                float3 metalColor = lerp(gradientColor, envReflection, 0.5) * lerp(0.8, 1.5, fresnel);
                Surface.Diffuse += metalColor * metalMask;
            }
            Surface.Attenuation = Surface.LightColor.a; // always use default attenuation for uma musume
            Surface.Albedo.a *= baseMap.b; // apply clipping from blue channel
        }

        // mode three: guilty gear strive
        void GetGGSDiffuse(inout BacklaceSurfaceData Surface)
        {
            // ilm texture, r: specular intensity, g: shadow threshold/occlusion, b: specular mask, a: line/detail mask
            float4 ilmData = UNITY_SAMPLE_TEX2D_SAMPLER(_PackedMapOne, _MainTex, Uvs[0]);
            // sss/shadow colour
            float3 sssColor = UNITY_SAMPLE_TEX2D_SAMPLER(_PackedMapTwo, _MainTex, Uvs[0]).rgb;
            // detail lines texture
            float4 detailLines = UNITY_SAMPLE_TEX2D_SAMPLER(_PackedMapThree, _MainTex, Uvs[0]);
            // (fast) approximate gamma -> linear conversion for ILM channels
            ilmData.r = ilmData.r * ilmData.r;
            ilmData.g = ilmData.g * ilmData.g;
            ilmData.b = ilmData.b * ilmData.b;
            // standard toon stuff but weighted with maps
            float halfLambert = Surface.UnmaxedNdotL * 0.5 + 0.5;
            float ndlWithILM = (halfLambert * 0.5) + ((ilmData.g * 2.0) - 1.0);    
            // calculate shadow masks with smoothstep
            float shadow1Mask = DizzyStep(ndlWithILM, _PackedGGShadow1Push, _PackedGGShadow1Smoothness);
            float shadow2Mask = DizzyStep(ndlWithILM, _PackedGGShadow2Push, _PackedGGShadow2Smoothness);
            // layer the shadows: shadow2 is deepest, shadow1 is mid, base is lit
            float shadow2Only = shadow2Mask;
            float shadow1Only = max(0, shadow1Mask - shadow2Mask);
            float litOnly = saturate(1.0 - shadow1Mask - shadow2Mask);
            // prepare colours for each layer
            float3 litColor = Surface.Albedo.rgb * _PackedLitColor.rgb;
            float3 directLight = Surface.LightColor.rgb * Surface.LightColor.a;
            float3 indirectLight = Surface.IndirectDiffuse * _PackedAmbient;
            #if defined(_BACKLACE_SHADOW_TEXTURE)
                float3 texturedShadowBase = GetTexturedShadowColor(Surface, directLight, sssColor);
                float3 shadow1Color = texturedShadowBase * _PackedGGShadow1Tint.rgb;
                float3 shadow2Color = texturedShadowBase * _PackedGGShadow2Tint.rgb * 0.7; // deeper shadow
            #else // _BACKLACE_SHADOW_TEXTURE
                float3 shadow1Color = sssColor * _PackedGGShadow1Tint.rgb;
                float3 shadow2Color = sssColor * _PackedGGShadow2Tint.rgb * 0.7; // deeper shadow
            #endif // _BACKLACE_SHADOW_TEXTURE
            // blend shadow layers
            float3 shadowResult = lerp(shadow1Color, shadow2Color, saturate(1.0 - shadow1Only));
            // final diffuse blend
            float3 diffuseResult = lerp(shadowResult, litColor, litOnly);
            // apply detail lines (lerp towards line color in dark areas of detail map)
            #if defined(_BACKLACE_SHADOW_TEXTURE)
                float3 lineColor = GetTexturedShadowColor(Surface);
                diffuseResult = lerp(lineColor, diffuseResult, detailLines.r);
                // apply ILM alpha line mask
                diffuseResult = lerp(lineColor, diffuseResult, ilmData.a);
            #else // _BACKLACE_SHADOW_TEXTURE
                diffuseResult = lerp(_PackedShadowColor.rgb * sssColor, diffuseResult, detailLines.r);
                // apply ILM alpha line mask
                diffuseResult = lerp(_PackedShadowColor.rgb * sssColor, diffuseResult, ilmData.a);
            #endif // _BACKLACE_SHADOW_TEXTURE
            // specular calculation (half-vector based)
            float3 halfVec = normalize(Surface.LightDir + Surface.ViewDir);
            float ndh = saturate(dot(Surface.NormalDir, halfVec));
            // colour burn style specular with ILM blue channel
            float specBase = saturate(1.0 - ((1.0 - ndh) / max(ilmData.b, 0.00001)));
            float specMask = specBase > (1.0 - _PackedGGSpecularSize) ? 1.0 : 0.0;
            specMask = saturate(specMask);
            // apply specular, before lighting for this style
            float3 specColor = litColor * specMask * ilmData.r * _PackedGGSpecularIntensity * _PackedGGSpecularTint.rgb;
            diffuseResult += specColor;
            // rim lighting (fresnel-based)
            if (_PackedRimLight == 1)
            {
                float rimDot = 1.0 - saturate(Surface.NdotV);
                float rimMask = smoothstep(_PackedRimThreshold, _PackedRimThreshold + 0.1, rimDot);
                float rimIntensity = rimMask * litOnly * _PackedRimPower; // reduce rim in shadowed areas
                diffuseResult += _PackedRimColor.rgb * rimIntensity;
            }
            // apply light color and attenuation
            Surface.Diffuse = CombineDiffuses(diffuseResult, directLight, indirectLight);
            Surface.Attenuation = StyliseAttenuation(Surface.LightColor.a, litOnly * Surface.LightColor.a);   
        }

        // these modes have simple diffuse calculations because they rely on textures for most
        void GetPackedMapDiffuse(inout BacklaceSurfaceData Surface)
        {
            [branch] if (_PackedMapStyle == 0) // genshin
            {
                GetGenshinPackedDiffuse(Surface);
            } else if (_PackedMapStyle == 1) // uma musume
            {
                GetUmaMusumeDiffuse(Surface);
            } else if (_PackedMapStyle == 2) // guilty gear strive
            {
                GetGGSDiffuse(Surface);
            }
        }

        void GetPackedVertexDiffuse(inout BacklaceSurfaceData Surface)
        {
            Surface.VertexDirectDiffuse = 0;
            #if defined(VERTEXLIGHT_ON)
                float3 ignoredDir;
                Shade4PointLights(Surface.NormalDir, FragData.worldPos, Surface.VertexDirectDiffuse, ignoredDir);
                Surface.VertexDirectDiffuse *= Surface.Albedo;
            #endif
        }


    // [ ♡ ] ────────────────────── [ ♡ ]
    //
    //          Skin Shading
    //
    // [ ♡ ] ────────────────────── [ ♡ ]


    #elif defined(_ANIMEMODE_SKIN) // _ANIMEMODE_*
        void GetSkinDiffuse(inout BacklaceSurfaceData Surface)
        {
            // use y axis for curvature
            float ndotl = Surface.UnmaxedNdotL * 0.5 + 0.5;
            float2 lutUV = float2(ndotl, _SkinScattering);
            float3 skinRamp = UNITY_SAMPLE_TEX2D(_SkinLUT, lutUV).rgb;
            float rampLuma = GetLuma(skinRamp);
            float3 directLight = (Surface.LightColor.rgb * Surface.LightColor.a) * lerp(1, skinRamp, _DirectDiffuse);
            float3 indirectLight = Surface.IndirectDiffuse * lerp(1, smoothstep(0, 0.5, rampLuma), _IndirectDiffuse);
            #if defined(_BACKLACE_SHADOW_TEXTURE)
                float3 tint = lerp(GetTexturedShadowColor(Surface, directLight, lerp(_SkinShadowColor.rgb, float3(1, 1, 1), rampLuma)) / Surface.Albedo, float3(1, 1, 1), rampLuma);
            #else // _BACKLACE_SHADOW_TEXTURE
                float3 tint = lerp(_SkinShadowColor.rgb, float3(1, 1, 1), rampLuma);
            #endif // _BACKLACE_SHADOW_TEXTURE
            Surface.Diffuse = Surface.Albedo * tint;
            Surface.Diffuse = CombineDiffuses(Surface.Diffuse, directLight, indirectLight);
            Surface.Attenuation = StyliseAttenuation(Surface.LightColor.a, rampLuma * Surface.LightColor.a);
        }

        void GetSkinVertexDiffuse(inout BacklaceSurfaceData Surface)
        {
            Surface.VertexDirectDiffuse = 0;
            #if defined(VERTEXLIGHT_ON)
                float3 ignoredDir;
                Shade4PointLights(Surface.NormalDir, FragData.worldPos, Surface.VertexDirectDiffuse, ignoredDir);
                Surface.VertexDirectDiffuse *= Surface.Albedo;
                Surface.VertexDirectDiffuse = lerp(Surface.VertexDirectDiffuse * _SkinShadowColor.rgb, Surface.VertexDirectDiffuse, 0.8);
            #endif // VERTEXLIGHT_ON
        }


    // [ ♡ ] ────────────────────── [ ♡ ]
    //
    //          Wrapped Shading
    //
    // [ ♡ ] ────────────────────── [ ♡ ]


    #elif defined(_ANIMEMODE_WRAPPED) // _ANIMEMODE_*
        void GetWrappedDiffuse(inout BacklaceSurfaceData Surface)
        {
            float wrappedTerm = (Surface.UnmaxedNdotL + _WrapFactor) / (1.0 + _WrapFactor); // (N*L + w) / (1 + w)
            float wrappedNdotL = saturate(wrappedTerm);
            float normalizationFactor = lerp(1.0, 1.0 / (1.0 + _WrapFactor), _WrapNormalization);
            float3 directLight = Surface.LightColor.rgb * Surface.LightColor.a;
            float3 indirectLight = Surface.IndirectDiffuse;
            #if defined(_BACKLACE_SHADOW_TEXTURE)
                float3 shadowColor = GetTexturedShadowColor(Surface, totalLight, _WrapColorLow.rgb) / Surface.Albedo;
                float3 ramp = lerp(shadowColor, _WrapColorHigh.rgb, wrappedNdotL);
            #else // _BACKLACE_SHADOW_TEXTURE
                float3 ramp = lerp(_WrapColorLow.rgb, _WrapColorHigh.rgb, wrappedNdotL);
            #endif // _BACKLACE_SHADOW_TEXTURE
            ramp *= normalizationFactor;
            Surface.Diffuse = Surface.Albedo * ramp;
            indirectLight *= lerp(1, ramp, _IndirectDiffuse);
            Surface.Diffuse = CombineDiffuses(Surface.Diffuse, directLight * lerp(1, wrappedNdotL, _DirectDiffuse), indirectLight);
            Surface.Attenuation = StyliseAttenuation(Surface.LightColor.a, wrappedNdotL * Surface.LightColor.a);
        }

        void WrappedVertLight(float3 normal, float3 worldPos, out float3 color)
        {
            float4 toLightX = unity_4LightPosX0 - worldPos.x;
            float4 toLightY = unity_4LightPosY0 - worldPos.y;
            float4 toLightZ = unity_4LightPosZ0 - worldPos.z;
            float4 lengthSq = toLightX * toLightX + toLightY * toLightY + toLightZ * toLightZ;
            float4 ndl = toLightX * normal.x + toLightY * normal.y + toLightZ * normal.z;
            float4 corr = rsqrt(lengthSq);
            ndl = ndl * corr;
            float4 atten = 1.0 / (1.0 + lengthSq * unity_4LightAtten0);
            float4 wrappedNdl = (ndl + _WrapFactor) / (1.0 + _WrapFactor);
            wrappedNdl = max(0, wrappedNdl);
            float norm = lerp(1.0, 1.0 / (1.0 + _WrapFactor), _WrapNormalization);
            float4 diff = wrappedNdl * norm * atten;
            color = 0;
            color += unity_LightColor[0].rgb * diff.x;
            color += unity_LightColor[1].rgb * diff.y;
            color += unity_LightColor[2].rgb * diff.z;
            color += unity_LightColor[3].rgb * diff.w;
        }

        void GetWrappedVertexDiffuse(inout BacklaceSurfaceData Surface)
        {
            Surface.VertexDirectDiffuse = 0;
            #if defined(VERTEXLIGHT_ON)
                WrappedVertLight(Surface.NormalDir, FragData.worldPos, Surface.VertexDirectDiffuse);
                Surface.VertexDirectDiffuse *= Surface.Albedo;
            #endif // VERTEXLIGHT_ON
        }
    #endif // _ANIMEMODE_*


    // [ ♡ ] ────────────────────── [ ♡ ]
    //
    //          Anime Wrapper
    //
    // [ ♡ ] ────────────────────── [ ♡ ]


    // wrapper function for toon diffuse
    void GetAnimeDiffuse(inout BacklaceSurfaceData Surface)
    {
        // apply applicable mixins
        #if defined(_BACKLACE_ANIME_EXTRAS)
            ApplyAnimeGradient(Surface);
            ApplyStockings(Surface);
            ApplyEyeParallax(Surface);
            ApplyExpressionMap(Surface);
            ApplyFaceMap(Surface);
            ApplyHairTransparency(Surface);
            ApplySDFShadow(Surface);
        #endif // _BACKLACE_ANIME_EXTRAS
        // select anime mode
        #if defined(_ANIMEMODE_RAMP)
            // traditional toony ramp
            GetRampDiffuse(Surface);
            GetRampVertexDiffuse(Surface);
        #elif defined(_ANIMEMODE_CEL) // _ANIMEMODE_*
            // cel-shaded style
            GetCelDiffuse(Surface);
            GetCelVertexDiffuse(Surface);
        #elif defined(_ANIMEMODE_NPR) // _ANIMEMODE_*
            // npr style
            GetNPRDiffuse(Surface);
            GetNPRVertexDiffuse(Surface);
        #elif defined(_ANIMEMODE_TRIBAND) // _ANIMEMODE_*
            // tri-band style
            GetTriBandDiffuse(Surface);
            GetTriBandVertexDiffuse(Surface);
        #elif defined(_ANIMEMODE_PACKED) // _ANIMEMODE_*
            // packed texture style
            GetPackedMapDiffuse(Surface);
            GetPackedVertexDiffuse(Surface);
        #elif defined(_ANIMEMODE_SKIN) // _ANIMEMODE_*
            // skin-focused anime style
            GetSkinDiffuse(Surface);
            GetSkinVertexDiffuse(Surface);
        #elif defined(_ANIMEMODE_WRAPPED) // _ANIMEMODE_*
            // wrapped lighting anime style
            GetWrappedDiffuse(Surface);
            GetWrappedVertexDiffuse(Surface);
        #endif // _ANIMEMODE_*
        // continue the optional mixins
        #if defined(_BACKLACE_ANIME_EXTRAS)
            ApplyAmbientGradient(Surface);
            // anime-styled specular goes after lighting
            ApplyToonHighlights(Surface);
            ApplyAngelRings(Surface);
            // preview manual normals in debug mode
            if (_ToggleManualNormals == 1 && _ManualNormalPreview != 0)
            {
                switch (_ManualNormalPreview)
                {
                    case 1: // X
                        Surface.Diffuse = abs(Surface.NormalDir.x);
                        break;
                    case 2: // Y
                        Surface.Diffuse = abs(Surface.NormalDir.y);
                        break;
                    case 3: // Z
                        Surface.Diffuse = abs(Surface.NormalDir.z);
                        break;
                    default: // (4) XYZ
                        Surface.Diffuse = abs(Surface.NormalDir);
                        break;
                }
            }
        #endif // _BACKLACE_ANIME_EXTRAS
    }
#endif // BACKLACE_TOON


// [ ♡ ] ────────────────────── [ ♡ ]
//
//        Specular Features
//
// [ ♡ ] ────────────────────── [ ♡ ]


#if defined(_BACKLACE_SPECULAR)


    // [ ♡ ] ────────────────────── [ ♡ ]
    //
    //         Specular Helpers
    //
    // [ ♡ ] ────────────────────── [ ♡ ]


    // unity's glossy environment function with remapped roughness
    half4 Unity_GlossyEnvironment(UNITY_ARGS_TEXCUBE(tex), half4 hdr, Unity_GlossyEnvironmentData glossIn)
    {
        half perceptualRoughness = glossIn.roughness;
        perceptualRoughness = perceptualRoughness * (1.5 - 0.5 * perceptualRoughness);
        half mip = perceptualRoughness * UNITY_SPECCUBE_LOD_STEPS;
        half3 R = glossIn.reflUVW;
        half4 rgbm = UNITY_SAMPLE_TEXCUBE_LOD(tex, R, mip);
        return float4(DecodeHDR(rgbm, hdr), rgbm.a);
    }

    // gets the indirect lighting color from a fallback cubemap using the reflected direction and remapped roughness
    void GetFallbackCubemap(inout BacklaceSurfaceData Surface)
    {
        Surface.CustomIndirect = texCUBElod(_FallbackCubemap, half4(Surface.ReflectDir.xyz, remap(Surface.SquareRoughness, 1, 0, 5, 0))).rgb;
    }

    // modifies the tangent based on the tangent map and original tangent direction
    float3 GetModifiedTangent(float3 tangentTS, float3 tangentDir)
    {
        tangentTS = tangentTS * 2.0 - 1.0; // remap from [0,1] to [-1,1] if needed
        return normalize(lerp(tangentDir, normalize(tangentTS), saturate(length(tangentTS.xy))));
    }

    // gtr2 anisotropic distribution function
    float GTR2_aniso(float NdotH, float HdotX, float HdotY, float ax, float ay)
    {
        float denominator = sqr(sqr(HdotX / ax) + sqr(HdotY / ay) + sqr(NdotH));
        return 1.0 / (UNITY_PI * ax * ay * denominator);
    }

    // ggx anisotropic distribution function
    float SmithGGGX_aniso(float NdotV, float VdotX, float VdotY, float ax, float ay)
    {
        return 1 / (NdotV + sqrt(sqr(VdotX * ax) + sqr(VdotY * ay) + sqr(NdotV)));
    }

    // shift a tangent
    float3 ShiftTangent(float3 T, float3 N, float shift)
    {
        return normalize(T + shift * N);
    }

    // standard direct specular calculation (used in a few modes)
    void StandardSpecular(float ndotH, float ndotL, float ndotV, out float outNDF, out float outGFS, inout BacklaceSurfaceData Surface)
    {
        outNDF = GTR2(ndotH, Surface.SquareRoughness);
        outGFS = SmithGGGX(max(ndotL, lerp(0.3, 0, Surface.SquareRoughness)), Surface.Roughness) * SmithGGGX(ndotV, Surface.Roughness);
    }


    // [ ♡ ] ────────────────────── [ ♡ ]
    //
    //          Specular Energy
    //
    // [ ♡ ] ────────────────────── [ ♡ ]

    
    void SetupDFG(inout BacklaceSurfaceData Surface)
    {
        Surface.EnergyCompensation = 1.0;
        switch(_SpecularEnergyMode)
        {
            case 1: // turquin approximation for multi-scaattering
                float3 F0 = Surface.SpecularColor;
                float f0Luminance = GetLuma(F0);
                float smoothness = 1.0 - Surface.Roughness;
                Surface.EnergyCompensation = 1.0 + f0Luminance * smoothness;
                break;
            case 2: // safe and cheap
                Surface.EnergyCompensation = 1.0 + Surface.Roughness * 0.5;
                break;
            case 3: // manual control
                Surface.EnergyCompensation = _SpecularEnergy;
                break;
            default: // (0) none, just 1.0
                // no energy compensation
                break;
        }
        Surface.EnergyCompensation = clamp(Surface.EnergyCompensation, _SpecularEnergyMin, _SpecularEnergyMax);
    }


    // [ ♡ ] ────────────────────── [ ♡ ]
    //
    //       Anisotropic Specular
    //
    // [ ♡ ] ────────────────────── [ ♡ ]


    void AnisoSpecular(float3 tangentDir, float3 bitangentDir, float3 lightDir, float3 halfDir, float ndotH, float ndotL, float ndotV, out float outNDF, out float outGFS, inout BacklaceSurfaceData Surface)
    {
        outNDF = 0;
        outGFS = 0;
        float TdotH = dot(Surface.ModifiedTangent, halfDir);
        float TdotL = dot(Surface.ModifiedTangent, lightDir);
        float BdotH = dot(bitangentDir, halfDir);
        float BdotL = dot(bitangentDir, lightDir);
        float TdotV = dot(Surface.ViewDir, Surface.ModifiedTangent);
        float BdotV = dot(bitangentDir, Surface.ViewDir);
        float ax = max(Surface.SquareRoughness * (1.0 + Surface.Anisotropy), 0.005);
        float ay = max(Surface.SquareRoughness * (1.0 - Surface.Anisotropy), 0.005);
        outNDF = GTR2_aniso(ndotH, TdotH, BdotH, ax, ay) * UNITY_PI;
        outGFS = SmithGGGX_aniso(ndotL, TdotL, BdotL, ax, ay);
        outGFS *= SmithGGGX_aniso(ndotV, TdotV, BdotV, ax, ay);
    }


    // [ ♡ ] ────────────────────── [ ♡ ]
    //
    //         Specular Wrappers
    //
    // [ ♡ ] ────────────────────── [ ♡ ]


    // indirect specular using box-projected cubemaps with a fallback option
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
        if ((_IndirectFallbackMode > 0 && indirectSpecularRGBA.a == 0) || (_IndirectOverride == 1))
        {
            // using the fake specular probe toned down based on the average light, it's not phisically accurate
            // but having a probe that reflects arbitrary stuff isn't accurate to begin with
            half lightColGrey = max((Surface.LightColor.r + Surface.LightColor.g + Surface.LightColor.b) / 3, (Surface.IndirectDiffuse.r + Surface.IndirectDiffuse.g + Surface.IndirectDiffuse.b) / 3);
            Surface.IndirectSpecular = Surface.CustomIndirect * min(lightColGrey, 1);
        }
        float horizon = min(1.0 + dot(Surface.ReflectDir, Surface.NormalDir), 1.0);
        Surface.IndirectSpecular *= Surface.EnergyCompensation * horizon * horizon * Surface.SpecularColor;
        #if defined(_BACKLACE_CLEARCOAT)
            Surface.IndirectSpecular *= _ClearcoatReflectionStrength;
        #endif // _BACKLACE_CLEARCOAT
    }

    // add indirect specular to final color with fresnel-based occlusion
    void AddIndirectSpecular(inout BacklaceSurfaceData Surface)
    {
        Surface.FinalColor.rgb += 
            (Surface.IndirectSpecular * clamp(pow(Surface.NdotV + Surface.Occlusion, 
            exp2(-16.0 * Surface.SquareRoughness - 1.0)) - 
            1.0 + Surface.Occlusion, 0.0, 1.0) * Surface.Attenuation);
    }

    // direct specular calculations
    float3 CalculateDirectSpecular(float3 tangentDir, float3 bitangentDir, float3 lightDir, float3 halfDir, float ndotH, float ndotL, float ndotV, float ldotH, float attenuation, inout BacklaceSurfaceData Surface)
    {
        if (ndotL <= 0 || !any(Surface.SpecularColor))
        {
            return 0.0; // safety checks
        }
        float3 specTerm = float3(0, 0, 0);
        float NDF_Term = 0;
        float GFS_Term = 0;
        [branch] if (_SpecularMode == 0) // standard
        {
            float3 F_Term = FresnelTerm(Surface.SpecularColor, ldotH);
            StandardSpecular(ndotH, ndotL, ndotV, NDF_Term, GFS_Term, Surface);
            float3 numerator = NDF_Term * GFS_Term * F_Term;
            float denominator = 4.0 * ndotV * ndotL;
            specTerm = numerator / max(denominator, 0.001);
            specTerm *= _SpecularIntensity * ndotL * Surface.EnergyCompensation;
            #if defined(UNITY_COLORSPACE_GAMMA)
                specTerm = sqrt(max(1e-4h, specTerm));
            #endif // UNITY_COLORSPACE_GAMMA
            return max(0, specTerm * attenuation);
        }
        else // anisotropic 
        {
            float4 tangentTS = UNITY_SAMPLE_TEX2D_SAMPLER(_TangentMap, _MainTex, BACKLACE_TRANSFORM_TEX(Uvs, _TangentMap));
            Surface.Anisotropy = tangentTS.a * _Anisotropy;
            Surface.ModifiedTangent = GetModifiedTangent(tangentTS.rgb, Surface.TangentDir);
            float3 anisotropyDirection = Surface.Anisotropy >= 0.0 ? Surface.BitangentDir : Surface.TangentDir;
            float3 anisotropicTangent = cross(anisotropyDirection, Surface.ViewDir);
            float3 anisotropicNormal = cross(anisotropicTangent, anisotropyDirection);
            float bendFactor = abs(Surface.Anisotropy) * saturate(1 - (Pow5(1 - Surface.SquareRoughness)));
            float3 bentNormal = normalize(lerp(Surface.NormalDir, anisotropicNormal, bendFactor));
            Surface.ReflectDir = reflect(-Surface.ViewDir, bentNormal);
            AnisoSpecular(tangentDir, bitangentDir, lightDir, halfDir, ndotH, ndotL, ndotV, NDF_Term, GFS_Term, Surface);
            float3 F_Term = FresnelTerm(Surface.SpecularColor, ldotH);
            float3 numerator = NDF_Term * GFS_Term * F_Term;
            float denominator = 4.0 * ndotV * ndotL;
            specTerm = numerator / max(denominator, 0.001);
            specTerm *= _SpecularIntensity * ndotL * Surface.EnergyCompensation;
            #ifdef UNITY_COLORSPACE_GAMMA
                specTerm = sqrt(max(1e-4h, specTerm));
            #endif // UNITY_COLORSPACE_GAMMA
            return max(0, specTerm * attenuation);
        }
    }

    // add direct specular to final color
    void AddDirectSpecular(inout BacklaceSurfaceData Surface)
    {
        Surface.FinalColor.rgb += Surface.DirectSpecular * Surface.LightColor.rgb * Surface.Attenuation;
    }

    // vertex specular feature
    #if defined(VERTEXLIGHT_ON)
        void AddVertexSpecular(inout BacklaceSurfaceData Surface)
        {
            if (_ToggleVertexSpecular == 0) return;
            if (dot(VertexLightDir, VertexLightDir) < 0.0001) return;
            float3 VLightDir = normalize(VertexLightDir);
            float3 V_HalfDir = normalize(VLightDir + Surface.ViewDir);
            float V_NdotL = saturate(dot(Surface.NormalDir, VLightDir));
            float V_NdotH = saturate(dot(Surface.NormalDir, V_HalfDir));
            float V_LdotH = saturate(dot(VLightDir, V_HalfDir));
            // note: just passing 1.0 for attenuation as the colour is already attenuated
            float3 VertexSpecular = CalculateDirectSpecular(Surface.TangentDir, Surface.BitangentDir, VLightDir, V_HalfDir, V_NdotH, V_NdotL, Surface.NdotV, V_LdotH, 1.0, Surface);
            Surface.FinalColor.rgb += VertexSpecular * Surface.VertexDirectDiffuse;
        }
    #endif // VERTEXLIGHT_ON
#endif // _BACKLACE_SPECULAR


#endif // BACKLACE_SHADING_CGINC