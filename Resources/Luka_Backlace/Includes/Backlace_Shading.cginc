#ifndef BACKLACE_SHADING_CGINC
#define BACKLACE_SHADING_CGINC

// clip alpha based on the _Cutoff value or dither mask
void ClipAlpha(inout BacklaceSurfaceData Surface)
{
    #if defined(_ALPHATEST_ON)
        clip(Surface.Albedo.a - _Cutoff);
    #else // _ALPHATEST_ON
        #if defined(_ALPHAMODULATE_ON)
            float dither = tex3D(_DitherMaskLOD, float3(FragData.pos.xy * 0.25, Surface.Albedo.a * 0.9375)).a; //Dither16x16Bayer(FragData.pos.xy * 0.25) * Albedo.a;
            clip(dither - 0.01);
        #endif // _ALPHAMODULATE_ON
    #endif // _ALPHATEST_ON
}

// sample normal map
void SampleNormal()
{
    NormalMap = UnpackScaleNormal(UNITY_SAMPLE_TEX2D_SAMPLER(_BumpMap, _MainTex, BACKLACE_TRANSFORM_TEX(Uvs, _BumpMap)), _BumpScale);
}

// calculate normals from normal map
void CalculateNormals(inout float3 normal, inout float3 tangent, inout float3 bitangent, float3 normalmap)
{
    /*float3 tspace0 = float3(tangent.x, bitangent.x, normal.x);
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
    bitangent = bumpedBitangent;*/
    float3x3 tbn = float3x3(tangent, bitangent, normal);
    normal = normalize(mul(normalmap, tbn));
    tangent = normalize(cross(bitangent, normal));
    bitangent = normalize(cross(normal, tangent));
}

// get geometry vectors
void GetGeometryVectors(inout BacklaceSurfaceData Surface)
{
    Surface.NormalDir = normalize(FragData.normal);
    Surface.TangentDir = normalize(UnityObjectToWorldDir(FragData.tangentDir.xyz));
    Surface.BitangentDir = normalize(cross(Surface.NormalDir, Surface.TangentDir) * FragData.tangentDir.w * unity_WorldTransformParams.w);
    Surface.ViewDir = normalize(UnityWorldSpaceViewDir(FragData.worldPos));
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
    Surface.NdotL = max(Surface.UnmaxedNdotL, 0);
    Surface.NdotV = abs(dot(Surface.NormalDir, Surface.ViewDir));
    Surface.NdotH = max(dot(Surface.NormalDir, Surface.HalfDir), 0);
    Surface.LdotH = max(dot(Surface.LightDir, Surface.HalfDir), 0);
}

// premultiply alpha
void PremultiplyAlpha(inout BacklaceSurfaceData Surface)
{
    #if defined(_ALPHAPREMULTIPLY_ON)
        Surface.Albedo.rgb *= Surface.Albedo.a;
    #endif
}

//unity's base diffuse based on disney implementation
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
}

// for toon lighting, we use a ramp texture
float4 RampDotL(inout BacklaceSurfaceData Surface)
{
    //Adding the occlusion into the offset of the ramp
    float offset = _RampOffset + (Surface.Occlusion * _OcclusionOffsetIntensity) - _OcclusionOffsetIntensity;
    //Calculating ramp uvs based on offset
    float newMin = max(offset, 0);
    float newMax = max(offset +1, 0);
    float rampUv = remap(Surface.UnmaxedNdotL, -1, 1, newMin, newMax);
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
    #else // DIRECTIONAL || DIRECTIONAL_COOKIE
        return float4(rampA, rampGrey);
    #endif // DIRECTIONAL || DIRECTIONAL_COOKIE
}

// toon shading
#if defined(_BACKLACE_TOON)
    void GetToonDiffuse(inout BacklaceSurfaceData Surface)
    {
        Surface.Diffuse = 0;
        //diffuse color
        float4 ramp = RampDotL(Surface);
        #if defined(_BACKLACE_PARALLAX) && defined(_BACKLACE_PARALLAX_SHADOWS)
            ramp *= ParallaxShadow;
        #endif // _BACKLACE_PARALLAX_SHADOWS
        #if defined(DIRECTIONAL) || defined(DIRECTIONAL_COOKIE)
            Surface.Diffuse = Surface.Albedo * ramp.rgb * (Surface.LightColor.rgb + Surface.IndirectDiffuse);
        #else
            Surface.Diffuse = Surface.Albedo * ramp.rgb * Surface.LightColor.rgb * Surface.LightColor.a;
        #endif
        Surface.Attenuation = ramp.a; // so that way specular gets the proper attenuation
        // tints, optionally
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
                default: // ramp based
                {
                    finalMask = ramp.a;
                    break;
                }
            }
            float shadowInfluence = (1 - finalMask) * _ShadowTint.a;
            Surface.Diffuse.rgb = lerp(Surface.Diffuse.rgb, Surface.Diffuse.rgb * _ShadowTint.rgb, shadowInfluence);
            float litInfluence = finalMask * _LitTint.a;
            Surface.Diffuse.rgb = lerp(Surface.Diffuse.rgb, Surface.Diffuse.rgb * _LitTint.rgb, litInfluence);
        }
    }
