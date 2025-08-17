#ifndef BACKLACE_FORWARD_CGINC
#define BACKLACE_FORWARD_CGINC

// Helper function to clamp the brightness of a light color while preserving its hue
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

// clip alpha based on the _Cutoff value or dither mask
// todo: make cutoff passed and not _Cutoff
void ClipAlpha()
{
    #if defined(_ALPHATEST_ON)
        clip(Albedo.a - _Cutoff);
    #else
        #if defined(_ALPHAMODULATE_ON)
            float dither = tex3D(_DitherMaskLOD, float3(FragData.pos.xy * 0.25, Albedo.a * 0.9375)).a; //Dither16x16Bayer(FragData.pos.xy * 0.25) * Albedo.a;
            clip(dither - 0.01);
        #endif
    #endif
}

// sample normal map
// todo: pass maps, not properties
void SampleNormal()
{
    NormalMap = UnpackScaleNormal(UNITY_SAMPLE_TEX2D_SAMPLER(_BumpMap, _MainTex, BACKLACE_TRANSFORM_TEX(Uvs, _BumpMap)), _BumpScale);
}

// safe normalize a half3 vector
half3 Unity_SafeNormalize(half3 inVec)
{
    half dp3 = max(0.001f, dot(inVec, inVec));
    return inVec * rsqrt(dp3);
}

// calculate normals from normal map
void CalculateNormals(inout float3 normal, inout float3 tangent, inout float3 bitangent, float3 normalmap)
{
    float3 tspace0 = float3(tangent.x, bitangent.x, normal.x);
    float3 tspace1 = float3(tangent.y, bitangent.y, normal.y);
    float3 tspace2 = float3(tangent.z, bitangent.z, normal.z);
    float3 calcedNormal;
    calcedNormal.x = dot(tspace0, normalmap);
    calcedNormal.y = dot(tspace1, normalmap);
    calcedNormal.z = dot(tspace2, normalmap);
    calcedNormal = normalize(calcedNormal);
    float3 bumpedTangent = (cross(bitangent, calcedNormal));
    float3 bumpedBitangent = (cross(calcedNormal, bumpedTangent));
    normal = calcedNormal;
    tangent = bumpedTangent;
    bitangent = bumpedBitangent;
}

// get direction vectors
void GetDirectionVectors()
{
    NormalDir = normalize(FragData.normal);
    TangentDir = normalize(UnityObjectToWorldDir(FragData.tangentDir.xyz));
    BitangentDir = normalize(cross(NormalDir, TangentDir) * FragData.tangentDir.w * unity_WorldTransformParams.w);
    CalculateNormals(NormalDir, TangentDir, BitangentDir, NormalMap);
    LightDir = normalize(UnityWorldSpaceLightDir(FragData.worldPos));
    ViewDir = normalize(UnityWorldSpaceViewDir(FragData.worldPos));
    ReflectDir = reflect(-ViewDir, NormalDir);
    HalfDir = Unity_SafeNormalize(LightDir + ViewDir);
}

// get SH length
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
        // UNITY_LIGHT_ATTENUATION doesn't fade shadows for us.
        float viewZ = dot(_WorldSpaceCameraPos - i.worldPos, UNITY_MATRIX_V[2].xyz);
        float shadowFadeDistance = UnityComputeShadowFadeDistance(i.worldPos, viewZ);
        float shadowFade = UnityComputeShadowFade(shadowFadeDistance);
        attenuation = saturate(attenuation + shadowFade);
    #endif
    #if defined(LIGHTMAP_ON) && defined(SHADOWS_SHADOWMASK)
        // UNITY_LIGHT_ATTENUATION doesn't fade shadows for us.
        float viewZ = dot(_WorldSpaceCameraPos - i.worldPos, UNITY_MATRIX_V[2].xyz);
        float shadowFadeDistance = UnityComputeShadowFadeDistance(i.worldPos, viewZ);
        float shadowFade = UnityComputeShadowFade(shadowFadeDistance);
        float bakedAttenuation = UnitySampleBakedOcclusion(i.lightmapUV, i.worldPos);
        attenuation = UnityMixRealtimeAndBakedShadows(attenuation, bakedAttenuation, shadowFade);
        //attenuation = saturate(attenuation + shadowFade);
        //attenuation = bakedAttenuation;   
    #endif
    return attenuation;
}

