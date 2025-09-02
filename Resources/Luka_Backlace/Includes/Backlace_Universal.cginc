#ifndef BACKLACE_UNIVERSAL_CGINC
#define BACKLACE_UNIVERSAL_CGINC

// macros
#define BACKLACE_TRANSFORM_TEX(set, name) (set[name##_UV].xy * name##_ST.xy + name##_ST.zw)

// data structures
struct BacklaceSurfaceData
{
    // resulting colour
    float4 FinalColor;
    // core surface properties
    float4 Albedo;
    float3 NormalDir;
    float3 TangentDir;
    float3 BitangentDir;
    // pbr from msso
    float Metallic;
    float Glossiness;
    float Roughness;
    float SquareRoughness;
    float Specular;
    float OneMinusReflectivity;
    float Occlusion;
    // directional/light vectors
    float3 ViewDir;
    float3 LightDir;
    float3 HalfDir;
    float3 ReflectDir;
    // dot products
    float NdotL;
    float UnmaxedNdotL;
    float NdotV;
    float NdotH;
    float LdotH;
    // calculated light data
    float4 LightColor;
    float4 SpecLightColor;
    float3 IndirectDiffuse;
    float3 Diffuse;
    float3 DirectSpecular;
    float3 IndirectSpecular;
    float3 VertexDirectDiffuse;
    float Attenuation;
    // specular intermediates
    float3 SpecularColor;
    float3 EnergyCompensation;
    float3 Dfg;
    float3 CustomIndirect;
    // extra data cos we ball >.<
    float2 ScreenCoords;
};

// loading uv function
#if defined(UNITY_PASS_FORWARDBASE) || defined(UNITY_PASS_FORWARDADD) || defined(UNITY_PASS_META) || defined(_ALPHATEST_ON) || defined(_ALPHABLEND_ON) || defined(_ALPHAPREMULTIPLY_ON) || defined(_ALPHAMODULATE_ON)

    // load the uvs
    float2 Uvs[4];
    void LoadUVs()
    {
        Uvs[0] = FragData.uv;
        Uvs[1] = FragData.uv1;
        Uvs[2] = FragData.uv2;
        Uvs[3] = FragData.uv3;
    }

    void SampleAlbedo(inout BacklaceSurfaceData Surface)
    {
        Surface.Albedo = UNITY_SAMPLE_TEX2D(_MainTex, BACKLACE_TRANSFORM_TEX(Uvs, _MainTex)) * _Color;
    }

#endif // defined(UNITY_PASS_FORWARDBASE) || defined(UNITY_PASS_FORWARDADD) || defined(UNITY_PASS_META) || defined(_ALPHATEST_ON) || defined(_ALPHABLEND_ON) || defined(_ALPHAPREMULTIPLY_ON) || defined(_ALPHAMODULATE_ON)

// remap float from [oldMin, oldMax] to [newMin, newMax]
inline float remap(float value, float oldMin, float oldMax, float newMin, float newMax)
{
    return (value - oldMin) / (oldMax - oldMin) * (newMax - newMin) + newMin;
}

// remap float2 from [oldMin, oldMax] to [newMin, newMax]
inline float2 remap(float2 value, float2 oldMin, float2 oldMax, float2 newMin, float2 newMax)
{
    return (value - oldMin) / (oldMax - oldMin) * (newMax - newMin) + newMin;
}

// remap float3 from [oldMin, oldMax] to [newMin, newMax]
inline float3 remap(float3 value, float3 oldMin, float3 oldMax, float3 newMin, float3 newMax)
{
    return (value - oldMin) / (oldMax - oldMin) * (newMax - newMin) + newMin;
}

// remap float4 from [oldMin, oldMax] to [newMin, newMax]
inline float4 remap(float4 value, float4 oldMin, float4 oldMax, float4 newMin, float4 newMax)
{
    return (value - oldMin) / (oldMax - oldMin) * (newMax - newMin) + newMin;
}

// to the fifth power without pow
inline half Pow5(half x)
{
    return x * x * x * x * x;
}

// square without pow
float sqr(float x)
{
    return x * x;
}