#endif // _BACKLACE_TOON

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
        Surface.VertexDirectDiffuse *= Surface.Albedo;
    #endif
}

// ...
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

// get the vertex diffuse contribution using a toon ramp
void GetToonVertexDiffuse(inout BacklaceSurfaceData Surface)
{
    Surface.VertexDirectDiffuse = 0;
    #if defined(VERTEXLIGHT_ON)
        #if defined(_BACKLACE_VERTEX_SPECULAR)
            RampDotLVertLight(Surface.NormalDir, FragData.worldPos, Surface.Occlusion, VertexDirectDiffuse, VertexLightDir);
        #else
            float3 ignoredDir;
            RampDotLVertLight(Surface.NormalDir, FragData.worldPos, Surface.Occlusion, VertexDirectDiffuse, ignoredDir);
        #endif
        Surface.VertexDirectDiffuse *= Surface.Albedo;
    #endif
}

// ...
void AddStandardDiffuse(inout BacklaceSurfaceData Surface)
{
    Surface.FinalColor.rgb += Surface.Diffuse + Surface.VertexDirectDiffuse;
}

// ...
void AddToonDiffuse(inout BacklaceSurfaceData Surface)
{
    Surface.FinalColor.rgb += Surface.Diffuse + Surface.VertexDirectDiffuse;
}

// ...
void AddAlpha(inout BacklaceSurfaceData Surface)
{
    Surface.FinalColor.a = Surface.Albedo.a;
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

// standard direct specular calculation
void StandardDirectSpecular(float ndotH, float ndotL, float ndotV, out float outNDF, out float outGFS, inout BacklaceSurfaceData Surface)
{
    outNDF = 0;
    outGFS = 0;
    outNDF = GTR2(ndotH, Surface.SquareRoughness) * UNITY_PI;
    outGFS = smithG_GGX(max(ndotL, lerp(0.3, 0, Surface.SquareRoughness)), Surface.Roughness) * smithG_GGX(ndotV, Surface.Roughness);
}

// ...
inline half3 FresnelTerm(half3 F0, half cosA)
{
    half t = Pow5(1 - cosA);   // ala Schlick interpoliation
    return F0 + (1 - F0) * t;
}

// specular-only features
#if defined(_BACKLACE_SPECULAR)

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

    // toon highlights specular
    float3 ApplyToonHighlights(float NDF, inout BacklaceSurfaceData Surface)
    {
        float newMin = max(_HighlightRampOffset, 0);
        float newMax = max(_HighlightRampOffset +1, 0);
        float Duv = remap(clamp(NDF, 0, 2), 0, 2, newMin, newMax);
        return UNITY_SAMPLE_TEX2D(_HighlightRamp, float2(Duv, Duv)).rgb * _HighlightRampColor.rgb * _HighlightIntensity * 10 * (1 - Surface.Metallic + (0.2 * Surface.Metallic));
    }

    // setup albedo and specular color
    void SetupDFG(inout BacklaceSurfaceData Surface)
    {
        float3 dfguv = float3(Surface.NdotV, Surface.Roughness, 0);
        Surface.Dfg = _DFG.Sample(sampler_DFG, dfguv).xyz;
        Surface.Dfg.y = max(Surface.Dfg.y, 1e-7f); // prevent division by zero
        Surface.EnergyCompensation = lerp(1.0 + Surface.SpecularColor * (1.0 / Surface.Dfg.y - 1.0), 1, _DFGType);
    }

    // ...
    void FinalizeDirectSpecularTerm(inout BacklaceSurfaceData Surface)
    {
        Surface.DirectSpecular = GFS * NDF * FresnelTerm(Surface.SpecularColor, Surface.LdotH) * Surface.EnergyCompensation;
        #ifdef UNITY_COLORSPACE_GAMMA
            Surface.DirectSpecular = sqrt(max(1e-4h, Surface.DirectSpecular));
        #endif
        Surface.DirectSpecular = max(0, Surface.DirectSpecular * Surface.Attenuation);
        Surface.DirectSpecular *= any(Surface.SpecularColor) ? 1.0 : 0.0;
    }

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
    void AddDirectSpecular(inout BacklaceSurfaceData Surface)
    {
        Surface.FinalColor.rgb += Surface.DirectSpecular * Surface.SpecLightColor.rgb * Surface.SpecLightColor.a;
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
        #endif // _SPECULARMODE_STANDARD || _SPECULARMODE_ANISOTROPIC || _SPECULARMODE_TOON
        // finalise the term
        specTerm *= FresnelTerm(Surface.SpecularColor, ldotH) * Surface.EnergyCompensation;
        #ifdef UNITY_COLORSPACE_GAMMA
            specTerm = sqrt(max(1e-4h, specTerm));
        #endif
        specTerm = max(0, specTerm * attenuation);
        specTerm *= any(Surface.SpecularColor) ? 1.0 : 0.0;
        return specTerm;
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
        float3 finalMatcap = matcapColor * _MatcapIntensity * mask;
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

#endif // BACKLACE_SHADING_CGINC