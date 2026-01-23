#ifndef BACKLACE_FRAGMENT_CGINC
#define BACKLACE_FRAGMENT_CGINC


// [ ♡ ] ────────────────────── [ ♡ ]
//
//           Pixel Shader
//
// [ ♡ ] ────────────────────── [ ♡ ]


// shared fragment between both base and add passes
float4 Fragment(FragmentData i, uint facing : SV_IsFrontFace) : SV_TARGET
{
    BacklaceSurfaceData Surface = (BacklaceSurfaceData)0;
    Surface.IsFrontFace = (facing == 1);
    Surface.FinalColor.a = -1.0; // flag to indicate not set yet
    Surface.Attenuation = -100; // flag to indicate not set yet
    FragData = i;
    LoadUVs();
    Uvs[0] = ManipulateUVs(FragData.uv, _UV_Rotation, _UV_Scale_X, _UV_Scale_Y, _UV_Offset_X, _UV_Offset_Y, _UV_Scroll_X_Speed, _UV_Scroll_Y_Speed);
    #if defined(_BACKLACE_PS1)
        ApplyPS1AffineUV(Uvs[0], i);
    #endif // _BACKLACE_PS1
    GetGeometryVectors(Surface, FragData);
    #if defined(_BACKLACE_UV_EFFECTS)
        ApplyUVEffects(Uvs[0], Surface);
    #endif // _BACKLACE_UV_EFFECTS
    #if defined(_BACKLACE_DISTANCE_FADE)
        bool isNearFading;
        float fadeFactor;
        CalculateDistanceFade(i, isNearFading, fadeFactor);
        if(ApplyDistanceFadePre(isNearFading, fadeFactor) == -1) {
            discard; // fully faded out, skip all processing
        }
    #endif // _BACKLACE_DISTANCE_FADE
    #if defined(_BACKLACE_PARALLAX)
        float2 parallax_uv = Uvs[_ParallaxMap_UV];
        [branch] if (_ParallaxMode == 0) // fast parallax
        {
            ApplyParallax_Fast(parallax_uv, Surface);
        }
        else if (_ParallaxMode == 1) // fancy parallax
        {
            ApplyParallax_Fancy(parallax_uv, Surface);
        }
        Uvs[0] = parallax_uv;
    #endif // _BACKLACE_PARALLAX
    SampleAlbedo(Surface, i.vertex.xyz);
    #if defined(BACKLACE_WORLD)
        #if defined(_BACKLACE_SPLATTER)
            float3 splatterNormals = 0;
            float splatterAlpha = 1;
            ApplySplatter(Surface, splatterNormals, splatterAlpha, i);
        #endif // _BACKLACE_SPLATTER
        #if defined(_BACKLACE_STOCHASTIC)
            StochasticData stoch = SampleStochasticAlbedo(Uvs[0], i.scrPos.xy / i.scrPos.w, Surface);
            Surface.Albedo = stoch.albedoSample;
        #endif // _BACKLACE_STOCHASTIC
        #if defined(_BACKLACE_BOMBING)
            float3 bombingNormal = 0;
            ApplyTextureBombing(Surface, bombingNormal,  i);
        #endif // _BACKLACE_BOMBING
    #endif // BACKLACE_WORLD
    #if defined(_BACKLACE_PARALLAX)
        [branch] if (_ParallaxMode == 2) // layered parallax
        {
            ApplyParallax_Layered(Surface, i);
        } else if (_ParallaxMode == 3) // interior parallax
        {
            ApplyParallax_Interior(Surface, i);
        }
    #endif // _BACKLACE_PARALLAX
    #if defined(_BACKLACE_VRCHAT_MIRROR)
        ApplyMirrorDetectionPre(Surface);
    #endif // _BACKLACE_VRCHAT_MIRROR
    #if defined(_BACKLACE_DECALS)
        [branch] if (_DecalStage == 0) // early
        {
            if (_Decal1Enable == 1) ApplyDecal1(Surface, FragData, Uvs);
            if (_Decal2Enable == 1) ApplyDecal2(Surface, FragData, Uvs);
        }
    #endif // _BACKLACE_DECALS
    ClipAlpha(Surface);
    SampleNormal();
    #if defined(BACKLACE_WORLD)
        #if defined(_BACKLACE_SPLATTER)
            NormalMap = splatterNormals;
        #endif // _BACKLACE_SPLATTER
        #if defined(_BACKLACE_STOCHASTIC)
            SampleStochasticNormal(Uvs[0], stoch); // re use data from albedo sampling
        #endif // _BACKLACE_STOCHASTIC
        #if defined(_BACKLACE_BOMBING)
            if (_BombingUseNormal) NormalMap = bombingNormal;
        #endif // _BACKLACE_BOMBING
    #endif // BACKLACE_WORLD
    #if defined(_BACKLACE_DETAIL)
        ApplyDetailMaps(Surface);
    #endif // _BACKLACE_DETAIL
    SampleMSSO(Surface);
    #if defined(_BACKLACE_EMISSION)
        CalculateEmission(Surface);
    #endif
    #if defined(BACKLACE_SPECULAR)
        GetSampleData(Surface);
    #endif // BACKLACE_SPECULAR
    GetLightData(Surface);
    #if defined(BACKLACE_SPECULAR)
        SetupAlbedoAndSpecColor(Surface);
        SetupDFG(Surface);
    #endif // BACKLACE_SPECULAR
    PremultiplyAlpha(Surface);
    #if defined(BACKLACE_TOON) // TOON LIGHTING
        GetAnimeDiffuse(Surface); // (includes vertex diffuse inside wrapper)
    #else // REAL LIGHTING
        GetPBRDiffuse(Surface);
        GetPBRVertexDiffuse(Surface);
    #endif // BACKLACE_TOON
    #if defined(_BACKLACE_SSS)
        ApplySubsurfaceScattering(Surface);
    #endif // _BACKLACE_SSS
    #if defined(BACKLACE_SPECULAR)
        SetupSpecularData(Surface);
        Surface.DirectSpecular = CalculateDirectSpecular(Surface.TangentDir, Surface.BitangentDir, Surface.LightDir, Surface.HalfDir, Surface.NdotH, Surface.NdotL, Surface.NdotV, Surface.LdotH, Surface.Attenuation, Surface);
        [branch] if (_IndirectFallbackMode == 1)
        {
            GetFallbackCubemap(Surface);
        }
        GetIndirectSpecular(Surface);
    #endif // BACKLACE_SPECULAR
    AddDiffuse(Surface);
    #if defined(_BACKLACE_TOUCH_REACTIVE)
        ApplyTouchReactive(Surface, i);
    #endif // _BACKLACE_TOUCH_REACTIVE
    #if defined(_BACKLACE_POST_PROCESSING)
        ApplyPostProcessing(Surface, i);
    #endif // _BACKLACE_POST_PROCESSING
    #if defined(_BACKLACE_MATCAP)
        ApplyMatcap(Surface, i);
    #endif // _BACKLACE_MATCAP
    #if defined(_BACKLACE_CUBEMAP)
        ApplyCubemap(Surface);
    #endif // _BACKLACE_CUBEMAP
    #if defined(BACKLACE_SPECULAR)
        AddDirectSpecular(Surface);
        AddIndirectSpecular(Surface);
        #if defined(_BACKLACE_VERTEX_SPECULAR) && defined(VERTEXLIGHT_ON)
            AddVertexSpecular(Surface);
        #endif // _BACKLACE_VERTEX_SPECULAR && VERTEXLIGHT_ON
    #endif // BACKLACE_SPECULAR
    #if defined(_BACKLACE_RIMLIGHT)
        CalculateRimlight(Surface);
        #if defined(_BACKLACE_AUDIOLINK)
            Rimlight *= i.alChannel1.y;
        #endif // !_BACKLACE_AUDIOLINK
        Surface.FinalColor.rgb += Rimlight;
    #endif // _BACKLACE_RIMLIGHT
    #if defined(_BACKLACE_DEPTH_RIMLIGHT)
        ApplyDepthRim(Surface, i);
    #endif // _BACKLACE_DEPTH_RIMLIGHT
    #if defined(_BACKLACE_EMISSION)
        #if defined(_BACKLACE_AUDIOLINK)
            Surface.FinalColor.rgb += ((Emission * Surface.LightColor.a) * i.alChannel1.x);
        #else // !_BACKLACE_AUDIOLINK
            Surface.FinalColor.rgb += Emission * Surface.LightColor.a;
        #endif // _BACKLACE_AUDIOLINK
    #endif // _BACKLACE_EMISSION
    #if defined(_BACKLACE_PATHING)
        ApplyPathing(Surface, i);
    #endif // _BACKLACE_PATHING
    #if defined(_BACKLACE_IRIDESCENCE)
        ApplyIridescence(Surface, i);
    #endif // _BACKLACE_IRIDESCENCE
    #if defined(BACKLACE_GRABPASS)
        #if defined(_BACKLACE_REFRACTION)
            ApplyRefraction(Surface, i);
        #endif // _BACKLACE_REFRACTION
        #if defined(_BACKLACE_SSR)
            ApplyScreenSpaceReflections(Surface, i);
        #endif // _BACKLACE_SSR
    #endif // BACKLACE_GRABPASS
    #if defined(_BACKLACE_GLITTER)
        ApplyGlitter(Surface);
    #endif // _BACKLACE_GLITTER
    #if defined(_BACKLACE_WORLD_EFFECT)
        ApplyWorldAlignedEffect(Surface, i);
    #endif // _BACKLACE_WORLD_EFFECT
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
    #if defined(_BACKLACE_PS1)
        ApplyPS1ColorCompression(Surface.FinalColor);
    #endif // _BACKLACE_PS1
    #if defined(_BACKLACE_DECALS)
        [branch] if (_DecalStage == 1) // late
        {
            if (_Decal1Enable == 1) ApplyDecal1(Surface, FragData, Uvs);
            if (_Decal1Enable == 2) ApplyDecal2(Surface, FragData, Uvs);
        }
    #endif // _BACKLACE_DECAL2
    AddAlpha(Surface);
    #if defined(_BACKLACE_DISTANCE_FADE)
        ApplyDistanceFadePost(i, fadeFactor, isNearFading, Surface);
    #endif // _BACKLACE_DISTANCE_FADE
    #if defined(_BACKLACE_DITHER)
        ApplyDither(Surface, i.worldPos.xy, Uvs[_Dither_UV]);
    #endif // _BACKLACE_DITHER
    #if defined(_BACKLACE_VRCHAT_MIRROR)
        ApplyMirrorDetectionPost(Surface); // todo: move before lighting but store alpha if not culling
    #endif // _BACKLACE_VRCHAT_MIRROR 
    #if defined(_BACKLACE_DISSOLVE) // todo: move before lighting but store edge glow value if not culling
        ApplyDissolve(Surface, i);
    #endif // _BACKLACE_DISSOLVE
    #if defined(BACKLACE_WORLD)
        #if defined(_BACKLACE_SPLATTER)
            Surface.FinalColor.a *= splatterAlpha;
        #endif // _BACKLACE_SPLATTER
    #endif // BACKLACE_WORLD
    Surface.FinalColor.a *= _Alpha;
    return Surface.FinalColor;
}


#endif // BACKLACE_FRAGMENT_CGINC