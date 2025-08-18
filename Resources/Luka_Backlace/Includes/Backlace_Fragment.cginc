#ifndef BACKLACE_FRAGMENT_CGINC
#define BACKLACE_FRAGMENT_CGINC

// shared fragment between both base and add passes
float4 Fragment(FragmentData i) : SV_TARGET
{
    FragData = i;
    FinalColor = float4(0, 0, 0, 0);
    LoadUVs();
    SampleAlbedo();
    ClipAlpha();
    SampleNormal();
    SampleMSSO();
    #if defined(_BACKLACE_EMISSION)
        CalculateEmission();
    #endif
    #if defined(_BACKLACE_SPECULAR)
        GetSampleData();
    #endif // _BACKLACE_SPECULAR
    GetDirectionVectors();
    GetLightData();
    GetDotProducts();
    #if defined(_BACKLACE_SPECULAR)
        SetupAlbedoAndSpecColor();
        SetupDFG();
    #endif // _BACKLACE_SPECULAR
    PremultiplyAlpha();
    if (_DirectLightMode == 0)
    {
        GetPBRDiffuse();
    }
    if (_DirectLightMode == 1)
    {
        GetToonDiffuse();
    }
    if (_DirectLightMode == 0)
    {
        GetPBRVertexDiffuse();
    }
    if (_DirectLightMode == 1)
    {
        GetToonVertexDiffuse();
    }
    if (_SpecularMode == 0)
    {
        StandardDirectSpecular();
    }
    if (_SpecularMode == 1)
    {
        AnisotropicDirectSpecular();
    }
    if (_SpecularMode == 2)
    {
        StandardDirectSpecular();
        ApplyToonHighlights();
    }
    #if defined(_BACKLACE_SPECULAR)
        FinalizeDirectSpecularTerm();
    #endif // _BACKLACE_SPECULAR
    if (_IndirectFallbackMode == 1)
    {
        GetFallbackCubemap();
    }
    #if defined(_BACKLACE_SPECULAR)
        GetIndirectSpecular();
    #endif // _BACKLACE_SPECULAR
    if (_DirectLightMode == 0)
    {
        AddStandardDiffuse();
    }
    if (_DirectLightMode == 1)
    {
        AddToonDiffuse();
    }
    #if defined(_BACKLACE_SPECULAR)
        AddDirectSpecular();
        AddIndirectSpecular();
    #endif // _BACKLACE_SPECULAR
    #if defined(_BACKLACE_RIMLIGHT)
        CalculateRimlight();
        FinalColor.rgb += Rimlight;
    #endif // _BACKLACE_RIMLIGHT
    #if defined(_BACKLACE_EMISSION)
        AddEmission();
    #endif
    AddAlpha();
    return FinalColor;
}

#endif // BACKLACE_FRAGMENT_CGINC