// get the greyscale of a colour
inline float GetLuma(float3 color)
{
    return dot(color, float3(0.299, 0.587, 0.114));
}

// approximation of pow(x, p) for x in [0, 1].
// note: may not be faster for all hardware
float fastpow(float x, float p)
{
    return exp2(p * log2(x));
}

// fast hash function
float Hash(float2 p)
{
    float3 p3 = frac(float3(p.xyx) * .1031);
    p3 += dot(p3, p3.yzx + 33.33);
    return frac((p3.x + p3.y) * p3.z);
}

// create a random-looking 2D vector
float2 Hash2(float2 p)
{
    return float2(Hash(p), Hash(p + 0.123));
}

// convert HSV to RGB
float3 HSVtoRGB(float3 c)
{
    float4 K = float4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
    float3 p = abs(frac(c.xxx + K.xyz) * 6.0 - K.www);
    return c.z * lerp(K.xxx, saturate(p - K.xxx), c.y);
}

// convert RGB to HSV
float3 RGBtoHSV(float3 c) {
	float4 K = float4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
	float4 p = lerp(float4(c.bg, K.wz), float4(c.gb, K.xy), step(c.b, c.g));
	float4 q = lerp(float4(p.xyw, c.r), float4(c.r, p.yzx), step(p.x, c.r));
	float d = q.x - min(q.w, q.y);
	float E = 1e-10;
	return float3(abs(q.z + (q.w - q.y) / (6.0 * d + E)), d / (q.x + E), q.x);
}

// apply a hue shift to a colour
float3 ApplyHueShift(float3 inColor, float baseShift, float autoCycleToggle, float autoCycleSpeed)
{
    float totalShift = baseShift;
    if (autoCycleToggle > 0)
    {
        totalShift += frac(_Time.y * autoCycleSpeed);
    }
    float3 hsv = RGBtoHSV(inColor);
    hsv.x = frac(hsv.x + totalShift);
    return HSVtoRGB(hsv);
}

// pastel sinebow function
float3 Sinebow(float val)
{
    val = 0.5 - val * 0.5; // remap to 0-0.5 for a more pastel range
    float3 sinebowColor = sin((val * UNITY_PI) + float3(0.0, 0.333 * UNITY_PI, 0.666 * UNITY_PI));
    return sinebowColor * sinebowColor;
}

// calculate camera position with vr in mind
float3 GetCameraPos()
{
    #if UNITY_SINGLE_PASS_STEREO
        return (unity_StereoWorldSpaceCameraPos[0] + unity_StereoWorldSpaceCameraPos[1]) * 0.5;
    #else // UNITY_SINGLE_PASS_STEREO
        return _WorldSpaceCameraPos;
    #endif // UNITY_SINGLE_PASS_STEREO
}

// rotates a 3D vector using euler angles (in degrees)
float3 RotateVector(float3 pos, float3 rotation)
{
    float3 angles = rotation * (UNITY_PI / 180.0); 
    float3 s, c;
    sincos(angles, s, c);
    float3x3 rotX = float3x3(1, 0, 0, 0, c.x, -s.x, 0, s.x, c.x);
    float3x3 rotY = float3x3(c.y, 0, s.y, 0, 1, 0, -s.y, 0, c.y);
    float3x3 rotZ = float3x3(c.z, -s.z, 0, s.z, c.z, 0, 0, 0, 1);
    return mul(rotZ, mul(rotY, mul(rotX, pos)));
}

// triplanar uv and weight calculation
void GetTriplanarUVsAndWeights(
    float3 worldPos, float3 normal,
    float3 position, float scale, float3 rotation, float sharpness,
    out float2 uvX, out float2 uvY, out float2 uvZ, out float3 weights)
{
    float3 localPos = RotateVector(worldPos - position, -rotation);
    weights = pow(abs(normal), sharpness);
    weights /= dot(weights, 1.0.xxx); // normalise the weights
    uvX = localPos.yz / scale;
    uvY = localPos.xz / scale;
    uvZ = localPos.xy / scale;
}

