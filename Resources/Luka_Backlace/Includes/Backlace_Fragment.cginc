#ifndef BACKLACE_FRAGMENT_CGINC
#define BACKLACE_FRAGMENT_CGINC

// shared fragment between both base and add passes
float4 Fragment(FragmentData i) : SV_TARGET
{
    BacklaceSurfaceData Surface = (BacklaceSurfaceData)0;
    FragData = i;
    LoadUVs();
    #if defined(_BACKLACE_FLOWMAP)
        float2 mainUv = Uvs[_Flowmap_Affects];
        ApplyFlowMap(mainUv);
        Uvs[_Flowmap_Affects] = mainUv;
    #endif // _BACKLACE_FLOWMAP
    GetGeometryVectors(Surface, FragData);
    #if defined(_BACKLACE_DISTANCE_FADE)
        bool isNearFading;
        float fadeFactor;
        CalculateDistanceFade(i, isNearFading, fadeFactor);
        if(ApplyDistanceFadePre(isNearFading, fadeFactor) == -1) {
            discard; // fully faded out, skip all processing
        }
    #endif // _BACKLACE_DISTANCE_FADE
    #if defined(_BACKLACE_PARALLAX)
        [branch] if (_ParallaxMode == 0) // fast parallax
        {
            ApplyParallax_Fast(Uvs[0], Surface);
        }
        else if (_ParallaxMode == 1) // fancy parallax
        {
            ApplyParallax_Fancy(Uvs[0], Surface);
        }
    #endif // _BACKLACE_PARALLAX
    SampleAlbedo(Surface);
    #if defined(_BACKLACE_DECAL1)
        ApplyDecal1(Surface, FragData, Uvs);
    #endif // _BACKLACE_DECAL1
    #if defined(_BACKLACE_DECAL2)
        ApplyDecal2(Surface, FragData, Uvs);
    #endif // _BACKLACE_DECAL2
    ClipAlpha(Surface);
    SampleNormal();
    #if defined(_BACKLACE_DETAIL)
        ApplyDetailMaps(Surface);
    #endif // _BACKLACE_DETAIL
    SampleMSSO(Surface);
    #if defined(_BACKLACE_EMISSION)
        CalculateEmission(Surface);
    #endif
    #if defined(_BACKLACE_SPECULAR)
        GetSampleData(Surface);
    #endif // _BACKLACE_SPECULAR
    GetDirectionVectors(Surface);
    GetLightData(Surface);
    GetDotProducts(Surface);
    #if defined(_BACKLACE_SPECULAR)
        SetupAlbedoAndSpecColor(Surface);
        SetupDFG(Surface);
    #endif // _BACKLACE_SPECULAR
    PremultiplyAlpha(Surface);
    #if defined(_BACKLACE_TOON) // TOON LIGHTING
        GetToonDiffuse(Surface); // (includes vertex diffuse inside wrapper)
    #else // REAL LIGHTING
        GetPBRDiffuse(Surface);
        GetPBRVertexDiffuse(Surface);
    #endif // _BACKLACE_TOON
    #if defined(_BACKLACE_SSS)
        ApplySubsurfaceScattering(Surface);
    #endif // _BACKLACE_SSS
    #if defined(_BACKLACE_SPECULAR)
        Surface.DirectSpecular = CalculateDirectSpecular(Surface.TangentDir, Surface.BitangentDir, Surface.LightDir, Surface.HalfDir, Surface.NdotH, Surface.NdotL, Surface.NdotV, Surface.LdotH, Surface.Attenuation, Surface);
        [branch] if (_IndirectFallbackMode == 1)
        {
            GetFallbackCubemap(Surface);
        }
        GetIndirectSpecular(Surface);
    #endif // _BACKLACE_SPECULAR
    #if defined(_BACKLACE_TOON) // TOON LIGHTING
        AddToonDiffuse(Surface);
    #else // REAL LIGHTING
        AddStandardDiffuse(Surface);
    #endif // _BACKLACE_TOON
    #if defined(_BACKLACE_POST_PROCESSING)
        ApplyPostProcessing(Surface);
    #endif // _BACKLACE_POST_PROCESSING
    #if defined(_BACKLACE_SPECULAR)
        AddDirectSpecular(Surface);
        AddIndirectSpecular(Surface);
        #if defined(_BACKLACE_VERTEX_SPECULAR) && defined(VERTEXLIGHT_ON)
            AddVertexSpecular(Surface);
        #endif // _BACKLACE_VERTEX_SPECULAR && VERTEXLIGHT_ON
    #endif // _BACKLACE_SPECULAR
    #if defined(_BACKLACE_RIMLIGHT)
        CalculateRimlight(Surface);
        Surface.FinalColor.rgb += Rimlight;
    #endif // _BACKLACE_RIMLIGHT
    #if defined(_BACKLACE_EMISSION)
        Surface.FinalColor.rgb += Emission;
    #endif // _BACKLACE_EMISSION
    #if defined(_BACKLACE_GLITTER)
        ApplyGlitter(Surface);
    #endif // _BACKLACE_GLITTER
    #if defined(_BACKLACE_MATCAP)
        ApplyMatcap(Surface, i);
    #endif // _BACKLACE_MATCAP
    #if defined(_BACKLACE_CUBEMAP)
        ApplyCubemap(Surface);
    #endif // _BACKLACE_CUBEMAP
    #if defined(_BACKLACE_CLEARCOAT)
        float3 baseColor = Surface.FinalColor.rgb;
        float3 clearcoatHighlight;
        float3 clearcoatAttenuation;
        CalculateClearcoat(Surface, clearcoatHighlight, clearcoatAttenuation);
        Surface.FinalColor.rgb = (baseColor * clearcoatAttenuation) + clearcoatHighlight;
        #if defined(_BACKLACE_VERTEX_SPECULAR) && defined(VERTEXLIGHT_ON)
            AddClearcoatVertex(Surface);
        #endif // _BACKLACE_VERTEX_SPECULAR && VERTEXLIGHT_ON
    #endif // _BACKLACE_CLEARCOAT
    AddAlpha(Surface);
    #if defined(_BACKLACE_DISTANCE_FADE)
        ApplyDistanceFadePost(i, fadeFactor, isNearFading, Surface);
    #endif // _BACKLACE_DISTANCE_FADE
    return Surface.FinalColor;
}

#endif // BACKLACE_FRAGMENT_CGINC