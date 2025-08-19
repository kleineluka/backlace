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
    [branch] if (_DirectLightMode == 0) // real lighting
    {
        GetPBRDiffuse();
        GetPBRVertexDiffuse();
    }
    else if (_DirectLightMode == 1)// toon lighting
    {
        GetToonDiffuse();
        GetToonVertexDiffuse();
    }
    #if defined(_BACKLACE_SPECULAR)
        [branch] if (_SpecularMode == 0) { // standard specular
            StandardDirectSpecular();
        } else if (_SpecularMode == 1) { // anisotropic specular
            AnisotropicDirectSpecular(); 
        } else if (_SpecularMode == 2) { // toon highlights
            StandardDirectSpecular();
            ApplyToonHighlights();
        }
        FinalizeDirectSpecularTerm();
        if (_IndirectFallbackMode == 1)
        {
            GetFallbackCubemap();
        }
        GetIndirectSpecular();
    #endif // _BACKLACE_SPECULAR
    [branch] if (_DirectLightMode == 0) // real lighting
    {
        AddStandardDiffuse();
    } else if (_DirectLightMode == 1) // toon lighting
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
    #endif // _BACKLACE_EMISSION
    AddAlpha();
    return FinalColor;
}

#endif // BACKLACE_FRAGMENT_CGINC