// triplanar texture sampling
float4 SampleTriplanar(
    Texture2D tex, SamplerState texSampler,
    float2 uvX, float2 uvY, float2 uvZ, float3 weights,
    bool isTiling, float2 scroll)
{
    float4 sampleX, sampleY, sampleZ;
    float2 scrollOffset = scroll * _Time.y;
    if (isTiling)
    {
        // for repeating patterns, use frac() to tile the texture
        sampleX = tex.Sample(texSampler, frac(uvX + scrollOffset));
        sampleY = tex.Sample(texSampler, frac(uvY + scrollOffset));
        sampleZ = tex.Sample(texSampler, frac(uvZ + scrollOffset));
    }
    else
    {
        // for single decals, we only sample if the UV is within the 0-1 range
        uvX += 0.5;
        uvY += 0.5;
        uvZ += 0.5;
        sampleX = 0;
        if (all(saturate(uvX) == uvX))
        {
            sampleX = tex.Sample(texSampler, uvX);
        }
        sampleY = 0;
        if (all(saturate(uvY) == uvY))
        {
            sampleY = tex.Sample(texSampler, uvY);
        }
        sampleZ = 0;
        if (all(saturate(uvZ) == uvZ))
        {
            sampleZ = tex.Sample(texSampler, uvZ);
        }
    }
    return sampleX * weights.x + sampleY * weights.y + sampleZ * weights.z;
}

// wrapper for all triplanar in one
float4 SampleTextureTriplanar(Texture2D tex, SamplerState texSampler, float3 worldPos, 
    float3 normal, float3 position, float scale, float3 rotation, 
    float sharpness, bool isTiling, float2 scroll)
{
    // step one~ coords n weights
    float2 uvX, uvY, uvZ;
    float3 weights;
    GetTriplanarUVsAndWeights(worldPos, normal, position, scale, rotation, sharpness, uvX, uvY, uvZ, weights);
    // step two~ sample tex
    return SampleTriplanar(tex, texSampler, uvX, uvY, uvZ, weights, isTiling, scroll);
}

float2 ApplyFlipbook(float2 uvs, float columns, float rows, float totalFrames, float fps, float scrub)
{
    float frame = floor(frac(fps * _Time.y + scrub) * totalFrames);
    float col = fmod(frame, columns);
    float row = floor(frame / columns);
    float2 cellSize = 1.0 / float2(columns, rows);
    row = (rows - 1) - row;
    float2 outputUVs = (uvs * cellSize) + float2(col, row) * cellSize;   
    return outputUVs;
}

