#ifndef BACKLACE_KEYWORDS_CGINC
#define BACKLACE_KEYWORDS_CGINC

// BRANCHING KEYWORDS
#pragma multi_compile _BLENDMODE_CUTOUT _BLENDMODE_FADE _BLENDMODE_TRANSPARENT _BLENDMODE_PREMULTIPLY
#pragma multi_compile _SPECULARMODE_STANDARD _SPECULARMODE_ANISOTROPIC _SPECULARMODE_TOON _SPECULARMODE_HAIR _SPECULARMODE_CLOTH
#pragma multi_compile _ANIMEMODE_RAMP _ANIMEMODE_PROCEDURAL

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
#pragma shader_feature_local _ _BACKLACE_SSS
#pragma shader_feature_local _ _BACKLACE_DETAIL
#pragma shader_feature_local _ _BACKLACE_DISSOLVE
#pragma shader_feature_local _ _BACKLACE_PATHING
#pragma shader_feature_local _ _BACKLACE_DEPTH_RIMLIGHT
#pragma shader_feature_local _ _BACKLACE_SHADOW_MAP
#pragma shader_feature_local _ _BACKLACE_AUDIOLINK
#pragma shader_feature_local _ _BACKLACE_LTCGI

// FUN KEYWORDS
#pragma shader_feature_local _ _BACKLACE_GLITTER
#pragma shader_feature_local _ _BACKLACE_DISTANCE_FADE
#pragma shader_feature_local _ _BACKLACE_IRIDESCENCE
#pragma shader_feature_local _ _BACKLACE_SHADOW_TEXTURE
#pragma shader_feature_local _ _BACKLACE_FLAT_MODEL
#pragma shader_feature_local _ _BACKLACE_WORLD_EFFECT
#pragma shader_feature_local _ _BACKLACE_VRCHAT_MIRROR
#pragma shader_feature_local _ _BACKLACE_TOUCH_REACTIVE
#pragma shader_feature_local _ _BACKLACE_REFRACTION
#pragma shader_feature_local _ _BACKLACE_VERTEX_DISTORTION
#pragma shader_feature_local _ _BACKLACE_SSR
#pragma shader_feature_local _ _BACKLACE_DITHER
#pragma shader_feature_local _ _BACKLACE_PS1
#pragma shader_feature_local _ _BACKLACE_STITCH

#endif // BACKLACE_KEYWORDS_CGINC