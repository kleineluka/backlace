#ifndef BACKLACE_KEYWORDS_CGINC
#define BACKLACE_KEYWORDS_CGINC


// [ ♡ ] ────────────────────── [ ♡ ]
//
//           Legacy Mode
//
// [ ♡ ] ────────────────────── [ ♡ ]


#include "./Backlace_Legacy.cginc" // toggle inside here!


// [ ♡ ] ────────────────────── [ ♡ ]
//
//        Branching Keywords
//
// [ ♡ ] ────────────────────── [ ♡ ]


#pragma shader_feature_local _BLENDMODE_CUTOUT _BLENDMODE_FADE _BLENDMODE_TRANSPARENT _BLENDMODE_PREMULTIPLY
#pragma shader_feature_local _ _ANIMEMODE_RAMP _ANIMEMODE_CEL _ANIMEMODE_NPR _ANIMEMODE_PACKED _ANIMEMODE_TRIBAND _ANIMEMODE_SKIN _ANIMEMODE_WRAPPED


// [ ♡ ] ────────────────────── [ ♡ ]
//
//         Small & Up Keywords
//
// [ ♡ ] ────────────────────── [ ♡ ]


#if defined(BACKLACE_CAPABILITIES_LOW)
    #pragma shader_feature_local _ _BACKLACE_ANIME_EXTRAS
    #pragma shader_feature_local _ _BACKLACE_UV_EFFECTS
    #pragma shader_feature_local _ _BACKLACE_DECALS
    #pragma shader_feature_local _ _BACKLACE_POST_PROCESSING
    #pragma shader_feature_local _ _BACKLACE_EMISSION
    #pragma shader_feature_local _ _BACKLACE_SPECULAR
    // #pragma shader_feature_local _ _BACKLACE_VERTEX_SPECULAR <-- removed
#endif // BACKLACE_CAPABILITIES_LOW


// [ ♡ ] ────────────────────── [ ♡ ]
//
//        Default & Up Keywords
//
// [ ♡ ] ────────────────────── [ ♡ ]


#if defined(BACKLACE_CAPABILITIES_MEDIUM)
    // #pragma shader_feature_local _ _BACKLACE_RIMLIGHT <- merged
    // #pragma shader_feature_local _ _BACKLACE_DEPTH_RIMLIGHT <- merged
    #pragma shader_feature_local _ _RIMMODE_FRESNEL _RIMMODE_DEPTH _RIMMODE_NORMAL
    #pragma shader_feature_local _ _BACKLACE_MATCAP
    #pragma shader_feature_local _ _BACKLACE_CUBEMAP
    #pragma shader_feature_local _ _BACKLACE_CLEARCOAT
    #pragma shader_feature_local _ _BACKLACE_SSS
    #pragma shader_feature_local _ _BACKLACE_DETAIL
    #pragma shader_feature_local _ _BACKLACE_SHADOW_MAP
#endif // BACKLACE_CAPABILITIES_MEDIUM


// [ ♡ ] ────────────────────── [ ♡ ]
//
//         Full Keywords
//
// [ ♡ ] ────────────────────── [ ♡ ]


#if defined(BACKLACE_CAPABILITIES_HIGH)
    #pragma shader_feature_local _ _BACKLACE_DISSOLVE
    #pragma shader_feature_local _ _BACKLACE_PARALLAX
    #pragma shader_feature_local _ _BACKLACE_PATHING
    #pragma shader_feature_local _ _BACKLACE_GLITTER
    #pragma shader_feature_local _ _BACKLACE_DISTANCE_FADE
    #pragma shader_feature_local _ _BACKLACE_IRIDESCENCE
    #pragma shader_feature_local _ _BACKLACE_WORLD_EFFECT
    #pragma shader_feature_local _ _BACKLACE_VRCHAT_MIRROR
    #pragma shader_feature_local _ _BACKLACE_TOUCH_REACTIVE
    #pragma shader_feature_local _ _BACKLACE_VERTEX_DISTORTION
    #pragma shader_feature_local _ _BACKLACE_SHADOW_TEXTURE
    #pragma shader_feature_local _ _BACKLACE_LIQUID_LAYER
    // #pragma shader_feature_local _ _BACKLACE_DITHER <-- no longer keyword, but still HIGH only
    // #pragma shader_feature_local _ _BACKLACE_PS1 <-- no longer keyword, but still HIGH only
    // #pragma shader_feature_local _ _BACKLACE_FLAT_MODEL <-- no longer keyword, but still HIGH only
#endif // BACKLACE_CAPABILITIES_HIGH


// [ ♡ ] ────────────────────── [ ♡ ]
//
//          Feature Keywords
//
// [ ♡ ] ────────────────────── [ ♡ ]


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

// WORLD KEYWORDS
#if defined(BACKLACE_WORLD)
    #pragma shader_feature_local _ _BACKLACE_STOCHASTIC
    #pragma shader_feature_local _ _BACKLACE_SPLATTER
    #pragma shader_feature_local _ _BACKLACE_BOMBING
#endif // BACKLACE_WORLD

// GENERATED DEFINES
#if defined(_ANIMEMODE_RAMP) || defined(_ANIMEMODE_CEL) || defined(_ANIMEMODE_NPR) || defined(_ANIMEMODE_PACKED) || defined(_ANIMEMODE_TRIBAND) || defined(_ANIMEMODE_SKIN) || defined(_ANIMEMODE_WRAPPED)
    #define BACKLACE_TOON
#endif // _ANIMEMODE_*

#if defined(_RIMMODE_FRESNEL) || defined(_RIMMODE_DEPTH) || defined(_RIMMODE_NORMAL)
    #define BACKLACE_RIMLIGHT
#endif // _RIMMODE_*


#endif // BACKLACE_KEYWORDS_CGINC