// decals-only features
#if defined(_BACKLACE_DECAL1) || defined(_BACKLACE_DECAL2)
    void ApplyDecal_UVSpace(inout float4 baseAlbedo, float2 baseUV, Texture2D decalTex, SamplerState decalSampler, float4 tint, float2 position, float2 scale, float rotation, int blendMode, float repeat, float2 scroll, float hueShift, float autoCycle, float cycleSpeed)
    {
        baseUV += scroll * _Time.y;
        float angle = -rotation * (UNITY_PI / 180.0);
        float s = sin(angle);
        float c = cos(angle);
        float2x2 rotationMatrix = float2x2(c, -s, s, c);
        float2 localUV = baseUV - position;
        localUV = mul(rotationMatrix, localUV);
        localUV /= max(scale, 0.0001);
        localUV += 0.5;
        if (repeat == 1) // repeating
        {
            localUV = frac(localUV); 

        }
        else // single instance
        {
            if (any(saturate(localUV) != localUV))
            {
                return;
            }
        }
        float4 decalColor = decalTex.Sample(decalSampler, localUV) * tint;
        decalColor.rgb = ApplyHueShift(decalColor.rgb, hueShift, autoCycle, cycleSpeed);
        switch(blendMode)
        {
            case 0: baseAlbedo.rgb += decalColor.rgb * decalColor.a; break; // additive
            case 1: baseAlbedo.rgb = lerp(baseAlbedo.rgb, baseAlbedo.rgb * decalColor.rgb, decalColor.a); break; // multiply
            case 2: baseAlbedo.rgb = lerp(baseAlbedo.rgb, decalColor.rgb, decalColor.a); break; //alpha blend

        }
    }

    void ApplyDecal_Triplanar(inout float4 baseAlbedo, float3 worldPos, float3 normal, Texture2D decalTex, SamplerState decalSampler, float4 tint, float3 position, float scale, float3 rotation, float sharpness, int blendMode, float repeat, float2 scroll, float hueShift, float autoCycle, float cycleSpeed)
    {
        float4 decalColor = SampleTextureTriplanar(decalTex, decalSampler, worldPos, normal, position, scale, rotation, sharpness, repeat > 0.5, scroll);
        decalColor *= tint;
        if (hueShift != 0) {
            decalColor.rgb = ApplyHueShift(decalColor.rgb, hueShift, autoCycle, cycleSpeed);
        }
        switch(blendMode)
        {
            case 0: baseAlbedo.rgb += decalColor.rgb * decalColor.a; break;
            case 1: baseAlbedo.rgb = lerp(baseAlbedo.rgb, baseAlbedo.rgb * decalColor.rgb, decalColor.a); break;
            case 2: baseAlbedo.rgb = lerp(baseAlbedo.rgb, decalColor.rgb, decalColor.a); break;
        }
    }

    // decal one application
    #if defined(_BACKLACE_DECAL1)
        void ApplyDecal1(inout BacklaceSurfaceData Surface, FragmentData i, float2 Uvs[4])
        {
            [branch] if (_Decal1IsTriplanar == 1)
            {
                ApplyDecal_Triplanar(Surface.Albedo, i.worldPos, Surface.NormalDir, _Decal1Tex, sampler_Decal1Tex, _Decal1Tint, _Decal1TriplanarPosition.xyz, _Decal1TriplanarScale, _Decal1TriplanarRotation.xyz, _Decal1TriplanarSharpness, _Decal1BlendMode, _Decal1Repeat, _Decal1Scroll.xy, _Decal1HueShift, _Decal1AutoCycleHue, _Decal1CycleSpeed);
            }
            else
            {
                ApplyDecal_UVSpace(Surface.Albedo, Uvs[_Decal1_UV], _Decal1Tex, sampler_Decal1Tex, _Decal1Tint, _Decal1Position.xy, _Decal1Scale.xy, _Decal1Rotation, _Decal1BlendMode, _Decal1Repeat, _Decal1Scroll, _Decal1HueShift, _Decal1AutoCycleHue, _Decal1CycleSpeed);
            }
        }
    #endif // _BACKLACE_DECAL1

    // decal two application
    #if defined(_BACKLACE_DECAL2)
        void ApplyDecal2(inout BacklaceSurfaceData Surface, FragmentData i, float2 Uvs[4])
        {
            [branch] if (_Decal2IsTriplanar == 1)
            {
                ApplyDecal_Triplanar(Surface.Albedo, i.worldPos, Surface.NormalDir, _Decal2Tex, sampler_Decal2Tex, _Decal2Tint, _Decal2TriplanarPosition.xyz, _Decal2TriplanarScale, _Decal2TriplanarRotation.xyz, _Decal2TriplanarSharpness, _Decal2BlendMode, _Decal2Repeat, _Decal2Scroll, _Decal2HueShift, _Decal2AutoCycleHue, _Decal2CycleSpeed);
            }
            else
            {
                ApplyDecal_UVSpace(Surface.Albedo, Uvs[_Decal2_UV], _Decal2Tex, sampler_Decal2Tex, _Decal2Tint, _Decal2Position.xy, _Decal2Scale.xy, _Decal2Rotation, _Decal2BlendMode, _Decal2Repeat, _Decal2Scroll, _Decal2HueShift, _Decal2AutoCycleHue, _Decal2CycleSpeed);
            }
        }
    #endif // _BACKLACE_DECAL2