// get light data
void GetLightData()
{
    UNITY_LIGHT_ATTENUATION(attenuation, FragData, FragData.worldPos);
    attenuation = FadeShadows(FragData, attenuation);
    LightAttenuation = attenuation;
    
    //lightmap sampling
    #if defined(LIGHTMAP_ON)
        Lightmap = DecodeLightmap(UNITY_SAMPLE_TEX2D(unity_Lightmap, FragData.lightmapUV));
        
        //directional map sampling
        #if defined(DIRLIGHTMAP_COMBINED)
            LightmapDirection = UNITY_SAMPLE_TEX2D_SAMPLER(unity_LightmapInd, unity_Lightmap, FragData.lightmapUV);
        #endif
    #endif
    //dynamic Lightmap sampling
    #if defined(DYNAMICLIGHTMAP_ON)
        DynamicLightmap = DecodeRealtimeLightmap(UNITY_SAMPLE_TEX2D(unity_DynamicLightmap, FragData.dynamicLightmapUV));
        
        #if defined(DIRLIGHTMAP_COMBINED)
            DynamicLightmapDirection = UNITY_SAMPLE_TEX2D_SAMPLER(unity_DynamicDirectionality, unity_DynamicLightmap, FragData.dynamicLightmapUV);
        #endif
    #endif
    
    LightColor = float4(_LightColor0.rgb, LightAttenuation);
    SpecLightColor = LightColor;
    IndirectDiffuse = 0;
    //only counts it in the forwardBase pass
    #if defined(UNITY_PASS_FORWARDBASE)
        
        LightColor.rgb += float3(unity_SHAr.w, unity_SHAg.w, unity_SHAb.w);
        //some random magic to get more tinted by the ambient
        LightColor.rgb = lerp(GetSHLength(), LightColor.rgb, .75);
        SpecLightColor = LightColor;
        
        #if defined(LIGHTMAP_ON)
            IndirectDiffuse = Lightmap;
            #if defined(DIRLIGHTMAP_COMBINED)
                IndirectDiffuse = DecodeDirectionalLightmap(IndirectDiffuse, LightmapDirection, NormalDir);
            #endif
        #endif
        
        #if defined(DYNAMICLIGHTMAP_ON)
            
            #if defined(DIRLIGHTMAP_COMBINED)
                IndirectDiffuse += DecodeDirectionalLightmap(DynamicLightmap, DynamicLightmapDirection, NormalDir);
            #else
                IndirectDiffuse += DynamicLightmap;
            #endif
        #endif
        
        #if !defined(LIGHTMAP_ON) && !defined(DYNAMICLIGHTMAP_ON)
            
            //if there's no direct light, we get the probe light direction to use as direct light direction and
            //we consider the indirect light color as it was the direct light color.
            //also taking into account the case of a really low intensity being considered like non existent due to it no having
            //much relevance anyways and it can cause problems locally on mirrors if the avatat has a very low intensity light
            //just for enabling the depth buffer.
            IndirectDiffuse = float3(unity_SHAr.w, unity_SHAg.w, unity_SHAb.w);
            if (any(_WorldSpaceLightPos0.xyz) == 0 || _LightColor0.a < 0.01)
            {
                LightDir = normalize(unity_SHAr.xyz + unity_SHAg.xyz + unity_SHAb.xyz);
                HalfDir = Unity_SafeNormalize(LightDir + ViewDir);
                SpecLightColor.rgb = IndirectDiffuse;
                LightColor.a = 1;
                if (_DirectLightMode > 0)
                {
                    LightColor.rgb = IndirectDiffuse;
                    IndirectDiffuse = 0;
                }
            }
        #endif
    #endif
}

