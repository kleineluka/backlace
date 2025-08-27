#ifndef BACKLACE_KEYWORDS_CGINC
#define BACKLACE_KEYWORDS_CGINC

// BRANCHING KEYWORDS
#pragma multi_compile _SPECULARMODE_STANDARD _SPECULARMODE_ANISOTROPIC _SPECULARMODE_TOON _SPECULARMODE_HAIR _SPECULARMODE_CLOTH
// should light model be here too, same with light direction?
#pragma multi_compile _TOONMODE_RAMP _TOONMODE_ANIME

// CORE FEATURES
#pragma shader_feature_local _ _BACKLACE_TOON
#pragma shader_feature_local _ _BACKLACE_EMISSION
#pragma shader_feature_local _ _BACKLACE_SPECULAR
#pragma shader_feature_local _ _BACKLACE_VERTEX_SPECULAR
#pragma shader_feature_local _ _BACKLACE_RIMLIGHT
#pragma shader_feature_local _ _BACKLACE_CLEARCOAT
#pragma shader_feature_local _ _BACKLACE_MATCAP
#pragma shader_feature_local _ _BACKLACE_DECAL1
#pragma shader_feature_local _ _BACKLACE_DECAL2
#pragma shader_feature_local _ _BACKLACE_POST_PROCESSING
#pragma shader_feature_local _ _BACKLACE_UV_EFFECTS

// ADVANCED KEYWORDS
#pragma shader_feature_local _ _BACKLACE_CUBEMAP
#pragma shader_feature_local _ _BACKLACE_PARALLAX
#pragma shader_feature_local _ _BACKLACE_PARALLAX_SHADOWS
#pragma shader_feature_local _ _BACKLACE_SSS
#pragma shader_feature_local _ _BACKLACE_DETAIL


// FUN KEYWORDS
#pragma shader_feature_local _ _BACKLACE_GLITTER
#pragma shader_feature_local _ _BACKLACE_DISTANCE_FADE
#pragma shader_feature_local _ _BACKLACE_IRIDESCENCE
#pragma shader_feature_local _ _BACKLACE_SHADOW_TEXTURE
#pragma shader_feature_local _ _BACKLACE_FLAT_MODEL

// GEOMETRY KEYWORDS
#pragma shader_feature_local _ _BACKLACE_GEOMETRY_EFFECTS

#endif // BACKLACE_KEYWORDS_CGINC