#endif // _BACKLACE_DECAL1 || _BACKLACE_DECAL2

    
// dissolve-only features
#if defined(_BACKLACE_DISSOLVE)
    float GetDissolveMapValue(float3 worldPos, float3 vertexPos, float3 normalDir)
    {
        float dissolveMapValue = 0;
        switch(_DissolveType)
        {
            case 0: // noise
            {
                dissolveMapValue = SampleTextureTriplanar(
                    _DissolveNoiseTex, sampler_DissolveNoiseTex,
                    worldPos, normalDir,
                    float3(0,0,0), _DissolveNoiseScale, float3(0,0,0),
                    2.0, true, float2(0, 0)
                ).r;
                break;
            }
            case 1: // directional
            {
                float3 position = (_DissolveDirectionSpace == 0) ? vertexPos : worldPos;
                float3 direction = normalize(_DissolveDirection.xyz);
                dissolveMapValue = dot(position, direction) / max(_DissolveDirectionBounds, 0.001);
                dissolveMapValue = saturate(dissolveMapValue * 0.5 + 0.5); // remap from [-1,1] to [0,1]
                break;
            }
            case 2: // voxel
            {
                float3 voxelID = floor(worldPos * _DissolveVoxelDensity);
                dissolveMapValue = Hash(voxelID.xy + voxelID.z);
                break;
            }
        }
        return dissolveMapValue;
    }
#endif // _BACKLACE_DISSOLVE

// here is where we leave out shadow pass
#if defined(UNITY_PASS_FORWARDBASE) || defined(UNITY_PASS_FORWARDADD) || defined(UNITY_PASS_META)

    // sample MSSO texture
    void SampleMSSO(inout BacklaceSurfaceData Surface)
    {
        Msso = UNITY_SAMPLE_TEX2D_SAMPLER(_MSSO, _MainTex, BACKLACE_TRANSFORM_TEX(Uvs, _MSSO));
        Surface.Occlusion = lerp(1, Msso.a, _Occlusion);
    }

    // specular feature
    #if defined(_BACKLACE_SPECULAR)
        // get sample data from MSSO texture
        void GetSampleData(inout BacklaceSurfaceData Surface)
        {
            Surface.Metallic = Msso.r * _Metallic;
            Surface.Glossiness = Msso.g * _Glossiness;
            Surface.Specular = Msso.b * _Specular;
            Surface.Roughness = 1 - Surface.Glossiness;
            Surface.SquareRoughness = max(Surface.Roughness * Surface.Roughness, 0.002);
        }

        // setup albedo and specular color
        void SetupAlbedoAndSpecColor(inout BacklaceSurfaceData Surface)
        {
            float3 specularTint = (UNITY_SAMPLE_TEX2D_SAMPLER(_SpecularTintTexture, _MainTex, BACKLACE_TRANSFORM_TEX(Uvs, _SpecularTintTexture)).rgb * _SpecularTint).rgb;
            float sp = Surface.Specular * 0.08;
            Surface.SpecularColor = lerp(float3(sp, sp, sp), Surface.Albedo.rgb, Surface.Metallic);
            if (_ReplaceSpecular == 1)
            {
                Surface.SpecularColor = specularTint;
            }
            else
            {
                Surface.SpecularColor *= specularTint;
            }
            Surface.OneMinusReflectivity = (1 - sp) - (Surface.Metallic * (1 - sp));
            Surface.Albedo.rgb *= Surface.OneMinusReflectivity;
        }
    #endif // defined(_BACKLACE_SPECULAR)

    // emission feature
    #if defined(_BACKLACE_EMISSION)
        // get strength and colour of emission
        void CalculateEmission(inout BacklaceSurfaceData Surface)
        {
            float3 baseEmission = _EmissionColor.rgb;
            [branch] if (_UseAlbedoAsEmission > 0)
            {
                baseEmission = lerp(baseEmission, Surface.Albedo.rgb, _UseAlbedoAsEmission);
            }
            float3 emissionMap = UNITY_SAMPLE_TEX2D_SAMPLER(_EmissionMap, _MainTex, BACKLACE_TRANSFORM_TEX(Uvs, _EmissionMap)).rgb;
            Emission = baseEmission * emissionMap * _EmissionStrength;
        }
    #endif // _BACKLACE_EMISSION

#endif // UNITY_PASS_FORWARDBASE || UNITY_PASS_FORWARDADD || UNITY_PASS_META

#endif // BACKLACE_UNIVERSAL_CGINC