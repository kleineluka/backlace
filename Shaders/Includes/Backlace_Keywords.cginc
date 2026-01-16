#ifndef BACKLACE_KEYWORDS_CGINC
#define BACKLACE_KEYWORDS_CGINC

// LEGACY MODE: Uncomment the line below to enable shader model 3.0 for older hardware
// NOTE: Legacy mode automatically disables AudioLink and LTCGI to reduce interpolator usage
// #define BACKLACE_LEGACY_MODE

// BRANCHING KEYWORDS
#pragma shader_feature_local _BLENDMODE_CUTOUT _BLENDMODE_FADE _BLENDMODE_TRANSPARENT _BLENDMODE_PREMULTIPLY
#pragma shader_feature_local _SPECULARMODE_STANDARD _SPECULARMODE_ANISOTROPIC _SPECULARMODE_TOON _SPECULARMODE_HAIR _SPECULARMODE_CLOTH
#pragma shader_feature_local _ _ANIMEMODE_RAMP _ANIMEMODE_HALFTONE _ANIMEMODE_HIFI _ANIMEMODE_SKIN _ANIMEMODE_WRAPPED

// TOGGLE KEYWORDS
#pragma shader_feature_local _ _BACKLACE_EMISSION
#pragma shader_feature_local _ _BACKLACE_SPECULAR
#pragma shader_feature_local _ _BACKLACE_VERTEX_SPECULAR
#pragma shader_feature_local _ _BACKLACE_RIMLIGHT
#pragma shader_feature_local _ _BACKLACE_CLEARCOAT
#pragma shader_feature_local _ _BACKLACE_MATCAP
#pragma shader_feature_local _ _BACKLACE_DECALS
#pragma shader_feature_local _ _BACKLACE_POST_PROCESSING
#pragma shader_feature_local _ _BACKLACE_UV_EFFECTS
#pragma shader_feature_local _ _BACKLACE_CUBEMAP
#pragma shader_feature_local _ _BACKLACE_PARALLAX
#pragma shader_feature_local _ _BACKLACE_SSS
#pragma shader_feature_local _ _BACKLACE_DETAIL
#pragma shader_feature_local _ _BACKLACE_DISSOLVE
#pragma shader_feature_local _ _BACKLACE_PATHING
#pragma shader_feature_local _ _BACKLACE_DEPTH_RIMLIGHT
#pragma shader_feature_local _ _BACKLACE_SHADOW_MAP
#pragma shader_feature_local _ _BACKLACE_GLITTER
#pragma shader_feature_local _ _BACKLACE_DISTANCE_FADE
#pragma shader_feature_local _ _BACKLACE_IRIDESCENCE
#pragma shader_feature_local _ _BACKLACE_SHADOW_TEXTURE
#pragma shader_feature_local _ _BACKLACE_FLAT_MODEL
#pragma shader_feature_local _ _BACKLACE_WORLD_EFFECT
#pragma shader_feature_local _ _BACKLACE_VRCHAT_MIRROR
#pragma shader_feature_local _ _BACKLACE_TOUCH_REACTIVE
#pragma shader_feature_local _ _BACKLACE_VERTEX_DISTORTION
#pragma shader_feature_local _ _BACKLACE_DITHER
#pragma shader_feature_local _ _BACKLACE_PS1

// NON-LEGACY ONLY KEYWORDS
#if !defined(BACKLACE_LEGACY_MODE)
    #pragma shader_feature_local _ _BACKLACE_AUDIOLINK
    #pragma shader_feature_local _ _BACKLACE_LTCGI
#endif // BACKLACE_LEGACY_MODE

// GRABPASS KEYWORDS
#if defined(BACKLACE_GRABPASS)
    #pragma shader_feature_local _ _BACKLACE_REFRACTION
    #pragma shader_feature_local _ _BACKLACE_SSR
#endif // BACKLACE_GRABPASS

// GENERATED DEFINES
#if defined(_ANIMEMODE_RAMP) || defined(_ANIMEMODE_HALFTONE) || defined(_ANIMEMODE_HIFI) || defined(_ANIMEMODE_SKIN) || defined(_ANIMEMODE_WRAPPED)
    #define BACKLACE_TOON
#endif // _ANIMEMODE_RAMP || _ANIMEMODE_HALFTONE || _ANIMEMODE_HIFI || _ANIMEMODE_SKIN || _ANIMEMODE_WRAPPED

#endif // BACKLACE_KEYWORDS_CGINC