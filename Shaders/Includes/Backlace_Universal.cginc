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
    float3 Lightmap;
    float4 LightmapDirection;
    float3 DynamicLightmap;
    float4 DynamicLightmapDirection;
    // specular intermediates
    float3 SpecularColor;
    float3 EnergyCompensation;
    float3 Dfg;
    float3 CustomIndirect;
    // specular samples
    #if defined(BACKLACE_SPECULAR)
        float Anisotropy;
        float3 ModifiedTangent;
        float3 HairFlow;
        float HairShiftMask;
        float SpecularJitter;
    #endif // BACKLACE_SPECULAR
    // extra data cos we ball >.<
    float2 ScreenCoords;
    bool IsFrontFace;
};

// debug function
float4 panty() {
    return float4(1.00, 0.98, 0.25, 1.00);
}

// loading uv function
#if defined(UNITY_PASS_FORWARDBASE) || defined(UNITY_PASS_FORWARDADD) || defined(UNITY_PASS_META) || defined(_BLENDMODE_CUTOUT) || defined(_BLENDMODE_TRANSPARENT) || defined(_BLENDMODE_PREMULTIPLY) || defined(_BLENDMODE_FADE)
    #ifndef UNITY_PASS_OUTLINE
        // load the uvs
        float2 Uvs[4];
        void LoadUVs()
        {
            Uvs[0] = FragData.uv;
            Uvs[1] = FragData.uv1;
            Uvs[2] = FragData.uv2;
            Uvs[3] = FragData.uv3;
        }

        void SafeLoadUVs()
        {
            // quick and dirty test, just see if uv0 is zero
            if (all(Uvs[0] == float2(0,0)))
            {
                LoadUVs();
            }
        }

        void SampleAlbedo(inout BacklaceSurfaceData Surface, float3 objectPos)
        {
            Surface.Albedo = UNITY_SAMPLE_TEX2D(_MainTex, BACKLACE_TRANSFORM_TEX(Uvs, _MainTex)) * _Color;
            [branch] if (_UseTextureStitching == 1)
            {
                float stitch_check = objectPos[_StitchAxis];
                if (stitch_check > _StitchOffset)
                {
                    Surface.Albedo = UNITY_SAMPLE_TEX2D_SAMPLER(_StitchTex, _MainTex, BACKLACE_TRANSFORM_TEX(Uvs, _StitchTex)) * _Color;
                }
            }
        }
    #endif // !UNITY_PASS_OUTLINE
#endif // defined(UNITY_PASS_FORWARDBASE) || defined(UNITY_PASS_FORWARDADD) || defined(UNITY_PASS_META) || defined(_BLENDMODE_CUTOUT) || defined(_BLENDMODE_TRANSPARENT) || defined(_BLENDMODE_PREMULTIPLY) || defined(_BLENDMODE_FADE)

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

// psuedo-random functions
float Hash12(float2 p)
{
    float3 p3 = frac(float3(p.xyx) * .1031);
    p3 += dot(p3, p3.yzx + 33.33);
    return frac((p3.x + p3.y) * p3.z);
}

float hash11(float p)
{
    p = frac(p * 0.1031);
    p *= p + 33.33;
    p *= p + p;
    return frac(p);
}

float Hash11(float p)
{
    p = frac(p * 0.1031);
    p *= p + 33.33;
    p *= p + p;
    return frac(p);
}

float2 Hash22(float2 p)
{
    float3 p3 = frac(float3(p.xyx) * float3(0.1031, 0.1030, 0.0973));
    p3 += dot(p3, p3.yzx + 33.33);
    return frac((p3.xx + p3.yz) * p3.zy);
}

float3 Hash33(float3 p)
{
    p = frac(p * float3(0.1031, 0.1030, 0.0973));
    p += dot(p, p.yxz + 33.33);
    return frac((p.xxy + p.yxx) * p.zyx);
}

float2 Hash23(float3 p)
{
    p = frac(p * float3(0.1031, 0.1030, 0.0973));
    p += dot(p, p.yxz + 33.33);
    return frac((p.xxy + p.yxx) * p.zyx).xy;
}

