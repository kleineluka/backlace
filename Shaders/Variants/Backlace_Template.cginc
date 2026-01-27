// this is not used in any variant, just a template for all potential defines
#ifndef BACKLACE_VARIANT_TEMPLATE
#define BACKLACE_VARIANT_TEMPLATE


// [ ♡ ] ────────────────────── [ ♡ ]
//
//           Quality Modes
//
// [ ♡ ] ────────────────────── [ ♡ ]


#ifndef BACKLACE_SMALL
    #define BACKLACE_SMALL
#endif // BACKLACE_SMALL

#ifndef BACKLACE_DEFAULT
    #define BACKLACE_DEFAULT
#endif // BACKLACE_DEFAULT

#ifndef BACKLACE_FULL
    #define BACKLACE_FULL
#endif // BACKLACE_FULL


// [ ♡ ] ────────────────────── [ ♡ ]
//
//           Capabilities
//
// [ ♡ ] ────────────────────── [ ♡ ]


#ifndef BACKLACE_CAPABILITIES_LOW // <-- roughly corresponds to BACKLACE_SMALL
    #define BACKLACE_CAPABILITIES_LOW
#endif // BACKLACE_CAPABILITIES_LOW

#ifndef BACKLACE_CAPABILITIES_MEDIUM // <-- roughly corresponds to BACKLACE_DEFAULT
    #define BACKLACE_CAPABILITIES_MEDIUM
#endif // BACKLACE_CAPABILITIES_MEDIUM

#ifndef BACKLACE_CAPABILITIES_HIGH // <-- roughly corresponds to BACKLACE_FULL
    #define BACKLACE_CAPABILITIES_HIGH
#endif // BACKLACE_CAPABILITIES_HIGH


// [ ♡ ] ────────────────────── [ ♡ ]
//
//           Feature Sets
//
// [ ♡ ] ────────────────────── [ ♡ ]


#ifndef BACKLACE_GRABPASS
    #define BACKLACE_GRABPASS
#endif // BACKLACE_GRABPASS

#ifndef BACKLACE_WORLD
    #define BACKLACE_WORLD
#endif // BACKLACE_WORLD

#ifndef BACKLACE_OUTLINE
    #define BACKLACE_OUTLINE
#endif // BACKLACE_OUTLINE


#endif // BACKLACE_VARIANT_TEMPLATE