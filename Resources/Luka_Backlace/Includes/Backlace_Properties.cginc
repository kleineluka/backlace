#ifndef BACKLACE_PROPERTIES_CGINC
#define BACKLACE_PROPERTIES_CGINC

FragmentData FragData;
float4 FinalColor;
float LightAttenuation;
float _DirectLightMode;
float UnmaxedNdotL;
float NdotL;
float NdotV;
float NdotH;
float LdotH;
float _MainTex_UV;
float _Occlusion;
float Occlusion;
float _MSSO_UV;
float _Cutoff;
float _BumpScale;
float _BumpMap_UV;
float Roughness;
float Attenuation;
float RampAttenuation;
float _RampOffset;
float _ShadowIntensity;
float _OcclusionOffsetIntensity;
float _Metallic;
float Metallic;
float _Glossiness;
float Glossiness;
float _Specular;
float Specular;
float SquareRoughness;
float _ReplaceSpecular;
float OneMinusReflectivity;
float _SpecularTintTexture_UV;
float GFS;
float _DFGType;
float _Anisotropy;
float _TangentMap_UV;
float _IndirectFallbackMode;
float _IndirectOverride;
float RoughnessSquared;
float _EnableSpecular;
float _SpecularMode;
float _GreyscaleLighting;
float _ForceLightColor;
float4 _ForcedLightColor;
float3 NormalMap;
float3 NormalDir;
float3 LightDir;
float3 ViewDir;
float3 TangentDir;
float3 BitangentDir;
float3 HalfDir;
float3 ReflectDir;
float3 Lightmap;
float3 DynamicLightmap;
float3 IndirectDiffuse;
float3 Diffuse;
float3 VertexDirectDiffuse;
float3 _RampMin;
float3 SpecularColor;
float3 DirectSpecular;
float3 NDF;
float3 EnergyCompensation;
float3 Dfg;
float3 IndirectSpecular;
float3 CustomIndirect;
float4 LightmapDirection;
float4 DynamicLightmapDirection;
float4 SpecLightColor;
float4 LightColor;
float4 Albedo;
float4 _MainTex_ST;
float4 _Color;
float4 _MSSO_ST;
float4 Msso;
float4 _BumpMap_ST;
float4 _RampColor;
float4 _SpecularTintTexture_ST;
float4 _SpecularTint;
float4 _TangentMap_ST;
samplerCUBE _FallbackCubemap;
UNITY_DECLARE_TEX2D(_MainTex);
UNITY_DECLARE_TEX2D(_Ramp);
UNITY_DECLARE_TEX2D_NOSAMPLER(_MSSO);
UNITY_DECLARE_TEX2D_NOSAMPLER(_BumpMap);
UNITY_DECLARE_TEX2D_NOSAMPLER(_SpecularTintTexture);
UNITY_DECLARE_TEX2D_NOSAMPLER(_TangentMap);
Texture2D_float _DFG;
SamplerState sampler_DFG;

#if defined(_ALPHAMODULATE_ON)
    sampler3D _DitherMaskLOD;
#endif // _ALPHAMODULATE_ON

#if defined(UNITY_PASS_FORWARDBASE)
    float _EnableBaseLightLimit;
    float _BaseLightMin;
    float _BaseLightMax;
#endif // UNITY_PASS_FORWARDBASE

#if defined(UNITY_PASS_FORWARDADD)
    float _EnableAddLightLimit;
    float _AddLightMin;
    float _AddLightMax;
#endif // UNITY_PASS_FORWARDADD

#endif // BACKLACE_PROPERTIES_CGINC