float3 Hash32(float2 p)
{
    float3 p3 = frac(float3(p.xyx) * float3(0.1031, 0.1030, 0.0973));
    p3 += dot(p3, p3.yzx + 33.33);
    return frac((p3.xxy + p3.yxx) * p3.zyx);
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

// fresnel term using Schlick's approximation
inline half3 FresnelTerm(half3 F0, half cosA)
{
    half t = Pow5(1 - cosA);
    return F0 + (1 - F0) * t;
}

// gtr2 distribution function (for specular and clearcoat)
float GTR2(float NdotH, float a)
{
    float a2 = a * a;
    float NdotH2 = NdotH * NdotH;
    float denominator = NdotH2 * (a2 - 1.0) + 1.0;
    denominator = UNITY_PI * denominator * denominator + 1e-7f;
    return a2 / denominator;
}

// ggx distribution function (for specular and clearcoat)
float smithG_GGX(float NdotV, float alphaG)
{
    float a = alphaG * alphaG;
    float b = NdotV * NdotV;
    return 1 / (NdotV + sqrt(a + b - a * b) + 1e-7f);
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

// rotate a 2D vector around the origin
float2 RotateUV(float2 uv, float angle)
{
    float s = sin(angle);
    float c = cos(angle);
    return float2(c * uv.x - s * uv.y, s * uv.x + c * uv.y);
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

// manipulate uvs
float2 ManipulateUVs(float2 uv, float rotation, float scalex, float scaley, float offsetx, float offsety, float scrollx, float scrolly)
{
    float2 finalUV = uv;
    if (rotation != 0)
    {
        finalUV = uv - 0.5;
        float angle = -rotation * (UNITY_PI / 180.0);
        float s = sin(angle);
        float c = cos(angle);
        float2x2 rotationMatrix = float2x2(c, -s, s, c);
        finalUV = mul(rotationMatrix, finalUV);
        finalUV += 0.5;
    }
    finalUV *= float2(scalex, scaley);
    finalUV += float2(offsetx, offsety);
    finalUV += float2(scrollx, scrolly) * _Time.y;
    return finalUV;
}

// fake dithering stylised as checkerboard pattern for the aesthetics
float GetTiltedCheckerboardPattern(float2 screenPos, float scale)
{
    float u = screenPos.x + screenPos.y;
    float v = screenPos.x - screenPos.y;
    float2 gridPos = floor(float2(u, v) / scale);
    return fmod(gridPos.x + gridPos.y, 2.0);
}

// decals-only features
#if defined(_BACKLACE_DECALS)
    struct SuperCuteSticker
    {
        float4 albedo;
        float4 tint;
        float3 position;   // float3 to support triplanar (use .xy for UV)
        float3 scale;      // float3 to support triplanar (use .xy for UV)
        float3 rotation;   // float3 to support triplanar (use .x for UV)
        float sharpness;   // triplanar only
        int blendMode;
        float behavior;
        float repeat;
        float2 scroll;
        float hueShift;
        float autoCycle;
        float cycleSpeed;
        float alHue;       // audiolink only
        float alEmission;  // audiolink only
        float alOpacity;   // audiolink only
    };

    void ApplyDecal_UVSpace(inout SuperCuteSticker decal, float2 baseUV, Texture2D decalTex, SamplerState decalSampler, int uvChannel)
    {
        baseUV += decal.scroll * _Time.y;
        float angle = -decal.rotation.x * (UNITY_PI / 180.0);
        float s = sin(angle);
        float c = cos(angle);
        float2x2 rotationMatrix = float2x2(c, -s, s, c);
        float2 localUV = baseUV - decal.position.xy;
        localUV = mul(rotationMatrix, localUV);
        localUV /= max(decal.scale.xy, 0.0001);
        localUV += saturate(decal.behavior - 0.5); // decal = 1, overlay = 0 - why can't enums pass float values :(
        if (decal.repeat == 1) // repeating
        {
            localUV = frac(localUV); 
        }
        else if (decal.repeat == 0) // cull outside
        {
            if (any(saturate(localUV) != localUV))
            {
                return;
            }
        } // else default behaviour
        float4 decalColor = decalTex.Sample(decalSampler, localUV) * decal.tint;
        decalColor.rgb = ApplyHueShift(decalColor.rgb, decal.hueShift + decal.alHue, decal.autoCycle, decal.cycleSpeed);
        decalColor.a *= decal.alOpacity;
        decalColor.rgb *= decal.alEmission;
        switch(decal.blendMode)
        {
            case 0: decal.albedo.rgb += decalColor.rgb * decalColor.a; break; // additive
            case 1: decal.albedo.rgb = lerp(decal.albedo.rgb, decal.albedo.rgb * decalColor.rgb, decalColor.a); break; // multiply
            default: decal.albedo.rgb = lerp(decal.albedo.rgb, decalColor.rgb, decalColor.a); break; // (2) alpha blend
        }
    }

    void ApplyDecal_Triplanar(inout SuperCuteSticker decal, float3 worldPos, float3 normal, Texture2D decalTex, SamplerState decalSampler)
    {
        float4 decalColor = SampleTextureTriplanar(decalTex, decalSampler, worldPos, normal, decal.position, decal.scale.x, decal.rotation, decal.sharpness, decal.repeat > 0.5, (decal.scroll == 1));
        decalColor *= decal.tint;
        if (decal.hueShift != 0) 
        {
            decalColor.rgb = ApplyHueShift(decalColor.rgb, decal.hueShift + decal.alHue, decal.autoCycle, decal.cycleSpeed);
        }
        decalColor.a *= decal.alOpacity;
        decalColor.rgb *= decal.alEmission;
        switch(decal.blendMode)
        {
            case 0: decal.albedo.rgb += decalColor.rgb * decalColor.a; break; // additive
            case 1: decal.albedo.rgb = lerp(decal.albedo.rgb, decal.albedo.rgb * decalColor.rgb, decalColor.a); break; // multiply
            default: decal.albedo.rgb = lerp(decal.albedo.rgb, decalColor.rgb, decalColor.a); break; // (2) alpha blend
        }
    }

    // decal one application
    void ApplyDecal1(inout BacklaceSurfaceData Surface, FragmentData i, float2 Uvs[4])
    {
        // create the decal object
        SuperCuteSticker decal1;
        decal1.albedo = (_DecalStage == 0) ? Surface.Albedo : float4(Surface.FinalColor.rgb, 1.0);
        decal1.tint = _Decal1Tint;
        decal1.blendMode = _Decal1BlendMode;
        decal1.behavior = _Decal1Behavior;
        decal1.repeat = _Decal1Repeat;
        decal1.scroll = _Decal1Scroll;
        decal1.hueShift = _Decal1HueShift;
        decal1.autoCycle = _Decal1AutoCycleHue;
        decal1.cycleSpeed = _Decal1CycleSpeed;
        decal1.alHue = 0;
        decal1.alEmission = 1;
        decal1.alOpacity = 1;
        #if defined(_BACKLACE_AUDIOLINK)
            decal1.alHue = i.alChannel2.w;
            decal1.alEmission = i.alChannel3.x;
            decal1.alOpacity = i.alChannel3.y;
        #endif // _BACKLACE_AUDIOLINK
        // assign position, scale, rotation, and sharpness based on space
        [branch] if (_Decal1Space == 1) // Triplanar
        {
            decal1.position = _Decal1TriplanarPosition.xyz;
            decal1.scale = float3(_Decal1TriplanarScale, _Decal1TriplanarScale, _Decal1TriplanarScale);
            decal1.rotation = _Decal1TriplanarRotation.xyz;
            decal1.sharpness = _Decal1TriplanarSharpness;
            ApplyDecal_Triplanar(decal1, i.worldPos, Surface.NormalDir, _Decal1Tex, sampler_Decal1Tex);
        }
        else // UV Space
        {
            decal1.position = float3(_Decal1Position.xy, 0);
            decal1.scale = float3(_Decal1Scale.xy, 1);
            decal1.rotation = float3(_Decal1Rotation, 0, 0);
            decal1.sharpness = 0;
            float2 decal1Uv = (_Decal1Space == 0) ? Uvs[_Decal1_UV] : i.scrPos.xy / i.scrPos.w;
            ApplyDecal_UVSpace(decal1, decal1Uv, _Decal1Tex, sampler_Decal1Tex, _Decal1_UV);
        }
        [branch] if (_DecalStage == 0) // early
        {
            Surface.Albedo = decal1.albedo;
        }
        else // late
        {
            Surface.FinalColor.rgb = decal1.albedo.rgb;
        }
    }

    // decal two application
    void ApplyDecal2(inout BacklaceSurfaceData Surface, FragmentData i, float2 Uvs[4])
    {
        SuperCuteSticker decal2;
        decal2.albedo = (_DecalStage == 0) ? Surface.Albedo : float4(Surface.FinalColor.rgb, 1.0);
        decal2.tint = _Decal2Tint;
        decal2.blendMode = _Decal2BlendMode;
        decal2.behavior = _Decal2Behavior;
        decal2.repeat = _Decal2Repeat;
        decal2.scroll = _Decal2Scroll;
        decal2.hueShift = _Decal2HueShift;
        decal2.autoCycle = _Decal2AutoCycleHue;
        decal2.cycleSpeed = _Decal2CycleSpeed;
        decal2.alHue = 0;
        decal2.alEmission = 1;
        decal2.alOpacity = 1;
        #if defined(_BACKLACE_AUDIOLINK)
            decal2.alHue = i.alChannel2.w;
            decal2.alEmission = i.alChannel3.x;
            decal2.alOpacity = i.alChannel3.y;
        #endif // _BACKLACE_AUDIOLINK
        // assign position, scale, rotation, and sharpness based on space
        [branch] if (_Decal2Space == 1) // Triplanar
        {
            decal2.position = _Decal2TriplanarPosition.xyz;
            decal2.scale = float3(_Decal2TriplanarScale, _Decal2TriplanarScale, _Decal2TriplanarScale);
            decal2.rotation = _Decal2TriplanarRotation.xyz;
            decal2.sharpness = _Decal2TriplanarSharpness;
            ApplyDecal_Triplanar(decal2, i.worldPos, Surface.NormalDir, _Decal2Tex, sampler_Decal1Tex);
        }
        else // UV Space
        {
            decal2.position = float3(_Decal2Position.xy, 0);
            decal2.scale = float3(_Decal2Scale.xy, 1);
            decal2.rotation = float3(_Decal2Rotation, 0, 0);
            decal2.sharpness = 0;
            float2 decal2Uv = (_Decal2Space == 0) ? Uvs[_Decal2_UV] : i.scrPos.xy / i.scrPos.w;
            ApplyDecal_UVSpace(decal2, decal2Uv, _Decal2Tex, sampler_Decal1Tex, _Decal2_UV);
        }
        [branch] if (_DecalStage == 0) // early
        {
            Surface.Albedo = decal2.albedo;
        }
        else // late
        {
            Surface.FinalColor.rgb = decal2.albedo.rgb;
        }
    }
#endif // _BACKLACE_DECALS

// uv effects-only features
#if defined(_BACKLACE_UV_EFFECTS)
    void ApplyUVEffects(inout float2 uv, in BacklaceSurfaceData Surface)
    {
        // triplanar uv mapping
        [branch] if (_UVTriplanarMapping == 1) 
        {
            float2 uvX, uvY, uvZ;
            float3 weights;
            GetTriplanarUVsAndWeights(
                FragData.worldPos, Surface.NormalDir,
                _UVTriplanarPosition, _UVTriplanarScale, _UVTriplanarRotation, _UVTriplanarSharpness,
                uvX, uvY, uvZ, weights
            );
            uv = uvX * weights.x + uvY * weights.y + uvZ * weights.z;
        }
        // screen space uv
        if (_UVScreenspaceMapping == 1) 
        {
            uv = frac(Surface.ScreenCoords * _UVScreenspaceTiling);
        }
        // flipbook
        if (_UVFlipbook == 1) {
            uv = ApplyFlipbook(uv, _UVFlipbookColumns, _UVFlipbookRows, _UVFlipbookFrames, _UVFlipbookFPS, _UVFlipbookScrub);
        }
        // flow map
        [branch] if (_UVFlowmap == 1) {
            float2 flow = UNITY_SAMPLE_TEX2D_SAMPLER(_UVFlowmapTex, _MainTex, uv).rg * 2.0 - 1.0;
            uv += flow * _UVFlowmapStrength * frac(_Time.y * _UVFlowmapSpeed);
        }
    }
#endif // _BACKLACE_UV_EFFECTS

// dissolve-only features
#if defined(_BACKLACE_DISSOLVE)
    float _DissolveProgress;
    UNITY_DECLARE_TEX2D(_DissolveNoiseTex);
    float _DissolveNoiseScale;
    float4 _DissolveEdgeColor;
    int _DissolveType;
    float _DissolveEdgeWidth;
    float4 _DissolveDirection;
    int _DissolveDirectionSpace;
    float _DissolveDirectionBounds;
    float _DissolveVoxelDensity;
    float _DissolveEdgeSharpness;
    float _DissolveEdgeMode;
    
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
                dissolveMapValue = Hash12(voxelID.xy + voxelID.z);
                break;
            }
        }
        return dissolveMapValue;
    }
#endif // _BACKLACE_DISSOLVE

// here is where we leave out shadow pass
// meta needs SOME features from specular, so we share here instead of shading or lighting
#if defined(UNITY_PASS_FORWARDBASE) || defined(UNITY_PASS_FORWARDADD) || defined(UNITY_PASS_META)

    // sample MSSO texture
    void SampleMSSO(inout BacklaceSurfaceData Surface)
    {
        Msso = UNITY_SAMPLE_TEX2D_SAMPLER(_MSSO, _MainTex, BACKLACE_TRANSFORM_TEX(Uvs, _MSSO));
        Surface.Occlusion = lerp(1, Msso.a, _Occlusion);
    }

    // specular feature
    #if defined(BACKLACE_SPECULAR)
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
            float sp = Surface.Specular;
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
    #endif // defined(BACKLACE_SPECULAR)

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