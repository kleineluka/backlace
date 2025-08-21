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
    [branch] if (_DirectLightMode == 0) // real lighting
    {
        GetPBRDiffuse(Surface);
        GetPBRVertexDiffuse(Surface);
    }
    else if (_DirectLightMode == 1)// toon lighting
    {
        GetToonDiffuse(Surface);
        GetToonVertexDiffuse(Surface);
    }
    #if defined(_BACKLACE_SPECULAR)
        //DirectSpecular = CalculateDirectSpecular(TangentDir, BitangentDir, LightDir, HalfDir, NdotH, NdotL, NdotV, LdotH, Attenuation);
        Surface.DirectSpecular = CalculateDirectSpecular(Surface.TangentDir, Surface.BitangentDir, Surface.LightDir, Surface.HalfDir, Surface.NdotH, Surface.NdotL, Surface.NdotV, Surface.LdotH, Surface.Attenuation, Surface);
        [branch] if (_IndirectFallbackMode == 1)
        {
            GetFallbackCubemap(Surface);
        }
        GetIndirectSpecular(Surface);
    #endif // _BACKLACE_SPECULAR
    [branch] if (_DirectLightMode == 0) // real lighting
    {
        AddStandardDiffuse(Surface);
    } else if (_DirectLightMode == 1) // toon lighting
    {
        AddToonDiffuse(Surface);
    }
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
        AddEmission(Surface);
    #endif // _BACKLACE_EMISSION
    AddAlpha(Surface);
    return Surface.FinalColor;
}

#endif // BACKLACE_FRAGMENT_CGINC