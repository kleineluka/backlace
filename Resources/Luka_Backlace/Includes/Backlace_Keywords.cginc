#ifndef BACKLACE_KEYWORDS_CGINC
#define BACKLACE_KEYWORDS_CGINC

// BRANCHING KEYWORDS
#pragma multi_compile _SPECULARMODE_STANDARD _SPECULARMODE_ANISOTROPIC _SPECULARMODE_TOON

// CORE FEATURES
#pragma shader_feature_local _ _BACKLACE_TOON
#pragma shader_feature_local _ _BACKLACE_EMISSION
#pragma shader_feature_local _ _BACKLACE_SPECULAR
#pragma shader_feature_local _ _BACKLACE_VERTEX_SPECULAR
#pragma shader_feature_local _ _BACKLACE_RIMLIGHT
#pragma shader_feature_local _ _BACKLACE_CLEARCOAT
#pragma shader_feature_local _ _BACKLACE_MATCAP
#pragma shader_feature_local _ _BACKLACE_CUBEMAP
#pragma shader_feature_local _ _BACKLACE_PARALLAX
#pragma shader_feature_local _ _BACKLACE_PARALLAX_SHADOWS
#pragma shader_feature_local _ _BACKLACE_SSS
#pragma shader_feature_local _ _BACKLACE_DETAIL
#pragma shader_feature_local _ _BACKLACE_DECAL1
//#pragma shader_feature_local _ _BACKLACE_DECAL1_TRIPLANAR
#pragma shader_feature_local _ _BACKLACE_DECAL2
//#pragma shader_feature_local _ _BACKLACE_DECAL2_TRIPLANAR

// FUN KEYWORDS
#pragma shader_feature_local _ _BACKLACE_GLITTER

#endif // BACKLACE_KEYWORDS_CGINC