// get dot products
void GetDotProducts()
{
    UnmaxedNdotL = dot(NormalDir, LightDir);
    UnmaxedNdotL = min(UnmaxedNdotL, LightColor.a);
    NdotL = max(UnmaxedNdotL, 0);
    NdotV = abs(dot(NormalDir, ViewDir));
    NdotH = max(dot(NormalDir, HalfDir), 0);
    LdotH = max(dot(LightDir, HalfDir), 0);
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
    return 1 / (NdotV + sqrt(a + b - a * b));
}

// standard direct specular calculation
void StandardDirectSpecular()
{
    NDF = GTR2(NdotH, SquareRoughness) * UNITY_PI;
    GFS = smithG_GGX(max(NdotL, lerp(0.3, 0, SquareRoughness)), Roughness) * smithG_GGX(NdotV, Roughness);
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
        fTangent = tangentTWS;
    else
        fTangent = tangentDir;
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

// ...
void AnisotropicDirectSpecular()
{
    float4 tangentTS = UNITY_SAMPLE_TEX2D_SAMPLER(_TangentMap, _MainTex, BACKLACE_TRANSFORM_TEX(Uvs, _TangentMap));
    float anisotropy = tangentTS.a * _Anisotropy;
    float3 tangent = GetModifiedTangent(tangentTS.rgb, TangentDir);
    float3 anisotropyDirection = anisotropy >= 0.0 ? BitangentDir : TangentDir;
    float3 anisotropicTangent = cross(anisotropyDirection, ViewDir);
    float3 anisotropicNormal = cross(anisotropicTangent, anisotropyDirection);
    float bendFactor = abs(anisotropy) * saturate(1 - (Pow5(1 - SquareRoughness)));
    float3 bentNormal = normalize(lerp(NormalDir, anisotropicNormal, bendFactor));
    ReflectDir = reflect(-ViewDir, bentNormal);
    float TdotH = dot(tangent, HalfDir);
    float TdotL = dot(tangent, LightDir);
    float BdotH = dot(BitangentDir, HalfDir);
    float BdotL = dot(BitangentDir, LightDir);
    float TdotV = dot(ViewDir, tangent);
    float BdotV = dot(ViewDir, BitangentDir);
    //float aspect = sqrt(1-anisotropy*.9);
    //float ax = max(.005, SquareRoughness / aspect);
    //float ay = max(.005, SquareRoughness * aspect);
    float ax = max(SquareRoughness * (1.0 + anisotropy), 0.005);
    float ay = max(SquareRoughness * (1.0 - anisotropy), 0.005);
    NDF = GTR2_aniso(NdotH, TdotH, BdotH, ax, ay) * UNITY_PI;
    GFS = smithG_GGX_aniso(NdotL, TdotL, BdotL, ax, ay);
    GFS *= smithG_GGX_aniso(NdotV, TdotV, BdotV, ax, ay);
    //NDF = GTR2(NdotH, SquareRoughness) * UNITY_PI;
    //GFS = smithG_GGX(max(NdotL,lerp(0.3,0,SquareRoughness)), Roughness) * smithG_GGX(NdotV, Roughness);
}

// ...
void GetFallbackCubemap()
{
    CustomIndirect = texCUBElod(_FallbackCubemap, half4(ReflectDir.xyz, remap(SquareRoughness, 1, 0, 5, 0))).rgb;
}

// specular feature
#if defined(_BACKLACE_SPECULAR)

    // setup albedo and specular color
    void SetupDFG()
    {
        float3 dfguv = float3(NdotV, Roughness, 0);
        Dfg = _DFG.Sample(sampler_DFG, dfguv).xyz;
        EnergyCompensation = lerp(1.0 + SpecularColor * (1.0 / Dfg.y - 1.0), 1, _DFGType);
    }

    // ...
    inline half3 FresnelTerm(half3 F0, half cosA)
    {
        half t = Pow5(1 - cosA);   // ala Schlick interpoliation
        return F0 + (1 - F0) * t;
    }

    // ...
    void FinalizeDirectSpecularTerm()
    {
        DirectSpecular = GFS * NDF * FresnelTerm(SpecularColor, LdotH) * EnergyCompensation;
        #ifdef UNITY_COLORSPACE_GAMMA
            DirectSpecular = sqrt(max(1e-4h, DirectSpecular));
        #endif
        DirectSpecular = max(0, DirectSpecular * Attenuation);
        DirectSpecular *= any(SpecularColor) ? 1.0 : 0.0;
    }

    // ...
    struct Unity_GlossyEnvironmentData
    {
        // - Deferred case have one cubemap
        // - Forward case can have two blended cubemap (unusual should be deprecated).
        // Surface properties use for cubemap integration
        half roughness; // CAUTION: This is perceptualRoughness but because of compatibility this name can't be change :(
        half3 reflUVW;
    };

    // ...
    half perceptualRoughnessToMipmapLevel(half perceptualRoughness)
    {
        return perceptualRoughness * UNITY_SPECCUBE_LOD_STEPS;
    }

    // ...
    half4 Unity_GlossyEnvironment(UNITY_ARGS_TEXCUBE(tex), half4 hdr, Unity_GlossyEnvironmentData glossIn)
    {
        half perceptualRoughness = glossIn.roughness /* perceptualRoughness */ ;
        #if 0
            float m = PerceptualRoughnessToRoughness(perceptualRoughness); // m is the real roughness parameter
            const float fEps = 1.192092896e-07F;        // smallest such that 1.0+FLT_EPSILON != 1.0  (+1e-4h is NOT good here. is visibly very wrong)
            float n = (2.0 / max(fEps, m * m)) - 2.0;        // remap to spec power. See eq. 21 in --> https://dl.dropboxusercontent.com/u/55891920/papers/mm_brdf.pdf
            n /= 4;                                     // remap from n_dot_h formulatino to n_dot_r. See section "Pre-convolved Cube Maps vs Path Tracers" --> https://s3.amazonaws.com/docs.knaldtech.com/knald/1.0.0/lys_power_drops.html
            perceptualRoughness = pow(2 / (n + 2), 0.25);      // remap back to square root of real roughness (0.25 include both the sqrt root of the conversion and sqrt for going from roughness to perceptualRoughness)
        #else
            // MM: came up with a surprisingly close approximation to what the #if 0'ed out code above does.
            perceptualRoughness = perceptualRoughness * (1.7 - 0.7 * perceptualRoughness);
        #endif
        half mip = perceptualRoughnessToMipmapLevel(perceptualRoughness);
        half3 R = glossIn.reflUVW;
        half4 rgbm = UNITY_SAMPLE_TEXCUBE_LOD(tex, R, mip);
        return float4(DecodeHDR(rgbm, hdr), rgbm.a);
    }

    // ...
    inline half3 FresnelLerp(half3 F0, half3 F90, half cosA)
    {
        half t = Pow5(1 - cosA);   // ala Schlick interpoliation
        return lerp(F0, F90, t);
    }

    // ...
    void GetIndirectSpecular()
    {
        Unity_GlossyEnvironmentData envData;
        envData.roughness = Roughness;
        envData.reflUVW = BoxProjectedCubemapDirection(ReflectDir, FragData.worldPos, unity_SpecCube0_ProbePosition, unity_SpecCube0_BoxMin, unity_SpecCube0_BoxMax);
        float4 indirectSpecularRGBA = Unity_GlossyEnvironment(UNITY_PASS_TEXCUBE(unity_SpecCube0), unity_SpecCube0_HDR, envData);
        #if defined(UNITY_SPECCUBE_BLENDING) && !defined(SHADER_API_MOBILE)
            UNITY_BRANCH
            if (unity_SpecCube0_BoxMin.w < 0.99999)
            {
                envData.reflUVW = BoxProjectedCubemapDirection(ReflectDir, FragData.worldPos, unity_SpecCube1_ProbePosition, unity_SpecCube1_BoxMin, unity_SpecCube1_BoxMax);
                float4 indirectSpecularRGBA1 = Unity_GlossyEnvironment(UNITY_PASS_TEXCUBE_SAMPLER(unity_SpecCube1, unity_SpecCube0), unity_SpecCube1_HDR, envData);
                indirectSpecularRGBA = lerp(indirectSpecularRGBA1, indirectSpecularRGBA, unity_SpecCube0_BoxMin.w);
            }
        #endif
        IndirectSpecular = indirectSpecularRGBA.rgb;
        if ((_IndirectFallbackMode > 0 && indirectSpecularRGBA.a == 0) || (_IndirectOverride > 0))
        {
            //using the fake specular probe toned down based on the average light, it's not phisically accurate
            //but having a probe that reflects arbitrary stuff isn't accurate to begin with
            half lightColGrey = max((LightColor.r + LightColor.g + LightColor.b) / 3, (IndirectDiffuse.r + IndirectDiffuse.g + IndirectDiffuse.b) / 3);
            IndirectSpecular = CustomIndirect * min(lightColGrey, 1);
        }
        float horizon = min(1 + NdotH, 1.0);
        float grazingTerm = saturate(1 - SquareRoughness + (1 - OneMinusReflectivity));
        Dfg.x *= lerp(1.0, saturate(dot(IndirectDiffuse, 1.0)), Occlusion);
        IndirectSpecular *= EnergyCompensation * horizon * horizon * lerp(lerp(Dfg.xxx, Dfg.yyy, SpecularColor), SpecularColor * Dfg.z, _DFGType);
    }

    // ...
    void AddDirectSpecular()
    {
        FinalColor.rgb += DirectSpecular * SpecLightColor.rgb * SpecLightColor.a;
    }

    // ...
    void AddIndirectSpecular()
    {
        FinalColor.rgb += IndirectSpecular * clamp(pow(NdotV + Occlusion, exp2(-16.0 * SquareRoughness - 1.0)) - 1.0 + Occlusion, 0.0, 1.0);
    }

#endif // defined(_BACKLACE_SPECULAR)

// premultiply alpha
void PremultiplyAlpha()
{
    #if defined(_ALPHAPREMULTIPLY_ON)
        Albedo.rgb *= Albedo.a;
    #endif
}

//unity's base diffuse based on disney implementation
float DisneyDiffuse(half perceptualRoughness)
{
    float fd90 = 0.5 + 2 * LdotH * LdotH * perceptualRoughness;
    // Two schlick fresnel term
    float lightScatter = (1 + (fd90 - 1) * Pow5(1 - NdotL));
    float viewScatter = (1 + (fd90 - 1) * Pow5(1 - NdotV));
    return lightScatter * viewScatter;
}

// get the direct diffuse contribution using disney's diffuse implementation
void GetPBRDiffuse()
{
    Diffuse = 0;
    float ramp = DisneyDiffuse(Roughness) * NdotL;
    Diffuse = Albedo * (LightColor.rgb * LightColor.a * ramp + IndirectDiffuse);
    Attenuation = ramp;
}

// for toon lighting, we use a ramp texture
float4 RampDotL()
{
    //Adding the occlusion into the offset of the ramp
    float offset = _RampOffset + (Occlusion * _OcclusionOffsetIntensity) - _OcclusionOffsetIntensity;
    //Calculating ramp uvs based on offset
    float newMin = max(offset, 0);
    float newMax = max(offset +1, 0);
    float rampUv = remap(UnmaxedNdotL, -1, 1, newMin, newMax);
    float3 ramp = UNITY_SAMPLE_TEX2D(_Ramp, float2(rampUv, rampUv)).rgb;
    //Adding the color and remapping it based on the shadow intensity stored into the alpha channel of the ramp color
    ramp *= _RampColor.rgb;
    float intensity = max(_ShadowIntensity, 0.001);
    ramp = remap(ramp, float3(0, 0, 0), float3(1, 1, 1), 1 - intensity, float3(1, 1, 1));
    //getting the modified ramp for highlights and all lights that are not directional
    float3 rmin = remap(_RampMin, 0, 1, 1 - intensity, 1);
    float3 rampA = remap(ramp, rmin, 1, 0, 1);
    float rampGrey = max(max(rampA.r, rampA.g), rampA.b);
    #if defined(DIRECTIONAL) || defined(DIRECTIONAL_COOKIE)
        return float4(ramp, rampGrey);
    #else
        return float4(rampA, rampGrey);
    #endif
}

// toon shading
void GetToonDiffuse()
{
    Diffuse = 0;
    //toon version of the NdotL for the direct light
    float4 ramp = RampDotL();
    Attenuation = ramp.a;
    //diffuse color
    #if defined(DIRECTIONAL) || defined(DIRECTIONAL_COOKIE)
        Diffuse = Albedo * ramp.rgb * (LightColor.rgb + IndirectDiffuse);
    #else
        Diffuse = Albedo * ramp.rgb * LightColor.rgb * LightColor.a;
    #endif
}

//modified version of Shade4PointLights
float3 Shade4PointLights(float3 normal, float3 worldPos)
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
    // correct NdotL
    float4 corr = rsqrt(lengthSq);
    ndl = ndl * corr;
    //attenuation
    float4 atten = 1.0 / (1.0 + lengthSq * unity_4LightAtten0);
    float4 diff = max(ndl, 0) * atten;
    // final color
    float3 col = 0;
    col += unity_LightColor[0] * diff.x;
    col += unity_LightColor[1] * diff.y;
    col += unity_LightColor[2] * diff.z;
    col += unity_LightColor[3] * diff.w;
    return col;
}

