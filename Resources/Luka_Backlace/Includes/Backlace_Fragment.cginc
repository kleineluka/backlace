#ifndef BACKLACE_FRAGMENT_CGINC
#define BACKLACE_FRAGMENT_CGINC

// shared fragment between both base and add passes
float4 Fragment(FragmentData i) : SV_TARGET
{
    BacklaceSurfaceData Surface = (BacklaceSurfaceData)0;
    FragData = i;
    LoadUVs();
    SampleAlbedo(Surface);
    ClipAlpha(Surface);
    SampleNormal();
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
        GetToonDiffuse(Surface);
        GetToonVertexDiffuse(Surface);
    #else // REAL LIGHTING
        GetPBRDiffuse(Surface);
        GetPBRVertexDiffuse(Surface);
    #endif // _BACKLACE_TOON
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
    #if defined(_BACKLACE_SPECULAR)
        AddDirectSpecular(Surface);
        AddIndirectSpecular(Surface);
        #if defined(_BACKLACE_VERTEX_SPECULAR) && defined(VERTEXLIGHT_ON)
            AddVertexSpecular(Surface);
        #endif // _BACKLACE_VERTEX_SPECULAR && VERTEXLIGHT_ON
    #endif // _BACKLACE_SPECULAR
    #if defined(_BACKLACE_CLEARCOAT)
        float3 clearcoatHighlight;
        float3 clearcoatOcclusion;
        CalculateClearcoat(Surface, clearcoatHighlight, clearcoatOcclusion);
        Surface.FinalColor.rgb *= clearcoatOcclusion;
    #endif // _BACKLACE_CLEARCOAT
    #if defined(_BACKLACE_RIMLIGHT)
        CalculateRimlight(Surface);
        Surface.FinalColor.rgb += Rimlight;
    #endif // _BACKLACE_RIMLIGHT
    #if defined(_BACKLACE_CLEARCOAT)
        Surface.FinalColor.rgb += clearcoatHighlight;
        #if defined(_BACKLACE_VERTEX_SPECULAR) && defined(VERTEXLIGHT_ON)
            AddClearcoatVertex(Surface);
        #endif // _BACKLACE_VERTEX_SPECULAR && VERTEXLIGHT_ON
    #endif // _BACKLACE_CLEARCOAT
    #if defined(_BACKLACE_EMISSION)
        Surface.FinalColor.rgb += Emission;
    #endif // _BACKLACE_EMISSION
    AddAlpha(Surface);
    return Surface.FinalColor;
}

#endif // BACKLACE_FRAGMENT_CGINC