// get vertex diffuse for vertex lighting
void GetPBRVertexDiffuse()
{
    VertexDirectDiffuse = 0;
    #if defined(VERTEXLIGHT_ON)
        VertexDirectDiffuse = Shade4PointLights(NormalDir, FragData.worldPos);
        VertexDirectDiffuse *= Albedo;
    #endif
}

// ...
float3 RampDotLVertLight(float3 normal, float3 worldPos, float occlusion)
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
    float3 ramp = remap(remap(UNITY_SAMPLE_TEX2D(_Ramp, float2(rampUv.x, rampUv.x)).rgb * _RampColor.rgb, float3(0, 0, 0), float3(1, 1, 1), 1 - intensity, float3(1, 1, 1)), rmin, 1, 0, 1).rgb * unity_LightColor[0].rgb * atten.r;
    ramp += remap(remap(UNITY_SAMPLE_TEX2D(_Ramp, float2(rampUv.y, rampUv.y)).rgb * _RampColor.rgb, float3(0, 0, 0), float3(1, 1, 1), 1 - intensity, float3(1, 1, 1)), rmin, 1, 0, 1).rgb * unity_LightColor[1].rgb * atten.g;
    ramp += remap(remap(UNITY_SAMPLE_TEX2D(_Ramp, float2(rampUv.z, rampUv.z)).rgb * _RampColor.rgb, float3(0, 0, 0), float3(1, 1, 1), 1 - intensity, float3(1, 1, 1)), rmin, 1, 0, 1).rgb * unity_LightColor[2].rgb * atten.b;
    ramp += remap(remap(UNITY_SAMPLE_TEX2D(_Ramp, float2(rampUv.w, rampUv.w)).rgb * _RampColor.rgb, float3(0, 0, 0), float3(1, 1, 1), 1 - intensity, float3(1, 1, 1)), rmin, 1, 0, 1).rgb * unity_LightColor[3].rgb * atten.a;
    return ramp;
}

// get the vertex diffuse contribution using a toon ramp
void GetToonVertexDiffuse()
{
    VertexDirectDiffuse = 0;
    #if defined(VERTEXLIGHT_ON)
        VertexDirectDiffuse = RampDotLVertLight(NormalDir, FragData.worldPos, Occlusion);
        VertexDirectDiffuse *= Albedo;
    #endif
}

// ...
void AddStandardDiffuse()
{
    FinalColor.rgb += Diffuse + VertexDirectDiffuse;
}

// ...
void AddToonDiffuse()
{
    FinalColor.rgb += Diffuse + VertexDirectDiffuse;
}

// ...
void AddAlpha()
{
    FinalColor.a = Albedo.a;
}

#endif // BACKLACE_FORWARD_CGINC